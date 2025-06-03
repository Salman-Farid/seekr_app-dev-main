import UIKit
import Network
import AVFoundation
import CoreMedia
import Vision

class SeekrAutoTextView {
    
    static let shared = SeekrAutoTextView()
    
    let mainView: UIView
    let streamHandler = CameraStreamHandler()
    var feedbackLabel: UILabel!
    var guideRectangle: CAShapeLayer!
    let speechSynthesizer = AVSpeechSynthesizer()
    var lastFeedbackTime: Date?
    let feedbackCooldown: TimeInterval = 3.0
    var isDetectionPaused = false
    var statusLabel: UILabel!
    var currentBuffer: CVPixelBuffer?
    
    let textDetector = TextDetector()


    private init() {
        // Initialize mainView as a virtual view
        mainView = UIView(frame: UIScreen.main.bounds)
        setupGuidanceUI()
//        startStreaming()
    }

    func setupGuidanceUI() {
        // Create a rectangle overlay
//        let overlayPath = UIBezierPath(rect: CGRect(x: 50, y: 150, width: mainView.frame.width - 100, height: mainView.frame.height / 2))
        
        // Calculate the aspect ratio of the stream frame
        let streamFrameWidth: CGFloat = 640
        let streamFrameHeight: CGFloat = 368
        let streamAspectRatio = streamFrameWidth / streamFrameHeight

        // Get the view's width and height
        let viewWidth = mainView.bounds.width
        let viewHeight = mainView.bounds.height

        // Calculate the guidance frame dimensions while maintaining the stream aspect ratio
        var guidanceFrameWidth = viewWidth
        var guidanceFrameHeight = viewWidth / streamAspectRatio

        if guidanceFrameHeight > viewHeight {
            guidanceFrameHeight = viewHeight
            guidanceFrameWidth = viewHeight * streamAspectRatio
        }

        // Center the guidance frame on the screen
        let guidanceFrameX = (viewWidth - guidanceFrameWidth) / 2
        let guidanceFrameY = (viewHeight - guidanceFrameHeight) / 2
        let guidanceFrame = CGRect(x: guidanceFrameX, y: guidanceFrameY, width: guidanceFrameWidth, height: guidanceFrameHeight)

        // Create the rectangle overlay
        let overlayPath = UIBezierPath(rect: guidanceFrame)
        
        guideRectangle = CAShapeLayer()
        guideRectangle.path = overlayPath.cgPath
        guideRectangle.fillColor = UIColor.clear.cgColor
        guideRectangle.strokeColor = UIColor.white.cgColor
        guideRectangle.lineWidth = 2
        mainView.layer.addSublayer(guideRectangle)

        // Add feedback label
        feedbackLabel = UILabel(frame: CGRect(x: 20, y: mainView.frame.height - 100, width: mainView.frame.width - 40, height: 40))
        feedbackLabel.textAlignment = .center
        feedbackLabel.textColor = .white
        feedbackLabel.font = UIFont.systemFont(ofSize: 18)
        feedbackLabel.text = "Place your document inside the frame."
        mainView.addSubview(feedbackLabel)
    }

    func startStreaming() {
        // If detection is paused, resume it
        if isDetectionPaused {
            isDetectionPaused = false
            speak("Resuming text detection")

        } else {
            speak("Text detection mode started!")
        }
        
        streamHandler.startStream()
        streamHandler.displayJPEGData = { [weak self] data in
            guard let self = self, !self.isDetectionPaused else { return }
            if let image = UIImage(data: data)?.cgImage {
                self.processFrame(image)
            }
        }
    }

    func processFrame(_ cgImage: CGImage) {
        let rectangleRequest = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self, let results = request.results as? [VNRectangleObservation], let strongestRectangle = results.first else { return }

            let rectangleBounds = CGRect(
                x: strongestRectangle.boundingBox.origin.x * self.mainView.bounds.width,
                y: (1 - strongestRectangle.boundingBox.origin.y - strongestRectangle.boundingBox.height) * self.mainView.bounds.height,
                width: strongestRectangle.boundingBox.width * self.mainView.bounds.width,
                height: strongestRectangle.boundingBox.height * self.mainView.bounds.height
            )

            if self.isRectangleInsideGuide(rectangleBounds) {
                DispatchQueue.main.async {
                    self.feedbackLabel.text = "Document detected! Checking text readability..."
                    self.guideRectangle.strokeColor = UIColor.green.cgColor
                }
//                self.detectText(in: cgImage)
                self.detectTextAzure(cgImage: cgImage)
//                self.isDetectionPaused = true
//
//                Helper().capturePhoto { status in
//                    print("photo_shoot_status____\(status)")
//                    if status == 0 {
//                        self.getPhotFromDevice()
//                    }
//                }

                
                
            } else {
                DispatchQueue.main.async {
                    self.feedbackLabel.text = "Place the document inside the frame."
                    self.guideRectangle.strokeColor = UIColor.white.cgColor
                    self.provideDirectionalGuidance(for: rectangleBounds)
                }
            }
        }

