import Foundation
import AVFoundation

class SpeechManager {
    
    static let shared = SpeechManager()
    
    let synthesizer = AVSpeechSynthesizer()
    
    enum SpeechRate: String {
        case slow, normal, fast
    }
    
    private init() {}

    /// Convert string speed value to enum
    func setVoiceSpeed(speed: String) {
        print("selected_____speed__\(speed)")

        // Save the speed in UserDefaults
        AppUserDefault.setSelectedSpeed(speed)
    }
    
    func getSpeechRate() -> SpeechRate {
        // Retrieve saved speed, default to "normal" if not set
        let savedSpeed = AppUserDefault.getSelectedSpeed() ?? "normal"

        return SpeechRate(rawValue: savedSpeed) ?? .normal
    }

    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        
        // Set speech rate based on UserDefaults
        let selectedRate = getSpeechRate()
        
        switch selectedRate {
        case .slow:
            speechUtterance.rate = 0.3
        case .normal:
            speechUtterance.rate = 0.5
        case .fast:
            speechUtterance.rate = 0.6
        }

        // Set the language for the utterance
        let language = detectLanguage(text: text)
        print("language____:\(language)")
        speechUtterance.voice = AVSpeechSynthesisVoice(language: language)

        synthesizer.speak(speechUtterance)
    }

    private func detectLanguage(text: String) -> String {
        let chineseIdentifier = "zh-HK"
        let englishIdentifier = "en-US"
        let spanishIdentifier = "es-ES"
        let japaneseIdentifier = "ja-JP"
        let koreanIdentifier = "ko-KR"
        let tagalogIdentifier = "tl-PH"
        let malayIdentifier = "ms-MY"

        var containsChinese = false
        var containsEnglish = false

        for scalar in text.unicodeScalars {
            if (scalar >= "\u{4E00}" && scalar <= "\u{9FFF}") {
                containsChinese = true
            } else if scalar.properties.isAlphabetic {
                containsEnglish = true
            }
        }

        let selectedLanguage = AppUserDefault.getSelectedLanguage()

        if selectedLanguage == "ja_JP" {
            return japaneseIdentifier
        } else if selectedLanguage == "es_ES" {
            return spanishIdentifier
        } else if selectedLanguage == "ko_KR" {
            return koreanIdentifier
        } else if selectedLanguage == "tl_PH" {
            return tagalogIdentifier
        } else if selectedLanguage == "ms_MY" {
            return malayIdentifier
        } else {
//            return containsChinese && !containsEnglish ? chineseIdentifier : englishIdentifier
            return containsChinese ? chineseIdentifier : englishIdentifier

        }
    }


    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            print("Stopped speaking")
        }
    }
}
