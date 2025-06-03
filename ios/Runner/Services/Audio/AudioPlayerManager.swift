import AVFoundation

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    
    // MARK: - Singleton
    static let shared = AudioPlayerManager()
    
    // Private init to prevent instantiation
    override init() {}
    
    // MARK: - Properties
    var audioPlayer: AVAudioPlayer?
    var processAudioPlayer: AVAudioPlayer?
    
    // MARK: - Methods
    
    func playSocketHelper() {
        guard let url = Bundle.main.url(forResource: "socket_helper", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    func playProcessingAudio() {
        let playProcessAudio = AppUserDefault.getIsSoundOn() ?? true
        print("playProcessAudio: \(playProcessAudio)")

        guard let url = Bundle.main.url(forResource: "processing", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            processAudioPlayer = try AVAudioPlayer(contentsOf: url)
            processAudioPlayer?.delegate = self
            processAudioPlayer?.numberOfLoops = -1

            if playProcessAudio {
                processAudioPlayer?.play()
            }
        } catch {
            print("Error initializing processAudioPlayer: \(error.localizedDescription)")
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
    }

    func stopProcessingAudio() {
        processAudioPlayer?.stop()
    }
    
    // Plays any `.mp3` file from a given URL (local or remote if downloaded)
    func playAudio(from url: URL, numberOfLoops: Int = 0) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = numberOfLoops
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("Playing audio from: \(url)")
        } catch {
            print("Error playing audio from URL: \(error.localizedDescription)")
        }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio playback finished successfully.")
        } else {
            print("Audio playback finished with an error.")
        }
    }
}
