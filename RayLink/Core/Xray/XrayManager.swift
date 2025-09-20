import Foundation
import NetworkExtension
import os.log

@MainActor
class XrayManager: ObservableObject {
    static let shared = XrayManager()
    
    @Published var connectionStatus: TunnelStatus = .disconnected
    @Published var currentServer: VPNServer?
    @Published var connectionTime: TimeInterval = 0
    @Published var statistics: TunnelConnectionStatistics = TunnelConnectionStatistics()
    
    private let logger = Logger(subsystem: "com.raylink.app", category: "XrayManager")
    private var tunnelManager: NETunnelProviderManager?
    private var connectionTimer: Timer?
    private var statisticsTimer: Timer?
    private var startTime: Date?
    
    private init() {
        setupTunnelManager()
        observeVPNStatus()
    }
    
    // MARK: - Public Interface
    
    func connect(to server: VPNServer) async throws {
        logger.info("Attempting to connect to server: \(server.name)")
        
        guard let manager = tunnelManager else {
            throw XrayManagerError.tunnelManagerNotReady
        }
        
        // Prepare server configuration
        let serverData = try JSONEncoder().encode(server)
        let options: [String: NSObject] = [
            "serverConfig": serverData as NSData
        ]
        
        // Update current server
        currentServer = server
        
        do {
            try await manager.connection.startVPNTunnel(options: options)
            startTime = Date()
            startTimers()
            
        } catch {
            logger.error("Failed to start VPN tunnel: \(error.localizedDescription)")
            currentServer = nil
            throw XrayManagerError.connectionFailed(error)
        }
    }
    
    func disconnect() async throws {
        logger.info("Disconnecting VPN")
        
        guard let manager = tunnelManager else {
            throw XrayManagerError.tunnelManagerNotReady
        }
        
        manager.connection.stopVPNTunnel()
        stopTimers()
        startTime = nil
        currentServer = nil
    }
    
    func getCurrentStatistics() async -> TunnelConnectionStatistics? {
        guard let connection = tunnelManager?.connection as? NETunnelProviderSession else {
            return nil
        }
        
        let message = TunnelMessage(type: .getStatistics, data: nil)
        let messageData = try? JSONEncoder().encode(message)
        
        return await withCheckedContinuation { continuation in
            do {
                try connection.sendProviderMessage(messageData ?? Data()) { response in
                    if let response = response,
                       let stats = try? JSONDecoder().decode(TunnelStatistics.self, from: response) {
                        let connectionStats = TunnelConnectionStatistics(
                            bytesReceived: stats.bytesReceived,
                            bytesSent: stats.bytesSent,
                            connectedTime: stats.connectedTime,
                            currentSpeed: ConnectionSpeed()
                        )
                        continuation.resume(returning: connectionStats)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
    
    func switchServer(to server: VPNServer) async throws {
        logger.info("Switching to server: \(server.name)")
        
        guard let connection = tunnelManager?.connection as? NETunnelProviderSession else {
            throw XrayManagerError.tunnelManagerNotReady
        }
        
        let serverData = try JSONEncoder().encode(server)
        let message = TunnelMessage(type: .updateConfig, data: serverData)
        let messageData = try JSONEncoder().encode(message)
        
        return await withCheckedContinuation { continuation in
            do {
                try connection.sendProviderMessage(messageData) { response in
                    if let response = response,
                       let result = try? JSONDecoder().decode(TunnelResponse.self, from: response) {
                        if result.success {
                            self.currentServer = server
                            continuation.resume(returning: ())
                        } else {
                            continuation.resume(throwing: XrayManagerError.serverSwitchFailed(result.error ?? "Unknown error"))
                        }
                    } else {
                        continuation.resume(throwing: XrayManagerError.serverSwitchFailed("No response"))
                    }
                }
            } catch {
                continuation.resume(throwing: XrayManagerError.serverSwitchFailed(error.localizedDescription))
            }
        }
    }
    
    func testServerLatency(_ server: VPNServer) async -> Int {
        // Implement ping test to server
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            // Create a simple TCP connection test
            let url = URL(string: "http://\(server.address):\(server.port)")!
            var request = URLRequest(url: url)
            request.timeoutInterval = 5.0
            
            let (_, _) = try await URLSession.shared.data(for: request)
            
            let latency = CFAbsoluteTimeGetCurrent() - startTime
            return Int(latency * 1000) // Convert to milliseconds
            
        } catch {
            // Fallback to system ping if available
            return await performSystemPing(to: server.address)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupTunnelManager() {
        Task {
            do {
                let managers = try await NETunnelProviderManager.loadAllFromPreferences()
                
                if let existingManager = managers.first {
                    tunnelManager = existingManager
                } else {
                    // Create new tunnel manager
                    let manager = NETunnelProviderManager()
                    
                    let providerProtocol = NETunnelProviderProtocol()
                    providerProtocol.providerBundleIdentifier = "com.raylink.app.tunnel"
                    providerProtocol.serverAddress = "RayLink VPN"
                    
                    manager.protocolConfiguration = providerProtocol
                    manager.localizedDescription = "RayLink VPN"
                    manager.isEnabled = true
                    
                    try await manager.saveToPreferences()
                    try await manager.loadFromPreferences()
                    
                    tunnelManager = manager
                }
                
                updateConnectionStatus()
                
            } catch {
                logger.error("Failed to setup tunnel manager: \(error.localizedDescription)")
            }
        }
    }
    
    private func observeVPNStatus() {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateConnectionStatus()
        }
    }
    
    private func updateConnectionStatus() {
        guard let manager = tunnelManager else {
            connectionStatus = .disconnected
            return
        }
        
        switch manager.connection.status {
        case .connecting:
            connectionStatus = .connecting
        case .connected:
            connectionStatus = .connected
        case .disconnecting:
            connectionStatus = .disconnecting
        case .disconnected:
            connectionStatus = .disconnected
        case .invalid:
            connectionStatus = .disconnected
        case .reasserting:
            connectionStatus = .connecting
        @unknown default:
            connectionStatus = .disconnected
        }
        
        logger.debug("VPN status changed to: \(self.connectionStatus)")
    }
    
    private func startTimers() {
        // Connection time timer
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if let startTime = self?.startTime {
                    self?.connectionTime = Date().timeIntervalSince(startTime)
                }
            }
        }
        
        // Statistics update timer
        statisticsTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if let stats = await self?.getCurrentStatistics() {
                    self?.statistics = stats
                }
            }
        }
    }
    
    private func stopTimers() {
        connectionTimer?.invalidate()
        connectionTimer = nil
        
        statisticsTimer?.invalidate()
        statisticsTimer = nil
        
        connectionTime = 0
        statistics = TunnelConnectionStatistics()
    }
    
    private func performSystemPing(to address: String) async -> Int {
        // Simplified ping implementation using URLSession
        let url = URL(string: "http://\(address)")!
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 3.0
            
            let (_, _) = try await URLSession.shared.data(for: request)
            let latency = CFAbsoluteTimeGetCurrent() - startTime
            return Int(latency * 1000)
            
        } catch {
            return -1 // Indicates timeout or error
        }
    }
}

