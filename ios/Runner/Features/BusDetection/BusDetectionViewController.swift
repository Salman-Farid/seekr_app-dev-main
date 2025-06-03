import UIKit
import Network
import AVFoundation
import CoreMedia
import Vision

struct TrackedObject {
    var trackingId: Int
    var boundingBox: CGRect
    var label: String
}


class BusDetectionViewController {
    static let shared = BusDetectionViewController()

    private init() {
        setupVisionModel()
//        setupBoundingBoxViews()
    }
    
    var mlModel = try! bus_panel_latest(configuration: .init()).model


    var currentBuffer: CVPixelBuffer?
    let streamHandler = CameraStreamHandler()

    // Vision model and request setup
    var detector = try! VNCoreMLModel(for: bus_panel_latest().model)
    var framesDone = 0
    var t0 = 0.0  // inference start
    var t1 = 0.0  // inference dt
    var t2 = 0.0  // inference dt smoothed
    var t3 = CACurrentMediaTime()  // FPS start
    var t4 = 0.0

    let maxBoundingBoxViews = 100
    var boundingBoxViews = [BoundingBoxView]()
    var colors: [String: UIColor] = [:]
    var busPanelDetector: BusPanelDetector?
    let textDetector = TextDetector()
    let busPanelModel = try! VNCoreMLModel(for: bus_panel_latest().model)
    let busNumberModel = try! VNCoreMLModel(for: bus_number_v2().model)


    private var trackedObjects: [Int: TrackedObject] = [:]
    private var nextObjectID: Int = 0
    private var objectTimeoutFrames: Int = 30
    private var objectAge: [Int: Int] = [:]
    private var objectTrackingDuration: [Int: Int] = [:]

    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: detector) { [weak self] request, error in
            self?.processObservations(for: request, error: error)
        }
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()

    func setupVisionModel() {
        busPanelDetector = BusPanelDetector(busPanelModel: busPanelModel, textDetector: textDetector, busNumberModel: busNumberModel)
    }

    func setupBoundingBoxViews() {
        while boundingBoxViews.count < maxBoundingBoxViews {
            let boxView = BoundingBoxView()
            boundingBoxViews.append(boxView)
        }

        guard let classLabels = mlModel.modelDescription.classLabels as? [String] else {
            fatalError("Class labels are missing from the model description")
        }

        for label in classLabels {
            if colors[label] == nil {
                colors[label] = UIColor(
                    red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1),
                    alpha: 0.6
                )
            }
        }
    }

    func startStreaming() {
        self.streamHandler.startStream()
        self.speak("Bus detection mode started!")
        streamHandler.displayJPEGData = { [weak self] data in
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    print("stream transferred to viewcontroller")
                    self?.runMLModel(on: image)
                }
            }
        }
    }
    
    
    func stopStreaming(){
        self.streamHandler.stopStream()
    }

    private func runMLModel(on image: UIImage) {
        guard let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) else { return }
        predict(pixelBuffer: pixelBuffer)
    }

    func processObservations(for request: VNRequest, error: Error?) {
        if let results = request.results as? [VNRecognizedObjectObservation] {
            print("Number of detections: \(results.count)")
            _ = update(detections: results)
        }
    }

//    func update(detections: [VNRecognizedObjectObservation]) -> [TrackedObject] {
//        var updatedObjects: [TrackedObject] = []
//
//        for detection in detections {
//            let matchingObjectID = matchDetectionWithTrackedObject(detection)
//
//            if let objectID = matchingObjectID {
//                currentBuffer = nil
//                trackedObjects[objectID]?.boundingBox = detection.boundingBox
//                objectAge[objectID] = 0
//                objectTrackingDuration[objectID, default: 0] += 1
//            } else {
//                let newObject = TrackedObject(
//                    trackingId: nextObjectID,
//                    boundingBox: detection.boundingBox,
//                    label: detection.labels.first?.identifier ?? "Unknown"
//                )
//                trackedObjects[nextObjectID] = newObject
//                objectAge[nextObjectID] = 0
//                updatedObjects.append(newObject)
//                nextObjectID += 1
//            }
//        }
//
//        removeStaleObjects()
//        return Array(trackedObjects.values)
//    }
    
    func update(detections: [VNRecognizedObjectObservation]) -> [TrackedObject] {
        var updatedObjects: [TrackedObject] = []

        // Step 1: Match new detections with existing tracked objects
        for detection in detections {
            let matchingObjectID = matchDetectionWithTrackedObject(detection)

            if let objectID = matchingObjectID {
                currentBuffer = nil

                // If we found a match, update the tracked object
                trackedObjects[objectID]?.boundingBox = detection.boundingBox
                objectAge[objectID] = 0 // Reset the "age" since we've seen it again
                

                objectTrackingDuration[objectID, default: 0] += 1
                
                print("Object \(objectID) is being tracked for \(objectTrackingDuration[objectID]!) frames.")
                if let trackingDuration = objectTrackingDuration[objectID] {
                    if trackingDuration > 200 && trackingDuration % 200 == 0 {
                        // Call captureFullFrameImage() after every 40 frames
                        captureFullFrameImage()
                        print("captureFullFrameImage() called for object \(objectID) at frame \(trackingDuration).")
                    }
                }
            } else {
                // If no match, assign a new ID to this object
                let newObject = TrackedObject(
                    trackingId: nextObjectID,
                    boundingBox: detection.boundingBox,
                    label: detection.labels.first?.identifier ?? "Unknown"
                )
                trackedObjects[nextObjectID] = newObject
                objectAge[nextObjectID] = 0 // New object starts with age 0
                updatedObjects.append(newObject) // It's a new object, capture it
                nextObjectID += 1 // Increment the ID counter for the next new object

                // Call captureObjectImage() for new detection
                captureFullFrameImage()
                print("Capture Image Called")
            }
        }

        // Step 2: Remove stale objects that haven't been detected for a while
        removeStaleObjects()

        // Return the list of currently tracked objects
        return Array(trackedObjects.values)
    }

    private func matchDetectionWithTrackedObject(_ detection: VNRecognizedObjectObservation) -> Int? {
        for (id, trackedObject) in trackedObjects {
            if trackedObject.boundingBox.intersects(detection.boundingBox) {
                return id
            }
        }
        return nil
    }

    private func removeStaleObjects() {
        trackedObjects.keys.forEach { id in
            objectAge[id, default: 0] += 1
            if objectAge[id]! > objectTimeoutFrames {
                trackedObjects[id] = nil
                objectAge[id] = nil
            }
        }
    }

 
}


