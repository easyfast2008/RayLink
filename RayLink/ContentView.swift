import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator

    private var selectionBinding: Binding<Int> {
        Binding(
            get: { coordinator.selectedTab },
            set: { newValue in
                if let tab = NavigationCoordinator.Tab(rawValue: newValue) {
                    coordinator.selectTab(tab)
                } else {
                    coordinator.selectedTab = newValue
                }
            }
        )
    }

    var body: some View {
        TabView(selection: selectionBinding) {
            HomeView()
                .tabItem {
                    Image(systemName: NavigationCoordinator.Tab.home.selectedIcon)
                    Text(NavigationCoordinator.Tab.home.title)
                }
                .tag(NavigationCoordinator.Tab.home.rawValue)

            ServerListView()
                .tabItem {
                    Image(systemName: NavigationCoordinator.Tab.servers.selectedIcon)
                    Text(NavigationCoordinator.Tab.servers.title)
                }
                .tag(NavigationCoordinator.Tab.servers.rawValue)

            SettingsView()
                .tabItem {
                    Image(systemName: NavigationCoordinator.Tab.settings.selectedIcon)
                    Text(NavigationCoordinator.Tab.settings.title)
                }
                .tag(NavigationCoordinator.Tab.settings.rawValue)
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(DependencyContainer.shared)
        .environmentObject(NavigationCoordinator())
}
