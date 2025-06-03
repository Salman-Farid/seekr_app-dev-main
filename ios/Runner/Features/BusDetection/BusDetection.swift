import Vision
import UIKit

class BusPanelDetector {
    var busPanelModel: VNCoreMLModel
    var busNumberModel: VNCoreMLModel

    var textDetector: TextDetector
    var croppedImages = [UIImage]()
    
    // Init with required models
    init(busPanelModel: VNCoreMLModel, textDetector: TextDetector, busNumberModel: VNCoreMLModel) {
        self.busPanelModel = busPanelModel
        self.textDetector = textDetector
        self.busNumberModel = busNumberModel
    }

    // Main function to detect bus panel and bus number
    func detectBusPanelAndNumber(image: UIImage, completion: @escaping (String, UIImage?) -> Void) {
        guard let cgImage = image.cgImage else { return }
        
        let busPanelRequest = VNCoreMLRequest(model: busPanelModel) { (request, error) in
            if let results = request.results as? [VNRecognizedObjectObservation], let observation = results.first {
                self.processBusPanelDetection(observation: observation, image: image, completion: completion)
            } else {
                completion("", nil)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([busPanelRequest])
    }

    // Process bus panel detection and detect bus number
    private func processBusPanelDetection(observation: VNRecognizedObjectObservation, image: UIImage, completion: @escaping (String, UIImage?) -> Void) {
        let boundingBox = observation.boundingBox
        let confidence = observation.confidence
        let paddedBox = addPaddingToBoundingBox(boundingBox, padding: 50, imageSize: image.size)

        if confidence > 0.5 {
            guard let cgImage = image.cgImage else {
                completion("", nil)
                return
            }

            if let croppedImage = cropImage(cgImage: cgImage, boundingBox: paddedBox) {
                self.saveImageToDisk(image: croppedImage)

//                let paddedImage = addPaddingToImage(image: croppedImage, padding: 50)

                if isImageDimensionValid(image: croppedImage) {
                    croppedImages.append(croppedImage)
                    detectBusNumberOcr(croppedImage: croppedImage, observation: observation) { detectedBusNumber in
                        print("Detected_______Bus________Number_____\(detectedBusNumber)🚌🚌🚌🚌🚌🚌")
                        completion("\(detectedBusNumber)", croppedImage)
                    }
                } else {
                    completion("", nil)
                }
            }
        } else {
            print("Low confidence for bus panel detection.")
            completion("", nil)
        }
    }
    
//    private func processBusPanelDetection(observation: VNRecognizedObjectObservation, image: UIImage, completion: @escaping (String, UIImage?) -> Void) {
//        let boundingBox = observation.boundingBox
//        let confidence = observation.confidence
//        let paddedBox = addPaddingToBoundingBox(boundingBox, padding: 50, imageSize: image.size)
//
//        if confidence > 0.5 {
//            guard let cgImage = image.cgImage else {
//                completion("", nil)
//                return
//            }
//
//            if let croppedImage = cropImage(cgImage: cgImage, boundingBox: boundingBox) {
//                self.saveImageToDisk(image: croppedImage)
//
////                let paddedImage = addPaddingToImage(image: croppedImage, padding: 50)
//                
//                if let rightHalf = cropRightHalfOfImage(image: croppedImage) {
//                    self.saveImageToDisk(image: rightHalf)
//                    self.interactWithBusNumberModel(image: rightHalf) { resultText, croppedImage in
//                        //                            self.saveImageToDisk(image: croppedImage)
//                        if let detectedImage = croppedImage {
//                            self.saveImageToDisk(image: detectedImage)
//                        }
//                        print("Model___Detected_______Bus________Number_____\(resultText)")
//                        
//                    }
//                }
//
//                if isImageDimensionValid(image: croppedImage) {
//                    croppedImages.append(croppedImage)
//                    detectBusNumberOcr(croppedImage: croppedImage, observation: observation) { detectedBusNumber in
//                        print("Detected_______Bus________Number_____\(detectedBusNumber)🚌🚌🚌🚌🚌🚌")
//                        completion("\(detectedBusNumber)", croppedImage)
//                    }
//                } else {
//                    completion("", nil)
//                }
//            }
//        } else {
//            print("Low confidence for bus panel detection.")
//            completion("", nil)
//        }
//    }

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

    
    private func addPaddingToImage(image: UIImage, padding: CGFloat) -> UIImage {
        let newSize = CGSize(width: image.size.width + 2 * padding, height: image.size.height + 2 * padding)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        let origin = CGPoint(x: padding, y: padding)
        image.draw(at: origin)
        
        let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.saveImageToDisk(image: paddedImage ?? image)
        
        return paddedImage ?? image
    }


    // Crop image based on bounding box
    private func cropImage(cgImage: CGImage, boundingBox: CGRect) -> UIImage? {
        let adjustedCropRect = CGRect(
            x: boundingBox.origin.x * CGFloat(cgImage.width),
            y: (1 - boundingBox.origin.y - boundingBox.height) * CGFloat(cgImage.height),
            width: boundingBox.width * CGFloat(cgImage.width),
            height: boundingBox.height * CGFloat(cgImage.height)
        )
        
        guard let croppedCGImage = cgImage.cropping(to: adjustedCropRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage)
    }

    // Crop right half of the image
    private func cropRightHalfOfImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let rightHalfRect = CGRect(x: cgImage.width / 2, y: 0, width: cgImage.width / 2, height: cgImage.height)
        
        guard let croppedCGImage = cgImage.cropping(to: rightHalfRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage)
    }

    // Check if image dimensions are valid
    private func isImageDimensionValid(image: UIImage) -> Bool {
        let width = image.size.width
        let height = image.size.height
        return width >= 50 && width <= 16000 && height >= 50 && height <= 16000
    }

    // Extract bus number using regex
    private func extractBusNumber(from detectedText: String) -> String? {
        let pattern = "\\d+[A-Za-z]?"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = detectedText as NSString
            let matches = regex.matches(in: detectedText, range: NSRange(location: 0, length: nsString.length))
            
            if let match = matches.first {
                return nsString.substring(with: match.range)
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }
        
        return nil
    }

    // Detect bus number using OCR
    private func detectBusNumberOcr(croppedImage: UIImage, observation:VNRecognizedObjectObservation, completion: @escaping (String) -> Void) {

        if let imageData = croppedImage.jpegData(compressionQuality: 1.0) {
            textDetector.processText(imageData: imageData) { detectedTexts, error in
                print("Detected_OCR_Text_Data\(detectedTexts)")
                if let error = error {
                    print("Error: \(error)")
                    completion("")
                } else if let detectedTexts = detectedTexts {
                    let filterText = self.extractBusNumber(from: detectedTexts) ?? ""
                    print("filterred__text\(filterText)")
                    print("non__filterred__text\(detectedTexts)")

                    completion(filterText)
                }
            }
        } else {
            print("Error: Could not convert UIImage to JPEG data.")
            completion("")
        }
    }
}


extension BusPanelDetector {
    func saveImageToDisk(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            let filename = getDocumentsDirectory().appendingPathComponent("before_ocr_bounding_box_new_\(Date()).jpg")
            try? data.write(to: filename)
            print("Image saved at: \(filename)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func interactWithBusNumberModel(image: UIImage, completion: @escaping (String, UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("", nil)
            return
        }

        let busPanelRequest = VNCoreMLRequest(model: busNumberModel) { (request, error) in
            print("✅ Bus_Number_Model_Request: \(request)")
            print("✅ ✅ ✅ Bus_Number_Model_Result: \(String(describing: request.results))")
            print("❌ Bus_Number_Model_error: \(String(describing: error))")

            guard let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty else {
                completion("", nil)
                return
            }

            // Mimicking the Python logic: sort, crop to right half, and extract text
            let imageSize = CGSize(width: image.size.width, height: image.size.height)

            // Optional: apply filtering like confidence threshold if needed
            let filteredResults = results.filter { $0.confidence > 0.7 }

            if filteredResults.isEmpty {
                completion("", nil)
                return
            }

            // In your case you're taking the right-half cropped region as AOI
            let observations: [VNRecognizedObjectObservation] = filteredResults

            let busNumberText = self.getFinalBusNumberString(from: observations, imageSize: imageSize)

            print("🚌 Detected Bus Number: \(busNumberText)")

            // Optional: apply whitelist match logic if required here too
            completion(busNumberText, image)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([busPanelRequest])
        } catch {
            print("❌ Error performing request: \(error)")
            completion("", nil)
        }
    }


    
    func getFinalBusNumberString(from observations: [VNRecognizedObjectObservation], imageSize: CGSize) -> String {
        // Filter out low confidence detections
        let confidenceThreshold: VNConfidence = 0.5
        let filtered = observations.filter { $0.confidence > confidenceThreshold }

        // Define Area of Interest (AOI): right half of the image
        let aoiMinX: CGFloat = 0.5

        // Convert bounding boxes to normalized coordinates and filter to right half
        let rightHalfBoxes = filtered.filter {
            let box = $0.boundingBox
            // Ensure box is in right half of the image (normalized coordinates)
            return box.origin.x >= aoiMinX
        }

        // Sort remaining boxes from left to right
        let sorted = rightHalfBoxes.sorted {
            $0.boundingBox.origin.x < $1.boundingBox.origin.x
        }

        // Construct bus number string
        var finalResult = ""
        for observation in sorted {
            if let topLabel = observation.labels.first {
                finalResult += topLabel.identifier
            }
        }

        return finalResult
    }

}
