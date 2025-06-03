//
//  AnnouncementU.swift
//  Runner
//
//  Created by Ahnaf Rahat on 13/5/25.
//

import Foundation
import UIKit

class AnnouncementUtility {
    static let shared = AnnouncementUtility() // Singleton instance
    
    private init() {
        
    }
    
    func fetchBatteryStatusAndSpeak() {
        Helper().getBatteryStatus { statusCode in
            print("battery_status_in_delegate\(statusCode)")
            let language = AppUserDefault.getSelectedLanguage() ?? ""
            
            switch statusCode {
            case 0:
                if language == "en_US" {
                    self.speak("Seekr device has one hundred percent battery remaining")
                } else if language == "ja_JP" {
                    self.speak("シーカーデバイスのバッテリーは残り100パーセントです")
                } else if language == "es_ES" {
                    self.speak("El dispositivo Seekr tiene el cien por ciento de batería restante")
                } else if language == "ko_KR" {
                    self.speak("Seekr 기기のバッテリーが100%残っています")
                } else if language == "tl_PH" {
                    self.speak("Ang Seekr device ay may 100 porsyentong natitirang baterya")
                } else if language == "ms_MY" {
                    self.speak("Peranti Seekr mempunyai baki bateri sebanyak seratus peratus")
                } else {
                    self.speak("Seekr裝置電量剩餘百分之100")
                }
            case 1:
                if language == "en_US" {
                    self.speak("Seekr device has seventy percent battery remaining")
                } else if language == "ja_JP" {
                    self.speak("シーカーデバイスのバッテリーは残り70パーセントです")
                } else if language == "es_ES" {
                    self.speak("El dispositivo Seekr tiene el setenta por ciento de batería restante")
                } else if language == "ko_KR" {
                    self.speak("Seekr 기기のバッテリーが70%残っています")
                } else if language == "tl_PH" {
                    self.speak("Ang Seekr device ay may 70 porsyentong natitirang baterya")
                } else if language == "ms_MY" {
                    self.speak("Peranti Seekr mempunyai baki bateri sebanyak tujuh puluh peratus")
                } else {
                    self.speak("Seekr裝置電量剩餘百分之70")
                }
            case 2:
                if language == "en_US" {
                    self.speak("Seekr device has fifty percent battery remaining")
                } else if language == "ja_JP" {
                    self.speak("シーカーデバイスのバッテリーは残り50パーセントです")
                } else if language == "es_ES" {
                    self.speak("El dispositivo Seekr tiene el cincuenta por ciento de batería restante")
                } else if language == "ko_KR" {
                    self.speak("Seekr 기기のバッテリーが50%残っています")
                } else if language == "tl_PH" {
                    self.speak("Ang Seekr device ay may 50 porsyentong natitirang baterya")
                } else if language == "ms_MY" {
                    self.speak("Peranti Seekr mempunyai baki bateri sebanyak lima puluh peratus")
                } else {
                    self.speak("Seekr裝置電量剩餘百分之50")
                }
            case 3:
                if language == "en_US" {
                    self.speak("Seekr device has twenty-five percent battery remaining")
                } else if language == "ja_JP" {
                    self.speak("シーカーデバイスのバッテリーは残り25パーセントです")
                } else if language == "es_ES" {
                    self.speak("El dispositivo Seekr tiene el veinticinco por ciento de batería restante")
                } else if language == "ko_KR" {
                    self.speak("Seekr 기기のバッテリーが25%残っています")
                } else if language == "tl_PH" {
                    self.speak("Ang Seekr device ay may 25 porsyentong natitirang baterya")
                } else if language == "ms_MY" {
                    self.speak("Peranti Seekr mempunyai baki bateri sebanyak dua puluh lima peratus")
                } else {
                    self.speak("Seekr裝置電量剩餘百分之25")
                }
            case 4:
                if language == "en_US" {
                    self.speak("Seekr device is running out of battery")
                } else if language == "ja_JP" {
                    self.speak("シーカーデバイスのバッテリーがなくなりかけています")
                } else if language == "es_ES" {
                    self.speak("El dispositivo Seekr se está quedando sin batería")
                } else if language == "ko_KR" {
                    self.speak("Seekr 기기のバッテリーがほとんどなくなっています")
                } else if language == "tl_PH" {
                    self.speak("Paubos na ang baterya ng Seekr device")
                } else if language == "ms_MY" {
                    self.speak("Bateri peranti Seekr hampir habis")
                } else {
                    self.speak("Seekr設備電池電量耗盡")
                }
            case 5:
                if language == "en_US" {
                    self.speak("Seekr device is charging")
                } else if language == "ja_JP" {
                    self.speak("シーカーデバイスが充電中です")
                } else if language == "es_ES" {
                    self.speak("El dispositivo Seekr se está cargando")
                } else if language == "ko_KR" {
                    self.speak("Seekr 기기를 충전 중입니다")
                } else if language == "tl_PH" {
                    self.speak("Nagcha-charge ang Seekr device")
                } else if language == "ms_MY" {
                    self.speak("Peranti Seekr sedang dicas")
                } else {
                    self.speak("Seekr設備正在充電")
                }
            default:
//                self.timer?.invalidate()
//                self.timer = nil
                break
            }
        }
    }
    
    func announceBackgroundModeStart(){
        if AppUserDefault.getSelectedLanguage() == "en_US" {
            speak("Device is connected in background mode")
        } else if AppUserDefault.getSelectedLanguage() == "ja_JP" {
            speak("デバイスがバックグラウンドモードで接続されています")
        } else if AppUserDefault.getSelectedLanguage() == "es_ES" {
            speak("El dispositivo está conectado en modo de fondo")
        } else if AppUserDefault.getSelectedLanguage() == "ko_KR" {
            speak("장치는 백그라운드 모드에서 연결되어 있습니다")
        } else if AppUserDefault.getSelectedLanguage() == "tl_PH" {
            speak("Nakakonekta ang device sa background mode")
        } else if AppUserDefault.getSelectedLanguage() == "ms_MY" {
            speak("Peranti disambungkan dalam mod latar belakang")
        } else {
            speak("設備以背景模式連接")
        }
        
        speak("\(AppUserDefault.getSelectedMode() ?? "") Mode Activated")
    }
    
    func announceConnectedToTheInternet(){
        let language = AppUserDefault.getSelectedLanguage() ?? ""
        
        if language == "en_US" {
            self.speak("Connected to the internet.")
        } else if language == "ja_JP" {
            self.speak("インターネットに接続されています。")
        } else if language == "es_ES" {
            self.speak("Conectado a internet.")
        } else {
            self.speak("⁠已連接到互聯網。")
        }
    }
    
    
    func announceNoInternetConnection(){
        let language = AppUserDefault.getSelectedLanguage() ?? ""
        
        if language == "en_US" {
            self.speak("No internet, Please check your connection")
        } else if language == "ja_JP" {
            self.speak("インターネット接続がありません。接続を確認してください。")
        } else if language == "es_ES" {
            self.speak("Sin internet, por favor revisa tu conexión.")
        } else {
            self.speak("⁠無互聯網連接，請檢查您的網絡連接")
        }
    }
    
    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }
    
}
