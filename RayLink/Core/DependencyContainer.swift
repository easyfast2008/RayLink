import Foundation
// Global types imported via RayLinkTypes
import Combine
import SwiftUI
import UserNotifications

// MARK: - Dependency Container Protocol
protocol DependencyContainerProtocol: ObservableObject {
    var networkService: NetworkServiceProtocol { get }
    var storageManager: StorageManagerProtocol { get }
    var vpnManager: VPNManagerProtocol { get }
}

// MARK: - Dependency Container Implementation
public final class DependencyContainer: DependencyContainerProtocol, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = DependencyContainer()
    
    // MARK: - Dependencies
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()
    
    lazy var storageManager: StorageManagerProtocol = {
        StorageManager()
    }()
    
    lazy var vpnManager: VPNManagerProtocol = {
        // Always use the mock VPN manager in this build configuration
        MockVPNManager()
    }()
    
    // MARK: - Additional Services
    lazy var analyticsService: AnalyticsServiceProtocol = {
        AnalyticsService()
    }()
    
    lazy var notificationService: NotificationServiceProtocol = {
        NotificationService()
    }()
    
    lazy var configService: ConfigServiceProtocol = {
        ConfigService(
            networkService: networkService,
            storageManager: storageManager
        )
    }()
    
    lazy var locationService: LocationServiceProtocol = {
        LocationService()
    }()
    
    lazy var speedTestService: SpeedTestServiceProtocol = {
        SpeedTestService(networkService: networkService)
    }()
    
    // MARK: - Private Initializer
    private init() {
        setupDependencies()
    }
    
    // MARK: - Setup
    private func setupDependencies() {
        // Configure dependencies that need initialization
        configureServices()
    }
    
    private func configureServices() {
        // Configure analytics if enabled
        if let userSettings = try? storageManager.loadUserSettings(),
           userSettings.analyticsEnabled {
            analyticsService.configure()
        }
        
        // Configure notifications
        notificationService.requestPermissions()
    }
}

// MARK: - Analytics Service
protocol AnalyticsServiceProtocol {
    func configure()
    func track(event: AnalyticsEvent)
    func setUserProperty(_ value: String, forName name: String)
}

final class AnalyticsService: AnalyticsServiceProtocol {
    private var isConfigured = false
    
    func configure() {
        guard !isConfigured else { return }
        
        // In a real implementation, you would configure analytics SDK here
        // For example: Firebase Analytics, Mixpanel, etc.
        print("Analytics service configured")
        isConfigured = true
    }
    
    func track(event: AnalyticsEvent) {
        guard isConfigured else { return }
        
        // Track analytics event
        print("Analytics event: \(event.name) with parameters: \(event.parameters)")
    }
    
    func setUserProperty(_ value: String, forName name: String) {
        guard isConfigured else { return }
        
        // Set user property
        print("Analytics user property: \(name) = \(value)")
    }
}

public struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    
    static func vpnConnected(protocol: VPNProtocol, country: String?) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "vpn_connected",
            parameters: [
                "protocol": `protocol`.rawValue,
                "country": country ?? "unknown"
            ]
        )
    }
    
    static func vpnDisconnected(duration: TimeInterval) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "vpn_disconnected",
            parameters: [
                "duration": duration
            ]
        )
    }
    
    static func serverImported(count: Int, source: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "servers_imported",
            parameters: [
                "count": count,
                "source": source
            ]
        )
    }
}

// MARK: - Notification Service
protocol NotificationServiceProtocol {
    func requestPermissions()
    func scheduleNotification(_ notification: AppNotification)
    func cancelNotification(withIdentifier identifier: String)
    func cancelAllNotifications()
}

