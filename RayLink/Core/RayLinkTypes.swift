// RayLinkTypes.swift
// This file contains all shared types and protocols used throughout the app

import Foundation
import SwiftUI
import Combine
import NetworkExtension

// MARK: - VPN Protocol Types
public enum VPNProtocol: String, CaseIterable, Codable {
    case shadowsocks = "shadowsocks"
    case vmess = "vmess"
    case vless = "vless"
    case trojan = "trojan"
    case ikev2 = "ikev2"
    case wireguard = "wireguard"
}

// MARK: - VPN Server Model
public struct VPNServer: Identifiable, Codable, Hashable {
    public let id: String
    public var name: String
    public var address: String
    public var port: Int
    public var `protocol`: VPNProtocol
    public var username: String?
    public var password: String?
    public var uuid: String?
    public var alterId: Int?
    public var encryption: String?
    public var sni: String?
    public var flow: String?
    public var ping: Int
    public var isActive: Bool
    public var configuration: [String: Any]?
    public var location: String?
    public var flag: String
    public var isPremium: Bool
    public var provider: String?
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        port: Int,
        protocol: VPNProtocol,
        username: String? = nil,
        password: String? = nil,
        uuid: String? = nil,
        alterId: Int? = nil,
        encryption: String? = nil,
        sni: String? = nil,
        flow: String? = nil,
        ping: Int = 0,
        isActive: Bool = true,
        location: String? = nil,
        flag: String = "🌍",
        isPremium: Bool = false,
        provider: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.port = port
        self.protocol = `protocol`
        self.username = username
        self.password = password
        self.uuid = uuid
        self.alterId = alterId
        self.encryption = encryption
        self.sni = sni
        self.flow = flow
        self.ping = ping
        self.isActive = isActive
        self.location = location
        self.flag = flag
        self.isPremium = isPremium
        self.provider = provider
    }
    
    public var displayLocation: String {
        location ?? "Unknown"
    }
    
    public var connectionURL: String {
        // Generate connection URL based on protocol
        switch `protocol` {
        case .vmess:
            return "vmess://\(uuid ?? "")"
        case .vless:
            return "vless://\(uuid ?? "")"
        case .shadowsocks:
            return "ss://\(password ?? "")"
        case .trojan:
            return "trojan://\(password ?? "")"
        default:
            return ""
        }
    }
    
    public func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "address": address,
            "port": port,
            "protocol": `protocol`.rawValue
        ]
    }
    
    // Codable
    enum CodingKeys: String, CodingKey {
        case id, name, address, port, username, password, uuid, alterId
        case encryption, sni, flow, ping, isActive, location, flag, isPremium, provider
        case `protocol`
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(port, forKey: .port)
        try container.encode(`protocol`, forKey: .protocol)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(uuid, forKey: .uuid)
        try container.encodeIfPresent(alterId, forKey: .alterId)
        try container.encodeIfPresent(encryption, forKey: .encryption)
        try container.encodeIfPresent(sni, forKey: .sni)
        try container.encodeIfPresent(flow, forKey: .flow)
        try container.encode(ping, forKey: .ping)
        try container.encode(isActive, forKey: .isActive)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encode(flag, forKey: .flag)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encodeIfPresent(provider, forKey: .provider)
    }
}

// MARK: - VPN Connection Status
public enum VPNConnectionStatus: String {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnecting = "Disconnecting"
    case reasserting = "Reasserting"
    case invalid = "Invalid"
}

// MARK: - User Settings
public struct UserSettings: Codable {
    public var autoConnect: Bool = false
    public var analyticsEnabled: Bool = false
    public var notificationsEnabled: Bool = true
    
    public init() {}
}

// MARK: - VPN Subscription
public struct VPNSubscription: Identifiable, Codable {
    public let id = UUID()
    public var name: String
    public var url: String
    public var lastUpdated: Date?
    public var autoUpdate: Bool
    
    public init(name: String, url: String, autoUpdate: Bool = true) {
        self.name = name
        self.url = url
        self.autoUpdate = autoUpdate
    }
}

// MARK: - Speed Test Result
public struct SpeedTestResult: Identifiable, Codable {
    public let id = UUID()
    public var server: String
    public var ping: Int
    public var downloadSpeed: Double
    public var uploadSpeed: Double
    public var timestamp: Date
    
    public init(server: String, ping: Int, downloadSpeed: Double = 0, uploadSpeed: Double = 0) {
        self.server = server
        self.ping = ping
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
        self.timestamp = Date()
    }
}

// MARK: - Navigation Types
public enum NavigationDestination: Hashable {
    case home
    case serverList
    case serverDetail(VPNServer)
    case addServer
    case editServer(VPNServer)
    case settings
    case settingsSection(SettingsSection)
    case `import`
    case importResult([VPNServer])
    case speedTest
    case speedTestResult(SpeedTestResult)
    case logs
    case about
    case help
    case subscription
    case routing
    case dns
    case addSubscription
    case trustedNetworks
    case routingRules
    case dataUsage
    case privacy
    case diagnostics
    case backup
    
    public enum SettingsSection: Hashable {
        case connection
        case privacy
        case advanced
        case appearance
        case notifications
        case subscription
        case about
    }
}

// MARK: - Alert Item
public struct AlertItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let dismissButton: String
    
    public init(title: String, message: String, dismissButton: String = "OK") {
        self.title = title
        self.message = message
        self.dismissButton = dismissButton
    }
}

// MARK: - Connection Mode
public enum ConnectionMode: String, CaseIterable {
    case automatic = "AUTOMATIC"
    case global = "GLOBAL"
    case direct = "DIRECT"
}

// MARK: - Protocol Extensions
public protocol VPNManagerProtocol {
    var connectionStatus: AnyPublisher<VPNConnectionStatus, Never> { get }
    var isConnected: Bool { get }
    
    func connect(to server: VPNServer) async throws
    func disconnect() async throws
    func loadConfigurations() async throws
    func removeAllConfigurations() async throws
}

public protocol StorageManagerProtocol {
    func saveServers(_ servers: [VPNServer]) throws
    func loadServers() throws -> [VPNServer]
    func saveUserSettings(_ settings: UserSettings) throws
    func loadUserSettings() throws -> UserSettings
}

public protocol NetworkServiceProtocol {
    func downloadConfig(from url: URL) async throws -> Data
}

// MARK: - Connection Statistics
public struct ConnectionStatistics {
    public let uploadSpeed: Int64
    public let downloadSpeed: Int64
    public let totalUploaded: Int64
    public let totalDownloaded: Int64
    public let connectionDuration: TimeInterval
    public let location: String
    public let serverName: String
    
    public init(uploadSpeed: Int64, downloadSpeed: Int64, totalUploaded: Int64, totalDownloaded: Int64, connectionDuration: TimeInterval, location: String, serverName: String) {
        self.uploadSpeed = uploadSpeed
        self.downloadSpeed = downloadSpeed
        self.totalUploaded = totalUploaded
        self.totalDownloaded = totalDownloaded
        self.connectionDuration = connectionDuration
        self.location = location
        self.serverName = serverName
    }
}

// MARK: - VPN Connection State
public enum VPNConnectionState {
    case connected
    case connecting
    case disconnected
}

// MARK: - Storage Keys
public enum StorageKey: String {
    case selectedServer = "selectedServer"
    case connectionMode = "connectionMode"
}