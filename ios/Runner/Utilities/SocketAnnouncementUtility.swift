//
//  SocketAnnouncementUtility.swift
//  Runner
//
//  Created by Ahnaf Rahat on 31/5/25.
//


class SocketAnnouncementUtility{
    
    static let shared = SocketAnnouncementUtility()
    
    private init() {}
    
    
    func speakChineseModes(processType: ProcessType) {
        if processType == .reading {
            self.speak("閱讀")
        } else if processType == .scene {
            self.speak("場景")
        } else if processType == .distance {
            self.speak("距離")
        } else if processType == .supermarket {
            self.speak("超市")
        } else if processType == .bus {
            self.speak("巴士")
        } else if processType == .walking {
            self.speak("走路")
        } else if processType == .chat {
            self.speak("聊天")
        } else if processType == .museum {
            self.speak("博物館")
        }
    }
    
    
    
    func speakJapaneseModes(processType: ProcessType) {
        if processType == .reading {
            self.speak("読書")
        } else if processType == .scene {
            self.speak("シーン")
        } else if processType == .distance {
            self.speak("距離")
        } else if processType == .supermarket {
            self.speak("スーパーマーケット")
        } else if processType == .bus {
            self.speak("バス")
        } else if processType == .walking {
            self.speak("歩行")
        } else if processType == .chat {
            self.speak("チャット")
        } else if processType == .museum {
            self.speak("博物館")
        }
    }

    func speakSpanishModes(processType: ProcessType) {
        if processType == .reading {
            self.speak("Lectura")
        } else if processType == .scene {
            self.speak("Escena")
        } else if processType == .distance {
            self.speak("Distancia")
        } else if processType == .supermarket {
            self.speak("Supermercado")
        } else if processType == .bus {
            self.speak("Autobús")
        } else if processType == .walking {
            self.speak("Caminando")
        } else if processType == .chat {
            self.speak("Charlar")
        } else if processType == .museum {
            self.speak("Museo")
        }
    }

    
    func speakMalayModes(processType: ProcessType) {
        if processType == .reading {
            self.speak("Membaca")
        } else if processType == .scene {
            self.speak("Adegan")
        } else if processType == .distance {
            self.speak("Jarak")
        } else if processType == .supermarket {
            self.speak("Pasar raya")
        } else if processType == .bus {
            self.speak("Bas")
        } else if processType == .walking {
            self.speak("Berjalan")
        } else if processType == .chat {
            self.speak("Sembang")
        } else if processType == .museum {
            self.speak("Muzium")
        }
    }

    func speakTagalogModes(processType: ProcessType) {
        if processType == .reading {
            self.speak("Pagbasa")
        } else if processType == .scene {
            self.speak("Eksena")
        } else if processType == .distance {
            self.speak("Distansya")
        } else if processType == .supermarket {
            self.speak("Pamilihan")
        } else if processType == .bus {
            self.speak("Bus")
        } else if processType == .walking {
            self.speak("Paglalakad")
        } else if processType == .chat {
            self.speak("Usap")
        } else if processType == .museum {
            self.speak("Museo")
        }
    }

    func speakKoreanModes(processType: ProcessType) {
        if processType == .reading {
            self.speak("읽기")
        } else if processType == .scene {
            self.speak("장면")
        } else if processType == .distance {
            self.speak("거리")
        } else if processType == .supermarket {
            self.speak("슈퍼마켓")
        } else if processType == .bus {
            self.speak("버스")
        } else if processType == .walking {
            self.speak("걷기")
        } else if processType == .chat {
            self.speak("채팅")
        } else if processType == .museum {
            self.speak("박물관")
        }
    }
    
    func museumSelectionActivatedAudio() {
        let selectedLanguage = AppUserDefault.getSelectedLanguage() ?? ""

        if selectedLanguage == "en_US" {
            speak("Choose a museum")
        } else if selectedLanguage == "ja_JP" {
            speak("美術館を選ぶ") // Choose a museum
        } else if selectedLanguage == "es_ES" {
            speak("Elige un museo") // Choose a museum
        } else if selectedLanguage == "ko_KR" {
            speak("박물관을 선택하세요") // Choose a museum
        } else if selectedLanguage == "tl_PH" {
            speak("Pumili ng museo") // Choose a museum
        } else if selectedLanguage == "ms_MY" {
            speak("Pilih muzium") // Choose a museum
        } else {
            speak("選擇博物館") // Chinese (fallback) - Choose a museum
        }
    }
    
    func museumSelectionDeactivatedAudio() {
        let selectedLanguage = AppUserDefault.getSelectedLanguage() ?? ""

        if selectedLanguage == "en_US" {
            speak("Museum Selection Deactivated")
        } else if selectedLanguage == "ja_JP" {
            speak("博物館の選択が無効になりました") // Japanese
        } else if selectedLanguage == "es_ES" {
            speak("Selección de museo desactivada") // Spanish
        } else if selectedLanguage == "ko_KR" {
            speak("박물관 선택이 비활성화되었습니다") // Korean
        } else if selectedLanguage == "tl_PH" {
            speak("Hindi pinagana ang pagpili ng museo") // Filipino/Tagalog
        } else if selectedLanguage == "ms_MY" {
            speak("Pemilihan muzium telah dinyahaktifkan") // Malay
        } else {
            speak("博物馆选择已停用") // Chinese (fallback)
        }
    }


    
    func museumSelectionAudio(museum: String) {
        let selectedLanguage = AppUserDefault.getSelectedLanguage() ?? ""

        switch selectedLanguage {
        case "en_US":
            speak("\(museum) is selected")
        case "ja_JP":
            speak("\(museum) が選択されました") // "\(museum) ga sentaku saremashita"
        case "es_ES":
            speak("Se ha seleccionado \(museum)")
        case "ko_KR":
            speak("\(museum)이(가) 선택되었습니다") // \(museum)i(ga) seontaek doeeotsseumnida
        case "tl_PH":
            speak("Napili ang \(museum)")
        case "ms_MY":
            speak("\(museum) telah dipilih")
        default:
            speak("\(museum) 已选择") // Mandarin Chinese (zh_CN)
        }
    }
    

    func museumSwitchingAudio(museum: String) {
        let selectedLanguage = AppUserDefault.getSelectedLanguage() ?? ""

        switch selectedLanguage {
        case "en_US":
            speak("Switched to \(museum) museum")
        case "ja_JP":
            speak("\(museum) 博物館に切り替えました") // Switched to [museum] museum
        case "es_ES":
            speak("Cambiado al museo \(museum)") // Switched to [museum] museum
        case "ko_KR":
            speak("\(museum) 박물관으로 전환되었습니다") // Switched to [museum] museum
        case "tl_PH":
            speak("Lumipat sa \(museum) museo") // Switched to [museum] museum
        case "ms_MY":
            speak("Beralih ke muzium \(museum)") // Switched to [museum] museum
        default:
            speak("切换到\(museum)博物馆") // Chinese fallback
        }
    }
    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }
}
