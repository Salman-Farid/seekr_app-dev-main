import Foundation
import UIKit
import Vision

class ModelManager {
    static let shared = ModelManager() // Singleton instance

    private var detector: VNCoreMLModel = try! VNCoreMLModel(for: buspanel().model)
    private var currentBuffer: CVPixelBuffer?
    
    private init() {} // Private initializer to prevent external instantiation
    
//    lazy var visionRequest: VNCoreMLRequest = {
//        let request = VNCoreMLRequest(model: detector) { [weak self] request, error in
//            guard let self = self else { return }
//            self.processObservations(for: request, error: error)
//        }
//        request.imageCropAndScaleOption = .scaleFill
//        return request
//    }()
    
    func predict(pixelBuffer: CVPixelBuffer,image:UIImage, completion: @escaping ([String: Any]?) -> Void) {
        guard currentBuffer !== pixelBuffer else {
            completion(nil)
            return
        }
        
        currentBuffer = pixelBuffer

        let request = VNCoreMLRequest(model: detector) { [weak self] request, error in
            guard let self = self else { return }
            let detections = self.processObservations(for: request,image: image, error: error)
            completion(detections) // Pass detections back
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform Vision request: \(error)")
            completion(nil)
        }
    }

    
    func processObservations(for request: VNRequest,image:UIImage, error: Error?) -> [String: Any]? {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return nil }
        
        var detectionsArray: [[String: Any]] = []
        for detection in results {
            let boundingBox = detection.boundingBox
            let paddedBox = addPaddingToBoundingBox(boundingBox, padding: 50, imageSize: image.size)
            print("Normal Bounding Box\(boundingBox)")
            print("padded Bounding Box\(paddedBox)")

            let detectionData: [String: Any] = [
                "boundingBox": [
                    "x": detection.boundingBox.origin.x,
                    "y": detection.boundingBox.origin.y,
                    "width": detection.boundingBox.width,
                    "height": detection.boundingBox.height
                ],
                "confidence": detection.confidence
            ]
            detectionsArray.append(detectionData)
        }
        
        return ["detections": detectionsArray]
    }
    
    private func addPaddingToBoundingBox(_ boundingBox: CGRect, padding: CGFloat, imageSize: CGSize) -> CGRect {
        // Convert normalized bounding box to pixel coordinates
        let x = boundingBox.origin.x * imageSize.width
        let y = boundingBox.origin.y * imageSize.height
        let width = boundingBox.size.width * imageSize.width
        let height = boundingBox.size.height * imageSize.height

        // Add padding
        let paddedX = max(x - padding, 0)
        let paddedY = max(y - padding, 0)
        let paddedWidth = min(width + 2 * padding, imageSize.width - paddedX)
        let paddedHeight = min(height + 2 * padding, imageSize.height - paddedY)

        // Convert back to normalized coordinates
        let normalizedX = paddedX / imageSize.width
        let normalizedY = paddedY / imageSize.height
        let normalizedWidth = paddedWidth / imageSize.width
        let normalizedHeight = paddedHeight / imageSize.height

        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }

}
//
//extension Notification.Name {
//    static let modelPredictionCompleted = Notification.Name("modelPredictionCompleted")
//}
