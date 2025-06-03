//
//  Helper.swift
//  Runner
//
//  Created by Ahnaf Rahat on 15/12/23.
//

import UIKit
import SWXMLHash
import SwiftSoup

class Helper {

    func getDeviceData() -> Bool {
        let urlString = "http://192.168.1.254/?custom=1&cmd=3016"
        if let url = URL(string: urlString) {
            var result = false
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        result = true
                    }
                    
                    if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                }
                
                semaphore.signal()
            }

            task.resume()
            
            _ = semaphore.wait(timeout: .now() + 5)
            
            return result
        } else {
            print("Invalid URL")
            return false
        }
    }
    
    
    func getBatteryStatus(completion: @escaping (Int) -> Void) {
        let urlString = "http://192.168.1.254/?custom=1&cmd=3019"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    completion(-1)
                } else if let data = data {
                    do {
                        let xml = try XMLHash.parse(data)
                        if let status = xml["Function"]["Value"].element?.text, let statusCode = Int(status) {
                            print("battery status: \(statusCode)")
                            completion(statusCode)
                        } else {
                            completion(-1)
                        }
                    } catch {
                        print("Error parsing XML: \(error)")
                        completion(-1)
                    }
                }
            }
            task.resume()
        } else {
            print("Invalid URL")
            completion(-1)
        }
    }
    
    
//    func switchDeviceToPhotoMode() {
//        let url = URL(string: "http://192.168.1.254/?custom=1&cmd=3016")!
//
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print("Error: \(error)")
//            } else if let data = data {
//                do {
//                    let xml = try XMLHash.parse(data)
//                    if let status = xml["Function"]["Status"].element?.text, let statusCode = Int(status), statusCode == 1 {
//                        let url2 = URL(string: "http://192.168.1.254/?custom=1&cmd=3001&par=0")!
//                        URLSession.shared.dataTask(with: url2).resume()
//                    }
//                } catch {
//                    print("Error parsing XML: \(error)")
//                }
//
//                let now = Date()
//                let formatter = DateFormatter()
//                formatter.dateFormat = "HH:mm:ss"
//                let timeStr = formatter.string(from: now)
//                print("Timestamp: \(timeStr)")
//
//                let dateString = String(format: "%04d-%02d-%02d", now.year, now.month, now.day)
//                let url3 = URL(string: "http://192.168.1.254/?custom=1&cmd=3005&str=\(dateString)")!
//                URLSession.shared.dataTask(with: url3).resume()
//
//                let url4 = URL(string: "http://192.168.1.254/?custom=1&cmd=3006&str=\(timeStr)")!
//                URLSession.shared.dataTask(with: url4).resume()
//            }
//        }
//
//        task.resume()
//    }
    func switchDeviceToVgaMode() {
        let url = URL(string: "http://192.168.1.254/?custom=1&cmd=3016")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    let xml = try XMLHash.parse(data)
                    if let status = xml["Function"]["Status"].element?.text, let statusCode = Int(status), statusCode == 1 {
                        let url2 = URL(string: "http://192.168.1.254/?custom=1&cmd=3001&par=0")!
                        URLSession.shared.dataTask(with: url2).resume()
                    }
                } catch {
                    print("Error parsing XML: \(error)")
                }

                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let timeStr = formatter.string(from: now)
                print("Timestamp: \(timeStr)")

                let dateString = String(format: "%04d-%02d-%02d", now.year, now.month, now.day)
                let url3 = URL(string: "http://192.168.1.254/?custom=1&cmd=3005&str=\(dateString)")!
                URLSession.shared.dataTask(with: url3).resume()

                let url4 = URL(string: "http://192.168.1.254/?custom=1&cmd=3006&str=\(timeStr)")!
                URLSession.shared.dataTask(with: url4).resume()

                // URL for changing photo resolution to VGA
                let vgaResolutionURL = URL(string: "http://192.168.1.254/?custom=1&cmd=1002&par=6")!
                URLSession.shared.dataTask(with: vgaResolutionURL).resume()
            }
        }

        task.resume()
    }
    
    func switchDeviceToHigherMode() {
        let url = URL(string: "http://192.168.1.254/?custom=1&cmd=3016")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    let xml = try XMLHash.parse(data)
                    if let status = xml["Function"]["Status"].element?.text, let statusCode = Int(status), statusCode == 1 {
                        let url2 = URL(string: "http://192.168.1.254/?custom=1&cmd=3001&par=0")!
                        URLSession.shared.dataTask(with: url2).resume()
                    }
                } catch {
                    print("Error parsing XML: \(error)")
                }

                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let timeStr = formatter.string(from: now)
                print("Timestamp: \(timeStr)")

                let dateString = String(format: "%04d-%02d-%02d", now.year, now.month, now.day)
                let url3 = URL(string: "http://192.168.1.254/?custom=1&cmd=3005&str=\(dateString)")!
                URLSession.shared.dataTask(with: url3).resume()

                let url4 = URL(string: "http://192.168.1.254/?custom=1&cmd=3006&str=\(timeStr)")!
                URLSession.shared.dataTask(with: url4).resume()

