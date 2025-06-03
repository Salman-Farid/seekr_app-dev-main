import UIKit
import Network
import AVFoundation
import CoreMedia
import Vision

struct SeekrObjectData {
    var depth: Float
    var location: String
    var stableCount: Int
    var lastAnnouncedFrame: Int
}

class ObstacleAvoidanceController {
    static let shared = ObstacleAvoidanceController()

    private init() {
//        setupVisionModel()
        loadClassNames()
    }
    
    let model_coco = try! VNCoreMLModel(for: yolov10m().model)
    let model_seekr = try! VNCoreMLModel(for: seekr_yolov10m().model)

    var classNames: [String] = []
    var seekrClassNames: [String] = []

    var seekrResult: [[String: Any]] = []
    var cocoResult: [[String: Any]] = []
    
    var combinedResult: [[String: Any]] = []

    var objectHistory: [String: SeekrObjectData] = [:]

    // Frame counter to track announcement timing
    var currentFrame = 0
   
    //Tracking variables
    var trackedObjects: [Int: TrackedObject] = [:]
    var objectAge: [Int: Int] = [:]
    var objectTrackingDuration: [Int: Int] = [:]
    var nextObjectID = 0
    let objectTimeoutFrames = 400

    var imageProcessingCount = 0
    var isProcessing = false
    var shouldAnnounce = false


    var currentBuffer: CVPixelBuffer?
    let streamHandler = CameraStreamHandler()
    
    var frameWidth: CGFloat = 0

      // Object classes categorized
    let movableObjects: Set<String> = [
        "person", "bicycle", "car", "motorbike", "aeroplane", "bus", "train", "truck", "boat",
        "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe",
        "Red taxi", "Minibus"
    ]

