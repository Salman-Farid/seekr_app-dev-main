import Reachability

enum ConnectionType {
    case wifi
    case cellular
    case none
}

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let reachability = try! Reachability()
    private(set) var connectionType: ConnectionType = .none
    
    private init() {
        setupReachability()
    }
    
    private func setupReachability() {
        reachability.whenReachable = { [weak self] reachability in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(reachability)
            }
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            DispatchQueue.main.async {
                self?.connectionType = .none
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func updateConnectionStatus(_ reachability: Reachability) {
        switch reachability.connection {
        case .wifi:
            connectionType = .wifi
        case .cellular:
            connectionType = .cellular
        case .unavailable:
            connectionType = .none
        }
        // Notify observers of network status change
        NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
    }
    
    func stopMonitoring() {
        reachability.stopNotifier()
    }
}

// Define a custom notification name for network status changes
extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
