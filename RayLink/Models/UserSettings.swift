import Foundation
import SwiftUI

// MARK: - User Settings Model
struct UserSettings: Codable, Equatable {
    // Connection Settings
    var autoConnect: Bool = false
    var connectOnDemand: Bool = false
    var dnsServer: String = "8.8.8.8"
    var killSwitch: Bool = false
    var bypassLAN: Bool = true
    var preferIPv6: Bool = false
    
    // App Settings
    var theme: AppTheme.Theme = .system
    var hapticFeedback: Bool = true
    var soundEffects: Bool = true
    var language: SupportedLanguage = .english
    var showNotifications: Bool = true
    var backgroundRefresh: Bool = true
    
    // Privacy Settings
    var analyticsEnabled: Bool = true
    var crashReportsEnabled: Bool = true
    var shareUsageData: Bool = false
    var autoReportIssues: Bool = true
    
    // Advanced Settings
    var connectionTimeout: TimeInterval = 30
    var retryAttempts: Int = 3
    var enableLogging: Bool = false
    var logLevel: LogLevel = .info
    var maxLogFiles: Int = 5
    var customDNS: [String] = []
    var mtu: Int = 1500
    var keepAliveInterval: TimeInterval = 25
    
    // Network Settings
    var trustedNetworks: [String] = []
    var blockedNetworks: [String] = []
    var routingRules: [RoutingRule] = []
    var portForwarding: [PortForwardingRule] = []
    
    // Subscription Settings
    var subscriptionURLs: [SubscriptionURL] = []
    var autoUpdateInterval: TimeInterval = 86400 // 24 hours
    var lastSubscriptionUpdate: Date?
    
    // Statistics Settings
    var trackDataUsage: Bool = true
    var resetStatisticsMonthly: Bool = true
    var exportStatistics: Bool = false
    
    // Metadata
    var version: String = "1.0.0"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // MARK: - Default Settings
    static let `default` = UserSettings()
    
    // MARK: - Validation
    var isValid: Bool {
        // Validate DNS server
        guard !dnsServer.isEmpty, dnsServer.isValidIPAddress else { return false }
        
        // Validate connection timeout
        guard connectionTimeout > 0 && connectionTimeout <= 300 else { return false }
        
        // Validate retry attempts
        guard retryAttempts > 0 && retryAttempts <= 10 else { return false }
        
        // Validate MTU
        guard mtu >= 576 && mtu <= 9000 else { return false }
        
        // Validate keep alive interval
        guard keepAliveInterval > 0 && keepAliveInterval <= 300 else { return false }
        
        return true
    }
    
    // MARK: - Helper Methods
    mutating func resetToDefaults() {
        self = UserSettings.default
    }
    
    mutating func updateVersion(_ newVersion: String) {
        version = newVersion
        updatedAt = Date()
    }
    
    mutating func addCustomDNS(_ dns: String) {
        guard dns.isValidIPAddress && !customDNS.contains(dns) else { return }
        customDNS.append(dns)
        updatedAt = Date()
    }
    
    mutating func removeCustomDNS(_ dns: String) {
        customDNS.removeAll { $0 == dns }
        updatedAt = Date()
    }
    
    mutating func addTrustedNetwork(_ network: String) {
        guard !network.isEmpty && !trustedNetworks.contains(network) else { return }
        trustedNetworks.append(network)
        updatedAt = Date()
    }
    
    mutating func removeTrustedNetwork(_ network: String) {
        trustedNetworks.removeAll { $0 == network }
        updatedAt = Date()
    }
    
    mutating func addSubscriptionURL(_ url: SubscriptionURL) {
        guard !subscriptionURLs.contains(where: { $0.id == url.id }) else { return }
        subscriptionURLs.append(url)
        updatedAt = Date()
    }
    
    mutating func removeSubscriptionURL(_ id: String) {
        subscriptionURLs.removeAll { $0.id == id }
        updatedAt = Date()
    }
    
    mutating func markSubscriptionUpdated() {
        lastSubscriptionUpdate = Date()
        updatedAt = Date()
    }
}

// MARK: - Supported Languages
enum SupportedLanguage: String, Codable, CaseIterable {
    case english = "en"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case russian = "ru"
    case arabic = "ar"
    case portuguese = "pt"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "中文"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .spanish:
            return "Español"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .russian:
            return "Русский"
        case .arabic:
            return "العربية"
        case .portuguese:
            return "Português"
        }
    }
    
    var locale: Locale {
        return Locale(identifier: self.rawValue)
    }
}

