import SwiftUI
import Foundation
import Combine
// Global types imported via RayLinkTypes

// MARK: - Navigation Destination
public enum NavigationDestination: Hashable {
    case home
    case serverList
    case serverDetail(VPNServer)
    case addServer
    case editServer(VPNServer)
    case settings
    case settingsSection(SettingsSection)
    case import
    case importResult([VPNServer])
    case speedTest
    case speedTestResult(SpeedTestResult)
    case logs
    case about
    case help
    case subscription
    case addSubscription
    case trustedNetworks
    case routingRules
    case dataUsage
    case privacy
    case diagnostics
    case backup
    
    // Settings sections
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

// MARK: - Navigation Coordinator
public final class NavigationCoordinator: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var selectedTab: Int = 0
    @Published public var presentedSheet: NavigationDestination?
    @Published public var presentedFullScreen: NavigationDestination?
    @Published public var alert: AlertItem?
    
    public init() {
        // Public initializer
    }
    
    // Tab-based navigation state
    public enum Tab: Int, CaseIterable {
        case home = 0
        case servers = 1
        case settings = 2
        
        var title: String {
            switch self {
            case .home:
                return "Home"
            case .servers:
                return "Servers"
            case .settings:
                return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .home:
                return "house"
            case .servers:
                return "list.bullet"
            case .settings:
                return "gearshape"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .home:
                return "house.fill"
            case .servers:
                return "list.bullet"
            case .settings:
                return "gearshape.fill"
            }
        }
    }
    
    // MARK: - Navigation Methods
    func start() {
        // Initial setup - can be used for deep linking or onboarding
        selectedTab = Tab.home.rawValue
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .home:
            selectedTab = Tab.home.rawValue
            path = NavigationPath()
        case .serverList:
            selectedTab = Tab.servers.rawValue
            path = NavigationPath()
        case .settings:
            selectedTab = Tab.settings.rawValue
            path = NavigationPath()
        case .addServer, .import, .speedTest:
            presentSheet(destination)
        default:
            path.append(destination)
        }
    }
    
    func push(_ destination: NavigationDestination) {
        path.append(destination)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func presentSheet(_ destination: NavigationDestination) {
        presentedSheet = destination
    }
    
    func presentFullScreen(_ destination: NavigationDestination) {
        presentedFullScreen = destination
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func dismissFullScreen() {
        presentedFullScreen = nil
    }
    
    func showAlert(_ alert: AlertItem) {
        self.alert = alert
    }
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab.rawValue
        path = NavigationPath() // Clear navigation stack when switching tabs
    }
    
    // MARK: - View Factory
    @ViewBuilder
    func view(for destination: NavigationDestination) -> some View {
        switch destination {
        case .home:
            HomeView()
        case .serverList:
            ServerListView()
        case .serverDetail(let server):
            ServerDetailView(server: server)
        case .addServer:
            AddServerView { server in
                // Handle server addition
                self.dismissSheet()
            }
        case .editServer(let server):
            EditServerView(server: server) { updatedServer in
                // Handle server update
                self.dismissSheet()
            }
        case .settings:
            SettingsView()
        case .settingsSection(let section):
            settingsView(for: section)
        case .import:
            ImportView()
        case .importResult(let servers):
            ImportResultView(servers: servers)
        case .speedTest:
            SpeedTestView()
        case .speedTestResult(let result):
            SpeedTestResultView(result: result)
        case .logs:
            LogsView()
        case .about:
            AboutView()
        case .help:
            HelpView()
        case .subscription:
            SubscriptionView()
        case .addSubscription:
            AddSubscriptionView()
        case .trustedNetworks:
            TrustedNetworksView()
        case .routingRules:
            RoutingRulesView()
        case .dataUsage:
            DataUsageView()
        case .privacy:
            PrivacyView()
        case .diagnostics:
            DiagnosticsView()
        case .backup:
            BackupView()
        }
    }
    
    @ViewBuilder
    private func settingsView(for section: NavigationDestination.SettingsSection) -> some View {
        switch section {
        case .connection:
            ConnectionSettingsView()
        case .privacy:
            PrivacySettingsView()
        case .advanced:
            AdvancedSettingsView()
        case .appearance:
            AppearanceSettingsView()
        case .notifications:
            NotificationSettingsView()
        case .subscription:
            SubscriptionSettingsView()
        case .about:
            AboutView()
        }
    }
    
    // MARK: - Deep Linking
    func handle(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme,
              scheme == "raylink" else {
            return false
        }
        
        switch components.host {
        case "servers":
            navigate(to: .serverList)
            return true
        case "settings":
            navigate(to: .settings)
            return true
        case "import":
            if let urlParam = components.queryItems?.first(where: { $0.name == "url" })?.value,
               let importURL = URL(string: urlParam) {
                // Handle subscription URL import
                navigate(to: .import)
            }
            return true
        case "server":
            // Handle specific server deep link
            if let serverId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                // Load and navigate to server detail
                // This would require loading the server from storage
            }
            return true
        default:
            return false
        }
    }
    
    // MARK: - Navigation State
    var canGoBack: Bool {
        !path.isEmpty
    }
    
    var currentTab: Tab? {
        Tab(rawValue: selectedTab)
    }
}

