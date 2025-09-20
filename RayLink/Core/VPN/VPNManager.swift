import Foundation
import NetworkExtension
import Combine

// MARK: - VPN Manager Protocol
protocol VPNManagerProtocol {
    var connectionStatus: AnyPublisher<VPNConnectionStatus, Never> { get }
    var isConnected: Bool { get }
    
    func connect(to server: VPNServer) async throws
    func disconnect() async throws
    func loadConfigurations() async throws
    func removeAllConfigurations() async throws
}

// MARK: - VPN Connection Status
enum VPNConnectionStatus: String, CaseIterable {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnecting = "Disconnecting"
    case reasserting = "Reasserting"
    case invalid = "Invalid"
    
    var isConnected: Bool {
        return self == .connected
    }
    
    var isConnecting: Bool {
        return self == .connecting || self == .reasserting
    }
}

// MARK: - VPN Errors
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

// MARK: - VPN Manager Implementation
final class VPNManager: NSObject, VPNManagerProtocol, ObservableObject {
    @Published private var currentStatus: VPNConnectionStatus = .disconnected
    @Published var currentServer: VPNServer?
    @Published var connectionStartTime: Date?
    @Published var bytesReceived: Int64 = 0
    @Published var bytesSent: Int64 = 0
    
    private let manager = NEVPNManager.shared()
    private let statusSubject = CurrentValueSubject<VPNConnectionStatus, Never>(.disconnected)
    private var statusObserver: NSObjectProtocol?
    
    var connectionStatus: AnyPublisher<VPNConnectionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    var isConnected: Bool {
        currentStatus.isConnected
    }
    
    override init() {
        super.init()
        setupStatusObserver()
        updateStatus(manager.connection.status)
    }
    
    deinit {
        if let observer = statusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Setup
    private func setupStatusObserver() {
        statusObserver = NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: manager.connection,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateStatus(self.manager.connection.status)
        }
    }
    
    private func updateStatus(_ status: NEVPNStatus) {
        let vpnStatus: VPNConnectionStatus
        
        switch status {
        case .invalid:
            vpnStatus = .invalid
        case .disconnected:
            vpnStatus = .disconnected
            connectionStartTime = nil
        case .connecting:
            vpnStatus = .connecting
        case .connected:
            vpnStatus = .connected
            if connectionStartTime == nil {
                connectionStartTime = Date()
            }
        case .reasserting:
            vpnStatus = .reasserting
        case .disconnecting:
            vpnStatus = .disconnecting
        @unknown default:
            vpnStatus = .invalid
        }
        
        currentStatus = vpnStatus
        statusSubject.send(vpnStatus)
    }
    
    // MARK: - Public Methods
    func loadConfigurations() async throws {
        try await manager.loadFromPreferences()
    }
    
    func connect(to server: VPNServer) async throws {
        guard currentStatus != .connected && currentStatus != .connecting else {
            throw VPNError.alreadyConnected
        }
        
        do {
            try await loadConfigurations()
            
            // Configure the VPN based on server type
            try await configureVPN(with: server)
            
            // Save the configuration
            try await manager.saveToPreferences()
            
            // Load the updated configuration
            try await manager.loadFromPreferences()
            
            // Start the VPN connection
            try manager.connection.startVPNTunnel()
            
            currentServer = server
            
        } catch {
            throw VPNError.connectionFailed
        }
    }
    
    func disconnect() async throws {
        guard currentStatus == .connected || currentStatus == .connecting else {
            throw VPNError.notConnected
        }
        
        manager.connection.stopVPNTunnel()
        currentServer = nil
    }
    
    func removeAllConfigurations() async throws {
        do {
            try await loadConfigurations()
            manager.removeFromPreferences { [weak self] error in
                if let error = error {
                    print("Failed to remove VPN configuration: \(error)")
                } else {
                    self?.currentServer = nil
                }
            }
        } catch {
            throw VPNError.configurationFailed
        }
    }
    
    // MARK: - Private Configuration Methods
    private func configureVPN(with server: VPNServer) async throws {
        switch server.serverProtocol {
        case .shadowsocks:
            try await configureShadowsocks(server)
        case .vmess:
            try await configureVMess(server)
        case .trojan:
            try await configureTrojan(server)
        case .vless:
            try await configureVLess(server)
        case .ikev2:
            try await configureIKEv2(server)
        case .wireguard:
            try await configureWireGuard(server)
        }
    }
    
