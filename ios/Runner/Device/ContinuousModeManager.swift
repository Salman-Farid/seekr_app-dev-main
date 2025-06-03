//
//  ContinuousModeManager.swift
//  Runner
//
//  Created by Ahnaf Rahat on 15/3/24.
//

import UIKit
import SocketIO

class ContinuousModeManager: UIViewController {
    
    static let shared = ContinuousModeManager()
   
    let socketManager = SocketManager(socketURL: URL(string: "https://busdetectiondev-wx2bjo7cia-uc.a.run.app")!, config: [.log(true), .compress])

    var socket: SocketIOClient?

    func setupSocket() {
        socket = socketManager.defaultSocket
        addSocketHandlers()
        socket?.connect()
    }
    
    func disconnectSocket() {
        socket?.disconnect()
    }
    
    func isSocketConnected() -> Bool {
        guard let socket = socket else {
            return false
        }
        return socket.status == .connected
    }

    func addSocketHandlers() {
        socket?.on(clientEvent: .connect) { _, _ in
            print("ContinuousModeSocket connected")
            self.fetchCameraDataLegacy()
        }

        socket?.on(clientEvent: .disconnect) { _, _ in
            print("Socket disconnected")
        }

        socket?.on("connect_error") { data, ack in
            if let error = data.first as? String {
                print("Socket connection error: \(error)")
            }
        }
        
        socket?.onAny { socketAnyEvent in
            print("Response from server on event: \(socketAnyEvent.event) data: \(socketAnyEvent.items)")
        }
        
        socket?.on("stream") { data, ack in
            print(" from 'someEvent' event: \(data)")
            // You can handle the response data here
        }
        
        socket?.on("response_from_server") { data, ack in
            if let dataDict = data.first as? [String: Any], let frameCount = dataDict["frame_count"] as? Int {
                print("Received_frame_count: \(frameCount)")
                
                self.speak("\(frameCount) Frame Received")
                // You can handle the frame count here
            } else {
                print("Invalid data format for 'response_from_server' event")
            }
        }
        
//        socket?.on("stream") { data, ack in
//              guard let dataArray = data as? [Any], let streamData = dataArray.first as? Data else {
//                  print("Invalid data format for 'stream' event")
//                  return
//              }
//              // Process the streamData here
//              print("Received stream data: \(streamData)")
//          }
        
    }

    func fetchCameraDataLegacy(){
        
        let urlString = "http://192.168.1.254:8192"

        guard let url = URL(string: urlString) else {
          print("Error: Invalid URL format")
          return
        }


        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-ndjson", forHTTPHeaderField: "Accept")

        let connnection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        connnection?.start()

        print("Fetching data...")
 
    }
    
    func fetchCameraDataModern(){
        
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

    


}

extension ContinuousModeManager:NSURLConnectionDelegate,NSURLConnectionDataDelegate{
    public func connection(_ connection: NSURLConnection, didReceive data: Data) {
        let string = String(data: data, encoding: .utf8)
        print("data______Receiv:\n\(data)")

        print("didReceive data:\n\(string ?? "N/A")")
        
        socket?.emit("stream", with: [data.base64EncodedString()]) {
            // Completion handler
            print("Data emitted to stream")
        }
    }
    
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
//        Logger.shared.log(level: .debug, "didFailWithError: \(error)")
        print("didFailWithError: \(error)")
    }
    
//    public func connection(_ connection: NSURLConnection, willSendRequestFor challenge: URLAuthenticationChallenge) {
//        guard let certificate = certificate, let identity = identity else {
//            Logger.shared.log(level: .info, "No credentials set. Using default handling. (certificate and/or identity are nil)")
//            challenge.sender?.performDefaultHandling?(for: challenge)
//            return
//        }
//
//        let credential = URLCredential(identity: identity, certificates: [certificate], persistence: .forSession)
//        challenge.sender?.use(credential, for: challenge)
//    }

}

extension ContinuousModeManager{
    func speak(_ textToRead: String) {
        print("___Entered___Speech__Block")
        SpeechManager.shared.speak(text: textToRead)
    }
}