// MARK: - Alert Item
public struct AlertItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let message: String?
    public let primaryButton: AlertButton?
    public let secondaryButton: AlertButton?
    
    init(
        title: String,
        message: String? = nil,
        primaryButton: AlertButton? = AlertButton.ok(),
        secondaryButton: AlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

public struct AlertButton {
    let title: String
    let action: () -> Void
    let style: AlertButtonStyle
    
    enum AlertButtonStyle {
        case `default`
        case cancel
        case destructive
    }
    
    static func ok(action: @escaping () -> Void = {}) -> AlertButton {
        AlertButton(title: "OK", action: action, style: .default)
    }
    
    static func cancel(action: @escaping () -> Void = {}) -> AlertButton {
        AlertButton(title: "Cancel", action: action, style: .cancel)
    }
    
    static func destructive(title: String, action: @escaping () -> Void) -> AlertButton {
        AlertButton(title: title, action: action, style: .destructive)
    }
}

// MARK: - Placeholder Views (These would be implemented separately)
struct ServerDetailView: View {
    let server: VPNServer
    
    var body: some View {
        VStack {
            Text("Server Detail")
            Text(server.name)
        }
        .navigationTitle(server.name)
    }
}

struct EditServerView: View {
    let server: VPNServer
    let onSave: (VPNServer) -> Void
    
    var body: some View {
        VStack {
            Text("Edit Server")
            Text(server.name)
        }
        .navigationTitle("Edit Server")
    }
}

struct ImportResultView: View {
    let servers: [VPNServer]
    
    var body: some View {
        VStack {
            Text("Import Result")
            Text("\(servers.count) servers imported")
        }
        .navigationTitle("Import Result")
    }
}

struct SpeedTestView: View {
    var body: some View {
        VStack {
            Text("Speed Test")
        }
        .navigationTitle("Speed Test")
    }
}

struct SpeedTestResultView: View {
    let result: SpeedTestResult
    
    var body: some View {
        VStack {
            Text("Speed Test Result")
            Text("Download: \(result.downloadSpeedFormatted)")
            Text("Upload: \(result.uploadSpeedFormatted)")
            Text("Ping: \(result.ping)ms")
        }
        .navigationTitle("Speed Test Result")
    }
}

struct LogsView: View {
    var body: some View {
        VStack {
            Text("Logs")
        }
        .navigationTitle("Logs")
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("About RayLink")
        }
        .navigationTitle("About")
    }
}

struct HelpView: View {
    var body: some View {
        VStack {
            Text("Help & Support")
        }
        .navigationTitle("Help")
    }
}

struct SubscriptionView: View {
    var body: some View {
        VStack {
            Text("Subscriptions")
        }
        .navigationTitle("Subscriptions")
    }
}

struct AddSubscriptionView: View {
    var body: some View {
        VStack {
            Text("Add Subscription")
        }
        .navigationTitle("Add Subscription")
    }
}

struct RoutingRulesView: View {
    var body: some View {
        VStack {
            Text("Routing Rules")
        }
        .navigationTitle("Routing Rules")
    }
}

struct PrivacyView: View {
    var body: some View {
        VStack {
            Text("Privacy")
        }
        .navigationTitle("Privacy")
    }
}

struct DiagnosticsView: View {
    var body: some View {
        VStack {
            Text("Diagnostics")
        }
        .navigationTitle("Diagnostics")
    }
}

struct BackupView: View {
    var body: some View {
        VStack {
            Text("Backup & Restore")
        }
        .navigationTitle("Backup")
    }
}

// Settings Detail Views
struct ConnectionSettingsView: View {
    var body: some View {
        VStack {
            Text("Connection Settings")
        }
        .navigationTitle("Connection")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        VStack {
            Text("Privacy Settings")
        }
        .navigationTitle("Privacy")
    }
}

struct AdvancedSettingsView: View {
    var body: some View {
        VStack {
            Text("Advanced Settings")
        }
        .navigationTitle("Advanced")
    }
}

struct AppearanceSettingsView: View {
    var body: some View {
        VStack {
            Text("Appearance Settings")
        }
        .navigationTitle("Appearance")
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        VStack {
            Text("Notification Settings")
        }
        .navigationTitle("Notifications")
    }
}

struct SubscriptionSettingsView: View {
    var body: some View {
        VStack {
            Text("Subscription Settings")
        }
        .navigationTitle("Subscriptions")
    }
}