import SwiftUI
import Combine
import Foundation
// Global types imported via RayLinkTypes

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        NavigationView {
            List {
                connectionSection
                generalSection
                privacySection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.setup(storageManager: container.storageManager)
            }
            .alert("Confirm", isPresented: $viewModel.showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm", role: .destructive) {
                    viewModel.executeConfirmationAction()
                }
            } message: {
                Text(viewModel.confirmationMessage)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private var connectionSection: some View {
        Section("Connection") {
            Toggle("Auto Connect", isOn: $viewModel.autoConnect)
                .onChangeCompat(of: viewModel.autoConnect) { _ in
                    viewModel.saveSettings()
                }
            
            Toggle("Connect on Demand", isOn: $viewModel.connectOnDemand)
                .onChangeCompat(of: viewModel.connectOnDemand) { _ in
                    viewModel.saveSettings()
                }
            
            NavigationLink("Trusted Networks") {
                TrustedNetworksView()
            }
            
            HStack {
                Text("DNS Server")
                Spacer()
                TextField("8.8.8.8", text: $viewModel.dnsServer)
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        viewModel.saveSettings()
                    }
            }
        }
    }
    
    private var generalSection: some View {
        Section("General") {
            Picker("Theme", selection: $viewModel.selectedTheme) {
                ForEach(AppTheme.Theme.allCases, id: \.self) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .onChangeCompat(of: viewModel.selectedTheme) { _ in
                viewModel.saveSettings()
            }
            
            Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedback)
                .onChangeCompat(of: viewModel.hapticFeedback) { _ in
                    viewModel.saveSettings()
                }
            
            Picker("Language", selection: $viewModel.selectedLanguage) {
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    Text(language.displayName).tag(language)
                }
            }
            .onChangeCompat(of: viewModel.selectedLanguage) { _ in
                viewModel.saveSettings()
            }
        }
    }
    
    private var privacySection: some View {
        Section("Privacy & Security") {
            Toggle("Analytics", isOn: $viewModel.analyticsEnabled)
                .onChangeCompat(of: viewModel.analyticsEnabled) { _ in
                    viewModel.saveSettings()
                }
            
            Toggle("Crash Reports", isOn: $viewModel.crashReportsEnabled)
                .onChangeCompat(of: viewModel.crashReportsEnabled) { _ in
                    viewModel.saveSettings()
                }
            
            NavigationLink("Data Usage") {
                DataUsageView()
            }
            
            Button("Clear All Data") {
                viewModel.requestClearAllData()
            }
            .foregroundColor(.red)
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(viewModel.appVersion)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(viewModel.buildNumber)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            NavigationLink("Privacy Policy") {
                WebView(url: "https://raylink.app/privacy")
            }
            
            NavigationLink("Terms of Service") {
                WebView(url: "https://raylink.app/terms")
            }
            
            NavigationLink("Support") {
                SupportView()
            }
            
            Button("Rate App") {
                viewModel.rateApp()
            }
        }
    }
}

struct TrustedNetworksView: View {
    @StateObject private var viewModel = TrustedNetworksViewModel()
    @State private var showingAddNetwork = false
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.trustedNetworks) { network in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(network.name)
                                .font(.headline)
                            Text(network.ssid)
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: binding(for: network))
                    }
                }
                .onDelete(perform: deleteNetworks)
            } header: {
                Text("Trusted Networks")
            } footer: {
                Text("VPN will automatically disconnect when connected to trusted networks")
            }
        }
        .navigationTitle("Trusted Networks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    showingAddNetwork = true
                }
            }
        }
        .sheet(isPresented: $showingAddNetwork) {
            AddTrustedNetworkView { network in
                viewModel.addTrustedNetwork(network)
            }
        }
    }
    
    private func binding(for network: TrustedNetwork) -> Binding<Bool> {
        Binding(
            get: { network.isEnabled },
            set: { newValue in
                viewModel.updateNetwork(network, isEnabled: newValue)
            }
        )
    }
    
    private func deleteNetworks(offsets: IndexSet) {
        for index in offsets {
            viewModel.removeTrustedNetwork(at: index)
        }
    }
}

struct DataUsageView: View {
    @StateObject private var viewModel = DataUsageViewModel()
    
    var body: some View {
        List {
            Section("Current Month") {
                dataUsageRow(title: "Total", upload: viewModel.currentMonthUpload, download: viewModel.currentMonthDownload)
                dataUsageRow(title: "VPN", upload: viewModel.currentMonthVPNUpload, download: viewModel.currentMonthVPNDownload)
            }
            
            Section("All Time") {
                dataUsageRow(title: "Total", upload: viewModel.allTimeUpload, download: viewModel.allTimeDownload)
                dataUsageRow(title: "VPN", upload: viewModel.allTimeVPNUpload, download: viewModel.allTimeVPNDownload)
            }
            
            Section {
                Button("Reset Statistics") {
                    viewModel.resetStatistics()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Data Usage")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadDataUsage()
        }
    }
    
    private func dataUsageRow(title: String, upload: Int64, download: Int64) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text((upload + download).formattedByteSize())
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            HStack {
                HStack {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.blue)
                    Text(upload.formattedByteSize())
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.green)
                    Text(download.formattedByteSize())
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
            }
        }
    }
}

struct SupportView: View {
    var body: some View {
        List {
            Section {
                Link(destination: URL(string: "mailto:support@raylink.app")!) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(AppTheme.Colors.accent)
                        Text("Email Support")
                    }
                }
                
                Link(destination: URL(string: "https://raylink.app/faq")!) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(AppTheme.Colors.accent)
                        Text("FAQ")
                    }
                }
                
                Link(destination: URL(string: "https://t.me/raylink_support")!) {
                    HStack {
                        Image(systemName: "message")
                            .foregroundColor(AppTheme.Colors.accent)
                        Text("Telegram Support")
                    }
                }
            }
            
            Section("Diagnostic") {
                Button("Export Logs") {
                    // Implement log export
                }
                
                Button("Test Connectivity") {
                    // Implement connectivity test
                }
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: View {
    let url: String
    
    var body: some View {
        // In a real implementation, you would use WKWebView
        VStack {
            Text("Web View")
            Text(url)
                .font(.caption)
                .foregroundColor(AppTheme.Colors.secondary)
        }
        .navigationTitle("Web")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddTrustedNetworkView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var networkName = ""
    @State private var ssid = ""
    
    let onSave: (TrustedNetwork) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Network Information") {
                    TextField("Network Name", text: $networkName)
                    TextField("WiFi SSID", text: $ssid)
                }
            }
            .navigationTitle("Add Trusted Network")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let network = TrustedNetwork(
                            name: networkName.isEmpty ? ssid : networkName,
                            ssid: ssid,
                            isEnabled: true
                        )
                        onSave(network)
                        dismiss()
                    }
                    .disabled(ssid.isEmpty)
                }
            }
        }
    }
}