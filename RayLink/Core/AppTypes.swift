import Foundation
import SwiftUI
import Combine
// This file re-exports all common types used throughout the app
// to fix "Cannot find type in scope" errors

// Re-export from Models
typealias VPNServer = RayLink.VPNServer
typealias VPNProtocol = RayLink.VPNProtocol
typealias UserSettings = RayLink.UserSettings
typealias VPNSubscription = RayLink.VPNSubscription

// Re-export from Core
typealias NavigationCoordinator = RayLink.NavigationCoordinator
typealias NavigationDestination = RayLink.NavigationDestination
typealias DependencyContainer = RayLink.DependencyContainer

// Re-export from Design
typealias AppTheme = RayLink.AppTheme

// Common types
typealias SpeedTestResult = RayLink.SpeedTestResult

// Alert item for navigation
struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: String
}

// Re-export or define other missing types
struct TrustedNetwork: Identifiable, Codable {
    let id = UUID()
    var name: String
    var ssid: String
    var isEnabled: Bool
}

struct DataUsageViewModel: ObservableObject {
    @Published var uploadBytes: Int64 = 0
    @Published var downloadBytes: Int64 = 0
}

struct TrustedNetworksViewModel: ObservableObject {
    @Published var networks: [TrustedNetwork] = []
}

// For Settings
struct SettingsViewModel: ObservableObject {
    @Published var userSettings = UserSettings()
}

// For Import
struct ImportViewModel: ObservableObject {
    @Published var importedServers: [VPNServer] = []
    @Published var isImporting = false
    @Published var importStatus = ""
    @Published var error: Error?
}

// For ServerList
struct ServerListViewModel: ObservableObject {
    @Published var servers: [VPNServer] = []
    @Published var selectedServer: VPNServer?
    @Published var currentServer: VPNServer?
    @Published var connectionStatus: VPNConnectionStatus = .disconnected
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isTestingAll = false
    
    private var vpnManager: VPNManagerProtocol?
    private var storageManager: StorageManagerProtocol?
    
    func setup(vpnManager: VPNManagerProtocol, storageManager: StorageManagerProtocol) {
        self.vpnManager = vpnManager
        self.storageManager = storageManager
        loadServers()
    }
    
    func loadServers() {
        // Implementation
    }
    
    func addServer(_ server: VPNServer) {
        servers.append(server)
    }
    
    func deleteServer(_ server: VPNServer) {
        servers.removeAll { $0.id == server.id }
    }
    
    func selectServer(_ server: VPNServer) {
        selectedServer = server
    }
    
    func connectToServer(_ server: VPNServer) async {
        // Implementation
    }
    
    func refreshAllServers() async {
        // Implementation
    }
    
    func testAllServers() async {
        // Implementation
    }
    
    func testGroupServers(_ servers: [VPNServer]) async {
        // Implementation
    }
}

// For Home
struct HomeViewModel: ObservableObject {
    @Published var connectionStatus: VPNConnectionStatus = .disconnected
    @Published var selectedServer: VPNServer?
    @Published var connectionMode: ConnectionMode = .automatic
    @Published var connectionStartTime: Date?
    @Published var uploadSpeed: Double = 0
    @Published var downloadSpeed: Double = 0
    @Published var uploadBytes: Int64 = 0
    @Published var downloadBytes: Int64 = 0
    @Published var currentLocation = "Unknown"
    @Published var serverPing = 0
    
    enum ConnectionMode: String, CaseIterable {
        case automatic = "AUTOMATIC"
        case global = "GLOBAL"
        case direct = "DIRECT"
    }
}

// VPN Connection Status
enum VPNConnectionStatus: String {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnecting = "Disconnecting"
    case reasserting = "Reasserting"
    case invalid = "Invalid"
}

// Missing view models
class SubscriptionManagerViewModel: ObservableObject {
    @Published var subscriptions: [VPNSubscription] = []
}

class RoutingSettingsViewModel: ObservableObject {
    @Published var rules: [String] = []
}

class DNSSettingsViewModel: ObservableObject {
    @Published var primaryDNS = "1.1.1.1"
    @Published var secondaryDNS = "8.8.8.8"
}

class SpeedTestViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var results: [SpeedTestResult] = []
}