// MARK: - Log Level
enum LogLevel: String, Codable, CaseIterable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var priority: Int {
        switch self {
        case .debug:
            return 0
        case .info:
            return 1
        case .warning:
            return 2
        case .error:
            return 3
        case .critical:
            return 4
        }
    }
}

// MARK: - Routing Rule
struct RoutingRule: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var domain: String
    var action: RoutingAction
    var priority: Int
    var isEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        domain: String,
        action: RoutingAction,
        priority: Int = 0,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.domain = domain
        self.action = action
        self.priority = priority
        self.isEnabled = isEnabled
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum RoutingAction: String, Codable, CaseIterable {
    case proxy = "proxy"
    case direct = "direct"
    case block = "block"
    
    var displayName: String {
        switch self {
        case .proxy:
            return "Use Proxy"
        case .direct:
            return "Direct Connection"
        case .block:
            return "Block"
        }
    }
}

// MARK: - Port Forwarding Rule
struct PortForwardingRule: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var localPort: Int
    var remotePort: Int
    var remoteHost: String
    var protocol: ForwardingProtocol
    var isEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        localPort: Int,
        remotePort: Int,
        remoteHost: String,
        protocol: ForwardingProtocol = .tcp,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.localPort = localPort
        self.remotePort = remotePort
        self.remoteHost = remoteHost
        self.protocol = `protocol`
        self.isEnabled = isEnabled
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ForwardingProtocol: String, Codable, CaseIterable {
    case tcp = "tcp"
    case udp = "udp"
    case both = "both"
    
    var displayName: String {
        return rawValue.uppercased()
    }
}

// MARK: - Subscription URL
struct SubscriptionURL: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var url: String
    var isEnabled: Bool
    var lastUpdate: Date?
    var serverCount: Int
    var updateInterval: TimeInterval
    var autoUpdate: Bool
    var userAgent: String?
    var headers: [String: String]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        url: String,
        isEnabled: Bool = true,
        serverCount: Int = 0,
        updateInterval: TimeInterval = 86400, // 24 hours
        autoUpdate: Bool = true,
        userAgent: String? = nil,
        headers: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.isEnabled = isEnabled
        self.serverCount = serverCount
        self.updateInterval = updateInterval
        self.autoUpdate = autoUpdate
        self.userAgent = userAgent
        self.headers = headers
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var isUpdateNeeded: Bool {
        guard autoUpdate, let lastUpdate = lastUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) >= updateInterval
    }
    
    mutating func markUpdated(serverCount: Int) {
        self.lastUpdate = Date()
        self.serverCount = serverCount
        self.updatedAt = Date()
    }
}

// MARK: - Trusted Network
struct TrustedNetwork: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var ssid: String
    var isEnabled: Bool
    var autoDisconnect: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        ssid: String,
        isEnabled: Bool = true,
        autoDisconnect: Bool = true
    ) {
        self.id = id
        self.name = name
        self.ssid = ssid
        self.isEnabled = isEnabled
        self.autoDisconnect = autoDisconnect
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Connection Statistics
struct ConnectionStatistics: Codable, Equatable {
    var totalConnections: Int = 0
    var successfulConnections: Int = 0
    var failedConnections: Int = 0
    var totalUpload: Int64 = 0
    var totalDownload: Int64 = 0
    var totalConnectionTime: TimeInterval = 0
    var averageConnectionTime: TimeInterval = 0
    var lastConnection: Date?
    var dailyStats: [String: DailyStats] = [:] // Date string as key
    
    mutating func recordConnection(success: Bool, duration: TimeInterval, upload: Int64, download: Int64) {
        totalConnections += 1
        
        if success {
            successfulConnections += 1
            totalConnectionTime += duration
            averageConnectionTime = totalConnectionTime / Double(successfulConnections)
        } else {
            failedConnections += 1
        }
        
        totalUpload += upload
        totalDownload += download
        lastConnection = Date()
        
        // Update daily stats
        let today = DateFormatter.dayKey.string(from: Date())
        var todayStats = dailyStats[today] ?? DailyStats()
        todayStats.connections += 1
        todayStats.upload += upload
        todayStats.download += download
        todayStats.connectionTime += duration
        dailyStats[today] = todayStats
    }
    
    mutating func reset() {
        totalConnections = 0
        successfulConnections = 0
        failedConnections = 0
        totalUpload = 0
        totalDownload = 0
        totalConnectionTime = 0
        averageConnectionTime = 0
        lastConnection = nil
        dailyStats.removeAll()
    }
}

struct DailyStats: Codable, Equatable {
    var connections: Int = 0
    var upload: Int64 = 0
    var download: Int64 = 0
    var connectionTime: TimeInterval = 0
}

// MARK: - Extensions
extension DateFormatter {
    static let dayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}