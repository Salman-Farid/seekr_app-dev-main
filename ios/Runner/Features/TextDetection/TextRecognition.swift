import UIKit
import AVFoundation
import Vision

class TextDetector {
    func processBusText(imageData: Data, observation: VNRecognizedObjectObservation, completion: @escaping (String?, Error?) -> Void) {
        let boundingBox = observation.boundingBox

        let path = "https://vidiazure.cognitiveservices.azure.com/computervision/imageanalysis:analyze?api-version=2023-10-01"
        
        guard let url = URL(string: path) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("b7e373dc1615410d86a06639e8e87b43", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        request.httpBody = imageData

        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("json_printed__textDetection\(json)")
                print("bounding_box_for_bus_panel\(boundingBox)")

                guard
                    let readResult = json?["readResult"] as? [String: Any],
                    let blocks = readResult["blocks"] as? [[String: Any]],
                    let metadata = json?["metadata"] as? [String: Any],
                    let imageWidth = metadata["width"] as? CGFloat,
                    let imageHeight = metadata["height"] as? CGFloat
                else {
                    completion("No text detected", nil)
                    return
                }

                // Convert normalized bounding box to image coordinates
                let rectX = boundingBox.origin.x * imageWidth
                let rectY = (1 - boundingBox.origin.y - boundingBox.size.height) * imageHeight
                let rectWidth = boundingBox.size.width * imageWidth
                let rectHeight = boundingBox.size.height * imageHeight
                let detectionRect = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)

                var includedTexts: [String] = []

                for block in blocks {
                    guard let lines = block["lines"] as? [[String: Any]] else { continue }

                    for line in lines {
                        guard let lineText = line["text"] as? String,
                              let polygonPoints = line["boundingPolygon"] as? [[String: CGFloat]]
                        else { continue }

                        // Check if all polygon points lie within the bounding box
                        let allPointsInside = polygonPoints.allSatisfy { point in
                            guard let x = point["x"], let y = point["y"] else { return false }
                            return detectionRect.contains(CGPoint(x: x, y: y))
                        }

                        if allPointsInside {
                            includedTexts.append(lineText)
                        }
                    }
                }

                let finalText = includedTexts.joined(separator: " ")
                completion(finalText.isEmpty ? "No matching text inside bounding box" : finalText, nil)

            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }

    
    func processText(imageData: Data, completion: @escaping (String?, Error?) -> Void) {
        let path = "https://vidiazure.cognitiveservices.azure.com/computervision/imageanalysis:analyze?features=read&model-version=latest&language=en&gender-neutral-caption=false&api-version=2023-10-01"
        
        let array: [String] = [
            "features=read",
            "model-version=latest",
            "language=en",
            "gender-neutral-caption=false",
        ]
        
        let string = array.joined(separator: "&")
        let fullPath = path + "?" + string
        
        print(fullPath)
        
        guard let url = URL(string: path) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("b7e373dc1615410d86a06639e8e87b43", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        

        request.httpBody = Data(imageDataToUInt8List(imageData: imageData))
        
        
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            guard let data = data, error == nil else {
                print("data_printed__textDetection\(data)")
                print("error_printed__textDetection\(error)")

                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("data_printed__textDetection\(data)")
                print("json_printed__textDetection\(json)")

                if let readResult = json?["readResult"] as? [String: Any], let blocks = readResult["blocks"] as? [[String: Any]] {
                    let text = blocks.map { block -> String in
                        if let lines = block["lines"] as? [[String: Any]] {
                            return lines.map { line -> String in
                                if let text = line["text"] as? String {
                                    return text
                                } else {
                                    return ""
                                }
                            }.joined(separator: " ")
                        } else {
                            return ""
                        }
                    }.joined(separator: " ")
                    completion(text, nil)
                } else {
                    completion("No text detected", nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    private func imageOrientation(deviceOrientation: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        }
    }
}



extension TextDetector{
    func imageDataToUInt8List(imageData: Data) -> [UInt8] {
        // Get a pointer to the raw data in the imageData
        let dataPointer = (imageData as NSData).bytes.bindMemory(to: UInt8.self, capacity: imageData.count)

        // Convert the pointer to an array
        let uint8Array = UnsafeBufferPointer(start: dataPointer, count: imageData.count).map { $0 }

        return uint8Array
    }
}
