import Foundation
import Combine

enum VPNConnectionStatus: String, CaseIterable {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case reasserting
    case invalid
    
    var isConnected: Bool { self == .connected }
}

enum VPNError: LocalizedError {
    case configurationFailed
    case connectionFailed
    case permissionDenied
    case networkUnavailable
    case invalidConfiguration
    case alreadyConnected
    case notConnected
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .configurationFailed:
            return "VPN configuration failed"
        case .connectionFailed:
            return "VPN connection failed"
        case .permissionDenied:
            return "VPN permission denied"
        case .networkUnavailable:
            return "Network unavailable"
        case .invalidConfiguration:
            return "Invalid VPN configuration"
        case .alreadyConnected:
            return "VPN already connected"
        case .notConnected:
            return "VPN not connected"
        case .unknown:
            return "Unknown VPN error"
        }
    }
}

protocol VPNManagerProtocol {
    var connectionStatus: AnyPublisher<VPNConnectionStatus, Never> { get }
    var isConnected: Bool { get }
    
    func connect(to server: VPNServer) async throws
    func disconnect() async throws
    func loadConfigurations() async throws
    func removeAllConfigurations() async throws
}
