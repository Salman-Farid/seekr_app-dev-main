import Foundation
import AVFoundation
import Speech

class VoiceChatbotManager: NSObject, AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate {
    static let shared = VoiceChatbotManager()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var sessionID: String?
    private var imageBase64: String?
    private var wordBuffer: [String] = []
    private var isSpeaking = false
    private var isCapturing = false
    private var capturedText = ""
    
    let audioPlayerManager = AudioPlayerManager()
    
    private override init() {
        super.init()
        speechRecognizer?.delegate = self
        speechSynthesizer.delegate = self
        requestSpeechAuthorization()
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Speech recognition authorized")
            default:
                print("Speech recognition not authorized")
            }
        }
    }
    
    func startPersistentListening() {
        guard !audioEngine.isRunning else { return }
        print("Start persistent listening...")
        stopListening()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let recognizedText = result.bestTranscription.formattedString.lowercased()
                print("User said: \(recognizedText)")
                
                if self.isCapturing {
                    self.capturedText += recognizedText + " "
                }
            }

            if error != nil {
                print("Recognition error: \(error!.localizedDescription)")
                self.stopListening()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options:[ .mixWithOthers, .defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            audioEngine.prepare()
            try audioEngine.start()
            print("Microphone is listening...")
        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
        }
    }
    
    func stopListening() {
        guard audioEngine.isRunning else { return }
        print("Stopping audio engine...")
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session deactivation error: \(error.localizedDescription)")
        }
    }

    // MARK: - Capturing Control

    func startCapturingText() {
        self.audioPlayerManager.stopProcessingAudio()
        print("Capturing text started...")
        isCapturing = true
        capturedText = ""
    }

    func stopCapturingText() {
        print("Capturing text stopped.")
        isCapturing = false

        let finalText = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
        capturedText = ""
        
        if !finalText.isEmpty {
            sendChatRequest(text: finalText)
        }
    }

    // MARK: - Image Request

    func setImageBase64(_ base64String: String) {
        self.imageBase64 = base64String
        self.sessionID = nil
        sendChatRequest(text: "Give a short description of this image.")
    }

    // MARK: - Chat Request

    private func sendChatRequest(text: String) {
        print("Sending chat request...")
        
        guard let url = URL(string: "https://chatbot.com.ngrok.app/chat/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var payload: [String: Any] = ["text": text]

        if let imageBase64 = imageBase64, !imageBase64.isEmpty {
            payload["image_base64"] = imageBase64
        }

        if let sessionID = sessionID, !sessionID.isEmpty {
            payload["session_id"] = sessionID
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }

        print("Payload: \(payload)")
        self.audioPlayerManager.playProcessingAudio()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                self.audioPlayerManager.stopProcessingAudio()

                return
            }

            guard let data = data else {
                print("No response data.")
                self.audioPlayerManager.stopProcessingAudio()

                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Response JSON: \(json)")
                    if let streamID = json["stream_id"] as? String {
                        self.sessionID = json["session_id"] as? String
                        self.listenToStream(streamId: streamID)
                    }
                }
            } catch {
                print("JSON parse error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    // MARK: - SSE Response

    func listenToStream(streamId: String) {
        guard let url = URL(string: "https://chatbot.com.ngrok.app/result_stream/\(streamId)") else { return }

        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        Task {
            do {
                let (stream, _) = try await URLSession.shared.bytes(from: url)
                self.audioPlayerManager.stopProcessingAudio()
                
                for try await line in stream.lines {
                    if line.hasPrefix("data: ") {
                        let jsonString = line.replacingOccurrences(of: "data: ", with: "")
                        if let jsonData = jsonString.data(using: .utf8),
                           let jsonResponse = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                           let tokens = jsonResponse["tokens"] as? String,
                           let tokenData = tokens.data(using: .utf8),
                           let tokenJson = try? JSONSerialization.jsonObject(with: tokenData) as? [String: Any],
                           let word = tokenJson["text"] as? String, !word.isEmpty {
                            
                            wordBuffer.append(word)
                            
                            if wordBuffer.count >= 5 {
                                let sentence = wordBuffer.joined(separator: " ")
                                print("Speaking: \(sentence)")
                                self.speak(sentence)
                                wordBuffer.removeAll()
                            }
                        }
                    }
                }

                if !wordBuffer.isEmpty {
                    let remainingText = wordBuffer.joined(separator: " ")
                    print("Speaking remaining: \(remainingText)")
                    self.speak(remainingText)
                    wordBuffer.removeAll()
                }

            } catch {
                self.audioPlayerManager.stopProcessingAudio()
                print("Stream read error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Speech Output

    private func speak(_ textToRead: String) {
        let utterance = AVSpeechUtterance(string: textToRead)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Finished speaking.")
        isSpeaking = false
    }
}


