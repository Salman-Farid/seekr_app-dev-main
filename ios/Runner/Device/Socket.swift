//
//  Socket.swift
//  Runner
//
//  Created by Ahnaf Rahat on 15/12/23.
//

import Foundation
import SWXMLHash
import UIKit

class Socket: NSObject, StreamDelegate {
    static let shared = Socket() // Singleton instance

    var inputStream: InputStream!
    var outputStream: OutputStream!
    var isConnected: Bool = false
    let processTypes: [ProcessType] = [.document, .bus, .walking, .museum, .supermarket, .scene, .distance, .reading]
    var selectedProcessType : ProcessType = .reading
    let audioPlayerManager = AudioPlayerManager.shared
    let socketAnnouncement = SocketAnnouncementUtility.shared
    let textDetector = TextDetector()
    let translator = TranslationManager.shared
    let staticTranslator = StaticTranslation.shared
    var responseToReply: String = ""
    var compressionQuality: CGFloat = 0.6
    var host: String = "192.168.1.254"
    var port: Int = 3333
    
    var socketChannel = FlutterMethodChannel()
   
    let busDetector = BusDetectionViewController.shared
    let textDetectorAuto = SeekrAutoTextView.shared
    let obstacleAuto = ObstacleAvoidanceController.shared

    var museumArray: [String] = []
    
    var isMuseumSelectionOn : Bool = false
    var isChatBotListeningOn : Bool = false
    var isDetailedScene : Bool = false
    
    var selectedMuseum = ""
    
    let chatBotManager = VoiceChatbotManager.shared

    private override init() {}
    
    func configureSocketChannel(with controller: FlutterViewController) {
        socketChannel = FlutterMethodChannel(name: "socket_channel/ios", binaryMessenger: controller.binaryMessenger)
        notifySocketStatus(event: "SocketNotConnected")
    }
    
    func connect() {
        guard !isConnected else {
             print("Socket is already connected.")
//                notifySocketStatus(event: "SocketAlreadyConnected")
             return
         }
        
        // Close any existing streams before creating new ones
        disconnect()
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        guard inputStream != nil && outputStream != nil else {
            print("Failed to create streams")
            return
        }
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
        isConnected = true
        
//        notifySocketStatus(event: "SocketConnected")

        
        let processType = AppUserDefault.getSelectedMode() ?? ""
        
        if processType == "text"{
            self.selectedProcessType = .reading
        }else if processType == "scene"{
            self.selectedProcessType = .scene
        }else if processType == "depth"{
            self.selectedProcessType = .distance
        }else if processType == "supermarket"{
            self.selectedProcessType = .supermarket
        }else if processType == "bus"{
            self.selectedProcessType = .bus
        }else if processType == "walking"{
            self.selectedProcessType = .walking
        }else if processType == "chat"{
            self.selectedProcessType = .chat
        }else if processType == "museum"{
            self.selectedProcessType = .museum
        }else if processType == "document"{
            self.selectedProcessType = .document
        }else{
            print("Else Mode Triggered")
            self.selectedProcessType = .reading

        }
        
        self.setSelectedMode()
        MuseumMode.shared.fetchMuseumList { museumList in
            if let museumList = museumList {
                self.museumArray = museumList
            }
        }
        
    }
    
    
    func setSelectedMode(){
        let processType = self.selectedProcessType
        if processType == .reading{
            Helper().switchDeviceToHigherMode()
            self.compressionQuality = 0.9
            AppUserDefault.setSelectedMode("text")
        }else if processType == .scene{
            Helper().switchDeviceToVgaMode()
            self.compressionQuality = 0.6
            AppUserDefault.setSelectedMode("scene")
        }else if processType == .distance{
            Helper().switchDeviceToVgaMode()
            self.compressionQuality = 0.6
            AppUserDefault.setSelectedMode("depth")
        }else if processType == .supermarket{
            Helper().switchDeviceToVgaMode()
            self.compressionQuality = 0.6
            AppUserDefault.setSelectedMode("supermarket")
        }else if processType == .bus{
            Helper().switchDeviceToHigherMode()
            self.compressionQuality = 0.9
            AppUserDefault.setSelectedMode("bus")
        }else if processType == .walking{
            Helper().switchDeviceToHigherMode()
            self.compressionQuality = 0.9
            AppUserDefault.setSelectedMode("walking")
        }else if processType == .museum{
            Helper().switchDeviceToVgaMode()
            self.compressionQuality = 0.6
            AppUserDefault.setSelectedMode("museum")
        }else if processType == .chat{
            Helper().switchDeviceToVgaMode()
            self.compressionQuality = 0.6
            AppUserDefault.setSelectedMode("chat")
        }else if processType == .document{
            Helper().switchDeviceToHigherMode()
            self.compressionQuality = 0.9
            AppUserDefault.setSelectedMode("document")
        }
        
        
        if processType != .bus{
            self.busDetector.stopStreaming()
        }
        
        
        if processType != .document{
            self.textDetectorAuto.stopStreaming()
        }
        
        if processType != .walking{
            self.obstacleAuto.stopStreaming()
        }
        
        if processType != .chat{
            self.chatBotManager.stopCapturingText()
        }
        
        if processType != .museum{
            isMuseumSelectionOn = false
            selectedMuseum = ""
        }
        
        print("selected__mode__string:\(AppUserDefault.getSelectedMode() ?? "")")
    }
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        let bgMode = AppUserDefault.getIsBackgroundMode() ?? false
        let isDeviceConnected : Bool = Helper().getDeviceData() ?? false
        
