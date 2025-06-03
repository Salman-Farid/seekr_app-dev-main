//
//  AutomatedTextDetectionModelManagerViewController.swift
//  Runner
//
//  Created by Ahnaf Rahat on 15/5/25.
//


import UIKit
import Network
import AVFoundation
import CoreMedia
import Vision

class AutomatedTextDetectionModelManager {
    
    static let shared = AutomatedTextDetectionModelManager()
    
    let mainView: UIView
    let speechSynthesizer = AVSpeechSynthesizer()
    var lastFeedbackTime: Date?
    let feedbackCooldown: TimeInterval = 3.0
    var isDetectionPaused = false
    var statusLabel: UILabel!
    
    let textDetector = TextDetector()

    private init() {
        // Initialize mainView as a virtual view
        mainView = UIView(frame: UIScreen.main.bounds)
        setupGuidanceUI()
    }

    func setupGuidanceUI() {
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
        
        let guideRectangle = CAShapeLayer()
        guideRectangle.path = overlayPath.cgPath
        guideRectangle.fillColor = UIColor.clear.cgColor
        guideRectangle.strokeColor = UIColor.white.cgColor
        guideRectangle.lineWidth = 2
        mainView.layer.addSublayer(guideRectangle)
    }

    func processFrame(_ cgImage: CGImage, completion: @escaping (String?, Bool) -> Void) {
        let rectangleRequest = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self, let results = request.results as? [VNRectangleObservation], let strongestRectangle = results.first else {
                completion(nil, false)
                return
            }

            let rectangleBounds = CGRect(
                x: strongestRectangle.boundingBox.origin.x * self.mainView.bounds.width,
                y: (1 - strongestRectangle.boundingBox.origin.y - strongestRectangle.boundingBox.height) * self.mainView.bounds.height,
                width: strongestRectangle.boundingBox.width * self.mainView.bounds.width,
                height: strongestRectangle.boundingBox.height * self.mainView.bounds.height
            )

            if self.isRectangleInsideGuide(rectangleBounds) {
                self.detectTextAzure(cgImage: cgImage) { detectedText in
                    completion(detectedText, true)
                }
            } else {
                let guidanceText = self.provideDirectionalGuidance(for: rectangleBounds)
                completion(guidanceText, false)
            }
        }

        rectangleRequest.minimumAspectRatio = 0.5
        rectangleRequest.maximumAspectRatio = 1.5
        rectangleRequest.minimumConfidence = 0.8

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([rectangleRequest])
    }

    func detectTextAzure(cgImage: CGImage, completion: @escaping (String?) -> Void) {
        let uiImage = UIImage(cgImage: cgImage)
        let imageData = uiImage.pngData() ?? Data()
        
        self.textDetector.processText(imageData: imageData) { detectedTexts, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
            } else if let detectedTexts = detectedTexts {
                print("Detected Texts: \(detectedTexts)")
                if detectedTexts != "" {
                    print("time_after_textDetection:\(Date())")
                    completion(detectedTexts)
                } else {
                    completion("No text detected!")
                }
            } else {
                completion(nil)
            }
        }
    }

    func provideDirectionalGuidance(for rectangle: CGRect) -> String {
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

        let guideFrame = guidanceFrame
        let currentTime = Date()

        guard lastFeedbackTime == nil || currentTime.timeIntervalSince(lastFeedbackTime!) > feedbackCooldown else {
            return "Adjusting position..."
        }

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
            lastFeedbackTime = currentTime
            return feedbackText
        }
        
        return "Place the document inside the frame."
    }

    func isRectangleInsideGuide(_ rectangle: CGRect) -> Bool {
        let guideFrame = CGRect(x: 50, y: 150, width: mainView.frame.width - 100, height: mainView.frame.height / 2)
        return guideFrame.contains(rectangle)
    }
    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }
}

//extension Character {
//    var isCJKCharacter: Bool {
//        guard let scalar = self.unicodeScalars.first else {
//            return false
//        }
//        return (0x4E00...0x9FFF).contains(scalar.value) ||  // CJK Unified Ideographs
//               (0x3400...0x4DBF).contains(scalar.value) ||  // CJK Unified Ideographs Extension A
//               (0x20000...0x2A6DF).contains(scalar.value) || // CJK Unified Ideographs Extension B
//               (0x2A700...0x2B73F).contains(scalar.value) || // CJK Unified Ideographs Extension C
//               (0x2B740...0x2B81F).contains(scalar.value) || // CJK Unified Ideographs Extension D
//               (0x2B820...0x2CEAF).contains(scalar.value) || // CJK Unified Ideographs Extension E
//               (0x2CEB0...0x2EBEF).contains(scalar.value) || // CJK Unified Ideographs Extension F
//               (0xF900...0xFAFF).contains(scalar.value) ||   // CJK Compatibility Ideographs
//               (0x2F800...0x2FA1F).contains(scalar.value)    // CJK Compatibility Ideographs Supplement
//    }
//}

