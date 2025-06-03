//
//  StaticTranslation.swift
//  Runner
//
//  Created by Ahnaf Rahat on 31/5/25.
//

class StaticTranslation{
    
    static let shared = StaticTranslation()
    let translator = TranslationManager.shared

    private init() {}
    
    func translateNow(textToTranslate: String) {
        let selectedLanguage = AppUserDefault.getSelectedLanguage()

        if selectedLanguage == "ja_JP" {
            self.translator.translateToJapanese(text: textToTranslate) { translatedText in
                if let translatedText = translatedText {
                    print("Translated text: \(translatedText)")
                    self.speak(translatedText)
                } else {
                    print("Translation failed.")
                }
            }
        } else if selectedLanguage == "es_ES" {
            self.translator.translateToSpanish(text: textToTranslate) { translatedText in
                if let translatedText = translatedText {
                    print("Translated text: \(translatedText)")
                    self.speak(translatedText)
                } else {
                    print("Translation failed.")
                }
            }
        } else if selectedLanguage == "ko_KR" {
            self.translator.translateToKorean(text: textToTranslate) { translatedText in
                if let translatedText = translatedText {
                    print("Translated text: \(translatedText)")
                    self.speak(translatedText)
                } else {
                    print("Translation failed.")
                }
            }
        } else if selectedLanguage == "tl_PH" {
            self.translator.translateToTagalog(text: textToTranslate) { translatedText in
                if let translatedText = translatedText {
                    print("Translated text: \(translatedText)")
                    self.speak(translatedText)
                } else {
                    print("Translation failed.")
                }
            }
        } else if selectedLanguage == "ms_MY" {
            self.translator.translateToMalay(text: textToTranslate) { translatedText in
                if let translatedText = translatedText {
                    print("Translated text: \(translatedText)")
                    self.speak(translatedText)
                } else {
                    print("Translation failed.")
                }
            }
        } else {
            self.translator.translateToChineseTraditional(text: textToTranslate) { translatedText in
                if let translatedText = translatedText {
                    print("Translated text: \(translatedText)")
                    self.speak(translatedText)
                } else {
                    print("Translation failed.")
                }
            }
        }
    }
    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }

}
