import NetworkExtension
import Foundation
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger = Logger(subsystem: "com.raylink.app", category: "PacketTunnelProvider")
    private var xrayProcess: Process?
    private var xrayWrapper: XrayWrapper?
    private var startTime: Date?
    private var bytesReceived: UInt64 = 0
    private var bytesSent: UInt64 = 0
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting VPN tunnel")
        startTime = Date()
        
        guard let serverConfig = options?["serverConfig"] as? Data,
              let server = try? JSONDecoder().decode(VPNServer.self, from: serverConfig) else {
            logger.error("Invalid server configuration")
            completionHandler(VPNTunnelError.configurationError)
            return
        }
        
        // Create tunnel interface
        let tunnelNetworkSettings = createTunnelNetworkSettings()
        
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            if let error = error {
                self?.logger.error("Failed to set network settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            // Start Xray-core
            self?.startXrayCore(with: server, completionHandler: completionHandler)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping VPN tunnel, reason: \(reason.rawValue)")
        
        // Stop Xray-core
        stopXrayCore()
        
        // Record session statistics
        recordSessionStatistics()
        
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        logger.debug("Received app message")
        
        guard let message = try? JSONDecoder().decode(TunnelMessage.self, from: messageData) else {
            logger.error("Failed to decode app message")
            completionHandler?(nil)
            return
        }
        
        switch message.type {
        case .getStatus:
            let status = getCurrentStatus()
            let responseData = try? JSONEncoder().encode(status)
            completionHandler?(responseData)
            
        case .getStatistics:
            let stats = getCurrentStatistics()
            let responseData = try? JSONEncoder().encode(stats)
            completionHandler?(responseData)
            
        case .updateConfig:
            if let configData = message.data,
               let server = try? JSONDecoder().decode(VPNServer.self, from: configData) {
                updateConfiguration(with: server) { error in
                    let response = TunnelResponse(success: error == nil, error: error?.localizedDescription)
                    let responseData = try? JSONEncoder().encode(response)
                    completionHandler?(responseData)
                }
            } else {
                completionHandler?(nil)
            }
            
        default:
            completionHandler?(nil)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        logger.debug("VPN extension going to sleep")
        completionHandler()
    }
    
    override func wake() {
        logger.debug("VPN extension waking up")
    }
    
    // MARK: - Private Methods
    
    private func createTunnelNetworkSettings() -> NEPacketTunnelNetworkSettings {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
        
        // IPv4 Settings
        let ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        ipv4Settings.excludedRoutes = [
            // Exclude local networks
            NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
            NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0"),
            NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0"),
            NEIPv4Route(destinationAddress: "127.0.0.0", subnetMask: "255.0.0.0"),
            NEIPv4Route(destinationAddress: "224.0.0.0", subnetMask: "240.0.0.0")
        ]
        settings.ipv4Settings = ipv4Settings
        
        // DNS Settings
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        dnsSettings.matchDomains = [""]
        settings.dnsSettings = dnsSettings
        
        // MTU
        settings.mtu = NSNumber(value: 1500)
        
        return settings
    }
    
    private func startXrayCore(with server: VPNServer, completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting Xray-core with server: \(server.name)")
        
        do {
            // Create Xray configuration
            let xrayConfig = try XrayConfigBuilder.buildConfig(for: server)
            
            // Initialize Xray wrapper
            xrayWrapper = XrayWrapper()
            
            // Start Xray with configuration
            xrayWrapper?.start(with: xrayConfig) { [weak self] result in
                switch result {
                case .success:
                    self?.logger.info("Xray-core started successfully")
                    self?.startPacketFlow()
                    completionHandler(nil)
                    
                case .failure(let error):
                    self?.logger.error("Failed to start Xray-core: \(error.localizedDescription)")
                    completionHandler(error)
                }
            }
            
        } catch {
            logger.error("Failed to create Xray configuration: \(error.localizedDescription)")
            completionHandler(error)
        }
    }
    
    private func stopXrayCore() {
        logger.info("Stopping Xray-core")
        xrayWrapper?.stop()
        xrayWrapper = nil
    }
    
    private func startPacketFlow() {
        logger.debug("Starting packet flow")
        
        // Start reading packets from the tunnel interface
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self else { return }
            
            // Forward packets to Xray
            self.forwardPacketsToXray(packets, protocols: protocols)
            
            // Continue reading
            self.startPacketFlow()
        }
    }
    
    private func forwardPacketsToXray(_ packets: [Data], protocols: [NSNumber]) {
        // Forward packets to Xray-core for processing
        xrayWrapper?.forwardPackets(packets, protocols: protocols) { [weak self] processedPackets, processedProtocols in
            guard let self = self else { return }
            
            // Send processed packets back to the system
            self.packetFlow.writePackets(processedPackets, withProtocols: processedProtocols)
            
            // Update statistics
            self.updateStatistics(packets: processedPackets)
        }
    }
    
    private func updateStatistics(packets: [Data]) {
        let bytesCount = packets.reduce(0) { $0 + UInt64($1.count) }
        bytesReceived += bytesCount
        
        // Notify the main app about statistics update
        NotificationCenter.default.post(
            name: NSNotification.Name("VPNStatisticsUpdated"),
            object: nil,
            userInfo: [
                "bytesReceived": bytesReceived,
                "bytesSent": bytesSent
            ]
        )
    }
    
    private func updateConfiguration(with server: VPNServer, completionHandler: @escaping (Error?) -> Void) {
        logger.info("Updating configuration with new server: \(server.name)")
        
        // Stop current Xray instance
        stopXrayCore()
        
        // Start with new configuration
        startXrayCore(with: server, completionHandler: completionHandler)
    }
    
    private func getCurrentStatus() -> TunnelStatus {
        let status = TunnelStatus(
            isConnected: xrayWrapper?.isRunning ?? false,
            serverName: "Current Server", // You would get this from current config
            connectedTime: startTime.map { Date().timeIntervalSince($0) },
            bytesReceived: bytesReceived,
            bytesSent: bytesSent
        )
        return status
    }
    
    private func getCurrentStatistics() -> TunnelStatistics {
        return TunnelStatistics(
            bytesReceived: bytesReceived,
            bytesSent: bytesSent,
            packetsReceived: 0, // You would track this separately
            packetsSent: 0,
            connectedTime: startTime.map { Date().timeIntervalSince($0) } ?? 0,
            serverLatency: 0 // You would measure this
        )
    }
    
    private func recordSessionStatistics() {
        guard let startTime = startTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        
        logger.info("Session statistics - Duration: \(sessionDuration)s, RX: \(bytesReceived) bytes, TX: \(bytesSent) bytes")
        
        // Save to shared container for the main app
        if let sharedDefaults = UserDefaults(suiteName: "group.com.raylink.app") {
            var sessions = sharedDefaults.array(forKey: "vpnSessions") as? [[String: Any]] ?? []
            
            let session: [String: Any] = [
                "startTime": startTime,
                "endTime": Date(),
                "duration": sessionDuration,
                "bytesReceived": bytesReceived,
                "bytesSent": bytesSent
            ]
            
            sessions.append(session)
            
            // Keep only last 100 sessions
            if sessions.count > 100 {
                sessions = Array(sessions.suffix(100))
            }
            
            sharedDefaults.set(sessions, forKey: "vpnSessions")
        }
    }
}

// MARK: - Supporting Types

enum VPNTunnelError: Error, LocalizedError {
    case configurationError
    case xrayStartError
    case networkSettingsError
    
    var errorDescription: String? {
        switch self {
        case .configurationError:
            return "Invalid VPN configuration"
        case .xrayStartError:
            return "Failed to start Xray-core"
        case .networkSettingsError:
            return "Failed to configure network settings"
        }
    }
}

struct TunnelMessage: Codable {
    enum MessageType: String, Codable {
        case getStatus
        case getStatistics
        case updateConfig
    }
    
    let type: MessageType
    let data: Data?
}

struct TunnelResponse: Codable {
    let success: Bool
    let error: String?
}

struct TunnelStatus: Codable {
    let isConnected: Bool
    let serverName: String
    let connectedTime: TimeInterval?
    let bytesReceived: UInt64
    let bytesSent: UInt64
}

struct TunnelStatistics: Codable {
    let bytesReceived: UInt64
    let bytesSent: UInt64
    let packetsReceived: UInt64
    let packetsSent: UInt64
    let connectedTime: TimeInterval
    let serverLatency: Int
}