        switch eventCode {
        case .openCompleted:
            NSLog("Stream opened successfully 🚀🚀🚀")
            isConnected = true
            //            speak("Device Connected!")
//            notifySocketStatus(event: "StreamOpened")

        case .hasBytesAvailable:
//            if bgMode{
                handleIncomingData()
//            }else{
//                print("App is in Foreground Mode")
//            }
        case .errorOccurred:
            NSLog("Error occurred: \(aStream.streamError.debugDescription)")
            isConnected = false
            // Attempt to reconnect after a short delay
            if isDeviceConnected && bgMode{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    if !self.isConnected {
                        print("socket retried to connect after error occured 🚀🚀🚀🚀")
                        self.disconnect()
                        self.connect()
                    }
                }
            }


//            notifySocketStatus(event: "SocketError")
        case .endEncountered:
            NSLog("End encountered")
            isConnected = false
            // Attempt to reconnect after a short delay
            if isDeviceConnected && bgMode{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    if !self.isConnected {
                        print("socket retried to connect after end encounter 🚀🚀🚀🚀")
                        self.disconnect()
                        self.connect()
                    }
                }
            }

//            notifySocketStatus(event: "StreamEndEncountered")

        default:
            break
        }
    }
    
    // Custom method to handle incoming data
    func handleIncomingData() {
        guard let inputStream = inputStream else {
            return
        }
//        let processTypeIterator = ProcessTypeIterator(processTypes: self.processTypes)
        
        var buffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
        
        if bytesRead > 0 {
            let data = Data(bytes: buffer, count: bytesRead)
            let receivedString = String(data: data, encoding: .utf8)
            NSLog("Received data: \(receivedString ?? "")")
//            notifySocketStatus(event: "DataReceived:\(receivedString)")

            do {
                let deviceCommand = try DeviceActionObject.fromXML(data)
                let time = Date()
                print("converted____XMLdeviceCommand.status:\(deviceCommand.status) , converted____XMLdeviceCommand.cmd:\(deviceCommand.cmd)")
                if deviceCommand.status == 1003 {
                    if isMuseumSelectionOn && selectedProcessType == .museum{
                        self.selectedMuseum = MuseumIterator.shared.previousMuseum() ?? ""
                        self.socketAnnouncement.museumSwitchingAudio(museum: selectedMuseum)
                    }else{
                        self.selectedProcessType =  ProcessTypeIterator.shared.previousProcessType()
                        self.setSelectedMode()
                        self.audioPlayerManager.stopProcessingAudio()
                        SpeechManager.shared.stopSpeaking()
                        print("Switch to \(self.selectedProcessType) Mode")

                        if AppUserDefault.getSelectedLanguage() == "en_US"{
                            self.speak("\(self.selectedProcessType)")
                        }else if AppUserDefault.getSelectedLanguage() == "ja_JP"{
                            self.socketAnnouncement.speakJapaneseModes(processType: self.selectedProcessType)
                        }else if AppUserDefault.getSelectedLanguage() == "es_ES"{
                            self.socketAnnouncement.speakSpanishModes(processType: self.selectedProcessType)
                            
                        } else if AppUserDefault.getSelectedLanguage() == "ko_KR" {
                            self.socketAnnouncement.speakKoreanModes(processType: self.selectedProcessType)
                        } else if AppUserDefault.getSelectedLanguage() == "tl_PH" {
                            self.socketAnnouncement.speakTagalogModes(processType: self.selectedProcessType)
                        } else if AppUserDefault.getSelectedLanguage() == "ms_MY" {
                            self.socketAnnouncement.speakMalayModes(processType: self.selectedProcessType)
                        }else{
                            self.socketAnnouncement.speakChineseModes(processType: self.selectedProcessType)
                        }
                    }

                } else if deviceCommand.status == 1005 {
                    if isMuseumSelectionOn && selectedProcessType == .museum{
                        self.selectedMuseum = MuseumIterator.shared.nextMuseum() ?? ""
                        self.socketAnnouncement.museumSwitchingAudio(museum: selectedMuseum)
                }else{
                    self.selectedProcessType =  ProcessTypeIterator.shared.nextProcessType()
                    self.setSelectedMode()
                    self.audioPlayerManager.stopProcessingAudio()
                    SpeechManager.shared.stopSpeaking()
                    print("Switch to \(self.selectedProcessType) Mode")
                    
                    if AppUserDefault.getSelectedLanguage() == "en_US"{
                        self.speak("\(self.selectedProcessType)")
                    }else if AppUserDefault.getSelectedLanguage() == "ja_JP"{
                        self.socketAnnouncement.speakJapaneseModes(processType: self.selectedProcessType)
                    }else if AppUserDefault.getSelectedLanguage() == "es_ES"{
                        self.socketAnnouncement.speakSpanishModes(processType: self.selectedProcessType)
                        
                    } else if AppUserDefault.getSelectedLanguage() == "ko_KR" {
                        self.socketAnnouncement.speakKoreanModes(processType: self.selectedProcessType)
                    } else if AppUserDefault.getSelectedLanguage() == "tl_PH" {
                        self.socketAnnouncement.speakTagalogModes(processType: self.selectedProcessType)
                    } else if AppUserDefault.getSelectedLanguage() == "ms_MY" {
                        self.socketAnnouncement.speakMalayModes(processType: self.selectedProcessType)
                    }else{
                        self.socketAnnouncement.speakChineseModes(processType: self.selectedProcessType)
                    }
                    }
                } else if deviceCommand.cmd == 3020 && deviceCommand.status == 1001 {
                    print("capturePhoto Mode 3020")
                    print("time_capturePhoto_Start:\(Date())")
                    self.audioPlayerManager.stopProcessingAudio()
                    SpeechManager.shared.stopSpeaking()
                    let language = AppUserDefault.getSelectedLanguage() ?? ""

                    if selectedProcessType == .document {
                        self.textDetectorAuto.startStreaming()
                    }else if selectedProcessType == .bus {
                        self.busDetector.startStreaming()
                    }else if selectedProcessType == .walking {
                        self.obstacleAuto.startStreaming()
                    }else if selectedProcessType == .chat {
                        print("Chat Mode Triggered")
                        if AppUserDefault.getIsChatMode() ?? false{
                            self.getPhotFromDeviceChatMode()
                        }else{
                            self.speak("Open ChatMode First")
                        }
                    }else if selectedProcessType == .museum{
                        if isMuseumSelectionOn{
                            self.isMuseumSelectionOn = false
                            self.socketAnnouncement.museumSelectionAudio(museum: self.selectedMuseum ?? "")
                        }else{
                            if selectedMuseum != ""{
                                self.getPhotFromDevice()
                            }else{
                                if language == "en_US"{
                                    speak("No museum selected. Select a museum by long press the bottom button")
                                }else{
                                    self.staticTranslator.translateNow(textToTranslate: "No museum selected. Select a museum by long press the bottom button")
                                }
                            }
                        }
                    }else {
                        self.getPhotFromDevice()

                    }

                } else if deviceCommand.cmd == 3020 && deviceCommand.status == 1006 {
                    print("Longpress____ status 1006")
                    print("time :\(Date())")
                    
                    self.audioPlayerManager.stopProcessingAudio()
                    SpeechManager.shared.stopSpeaking()
                    
                    if selectedProcessType == .museum{
                        if !isMuseumSelectionOn{
                                self.isMuseumSelectionOn = true
                            self.socketAnnouncement.museumSelectionActivatedAudio()
                        }else{
                            isMuseumSelectionOn = false
                            self.socketAnnouncement.museumSelectionDeactivatedAudio()
                        }
                        
                    }else if selectedProcessType == .chat{
                        if isChatBotListeningOn{
                            self.isChatBotListeningOn = false
                            DispatchQueue.main.async {
//                                self.chatBotManager.triggerSend = true
                                self.chatBotManager.stopCapturingText()
                            }
                        }else{
                            self.isChatBotListeningOn = true
                            self.speak("Chat bot is listening. longpress again after finish talking")
                            DispatchQueue.main.async {
                                self.chatBotManager.startCapturingText()
                            }
                        }
                        
                    }else if selectedProcessType == .scene{
                        self.isDetailedScene = true
                        self.getPhotFromDevice()
                        
                    }else{
                        if self.responseToReply != ""{
                            self.speak(self.responseToReply)
                        }else{
                            self.speak("Nothing to reply!")
                        }
                    }
                    
                    
                } else {
                    
                }
            } catch {
                print("Device Listener Error")
            }
            
        }
    }
        
    
    func disconnect() {
        
        guard isConnected else {
            print("Socket is not connected.")
//            notifySocketStatus(event: "SocketNotConnected")
            return
        }
        
        inputStream.close()
        outputStream.close()
        inputStream.remove(from: .current, forMode: .common)
        outputStream.remove(from: .current, forMode: .common)
        inputStream.delegate = nil
        outputStream.delegate = nil
        
        isConnected = false
        
//        notifySocketStatus(event: "SocketDisconnected")

        
    }
    
    func notifySocketStatus(event: String) {
        socketChannel.invokeMethod("socketStatus", arguments: event)
    }
    

    
    func getPhotFromDevice(){
        Helper().getPhotoDataFromDevice { result in
            switch result {
            case .success(let imageData):
                // Handle the image data
                print("Image data: \(imageData)")
                
                if self.selectedProcessType != .scene{
                    Helper().deleteDataFromDevice { error in
                        print(error?.localizedDescription)
                    }
                }
                print("time_image_fetched_from_device:\(Date())")

                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)!
                    print("Image size: height\(image.size.height) , width\(image.size.width)")
                    self.audioPlayerManager.playProcessingAudio()
                    
                    if self.selectedProcessType == ProcessType.reading{
                        
                        self.textDetector.processText(imageData: imageData) { detectedTexts, error in
                            if let error = error {
                                self.audioPlayerManager.stopProcessingAudio()
                                
                                print("Error: \(error)")
                            } else if let detectedTexts = detectedTexts {
                                self.audioPlayerManager.stopProcessingAudio()
                                
                                print("Detected Texts: \(detectedTexts)")
                                if detectedTexts != "" {
                                    print("time_after_textDetection:\(Date())")
                                    if AppUserDefault.getSelectedLanguage() == "en_US"{
                                        self.speak(detectedTexts)
                                    }else{
                                        self.staticTranslator.translateNow(textToTranslate: detectedTexts)
                                    }
                                    
                                }else{
                                    
                                    if AppUserDefault.getSelectedLanguage() == "en_US"{
                                        self.speak("No text detected!")
                                    }else{
                                        self.staticTranslator.translateNow(textToTranslate: "No text detected!")
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }else{
                        let imageProcessUrl = ImageProcessor().getServerUrl(type: self.selectedProcessType)
                        print("imageProcessUrl____\(imageProcessUrl)")
                        print("time_before_upload:\(Date())")
                        
                        self.uploadImageNew(paramName: "file", fileName:"\(Date().timeIntervalSince1970).jpeg", image: image, urlString: imageProcessUrl)
                    }
                    
                    
                }
                
            case .failure(let error):
                print("Completion error: \(error)")
                self.audioPlayerManager.stopProcessingAudio()
            }
        }
        

    }
    
    func getPhotFromDeviceChatMode() {
        Helper().getPhotoDataFromDevice { result in
            switch result {
            case .success(let imageData):
                print("Image data fetched: \(imageData)")
                
                // Convert image to Base64
                let base64String = imageData.base64EncodedString()
                
                // Set the image in VoiceChatbotManager and start the chat
                DispatchQueue.main.async {
                    self.chatBotManager.setImageBase64(base64String)
                }
                
                // Delete image data from device after processing
                Helper().deleteDataFromDevice { error in
                    if let error = error {
                        print("Error deleting data: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Completion error: \(error)")
                self.audioPlayerManager.stopProcessingAudio()

            }
        }
    }
    



    
}


extension Socket{
    func getCurrentTimeZone() -> String {
        TimeZone.current.identifier
    }


    
    func uploadImageNew(paramName: String, fileName: String, image: UIImage , urlString:String) {
        let url = URL(string: urlString)
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let session = URLSession.shared
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(AppUserDefault.getSelectedLanguage() ?? "", forHTTPHeaderField: "Accept-Language")
        
        let currentTimeZone = getCurrentTimeZone()
        print("currentTimeZone___\(currentTimeZone)")
        
        if self.selectedProcessType == .scene{
            if isDetailedScene{
                urlRequest.setValue("Scene Detailed", forHTTPHeaderField: "mode")
                self.isDetailedScene = false
            }else{
                urlRequest.setValue("Scene Short", forHTTPHeaderField: "mode")
            }
        }

        urlRequest.setValue(currentTimeZone ?? "", forHTTPHeaderField: "timeZone")
//        urlRequest.setValue("test", forHTTPHeaderField: "geoLocation")
        let token = AppUserDefault.getAccessToken() ?? ""
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("Request Headers:")
        for (key, value) in urlRequest.allHTTPHeaderFields ?? [:] {
            print("\(key): \(value)")
        }
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        
        let imageDataCompressed = resizeImage(image: image, targetSize: CGSize(width: 720, height: 720)).jpegData(compressionQuality: self.compressionQuality) ?? Data()
        print("Image data Compressed: \(imageDataCompressed)")

        data.append(imageDataCompressed)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            self.audioPlayerManager.stopProcessingAudio()
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? String {
                    print("result______\(json)")
                    Helper().sendEventRequest(feature: self.selectedProcessType, details: "\(json)", title: "IMAGE-PROCESS-RESULT")
                    let textToSpeech = json
                    print("time_after_upload:\(Date())")
                    DispatchQueue.main.async {
                        if textToSpeech != ""{
                            if self.selectedProcessType == .distance{
                                self.speak(json)
                            }else{
                                if AppUserDefault.getSelectedLanguage() == "en_US"{
                                    self.speak(json)
                                }else{
                                    self.staticTranslator.translateNow(textToTranslate: json)
                                }
                            }
                        }else{
                            let emptyString = "Server busy, please try again later"
                            if AppUserDefault.getSelectedLanguage() == "en_US"{
                                self.speak(emptyString)
                            }else{
                                self.staticTranslator.translateNow(textToTranslate: emptyString)
                            }
                        }
                    }
                    
                }
            }else{
                Helper().sendEventRequest(feature: self.selectedProcessType, details: "Error details", title: "IMAGE-PROCESS-RESULT")
                
                let emptyString = "Server busy, please try again later"
                if AppUserDefault.getSelectedLanguage() == "en_US"{
                    self.speak(emptyString)
                }else{
                    self.staticTranslator.translateNow(textToTranslate: emptyString)
                }
            }
            
        }).resume()
    }
    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        self.responseToReply = textToRead
        SpeechManager.shared.speak(text: textToRead)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
         let size = image.size
         
         let widthRatio  = targetSize.width  / size.width
         let heightRatio = targetSize.height / size.height
         
         // Figure out what our orientation is, and use that to form the rectangle
         var newSize: CGSize
         if(widthRatio > heightRatio) {
             newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
         } else {
             newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
         }
         
         // This is the rect that we've calculated out and this is what is actually used below
         let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
         
         // Actually do the resizing to the rect using the ImageContext stuff
         UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
         image.draw(in: rect)
         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         
         return newImage!
     }
    
}

