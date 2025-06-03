////
////  TraslatorManager.swift
////  Runner
////
////  Created by Ahnaf Rahat on 3/1/24.
////
//
//import Foundation
//import MLKitTranslate
//
//class TranslationManager {
//    static let shared = TranslationManager()
//
//    private init() {}
//
//    // Shared preferences for storing translated text
//    private let translationKey = "translatedText"
//    
//    // Configure dynamic translator options for different languages
//    private func createTranslator(sourceLanguage: TranslateLanguage, targetLanguage: TranslateLanguage) -> Translator {
//        let options = TranslatorOptions(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
//        return Translator.translator(options: options)
//    }
//
//    // Function to translate text to Chinese Traditional (keeping existing functionality)
//    func translateToChineseTraditional(text: String, completion: @escaping (String?) -> Void) {
//        let translator = createTranslator(sourceLanguage: .english, targetLanguage: .chinese)
//        translator.downloadModelIfNeeded { error in
//            if let error = error {
//                print("Error downloading model: \(error.localizedDescription)")
//                completion(nil)
//            } else {
//                translator.translate(text) { translatedText, error in
//                    if let error = error {
//                        print("Error translating text: \(error.localizedDescription)")
//                        completion(nil)
//                    } else {
//                        // Save translated text to shared preferences if needed
//                        // UserDefaults.standard.set(translatedText, forKey: self.translationKey)
//                        completion(translatedText)
//                    }
//                }
//            }
//        }
//    }
//
//    // Function to translate text to Japanese
//    func translateToJapanese(text: String, completion: @escaping (String?) -> Void) {
//        let translator = createTranslator(sourceLanguage: .english, targetLanguage: .japanese)
//        translator.downloadModelIfNeeded { error in
//            if let error = error {
//                print("Error downloading model: \(error.localizedDescription)")
//                completion(nil)
//            } else {
//                translator.translate(text) { translatedText, error in
//                    if let error = error {
//                        print("Error translating text: \(error.localizedDescription)")
//                        completion(nil)
//                    } else {
//                        completion(translatedText)
//                    }
//                }
//            }
//        }
//    }
//
//    // Function to translate text to Spanish
//    func translateToSpanish(text: String, completion: @escaping (String?) -> Void) {
//        let translator = createTranslator(sourceLanguage: .english, targetLanguage: .spanish)
//        translator.downloadModelIfNeeded { error in
//            if let error = error {
//                print("Error downloading model: \(error.localizedDescription)")
//                completion(nil)
//            } else {
//                translator.translate(text) { translatedText, error in
//                    if let error = error {
//                        print("Error translating text: \(error.localizedDescription)")
//                        completion(nil)
//                    } else {
//                        completion(translatedText)
//                    }
//                }
//            }
//        }
//    }
//
//    // Retrieve stored translation if needed
//    func getStoredTranslation() -> String? {
//        return UserDefaults.standard.string(forKey: translationKey)
//    }
//}
//