        rectangleRequest.minimumAspectRatio = 0.5
        rectangleRequest.maximumAspectRatio = 1.5
        rectangleRequest.minimumConfidence = 0.8

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([rectangleRequest])
    }

    func detectText(in cgImage: CGImage) {
        let textRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self, let observations = request.results as? [VNRecognizedTextObservation] else { return }

            if let textObservation = observations.first(where: { $0.confidence > 0.8 }) {
                DispatchQueue.main.async {
                    self.feedbackLabel.text = "Readable text detected! Processing..."
                    self.guideRectangle.strokeColor = UIColor.green.cgColor
                    self.isDetectionPaused = true
                    self.speak(textObservation.topCandidates(1).first?.string ?? "Text detected.")
                }
            } else {
                DispatchQueue.main.async {
                    self.feedbackLabel.text = "Text not readable. Adjust your position."
                    self.guideRectangle.strokeColor = UIColor.red.cgColor
                }
            }
        }
        textRequest.recognitionLevel = .accurate
        textRequest.recognitionLanguages = ["en-US", "zh-Hans", "zh-Hant"]

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([textRequest])
    }

//    func provideDirectionalGuidance(for rectangle: CGRect) {
//        let guideFrame = CGRect(x: 50, y: 150, width: mainView.frame.width - 100, height: mainView.frame.height / 2)
//        let currentTime = Date()
//
//        guard lastFeedbackTime == nil || currentTime.timeIntervalSince(lastFeedbackTime!) > feedbackCooldown else { return }
//
//        var feedbackText: String?
//        if rectangle.minX < guideFrame.minX {
//            feedbackText = "Move to the right."
//        } else if rectangle.maxX > guideFrame.maxX {
//            feedbackText = "Move to the left."
//        }
//
//        if rectangle.minY < guideFrame.minY {
//            feedbackText = "Move down."
//        } else if rectangle.maxY > guideFrame.maxY {
//            feedbackText = "Move up."
//        }
//
//        let guideArea = guideFrame.width * guideFrame.height
//        let rectangleArea = rectangle.width * rectangle.height
//        if rectangleArea < guideArea * 0.5 {
//            feedbackText = "Move closer."
//        } else if rectangleArea > guideArea * 1.2 {
//            feedbackText = "Move farther."
//        }
//
//        if let feedbackText = feedbackText {
//            feedbackLabel.text = feedbackText
//            speak(feedbackText)
//            lastFeedbackTime = currentTime
//        }
//    }
    
    func provideDirectionalGuidance(for rectangle: CGRect) {
        
        let streamFrameWidth: CGFloat = 640
        let streamFrameHeight: CGFloat = 368
        let streamAspectRatio = streamFrameWidth / streamFrameHeight

        // Get the view's width and height
        let viewWidth = mainView.bounds.width
        let viewHeight = mainView.bounds.height

        // Calculate the guidance frame dimensions while maintaining the stream aspect ratio
        var guidanceFrameWidth = viewWidth
        var guidanceFrameHeight = viewWidth / streamAspectRatio

        if guidanceFrameHeight > viewHeight {
            guidanceFrameHeight = viewHeight
            guidanceFrameWidth = viewHeight * streamAspectRatio
        }

        // Center the guidance frame on the screen
        let guidanceFrameX = (viewWidth - guidanceFrameWidth) / 2
        let guidanceFrameY = (viewHeight - guidanceFrameHeight) / 2
        let guidanceFrame = CGRect(x: guidanceFrameX, y: guidanceFrameY, width: guidanceFrameWidth, height: guidanceFrameHeight)

        // Create the rectangle overlay
        let overlayPath = UIBezierPath(rect: guidanceFrame)
        
        let guideFrame = guidanceFrame
        let currentTime = Date()

        guard lastFeedbackTime == nil || currentTime.timeIntervalSince(lastFeedbackTime!) > feedbackCooldown else { return }

        var feedbackText: String?
        if rectangle.minX < guideFrame.minX {
            feedbackText = "Move to the right."
        } else if rectangle.maxX > guideFrame.maxX {
            feedbackText = "Move to the left."
        }

        if rectangle.minY < guideFrame.minY {
            feedbackText = "Move down."
        } else if rectangle.maxY > guideFrame.maxY {
            feedbackText = "Move up."
        }

        let guideArea = guideFrame.width * guideFrame.height
        let rectangleArea = rectangle.width * rectangle.height
        if rectangleArea < guideArea * 0.5 {
            feedbackText = "Move closer."
        } else if rectangleArea > guideArea * 1.2 {
            feedbackText = "Move farther."
        }

        if let feedbackText = feedbackText {
            feedbackLabel.text = feedbackText
            speak(feedbackText)
            lastFeedbackTime = currentTime
        }
    }

    func getPhotFromDevice(){
        Helper().getPhotoDataFromDevice { result in
            switch result {
            case .success(let imageData):
                // Handle the image data
                print("Image data: \(imageData)")
                Helper().deleteDataFromDevice { error in
                    print(error?.localizedDescription)
                }                //                    guard let imageData = data else { return }
                print("time_image_fetched_from_device:\(Date())")

                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)!
                    print("Image size: height\(image.size.height) , width\(image.size.width)")

                    self.textDetector.processText(imageData: imageData) { detectedTexts, error in
                        if let error = error {
                            print("Error: \(error)")
                        } else if let detectedTexts = detectedTexts {
                            print("Detected Texts: \(detectedTexts)")
                            if detectedTexts != "" {
                                print("time_after_textDetection:\(Date())")
                                self.speak(detectedTexts)

                            } else {
                                    self.speak("No text detected!")
                            }
                        }
                    }
                }
                
            case .failure(let error):
                print("Completion error: \(error)")
            
            }
        }
        

    }
    

    func isRectangleInsideGuide(_ rectangle: CGRect) -> Bool {
        let guideFrame = CGRect(x: 50, y: 150, width: mainView.frame.width - 100, height: mainView.frame.height / 2)
        return guideFrame.contains(rectangle)
    }

    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }
    
    func stopStreaming() {
        self.streamHandler.stopStream()
    }

    func resumeStream() {
        self.isDetectionPaused = false
    }
}

