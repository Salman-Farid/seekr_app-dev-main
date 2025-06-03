//
//  DevelopmentUtility.swift
//  Runner
//
//  Created by Ahnaf Rahat on 31/5/25.
//


class DevelopmentUtility{
    
    
        func fetchCameraData(){
    
            let urlString = "http://192.168.1.254:8192"
    
            guard let url = URL(string: urlString) else {
              print("Error: Invalid URL format")
              // Handle the error
              return
            }
    
            var request = URLRequest(url: url)
            // You can optionally set additional request properties here,
            // like headers or timeout interval
    
            do {
                if #available(iOS 15.0, *) {
                    async {
                        let (data, response) = try await URLSession.shared.bytes(for: request)
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            print("Error: Failed to fetch data. Status code:")
                            // Handle the error
                            return
                        }
    
                        for try await line in data.lines {
                            print("line_____________________")
                            print(String(line.utf8)) // Use String.init(_:) with line.utf8
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            } catch {
              print("Error: \(error)")
              // Handle the error
            }
    
            print("Fetching data...")
    
        }
    
    
    
    func testLocalImagePrediction() {
        guard let image = UIImage(named: "bus_image101.jpg") else {
            print("Failed to load image")
            return
        }
        
        guard let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) else {
            print("Failed to convert image to pixel buffer")
            return
        }

        ModelManager.shared.predict(pixelBuffer: pixelBuffer, image:image) { result in
            if let detections = result {
                print("Model Detections: \(detections)")
            } else {
                print("No detections found.")
            }
        }
    }
    
    
    
    func testLocalImageObstacle() {
        guard let image = UIImage(named: "bus_image101.jpg") else {
            print("Failed to load image")
            return
        }
        
        ObstacleAvoidanceManager.shared.processImage(image: image) { result in
            print("Obstacle Avoidance Output: \(result)")
        }
    }
}
