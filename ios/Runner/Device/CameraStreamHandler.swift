import Foundation
import UIKit

class CameraStreamHandler: NSObject, NSURLConnectionDataDelegate {
    var connection: NSURLConnection?
    var receivedData: Data = Data()
    var boundary: String? = nil

    // Define displayJPEGData as a closure property to handle JPEG data
    var displayJPEGData: ((Data) -> Void)?
    
    func startStream() {
        if let currentConnection = connection {
            currentConnection.cancel()
            connection = nil
            buffer.removeAll()
            print("Stream stopped and re opened")
            self.startStreamInternal()
        } else {
            print("Stream is not currently open.")
            self.startStreamInternal()
        }
    }
    
    func startStreamInternal() {
        if let url = URL(string: "http://192.168.1.254:8192/") {
            let request = URLRequest(url: url)
            connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        } else {
            print("Invalid URL.")
        }
    }
    
    func stopStream() {
        if let currentConnection = connection {
            currentConnection.cancel()
            connection = nil
            buffer.removeAll()
            print("Stream stopped.")
        } else {
            print("Stream is not currently open.")
        }
    }
    
    
    // MARK: - NSURLConnectionDataDelegate Methods
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse,
              let contentType = httpResponse.allHeaderFields["Content-Type"] as? String else {
            print("Failed to get Content-Type.")
            return
        }
        
        print("Received Content-Type: \(contentType)")
        
        // Set boundary only if it's not already set
        if boundary == nil, let boundaryRange = contentType.range(of: "boundary=") {
            boundary = String(contentType[boundaryRange.upperBound...])
            print("Boundary: \(boundary!)")
        }
    }

    var buffer = Data()

    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        buffer.append(data)

        // JPEG start and end markers
        let jpegStart: [UInt8] = [0xFF, 0xD8]
        let jpegEnd: [UInt8] = [0xFF, 0xD9]

        // Convert markers to Data for easier searching
        let startMarker = Data(jpegStart)
        let endMarker = Data(jpegEnd)

        // Process images by detecting start and end markers
        while let startRange = buffer.range(of: startMarker),
              let endRange = buffer.range(of: endMarker, options: [], in: startRange.upperBound..<buffer.endIndex) {

            // Extract JPEG image data
            let imageData = buffer.subdata(in: startRange.lowerBound..<endRange.upperBound)

            // Process the image data
            processImageData(imageData)

            // Remove processed data from buffer
            buffer.removeSubrange(buffer.startIndex..<endRange.upperBound)
        }
    }

    func processImageData(_ imageData: Data) {
        // Convert image data to UIImage or handle it as required
        displayJPEGData?(imageData)

        if let image = UIImage(data: imageData) {
            print("Received an image with size: \(image.size)")
        } else {
            print("Failed to create image from data.")
        }
    }
    

    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("Connection failed with error: \(error.localizedDescription)")
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        print("Connection finished.")
    }
   
}