// MARK: - Supporting Types

enum TunnelStatus {
    case disconnected
    case connecting
    case connected
    case disconnecting
    
    var displayName: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting"
        }
    }
    
    var isConnected: Bool {
        return self == .connected
    }
}

struct TunnelConnectionStatistics {
    let bytesReceived: UInt64
    let bytesSent: UInt64
    let connectedTime: TimeInterval
    let currentSpeed: ConnectionSpeed
    
    init(
        bytesReceived: UInt64 = 0,
        bytesSent: UInt64 = 0,
        connectedTime: TimeInterval = 0,
        currentSpeed: ConnectionSpeed = ConnectionSpeed()
    ) {
        self.bytesReceived = bytesReceived
        self.bytesSent = bytesSent
        self.connectedTime = connectedTime
        self.currentSpeed = currentSpeed
    }
    
    var totalBytes: UInt64 {
        return bytesReceived + bytesSent
    }
    
    var formattedBytesReceived: String {
        return ByteCountFormatter.string(fromByteCount: Int64(bytesReceived), countStyle: .binary)
    }
    
    var formattedBytesSent: String {
        return ByteCountFormatter.string(fromByteCount: Int64(bytesSent), countStyle: .binary)
    }
    
    var formattedTotalBytes: String {
        return ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .binary)
    }
    
    var formattedConnectedTime: String {
        let hours = Int(connectedTime) / 3600
        let minutes = Int(connectedTime) % 3600 / 60
        let seconds = Int(connectedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct ConnectionSpeed {
    let downloadSpeed: UInt64 // bytes per second
    let uploadSpeed: UInt64   // bytes per second
    
    init(downloadSpeed: UInt64 = 0, uploadSpeed: UInt64 = 0) {
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
    }
    
    var formattedDownloadSpeed: String {
        return ByteCountFormatter.string(fromByteCount: Int64(downloadSpeed), countStyle: .binary) + "/s"
    }
    
    var formattedUploadSpeed: String {
        return ByteCountFormatter.string(fromByteCount: Int64(uploadSpeed), countStyle: .binary) + "/s"
    }
}

enum XrayManagerError: Error, LocalizedError {
    case tunnelManagerNotReady
    case connectionFailed(Error)
    case serverSwitchFailed(String)
    case configurationError
    
    var errorDescription: String? {
        switch self {
        case .tunnelManagerNotReady:
            return "VPN tunnel manager is not ready"
        case .connectionFailed(let error):
            return "Connection failed: \(error.localizedDescription)"
        case .serverSwitchFailed(let message):
            return "Server switch failed: \(message)"
        case .configurationError:
            return "Invalid configuration"
        }
    }
}