//                // URL for changing photo resolution to VGA
                let resolutionURL = URL(string: "http://192.168.1.254/?custom=1&cmd=1002&par=3")!
                URLSession.shared.dataTask(with: resolutionURL).resume()
            }
        }

        task.resume()
    }
    

    func switchDeviceToPhotoMode() {
        let url = URL(string: "http://192.168.1.254/?custom=1&cmd=3016")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    let xml = try XMLHash.parse(data)
                    if let status = xml["Function"]["Status"].element?.text, let statusCode = Int(status), statusCode == 1 {
                        let url2 = URL(string: "http://192.168.1.254/?custom=1&cmd=3001&par=0")!
                        URLSession.shared.dataTask(with: url2).resume()
                    }
                } catch {
                    print("Error parsing XML: \(error)")
                }

                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let timeStr = formatter.string(from: now)
                print("Timestamp: \(timeStr)")

                let dateString = String(format: "%04d-%02d-%02d", now.year, now.month, now.day)
                let url3 = URL(string: "http://192.168.1.254/?custom=1&cmd=3005&str=\(dateString)")!
                URLSession.shared.dataTask(with: url3).resume()

                let url4 = URL(string: "http://192.168.1.254/?custom=1&cmd=3006&str=\(timeStr)")!
                URLSession.shared.dataTask(with: url4).resume()

                // URL for changing photo resolution to VGA
                let vgaResolutionURL = URL(string: "http://192.168.1.254/?custom=1&cmd=1002&par=6")!
                URLSession.shared.dataTask(with: vgaResolutionURL).resume()
            }
        }

        task.resume()
    }
    
    func getPhotoDataFromDevice(completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            let url = URL(string: "http://192.168.1.254/DCIM/Photo")!

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Request error: \(error)")
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let html = String(data: data, encoding: .utf8)!
                        let document = try SwiftSoup.parse(html)
                        let elements = try document.select("b")
                        let fileName = try elements.last()?.text()
                        print(try elements.map { try $0.text() }.joined(separator: ",\n"))
                        print("file___name____:\(fileName ?? "")")

                        if let fileName = fileName {
                            let fileURL = URL(string: "http://192.168.1.254/DCIM/Photo/\(fileName)")!

                            URLSession.shared.dataTask(with: fileURL) { (imageData, response, error) in
                                if let error = error {
                                    print("Download error: \(error)")
                                    completion(.failure(error))
                                } else if let imageData = imageData {
                                    completion(.success(imageData))
                                }
                            }.resume()
                        } else {
                            print("File name not found.")
                            completion(.failure(NSError(domain: "File name not found", code: 404, userInfo: nil)))
                        }
                    } catch {
                        print("Error parsing HTML: \(error)")
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }


//    func deleteDataFromDevice(completion: @escaping (Error?) -> Void) {
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            let url = URL(string: "http://192.168.1.254/DCIM/Photo")!
//
//            URLSession.shared.dataTask(with: url) { (data, response, error) in
//                if let error = error {
//                    print("Request error: \(error)")
//                    completion(error)
//                } else if let data = data {
//                    do {
//                        let html = String(data: data, encoding: .utf8)!
//                        let document = try SwiftSoup.parse(html)
//                        let elements = try document.select("b")
//                        let fileNames = try elements.map { try $0.text() }
//                        
//                        for fileName in fileNames {
//                            let fileURL = URL(string: "http://192.168.1.254/DCIM/Photo/\(fileName)?del=1")!
//                            
//                            URLSession.shared.dataTask(with: fileURL) { (_, _, error) in
//                                if let error = error {
//                                    print("Deletion error: \(error)")
//                                    completion(error)
//                                }
//                            }.resume()
//                        }
//                        
//                        completion(nil)
//                    } catch {
//                        print("Error parsing HTML: \(error)")
//                        completion(error)
//                    }                }
//            }.resume()
//        }
//    }
    
    
    func deleteDataFromDevice(completion: @escaping (Error?) -> Void) {
            let url = URL(string: "http://192.168.1.254/DCIM/Photo")!

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Request error: \(error)")
                    completion(error)
                } else if let data = data {
                    do {
                        let html = String(data: data, encoding: .utf8)!
                        let document = try SwiftSoup.parse(html)
                        let elements = try document.select("b")
                        let fileNames = try elements.map { try $0.text() }
                        
                        for fileName in fileNames {
                            let fileURL = URL(string: "http://192.168.1.254/DCIM/Photo/\(fileName)?del=1")!
                            
                            URLSession.shared.dataTask(with: fileURL) { (_, _, error) in
                                if let error = error {
                                    print("Deletion error: \(error)")
                                    completion(error)
                                }
                            }.resume()
                        }
                        
                        completion(nil)
                    } catch {
                        print("Error parsing HTML: \(error)")
                        completion(error)
                    }                }
            }.resume()
        
    }
    
    
    func capturePhoto(completion: @escaping (Int) -> Void) {
        let urlString = "http://192.168.1.254/?custom=1&cmd=1001"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    completion(-1)
                    return
                }
                guard let data = data else {
                    completion(-1)
                    return
                }
                let result = String(data: data, encoding: .utf8)
                print("result_____\((result ?? ""))")
                completion(0)
            }
            task.resume()
        }
    }

}