extension BusDetectionViewController {
    func predict(pixelBuffer: CVPixelBuffer) {
        guard currentBuffer !== pixelBuffer else { return }
        
        currentBuffer = pixelBuffer
        let imageOrientation: CGImagePropertyOrientation = {
//            switch UIDevice.current.orientation {
//            case .portrait: return .up
//            case .portraitUpsideDown: return .down
//            case .landscapeLeft, .landscapeRight, .unknown: return .up
//            default:
                
            return .up
//            }
        }()
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: imageOrientation, options: [:])
//        if UIDevice.current.orientation != .faceUp {
            t0 = CACurrentMediaTime()
            do {
                try handler.perform([visionRequest])
            } catch {
                print("Failed to perform Vision request: \(error)")
            }
            t1 = CACurrentMediaTime() - t0
//        }
    }
    
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }
    
//    private func askForPermission() {
//        let params = NWParameters()
//        let browser = NWBrowser(for: .bonjour(type: "_http._tcp", domain: nil), using: params)
//
//        browser.stateUpdateHandler = { [weak self] newState in
//            switch newState {
//            case .ready:
//                print("Permission granted")
//                self.streamHandler.startStream()
//                
//                // Setup bounding boxes
//                self?.setUpBoundingBoxViews()
//                browser.cancel()
//            case .failed(let error):
//                print("Browser failed with error: \(error)")
//                browser.cancel()
//            default:
//                break
//            }
//        }
//
//        browser.start(queue: .main)
//    }
    
}

extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ), let cgImage = self.cgImage else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return buffer
    }
    
       
}


extension BusDetectionViewController {
    func captureFullFrameImage() {
        print("Full frame Image Capture Called \(currentBuffer)")
        guard let pixelBuffer = currentBuffer else { return }
        currentBuffer = nil
        
        // Create CIImage from pixelBuffer
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Enhance brightness and contrast to make LED panels more visible
        let enhancedImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                kCIInputBrightnessKey: 0.1, // Adjust as needed
                kCIInputContrastKey: 1.2 // Adjust as needed
            ])
        
        // Convert the enhanced CIImage to UIImage
        let context = CIContext()
        if let cgImage = context.createCGImage(enhancedImage, from: enhancedImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            
            // Print image info to console
            print("Captured full frame image size: \(uiImage.size)")
//            self.saveImageToDisk(image: uiImage)
            
            // Detect bus panel and number
            busPanelDetector?.detectBusPanelAndNumber(image: uiImage) { [weak self] detectedText, croppedImage in
                DispatchQueue.main.async {
                    // Update your UI with the detection results
                    //                    self?.resultLabel.text = detectedText
                    print("Bus panel detected")
                    
                    print("Detected Bus Number: \(detectedText)")
                    
                    if detectedText != nil && detectedText != ""{
                        let stringToPlay = "Bus number \(detectedText) is approaching."
                        self?.speak(stringToPlay)
                    }
//                    else if detectedText != nil && detectedText == ""{
//                        let stringToPlay = "Bus detected but the number plate is not clear"
//                        self?.speak(stringToPlay)
//                    }
                    
                    
                    
                    
                    if let busImage = croppedImage {
                        // Do something with the cropped image, like displaying it
                        self?.saveImageToDisk(image: busImage)
                        
                    } else {
                        print("No bus panel detected")
                    }
                }
            }
        } else {
            print("Failed to convert enhanced image to CGImage.")
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
