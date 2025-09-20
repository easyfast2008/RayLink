import SwiftUI
// Global types imported via RayLinkTypes
import NetworkExtension
import Combine

@main
struct RayLinkApp: App {
    @StateObject private var container = DependencyContainer.shared
    @StateObject private var coordinator = NavigationCoordinator()

    init() {
        setupAppearance()
        requestVPNPermissions()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                ContentView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        coordinator.view(for: destination)
                    }
            }
            .environmentObject(container)
            .environmentObject(coordinator)
            .onAppear {
                coordinator.start()
            }
        }
    }

    private func setupAppearance() {
        // Configure app-wide appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.Colors.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.Colors.primary)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    private func requestVPNPermissions() {
        Task {
            do {
                try await NEVPNManager.shared().loadFromPreferences()
            } catch {
                print("Failed to load VPN preferences: \(error)")
            }
        }
    }
}