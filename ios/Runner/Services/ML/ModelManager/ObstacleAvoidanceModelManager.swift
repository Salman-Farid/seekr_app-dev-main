import UIKit
import Vision
import CoreML

class ObstacleAvoidanceManager {
    static let shared = ObstacleAvoidanceManager()
    
    private init() {
        loadClassNames()
    }
    
    let modelCOCO = try! VNCoreMLModel(for: yolov10m().model)
    let modelSeekr = try! VNCoreMLModel(for: seekr_yolov10m().model)
    
    var classNames: [String] = []
    var seekrClassNames: [String] = []
    var objectHistory: [String: SeekrObjectData] = [:]
    var isProcessing = false
    var currentFrame = 0
    
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
    
    func processImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard !isProcessing else {
            completion(nil)
            return
        }
        isProcessing = true
        
        let dispatchGroup = DispatchGroup()
        var finalMessage: String?
        
        dispatchGroup.enter()
        detectObjects(image: image, model: modelCOCO) { message in
            if let msg = message {
                finalMessage = msg
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        detectObjects(image: image, model: modelSeekr) { message in
            if let msg = message {
                finalMessage = msg
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isProcessing = false
            completion(finalMessage)
        }
    }
    
    private func detectObjects(image: UIImage, model: VNCoreMLModel, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let featureValue = results.first?.featureValue,
                  featureValue.type == .multiArray,
                  let multiArray = featureValue.multiArrayValue else {
                completion(nil)
                return
            }
            
            let detectedObjects = self.processMultiArray(multiArray, imageSize: image.size, image: image)
            let message = self.generateObstacleMessage(from: detectedObjects)
            completion(message)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    private func generateObstacleMessage(from detections: [[String: Any]]) -> String? {
        for detection in detections {
            guard let className = detection["class"] as? String,
                  let depth = detection["depth"] as? Float,
                  let location = detection["location"] as? String else {
                continue
            }
            
            if let previousData = objectHistory[className],
               abs(previousData.depth - depth) < 0.5,
               previousData.location == location {
                objectHistory[className]?.stableCount += 1
                
                if objectHistory[className]!.stableCount >= 400 {
//                    return "Within \(Int(depth)) meters you have a \(className) at your \(location)."
                    return "\(className), \(Int(depth)) meter at \(location)."
                }
            } else {
                objectHistory[className] = SeekrObjectData(depth: depth, location: location, stableCount: 1, lastAnnouncedFrame: currentFrame)
                return "\(className), \(Int(depth)) meter at \(location)."
            }
        }
        return nil
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
                self.saveImageToDisk(image: image, detecteName: classLabel)
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