extension Character {
    var isCJKCharacter: Bool {
        guard let scalar = self.unicodeScalars.first else {
            return false
        }
        return (0x4E00...0x9FFF).contains(scalar.value) ||  // CJK Unified Ideographs
               (0x3400...0x4DBF).contains(scalar.value) ||  // CJK Unified Ideographs Extension A
               (0x20000...0x2A6DF).contains(scalar.value) || // CJK Unified Ideographs Extension B
               (0x2A700...0x2B73F).contains(scalar.value) || // CJK Unified Ideographs Extension C
               (0x2B740...0x2B81F).contains(scalar.value) || // CJK Unified Ideographs Extension D
               (0x2B820...0x2CEAF).contains(scalar.value) || // CJK Unified Ideographs Extension E
               (0x2CEB0...0x2EBEF).contains(scalar.value) || // CJK Unified Ideographs Extension F
               (0xF900...0xFAFF).contains(scalar.value) ||   // CJK Compatibility Ideographs
               (0x2F800...0x2FA1F).contains(scalar.value)    // CJK Compatibility Ideographs Supplement
    }
}


extension SeekrAutoTextView {
    func detectTextAzure(cgImage: CGImage) {
        let uiImage = UIImage(cgImage: cgImage)
        
        // Print image info to console
        print("Captured full frame image size: \(uiImage.size)")
//        self.saveImageToDisk(image: uiImage)
        self.isDetectionPaused = true

        
        let imageData = uiImage.pngData() ?? Data()
        self.textDetector.processText(imageData: imageData) { detectedTexts, error in
            if let error = error {
//                self.audioPlayerManager.stopProcessingAudio()
                print("Error: \(error)")
            } else if let detectedTexts = detectedTexts {
//                self.audioPlayerManager.stopProcessingAudio()
                print("Detected Texts: \(detectedTexts)")
                if detectedTexts != "" {
                    print("time_after_textDetection:\(Date())")
                    // if AppUserDefault.getSelectedLanguage() == "en_US"{
                    self.speak(detectedTexts)
                    // }else{
                    //    self.translateNow(textToTranslate: detectedTexts)
                    // }
                } else {
//                    if AppUserDefault.getSelectedLanguage() == "en_US" {
                        self.speak("No text detected!")
//                    } else {
//                        self.translateNow(textToTranslate: "No text detected!")
//                    }
                }
            }
        }
    }
    

    
    // Helper to save image for debugging purposes
    func saveImageToDisk(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            let filename = getDocumentsDirectory().appendingPathComponent("bounding_box_new\(Date()).jpg")
            try? data.write(to: filename)
            print("Image saved at: \(filename)")
        }
    }

    // Helper to get documents directory for saving images
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

