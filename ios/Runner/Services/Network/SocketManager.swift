//
//  SocketManager.swift
//  IP_Camera
//
//  Created by Ahnaf Rahat on 15/12/23.
//

import Foundation
import UIKit

class CustomSocketManager {
    static let shared = CustomSocketManager() // Singleton instance

    private init() {} // Private initializer to prevent external instantiation

    private let socket = Socket.shared // Use the shared Socket instance
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func connectToSocket() {
        guard !socket.isConnected else {
            print("Socket is already connected.")
            return
        }

        socket.connect()
        socket.setSelectedMode()
        print("Socket connected and mode set.")
    }

    func isSocketConnected() -> Bool {
        return socket.isConnected
    }

    func disconnectSocket() {
        guard socket.isConnected else {
            print("Socket is not connected.")
            return
        }

        socket.disconnect()
        print("Socket disconnected.")
    }

    func connectToSocketInBackground() {
        guard !socket.isConnected else {
            print("Socket is already connected in the background.")
            return
        }

        backgroundTask = UIApplication.shared.beginBackgroundTask {
            // Clean up or end the background task when it expires
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }

        DispatchQueue.global(qos: .background).async {
            self.socket.connect()

            while !Thread.current.isCancelled {
                usleep(100)
            }

            self.socket.disconnect()

            // When finished, end the background task
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
    }
}