final class NotificationService: NotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    
    func requestPermissions() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else {
                print("Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func scheduleNotification(_ notification: AppNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        
        if let badge = notification.badge {
            content.badge = NSNumber(value: badge)
        }
        
        let request = UNNotificationRequest(
            identifier: notification.identifier,
            content: content,
            trigger: notification.trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}

public struct AppNotification {
    let identifier: String
    let title: String
    let body: String
    let badge: Int?
    let trigger: UNNotificationTrigger?
    
    static func connectionLost() -> AppNotification {
        AppNotification(
            identifier: "connection_lost",
            title: "VPN Connection Lost",
            body: "Your VPN connection has been interrupted",
            badge: nil,
            trigger: nil
        )
    }
    
    static func connectionRestored() -> AppNotification {
        AppNotification(
            identifier: "connection_restored",
            title: "VPN Connection Restored",
            body: "Your VPN connection has been restored",
            badge: nil,
            trigger: nil
        )
    }
    
    static func subscriptionUpdateAvailable(count: Int) -> AppNotification {
        AppNotification(
            identifier: "subscription_update",
            title: "Server Update Available",
            body: "\(count) new servers are available",
            badge: count,
            trigger: nil
        )
    }
}

// MARK: - Config Service
protocol ConfigServiceProtocol {
    func importConfiguration(from url: URL) async throws -> [VPNServer]
    func exportConfiguration(_ servers: [VPNServer]) async throws -> URL
    func validateConfiguration(_ config: [String: Any]) -> Bool
}

final class ConfigService: ConfigServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let storageManager: StorageManagerProtocol
    
    init(networkService: NetworkServiceProtocol, storageManager: StorageManagerProtocol) {
        self.networkService = networkService
        self.storageManager = storageManager
    }
    
    func importConfiguration(from url: URL) async throws -> [VPNServer] {
        let data = try await networkService.downloadConfig(from: url)
        
        // Parse configuration data
        // This would involve parsing various config formats
        return []
    }
    
    func exportConfiguration(_ servers: [VPNServer]) async throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let configData = [
            "version": "1.0",
            "app": "RayLink",
            "servers": servers.map { $0.toDictionary() }
        ]
        
        let data = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsPath.appendingPathComponent("raylink-config-\(Date().timeIntervalSince1970).json")
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    func validateConfiguration(_ config: [String: Any]) -> Bool {
        // Validate configuration structure
        guard config["version"] is String,
              config["servers"] is [[String: Any]] else {
            return false
        }
        
        return true
    }
}

// MARK: - Location Service
protocol LocationServiceProtocol {
    func getCurrentLocation() async throws -> Location
    func getLocationInfo(for address: String) async throws -> Location?
}

final class LocationService: LocationServiceProtocol {
    func getCurrentLocation() async throws -> Location {
        // In a real implementation, this would use Core Location
        // For now, return a mock location
        return Location(
            country: "United States",
            countryCode: "US",
            city: "San Francisco",
            region: "California",
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
    
    func getLocationInfo(for address: String) async throws -> Location? {
        // In a real implementation, this would use geocoding services
        return nil
    }
}

public struct Location: Codable {
    let country: String
    let countryCode: String
    let city: String
    let region: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Speed Test Service
protocol SpeedTestServiceProtocol {
    func runSpeedTest() async throws -> SpeedTestResult
}

final class SpeedTestService: SpeedTestServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func runSpeedTest() async throws -> SpeedTestResult {
        // In a real implementation, this would perform actual speed tests
        // For now, return mock results
        
        let downloadSpeed = Double.random(in: 10...100) // Mbps
        let uploadSpeed = Double.random(in: 5...50) // Mbps
        let ping = Int.random(in: 10...200) // ms
        
        return SpeedTestResult(
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            ping: ping,
            timestamp: Date()
        )
    }
}

public struct SpeedTestResult: Codable, Hashable {
    let downloadSpeed: Double // Mbps
    let uploadSpeed: Double // Mbps
    let ping: Int // ms
    let timestamp: Date
    
    var downloadSpeedFormatted: String {
        return String(format: "%.1f Mbps", downloadSpeed)
    }
    
    var uploadSpeedFormatted: String {
        return String(format: "%.1f Mbps", uploadSpeed)
    }
    
    var grade: SpeedGrade {
        if downloadSpeed >= 50 {
            return .excellent
        } else if downloadSpeed >= 25 {
            return .good
        } else if downloadSpeed >= 10 {
            return .fair
        } else {
            return .poor
        }
    }
}

public enum SpeedGrade: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var color: Color {
        switch self {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .fair:
            return .orange
        case .poor:
            return .red
        }
    }
}

// MARK: - Environment Object Extension
extension EnvironmentValues {
    var container: DependencyContainer {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

private struct ContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

// MARK: - View Extension
extension View {
    func withDependencies() -> some View {
        self.environmentObject(DependencyContainer.shared)
    }
}