extension Helper{
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func sendEventRequest(feature: ProcessType, details: String, title: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let url = URL(string: "https://seekr-analytics.squadhead.workers.dev/event") else {
                print("Invalid URL")
                return
            }
            
            var userId = AppUserDefault.getUserId() ?? ""
            var sessionID = AppUserDefault.getSessionId() ?? ""
            
//            if userId.isEmpty {
//                userId = randomString(length: 8)
//                AppUserDefault.setUserId("\(userId)")
//            }
            
            let featureString = Helper().getFeatureString(type: feature) ?? ""
            
            let json: [String: Any] = [
                "session": sessionID,
                "feature": featureString,
                "event": [
                    "title": title,
                    "details": details
                ]
            ]
            
            print("param check before send \(json)")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
                print("Failed to convert JSON to Data")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print("raw___response_____\(response)_____\(data)")
                
                if let error = error {
                    print("Error_______: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
//                    print("Error: Invalid response::::::\(httpResponse)")
                    return
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response from event: \(responseString)")
                } else {
                    print("Error: No data received")
                }
            }
            
            task.resume()
        }
    }

//    func sendEventRequest(action:String, feature:ProcessType, details:String, title:String, responseCode:Int) {
//        // Define the URL
//        guard let url = URL(string: "https://seekr-analytics.squadhead.workers.dev/event") else {
//            print("Invalid URL")
//            return
//        }
//        
//        var userId = AppUserDefault.getUserId() ?? ""
//        var sessionID = AppUserDefault.getSessionId() ?? ""
//
//        
//        if userId == ""{
//            userId = randomString(length: 8)
//            AppUserDefault.setUserId("\(userId)")
//        }
//        
//        
//        let feature = getFeatureString(type: feature)
//        let imageProcessUrl = ImageProcessor().getServerUrl(type: feature) ?? ""
//        let language = AppUserDefault.getSelectedLanguage() ?? "en_US"
//        // Define the JSON payload
//        let json: [String: Any] = [
//            "session": sessionID,
//            "url": imageProcessUrl,
//            "feature": feature,
//            "title": title,
//            "event": [
//                "action": action,
//                "details": details
//            ],
//            "headers":{
//                　　　"Accept-Charset":"UTF-8",
//                　　　"Accept-Language": language,
//                　　},
//            "status": responseCode,
//        ]
//        
//        print("param check before send\(json)")
//        
//        // Convert the JSON to Data
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
//            print("Failed to convert JSON to Data")
//            return
//        }
//        
//        // Create the URLRequest
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        
//        // Create URLSessionDataTask
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                print("Error: Invalid response")
//                return
//            }
//            
//            if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                print("Response__from___event: \(responseString)")
//            } else {
//                print("Error: No data received")
//            }
//        }
//        
//        // Start the URLSessionDataTask
//        task.resume()
//    }
    
    func getFeatureString(type: ProcessType) -> String {
        switch type {
        case .reading:
            return "TEXT_DETECTION"
        case .object:
            return "SCENE_DETECTION"
        case .scene:
            return "SCENE_DETECTION"
        case .supermarket:
            return "SUPERMARKET_MODE"
        case .distance:
            return "DEPTH_DETECTION"
        case .bus:
            return "BUS_DETECTION"
        case .walking:
            return "WALKING_MODE"
        case .museum:
            return "MUSEUM_MODE"
        case .chat:
            return "CHAT_BOT"
        case .document:
            return "DOCUMENT"

        }
    }
}