    let nonMovableObjects: Set<String> = [
        "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "backpack",
        "umbrella", "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball",
        "kite", "baseball bat", "baseball glove", "skateboard", "surfboard", "tennis racket",
        "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple",
        "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair",
        "sofa", "pottedplant", "bed", "diningtable", "toilet", "tvmonitor", "laptop", "mouse",
        "remote", "keyboard", "cell phone", "microwave", "oven", "toaster", "sink", "refrigerator",
        "book", "clock", "vase", "scissors", "teddy bear", "hair drier", "toothbrush", "MTR sign",
        "EXIT sign", "Dustbin", "Customer service sign", "Shoulder and Neck Wheel",
        "Finger Strength Trainer", "Grip Strength Trainer", "Half-circle rack",
        "Shoulder and Neck Ladder", "Bus Stops", "Elevator Buttons", "Minibus Stops", "Traffic Cones"
    ]

    
    func startStreaming() {
        self.streamHandler.startStream()
        self.walkingModeStartedAnnouncement()
        
        streamHandler.displayJPEGData = { [weak self] data in
            guard let self = self, !self.isProcessing else { return }  // Skip processing if paused
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.detectObjectsInImage(image: image)
                    self.detectObjectsInImageSeekrModel(image: image)
                }
            }
        }
    }

    
    func stopStreaming(){
        self.streamHandler.stopStream()
    }
    
    func detectObjectsInImage(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let request = VNCoreMLRequest(model: model_coco) { request, error in
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let featureValue = results.first?.featureValue,
                  featureValue.type == .multiArray,
                  let multiArray = featureValue.multiArrayValue else {
                print("Error: Unable to parse COCO model results")
                return
            }
         
            self.update(image: image, multiArray: multiArray)
        }
        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    func detectObjectsInImageSeekrModel(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let request = VNCoreMLRequest(model: model_seekr) { request, error in
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let featureValue = results.first?.featureValue,
                  featureValue.type == .multiArray,
                  let multiArray = featureValue.multiArrayValue else {
                print("Error: Unable to parse Seekr model results")
                return
            }
            
            self.update(image: image, multiArray: multiArray)

        }
        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    func loadClassNames() {
        if let cocoPath = Bundle.main.path(forResource: "coco", ofType: "names") {
            classNames = (try? String(contentsOfFile: cocoPath).components(separatedBy: .newlines)) ?? []
        }
        if let seekrPath = Bundle.main.path(forResource: "classes", ofType: "txt") {
            seekrClassNames = (try? String(contentsOfFile: seekrPath).components(separatedBy: .newlines)) ?? []
        }
    }
    
    

    func processMultiArray(_ multiArray: MLMultiArray, imageSize: CGSize, image: UIImage) -> [[String: Any]] {
        var detectedObjects: [[String: Any]] = []
        let numObjects = multiArray.shape[1].intValue

        for i in 0..<numObjects {
            let x1 = multiArray[[0, i, 0] as [NSNumber]].floatValue * Float(imageSize.width)
            let y1 = multiArray[[0, i, 1] as [NSNumber]].floatValue * Float(imageSize.height)
            let x2 = multiArray[[0, i, 2] as [NSNumber]].floatValue * Float(imageSize.width)
            let y2 = multiArray[[0, i, 3] as [NSNumber]].floatValue * Float(imageSize.height)
            let confidence = multiArray[[0, i, 4] as [NSNumber]].floatValue
            let classIndex = multiArray[[0, i, 5] as [NSNumber]].intValue

            let boxWidth = x2 - x1
            let boxHeight = y2 - y1
            let boundingBox = CGRect(x: CGFloat(x1), y: CGFloat(y1), width: CGFloat(boxWidth), height: CGFloat(boxHeight))

            if confidence > 0.8 {
                let classLabel = classNames.indices.contains(classIndex) ? classNames[classIndex] : "Unknown"
                let (depth, location) = estimateDepth(x1: x1, y1: y1, x2: x2, y2: y2, image: image, classId: classIndex, confidence: confidence)

                let detectedObject: [String: Any] = [
                    "class": classLabel,
                    "confidence": confidence,
                    "coordinates": [x1, y1, x2, y2],
                    "boundingBox": boundingBox,
                    "depth": depth,
                    "location": location
                ]
                detectedObjects.append(detectedObject)
            }
        }

        print("detected____object\(detectedObjects)")
        return detectedObjects
    }


    
    func estimateDepth(x1: Float, y1: Float, x2: Float, y2: Float, image: UIImage, classId: Int, confidence: Float) -> (Float, String) {
                let boxWidth = x2 - x1
                let boxHeight = y2 - y1
        let boundingBox = CGRect(x: CGFloat(x1), y: CGFloat(y1), width: CGFloat(boxWidth), height: CGFloat(boxHeight))

                // Object size reference
        let objHeightWidth: [String: (CGFloat, CGFloat)] = DistanceEstimator().knownObjectSizes.mapValues { ($0.height, $0.width) }


        let predData: [[CGFloat]] = [[CGFloat(x1), CGFloat(y1), CGFloat(x2), CGFloat(y2), CGFloat(confidence), CGFloat(classId)]]
        let depthEstimator = DepthEstimator()
        let classNames = self.classNames.isEmpty ? self.seekrClassNames : self.classNames
        let estimatedObjects = depthEstimator.depthEstimation(image: image, predData: predData, classNames: classNames, objHeightWidth: objHeightWidth, mode: "depth estimation")
        if let firstObject = estimatedObjects.first {
            return (Float(firstObject.distance), firstObject.location)
        }
        return (0.0, "")
    }
    
    func speak(_ textToRead: String) {
        SpeechManager.shared.speak(text: textToRead)
    }
}


extension ObstacleAvoidanceController{
    
    func update(image: UIImage, multiArray: MLMultiArray) {
        guard !isProcessing else { return } // Skip processing if paused

        let detections = processMultiArray(multiArray, imageSize: image.size, image: image)

        if detections.isEmpty {
            return  // If no objects detected, continue processing normally
        }

        // Pause frame processing for 2 seconds
        isProcessing = true

        let frameWidth = image.size.width
        let walkingZoneMinX = frameWidth / 3
        let walkingZoneMaxX = 2 * frameWidth / 3

        for detection in detections {
            guard let boundingBox = detection["boundingBox"] as? CGRect,
                  let className = detection["class"] as? String,
                  let depth = detection["depth"] as? Float,
                  let location = detection["location"] as? String else {
                continue
            }

            let objectCenterX = boundingBox.midX
            let isMovable = movableObjects.contains(className)
            let isNonMovable = nonMovableObjects.contains(className)
            let isInWalkingZone = (objectCenterX >= walkingZoneMinX && objectCenterX <= walkingZoneMaxX)
            let isInLeftZone = (objectCenterX < walkingZoneMinX)
            let isInRightZone = (objectCenterX > walkingZoneMaxX)

            // **New Announcement Logic Before Calling `announceObject`**

            if isInWalkingZone && depth < 1.5{
                shouldAnnounce = true // Announce any object in the Walking Zone
            } else if isMovable && depth < 1.5 && (isInLeftZone || isInRightZone) {
                shouldAnnounce = true // Announce if a movable object is approaching the Walking Zone
            }else{
                shouldAnnounce = false
            }

            // **Only Announce if Passed the New Logic**
            if shouldAnnounce {
                if let previousData = objectHistory[className],
                   abs(previousData.depth - depth) < 0.5,
                   previousData.location == location {
                    objectHistory[className]?.stableCount += 1

                    if objectHistory[className]!.stableCount >= 400 {
                        announceObject(className: className, depth: depth, location: location)
                        objectHistory[className]?.lastAnnouncedFrame = currentFrame
                        // Save image after successful detection
                        self.saveImageToDisk(image: image, detecteName: className)
                    }

                } else {
                    objectHistory[className] = SeekrObjectData(depth: depth, location: location, stableCount: 1, lastAnnouncedFrame: currentFrame)
                    announceObject(className: className, depth: depth, location: location)
                    // Save image after successful detection
                    self.saveImageToDisk(image: image, detecteName: className)
                }
            }
        }

        // Resume processing after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.isProcessing = false
        }
    }


    

    func announceObject(className: String, depth: Float, location: String) {
//        let outputString = "Within \(Int(depth)) meters you have a \(className) at your \(location)."
        let outputString = "\(className), \(Int(depth)) meter at \(location)."
        speak(outputString)
        print(outputString)
    }
    
    private func matchDetectionWithTrackedObject(_ detection: CGRect) -> Int? {
        for (id, trackedObject) in trackedObjects {
            // Calculate IoU (Intersection over Union)
            let intersection = trackedObject.boundingBox.intersection(detection)
            let union = trackedObject.boundingBox.union(detection)
            let iou = intersection.area / union.area
            
            if iou > 0.5 { // If IoU is above threshold, it's considered a match
                return id
            }
        }
        return nil
    }
    

    private func removeStaleObjects() {
        trackedObjects.keys.forEach { id in
            objectAge[id, default: 0] += 1
            if objectAge[id]! > objectTimeoutFrames {
                trackedObjects.removeValue(forKey: id)
                objectAge.removeValue(forKey: id)
                objectTrackingDuration.removeValue(forKey: id)
            }
        }
    }
    
}

extension CGRect {
    var area: CGFloat {
        return self.width * self.height
    }
}


extension ObstacleAvoidanceController{
    func walkingModeStartedAnnouncement() {
           let selectedLanguage = AppUserDefault.getSelectedLanguage() ?? ""

           if selectedLanguage == "en_US" {
               speak("Walking mode started")
           } else if selectedLanguage == "ja_JP" {
               speak("歩行モードが開始されました") // Choose a museum
           } else if selectedLanguage == "es_ES" {
               speak("Modo de caminar iniciado") // Choose a museum
           } else if selectedLanguage == "ko_KR" {
               speak("걷기 모드가 시작되었습니다") // Choose a museum
           } else if selectedLanguage == "tl_PH" {
               speak("Nagsimula ang mode ng paglalakad") // Choose a museum
           } else if selectedLanguage == "ms_MY" {
               speak("Modus berjalan telah dimulakan") // Choose a museum
           } else {
               speak("步行模式已啟動") // Chinese (fallback) - Choose a museum
           }
       }
    
    func saveImageToDisk(image: UIImage, detecteName:String) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(detecteName)_\(Date()).jpg")
            try? data.write(to: filename)
            print("Image saved at: \(filename)")
        }
    }


    // Helper to get documents directory for saving images
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
