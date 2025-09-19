import Foundation

struct VPNSubscription: Codable, Identifiable {
    let id: String
    var name: String
    let url: String
    var isEnabled: Bool
    var lastUpdated: Date?
    var serverCount: Int
    var updateInterval: TimeInterval // in seconds
    var autoUpdate: Bool
    var userAgent: String?
    var customHeaders: [String: String]?
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        url: String,
        isEnabled: Bool = true,
        lastUpdated: Date? = nil,
        serverCount: Int = 0,
        updateInterval: TimeInterval = 3600, // 1 hour default
        autoUpdate: Bool = true,
        userAgent: String? = nil,
        customHeaders: [String: String]? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.isEnabled = isEnabled
        self.lastUpdated = lastUpdated
        self.serverCount = serverCount
        self.updateInterval = updateInterval
        self.autoUpdate = autoUpdate
        self.userAgent = userAgent
        self.customHeaders = customHeaders
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
    }
    
    var displayName: String {
        name.isEmpty ? URL(string: url)?.host ?? "Unknown" : name
    }
    
    var lastUpdatedString: String {
        guard let lastUpdated = lastUpdated else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
    
    var updateIntervalString: String {
        let hours = Int(updateInterval / 3600)
        if hours < 1 {
            let minutes = Int(updateInterval / 60)
            return "\(minutes) minutes"
        } else if hours == 1 {
            return "1 hour"
        } else if hours < 24 {
            return "\(hours) hours"
        } else {
            let days = hours / 24
            return "\(days) day\(days == 1 ? "" : "s")"
        }
    }
    
    mutating func updateServerCount(_ count: Int) {
        serverCount = count
        lastUpdated = Date()
        updatedAt = Date()
    }
    
    mutating func markAsUpdated() {
        lastUpdated = Date()
        updatedAt = Date()
    }
}

enum SubscriptionUpdateInterval: CaseIterable, Identifiable {
    case minutes15
    case minutes30
    case hour1
    case hours6
    case hours12
    case day1
    case days3
    case week1
    case manual
    
    var id: String { displayName }
    
    var displayName: String {
        switch self {
        case .minutes15: return "15 minutes"
        case .minutes30: return "30 minutes"
        case .hour1: return "1 hour"
        case .hours6: return "6 hours"
        case .hours12: return "12 hours"
        case .day1: return "1 day"
        case .days3: return "3 days"
        case .week1: return "1 week"
        case .manual: return "Manual only"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .minutes15: return 15 * 60
        case .minutes30: return 30 * 60
        case .hour1: return 3600
        case .hours6: return 6 * 3600
        case .hours12: return 12 * 3600
        case .day1: return 24 * 3600
        case .days3: return 3 * 24 * 3600
        case .week1: return 7 * 24 * 3600
        case .manual: return 0
        }
    }
    
    static func from(timeInterval: TimeInterval) -> SubscriptionUpdateInterval {
        switch timeInterval {
        case 15 * 60: return .minutes15
        case 30 * 60: return .minutes30
        case 3600: return .hour1
        case 6 * 3600: return .hours6
        case 12 * 3600: return .hours12
        case 24 * 3600: return .day1
        case 3 * 24 * 3600: return .days3
        case 7 * 24 * 3600: return .week1
        default: return .manual
        }
    }
}