    private func configureShadowsocks(_ server: VPNServer) async throws {
        // Configure Shadowsocks using NEPacketTunnelProvider
        let providerProtocol = NETunnelProviderProtocol()
        providerProtocol.providerBundleIdentifier = "com.raylink.ios.PacketTunnel"
        providerProtocol.serverAddress = server.address
        
        var config: [String: Any] = [
            "server": server.address,
            "port": server.port,
            "password": server.password ?? "",
            "method": server.encryption ?? "chacha20-ietf-poly1305",
            "protocol": "shadowsocks"
        ]
        
        if let additionalConfig = server.configuration {
            config.merge(additionalConfig) { (_, new) in new }
        }
        
        providerProtocol.providerConfiguration = config
        
        manager.protocolConfiguration = providerProtocol
        manager.localizedDescription = "RayLink - \(server.name)"
        manager.isEnabled = true
    }
    
    private func configureVMess(_ server: VPNServer) async throws {
        let providerProtocol = NETunnelProviderProtocol()
        providerProtocol.providerBundleIdentifier = "com.raylink.ios.PacketTunnel"
        providerProtocol.serverAddress = server.address
        
        var config: [String: Any] = [
            "server": server.address,
            "port": server.port,
            "uuid": server.uuid ?? "",
            "alterId": server.alterId ?? 0,
            "security": server.encryption ?? "auto",
            "protocol": "vmess"
        ]
        
        if let additionalConfig = server.configuration {
            config.merge(additionalConfig) { (_, new) in new }
        }
        
        providerProtocol.providerConfiguration = config
        
        manager.protocolConfiguration = providerProtocol
        manager.localizedDescription = "RayLink - \(server.name)"
        manager.isEnabled = true
    }
    
    private func configureTrojan(_ server: VPNServer) async throws {
        let providerProtocol = NETunnelProviderProtocol()
        providerProtocol.providerBundleIdentifier = "com.raylink.ios.PacketTunnel"
        providerProtocol.serverAddress = server.address
        
        var config: [String: Any] = [
            "server": server.address,
            "port": server.port,
            "password": server.password ?? "",
            "sni": server.sni ?? server.address,
            "protocol": "trojan"
        ]
        
        if let additionalConfig = server.configuration {
            config.merge(additionalConfig) { (_, new) in new }
        }
        
        providerProtocol.providerConfiguration = config
        
        manager.protocolConfiguration = providerProtocol
        manager.localizedDescription = "RayLink - \(server.name)"
        manager.isEnabled = true
    }
    
    private func configureVLess(_ server: VPNServer) async throws {
        let providerProtocol = NETunnelProviderProtocol()
        providerProtocol.providerBundleIdentifier = "com.raylink.ios.PacketTunnel"
        providerProtocol.serverAddress = server.address
        
        var config: [String: Any] = [
            "server": server.address,
            "port": server.port,
            "uuid": server.uuid ?? "",
            "encryption": server.encryption ?? "none",
            "flow": server.flow ?? "",
            "protocol": "vless"
        ]
        
        if let additionalConfig = server.configuration {
            config.merge(additionalConfig) { (_, new) in new }
        }
        
        providerProtocol.providerConfiguration = config
        
        manager.protocolConfiguration = providerProtocol
        manager.localizedDescription = "RayLink - \(server.name)"
        manager.isEnabled = true
    }
    
    private func configureIKEv2(_ server: VPNServer) async throws {
        let ikev2Protocol = NEVPNProtocolIKEv2()
        ikev2Protocol.serverAddress = server.address
        ikev2Protocol.remoteIdentifier = server.address
        ikev2Protocol.username = server.username ?? ""
        ikev2Protocol.passwordReference = try createKeychainReference(for: server.password ?? "")
        
        ikev2Protocol.useExtendedAuthentication = true
        ikev2Protocol.authenticationMethod = .none
        
        manager.protocolConfiguration = ikev2Protocol
        manager.localizedDescription = "RayLink - \(server.name)"
        manager.isEnabled = true
    }
    
    private func configureWireGuard(_ server: VPNServer) async throws {
        // WireGuard configuration would require a separate framework
        // This is a placeholder for WireGuard implementation
        throw VPNError.invalidConfiguration
    }
    
    private func createKeychainReference(for password: String) throws -> Data {
        let passwordData = password.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "RayLink_VPN_Password",
            kSecValueData as String: passwordData,
            kSecReturnPersistentRef as String: true
        ]
        
        var result: CFTypeRef?
        let status = SecItemAdd(query as CFDictionary, &result)
        
        if status == errSecDuplicateItem {
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "RayLink_VPN_Password"
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: passwordData
            ]
            
            SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            var updateResult: CFTypeRef?
            let getQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "RayLink_VPN_Password",
                kSecReturnPersistentRef as String: true
            ]
            
            SecItemCopyMatching(getQuery as CFDictionary, &updateResult)
            result = updateResult
        }
        
        guard let persistentRef = result as? Data else {
            throw VPNError.configurationFailed
        }
        
        return persistentRef
    }
}