import Foundation
import MLKitTranslate
import MLKitLanguageID

class TranslationManager {
    static let shared = TranslationManager()

    private init() {}

    private let translationKey = "translatedText"
    private let apiKey = "3be792f0-6f11-4a98-84c7-77d04c569487:fx"
    private let apiURL = "https://api-free.deepl.com/v2/translate"

    // MARK: - Public Translation Methods

    func translateToChineseTraditional(text: String, completion: @escaping (String?) -> Void) {
        detectLanguage(text: text) { detectedLanguage in
            if detectedLanguage == "zh" {
                print("Already in \(detectedLanguage) and the result: \(text)")
                completion(text)
                return
            }
            self.translateViaDeepL(text: text, targetLang: "ZH", completion: completion)
        }
    }

    func translateToJapanese(text: String, completion: @escaping (String?) -> Void) {
        detectLanguage(text: text) { detectedLanguage in
            if detectedLanguage == "ja" {
                print("Already in \(detectedLanguage) and the result: \(text)")
                completion(text)
                return
            }
            self.translateViaDeepL(text: text, targetLang: "JA", completion: completion)
        }
    }

    func translateToSpanish(text: String, completion: @escaping (String?) -> Void) {
        detectLanguage(text: text) { detectedLanguage in
            if detectedLanguage == "es" {
                print("Already in \(detectedLanguage) and the result: \(text)")
                completion(text)
                return
            }
            self.translateViaDeepL(text: text, targetLang: "ES", completion: completion)
        }
    }

    func translateToKorean(text: String, completion: @escaping (String?) -> Void) {
        detectLanguage(text: text) { detectedLanguage in
            if detectedLanguage == "ko" {
                print("Already in \(detectedLanguage) and the result: \(text)")
                completion(text)
                return
            }
            self.translateViaDeepL(text: text, targetLang: "KO", completion: completion)
        }
    }

    func translateToTagalog(text: String, completion: @escaping (String?) -> Void) {
        detectLanguage(text: text) { detectedLanguage in
            if detectedLanguage == "tl" {
                print("Already in \(detectedLanguage) and the result: \(text)")
                completion(text)
                return
            }
            self.translateViaMLKit(text: text, targetLanguage: .tagalog, completion: completion)
        }
    }

    func translateToMalay(text: String, completion: @escaping (String?) -> Void) {
        detectLanguage(text: text) { detectedLanguage in
            if detectedLanguage == "ms" {
                print("Already in \(detectedLanguage) and the result: \(text)")
                completion(text)
                return
            }
            self.translateViaMLKit(text: text, targetLanguage: .malay, completion: completion)
        }
    }

    func getStoredTranslation() -> String? {
        return UserDefaults.standard.string(forKey: translationKey)
    }

    // MARK: - Private Methods

    private func detectLanguage(text: String, completion: @escaping (String) -> Void) {
        let languageId = LanguageIdentification.languageIdentification()
        languageId.identifyLanguage(for: text) { languageCode, error in
            if let error = error {
                print("Language detection error: \(error.localizedDescription)")
                completion("unknown")
                return
            }
            completion(languageCode ?? "unknown")
        }
    }

    private func translateViaDeepL(text: String, targetLang: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("DeepL-Auth-Key \(apiKey)", forHTTPHeaderField: "Authorization")

        let bodyString = "text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&target_lang=\(targetLang)&source_lang=EN"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DeepL request error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("DeepL returned no data.")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let translations = json["translations"] as? [[String: Any]],
                   let translatedText = translations.first?["text"] as? String {
                    completion(translatedText)
                } else {
                    print("DeepL response parsing failed.")
                    completion(nil)
                }
            } catch {
                print("DeepL JSON decoding error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    private func translateViaMLKit(text: String, targetLanguage: TranslateLanguage, completion: @escaping (String?) -> Void) {
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: targetLanguage)
        let translator = Translator.translator(options: options)

        translator.downloadModelIfNeeded { error in
            if let error = error {
                print("MLKit model download error: \(error.localizedDescription)")
                completion(nil)
            } else {
                translator.translate(text) { translatedText, error in
                    if let error = error {
                        print("MLKit translation error: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        completion(translatedText)
                    }
                }
            }
        }
    }
}
