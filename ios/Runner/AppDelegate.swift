import UIKit
import Network
import Flutter
import AVFoundation
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    let socketManager = CustomSocketManager.shared
    var backgroundUpdateTask: UIBackgroundTaskIdentifier = .invalid
    let audioPlayerManager = AudioPlayerManager.shared
    let networkMonitor = NetworkMonitor.shared
    let announcementUtility = AnnouncementUtility.shared
    
    var timer: Timer?
    
    var isBackgroundMode: Bool = false
    private var isForegroundAudioPlaying: Bool = false

    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        AppUserDefault.setIsBackgroundMode(false)

//        zh_HK en_US
        
//        self.fetchCameraData()
        self.networkMonitor
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .networkStatusChanged, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }

        
        if AppUserDefault.getSelectedLanguage() == nil{
            self.setDeviceSettings(languageCode: "en_US")
        }
        
        if !AppUserDefault.getIsFirstTime(){
            self.setProcessSound(isOn: true)
            AppUserDefault.setIsFirstTime(true)
            print("first_time_got_true\(AppUserDefault.getIsSoundOn())")
        }
        
//        self.testLocalImagePrediction()
//        self.testLocalImageObstacle()
        
        let controller = window.rootViewController as! FlutterViewController
        
//        Socket.shared.configureSocketChannel(with: controller)

        
        let swiftChannel = FlutterMethodChannel(name: "background_channel/ios", binaryMessenger: controller.binaryMessenger)

        // Register the Swift method with Flutter
        swiftChannel.setMethodCallHandler { (call, result) in
            if call.method == "setDeviceSettings" {
                if let languageCode = call.arguments as? String {
                    self.setDeviceSettings(languageCode: languageCode)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            } else if call.method == "setProcessSound" {
                if let isSoundOn = call.arguments as? Bool {
                    self.setProcessSound(isOn: isSoundOn)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            } else if call.method == "setSelectedMode" {
                if let selectedMode = call.arguments as? String {
                    self.setSelectedMode(selectedMode: selectedMode)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            }  else if call.method == "setVoiceSpeed" {
                if let selectedSpeed = call.arguments as? String {
                    self.setVoiceSpeed(speed: selectedSpeed)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            }else if call.method == "getSelectedMode" {
                let mode = self.getSelectedMode()
                result(mode)
            } else if call.method == "setUserId" { // Handling setUserId method
                if let userId = call.arguments as? String {
                    self.setUserId(userId: userId)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            } else if call.method == "setSessionId" { // Handling setSessionId method
                if let sessionId = call.arguments as? String {
                    self.setSessionId(sessionId: sessionId)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            } else if call.method == "setAccessToken" { // Handling setSessionId method
                if let accessToken = call.arguments as? String {
                    self.setAccessToken(accessToken: accessToken)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            }else if call.method == "setUserDetails" { // Handling setSessionId method
                if let userDetails = call.arguments as? Dictionary<String, String> {
                    print("userDetails::\(userDetails)")
                    
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
                }
            }else if call.method == "connectSocketNative" {
                self.socketManager.connectToSocket()
                result(nil)
            } else if call.method == "disconnectSocketNative" {
                self.socketManager.disconnectSocket()
                result(nil)
            } else if call.method == "runModel", let args = call.arguments as? [String: Any],
                let imageData = args["image"] as? FlutterStandardTypedData {
                
                guard let uiImage = UIImage(data: imageData.data) else {
                    result(FlutterError(code: "INVALID_IMAGE", message: "Could not convert image data", details: nil))
                    return
                }
                
                guard let pixelBuffer = uiImage.pixelBuffer(width: Int(uiImage.size.width), height: Int(uiImage.size.height)) else {
                    result(FlutterError(code: "PIXEL_BUFFER_ERROR", message: "Failed to create pixel buffer", details: nil))
                    return
                }
                
                ModelManager.shared.predict(pixelBuffer: pixelBuffer, image:uiImage) { detections in
                    if let detections = detections {
                        result(detections)
                    } else {
                        result(FlutterError(code: "PREDICTION_ERROR", message: "Failed to process image", details: nil))
                    }
                }
            }else if call.method == "processObstacleImage", let args = call.arguments as? [String: Any],
                     let imageData = args["image"] as? FlutterStandardTypedData {
                
                guard let uiImage = UIImage(data: imageData.data) else {
                    result(FlutterError(code: "INVALID_IMAGE", message: "Could not convert image data", details: nil))
                    return
                }
                
                // Call ObstacleAvoidanceManager to process the image
                ObstacleAvoidanceManager.shared.processImage(image: uiImage) { processingResult in
                      result(processingResult ?? "")
                }
            } else if call.method == "processTextDetection", let args = call.arguments as? [String: Any],
                      let imageData = args["image"] as? FlutterStandardTypedData {
                
                guard let uiImage = UIImage(data: imageData.data) else {
                    result(FlutterError(code: "INVALID_IMAGE", message: "Could not convert image data", details: nil))
                    return
                }
                
                // Call AutomatedTextDetectionModelManager to process the image
                AutomatedTextDetectionModelManager.shared.processFrame(uiImage.cgImage!) { message, isResultGenerated in
                    if let message = message {
                        // Return both the message and isResultGenerated flag
                        result([
                            "message": message,
                            "isResultGenerated": isResultGenerated
                        ])
                    } else {
                        result(FlutterError(code: "PROCESSING_ERROR", message: "Failed to process image", details: nil))
                    }
                }
            } else if call.method == "playAudio" {
                if let args = call.arguments as? [String: Any],
                   let urlString = args["url"] as? String,
                   let url = URL(string: urlString) {
                    
                    let loop = args["loop"] as? Int ?? 0
                    self.audioPlayerManager.playAudio(from: url, numberOfLoops: loop)
                    result("Playing audio with loop count: \(loop)")
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid URL", details: nil))
                }
            } else if call.method == "stopAudio" {
                self.audioPlayerManager.stopAudio()
                result("Audio stopped")
            } else if call.method == "playProcessingSound" {
                self.audioPlayerManager.playProcessingAudio()
                result("Audio stopped")
            } else if call.method == "stopProcessingSound" {
                self.audioPlayerManager.stopProcessingAudio()
                result("Audio stopped")
            } else if call.method == "setAudioPlayingStatus" {
                if let isPlaying = call.arguments as? Bool {
                    self.isForegroundAudioPlaying = isPlaying
                    print("Audio Playing Status updated: \(isPlaying)")
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument for audio status", details: nil))
                }
            }else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    override func applicationWillEnterForeground(_ application: UIApplication) {

        if socketManager.isSocketConnected(){
            self.socketManager.disconnectSocket()
//            self.endBackgroundUpdateTask()

        }
        self.audioPlayerManager.stopAudio()
        self.audioPlayerManager.stopProcessingAudio()
        
        self.timer?.invalidate()
        self.timer = nil
        self.isBackgroundMode = false
        
        AppUserDefault.setIsBackgroundMode(false)
        VoiceChatbotManager.shared.stopListening()
        AppUserDefault.setSelectedMode("")
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(backgroundUpdateTask)
        backgroundUpdateTask = .invalid
    }
    
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application____Did____Enter____Background")
        self.printAllSavedData()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        var selectedMode = AppUserDefault.getSelectedMode() ?? ""
        if selectedMode == "chat"{
            VoiceChatbotManager.shared.startPersistentListening()
            AppUserDefault.setIsChatMode(true)

        }else{
            AppUserDefault.setIsChatMode(false)

        }

        self.audioPlayerManager.playSocketHelper()
        

        let isDeviceConnected : Bool = Helper().getDeviceData() ?? false
        if isDeviceConnected{
            
            self.isBackgroundMode = true
            AppUserDefault.setIsBackgroundMode(true)

            if !self.isForegroundAudioPlaying{
                self.announcementUtility.announceBackgroundModeStart()
            }
            
            
           
            Helper().switchDeviceToPhotoMode()
            Helper().deleteDataFromDevice { error in
                print(error?.localizedDescription)
            }
            self.socketManager.connectToSocket()
            
            if !isForegroundAudioPlaying{
                if self.timer == nil {
                    self.startBettryStatusTimer()
                }
            }
           


        }else{
            print("Device_is_not_connected")
            
            self.timer?.invalidate()
            self.timer = nil
        }
        
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        // Stop monitoring when the app is about to terminate
        networkMonitor.stopMonitoring()
        NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
    }
    
    private func startBettryStatusTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in
            self?.announcementUtility.fetchBatteryStatusAndSpeak()
         }
        self.timer?.fire()
     }
    
    
    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }
    
    
    func setDeviceSettings(languageCode:String){
        print("selected_____LanguageCode__\(languageCode)")
        let language = languageCode ?? ""
        AppUserDefault.setSelectedLanguage(language)
    }
    
    
    func setProcessSound(isOn:Bool){
        print("set______ProcessSound\(isOn)")
        AppUserDefault.setIsSoundOn(isOn)
    }
    
    func setVoiceSpeed(speed:String){
        print("selected_____speed__\(speed)")
        let speed = speed ?? ""
        AppUserDefault.setSelectedSpeed(speed)
    }
    
    func setSelectedMode(selectedMode:String){
        print("selected_____mode__\(selectedMode)")
        let mode = selectedMode ?? ""
        AppUserDefault.setSelectedMode(mode)
    }
    
    func getSelectedMode() -> String{
        let mode = AppUserDefault.getSelectedMode() ?? ""
        return mode
    }
    
    func setAccessToken(accessToken:String){
        print("selected_____mode__\(accessToken)")
        let token = accessToken ?? ""
        AppUserDefault.setAccessToken(accessToken)
    }
    
    func getAccessToken() -> String{
        let token = AppUserDefault.getAccessToken() ?? ""
        return token
    }
    
    func setUserId(userId:String){
        print("userId::::\(userId)")
        let id = userId ?? ""
        AppUserDefault.setUserId(id)
    }
    
    func getUserId() -> String{
        let id = AppUserDefault.getUserId() ?? ""
        return id
    }
    
    
    func setSessionId(sessionId:String){
        print("sessionId::::\(sessionId)")
        let session = sessionId ?? ""
        AppUserDefault.setSessionId(session)
    }
    
    func getSessionId() -> String{
        let id = AppUserDefault.getSessionId() ?? ""
        return id
    }
    
    func printAllSavedData(){
        print("Session___id:\(AppUserDefault.getSessionId() ?? "")")
        print("getAccessToken():\(AppUserDefault.getAccessToken() ?? "")")
        print("User___id:\(AppUserDefault.getUserId() ?? "")")

    }
    
    
    @objc private func networkStatusChanged() {
        let connectionType = networkMonitor.connectionType
        let language = AppUserDefault.getSelectedLanguage() ?? ""

        switch connectionType {
        case .wifi:
            print("AppDelegate: Connected via Wi-Fi")
        case .cellular:
            print("AppDelegate: Connected via Cellular")
            if isBackgroundMode{
                self.announcementUtility.announceConnectedToTheInternet()
            }
        case .none:
            print("AppDelegate: No network connection")
            if isBackgroundMode{
                self.announcementUtility.announceNoInternetConnection()
            }
        }
    }

}


