import Foundation
// Global types imported via RayLinkTypes
import SwiftUI
import Combine
import StoreKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var autoConnect = false
    @Published var connectOnDemand = false
    @Published var dnsServer = "8.8.8.8"
    @Published var selectedTheme = AppTheme.Theme.system
    @Published var hapticFeedback = true
    @Published var selectedLanguage = SupportedLanguage.english
    @Published var analyticsEnabled = true
    @Published var crashReportsEnabled = true
    @Published var showingConfirmation = false
    @Published var confirmationMessage = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var storageManager: StorageManagerProtocol?
    private var confirmationAction: (() -> Void)?
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    func setup(storageManager: StorageManagerProtocol) {
        self.storageManager = storageManager
        loadSettings()
    }
    
    func saveSettings() {
        guard let storageManager = storageManager else { return }
        
        let settings = UserSettings(
            autoConnect: autoConnect,
            connectOnDemand: connectOnDemand,
            dnsServer: dnsServer,
            theme: selectedTheme,
            hapticFeedback: hapticFeedback,
            language: selectedLanguage,
            analyticsEnabled: analyticsEnabled,
            crashReportsEnabled: crashReportsEnabled
        )
        
        do {
            try storageManager.saveUserSettings(settings)
            
            // Apply theme changes immediately
            applyTheme(selectedTheme)
            
        } catch {
            showErrorMessage("Failed to save settings: \(error.localizedDescription)")
        }
    }
    
    func requestClearAllData() {
        confirmationMessage = "This will delete all servers, settings, and data. This action cannot be undone."
        confirmationAction = clearAllData
        showingConfirmation = true
    }
    
    func executeConfirmationAction() {
        confirmationAction?()
        confirmationAction = nil
    }
    
    func rateApp() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        SKStoreReviewController.requestReview(in: scene)
    }
    
    func cleanConfigs() {
        // Implement config cleaning logic
        showErrorMessage("Config cleaning feature coming soon!")
    }
    
    private func loadSettings() {
        guard let storageManager = storageManager else { return }
        
        do {
            let settings = try storageManager.loadUserSettings()
            
            autoConnect = settings.autoConnect
            connectOnDemand = settings.connectOnDemand
            dnsServer = settings.dnsServer
            selectedTheme = settings.theme
            hapticFeedback = settings.hapticFeedback
            selectedLanguage = settings.language
            analyticsEnabled = settings.analyticsEnabled
            crashReportsEnabled = settings.crashReportsEnabled
            
        } catch {
            // Use default settings if loading fails
            print("Failed to load settings, using defaults: \(error)")
        }
    }
    
    private func clearAllData() {
        guard let storageManager = storageManager else { return }
        
        storageManager.clearAllData()
        
        // Reset to default settings
        autoConnect = false
        connectOnDemand = false
        dnsServer = "8.8.8.8"
        selectedTheme = .system
        hapticFeedback = true
        selectedLanguage = .english
        analyticsEnabled = true
        crashReportsEnabled = true
        
        // Save default settings
        saveSettings()
    }
    
    private func applyTheme(_ theme: AppTheme.Theme) {
        let userInterfaceStyle: UIUserInterfaceStyle
        
        switch theme {
        case .light:
            userInterfaceStyle = .light
        case .dark:
            userInterfaceStyle = .dark
        case .aurora:
            userInterfaceStyle = .unspecified
        case .system:
            userInterfaceStyle = .unspecified
        }
        
        // Apply to all windows
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.overrideUserInterfaceStyle = userInterfaceStyle
            }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Supporting ViewModels

@MainActor
final class TrustedNetworksViewModel: ObservableObject {
    @Published var trustedNetworks: [TrustedNetwork] = []
    
    func addTrustedNetwork(_ network: TrustedNetwork) {
        trustedNetworks.append(network)
        saveNetworks()
    }
    
    func removeTrustedNetwork(at index: Int) {
        trustedNetworks.remove(at: index)
        saveNetworks()
    }
    
    func updateNetwork(_ network: TrustedNetwork, isEnabled: Bool) {
        if let index = trustedNetworks.firstIndex(where: { $0.id == network.id }) {
            trustedNetworks[index].isEnabled = isEnabled
            saveNetworks()
        }
    }
    
    private func saveNetworks() {
        // Save to storage
        UserDefaults.standard.set(
            try? JSONEncoder().encode(trustedNetworks),
            forKey: "trusted_networks"
        )
    }
    
    private func loadNetworks() {
        guard let data = UserDefaults.standard.data(forKey: "trusted_networks"),
              let networks = try? JSONDecoder().decode([TrustedNetwork].self, from: data) else {
            return
        }
        
        trustedNetworks = networks
    }
    
    init() {
        loadNetworks()
    }
}

@MainActor
final class DataUsageViewModel: ObservableObject {
    @Published var currentMonthUpload: Int64 = 0
    @Published var currentMonthDownload: Int64 = 0
    @Published var currentMonthVPNUpload: Int64 = 0
    @Published var currentMonthVPNDownload: Int64 = 0
    @Published var allTimeUpload: Int64 = 0
    @Published var allTimeDownload: Int64 = 0
    @Published var allTimeVPNUpload: Int64 = 0
    @Published var allTimeVPNDownload: Int64 = 0
    
    func loadDataUsage() {
        // In a real implementation, this would load actual usage data
        // For now, using sample data
        currentMonthUpload = Int64.random(in: 100_000_000...1_000_000_000)
        currentMonthDownload = Int64.random(in: 500_000_000...5_000_000_000)
        currentMonthVPNUpload = Int64.random(in: 50_000_000...500_000_000)
        currentMonthVPNDownload = Int64.random(in: 200_000_000...2_000_000_000)
        
        allTimeUpload = currentMonthUpload * Int64.random(in: 3...12)
        allTimeDownload = currentMonthDownload * Int64.random(in: 3...12)
        allTimeVPNUpload = currentMonthVPNUpload * Int64.random(in: 3...12)
        allTimeVPNDownload = currentMonthVPNDownload * Int64.random(in: 3...12)
    }
    
    func resetStatistics() {
        currentMonthUpload = 0
        currentMonthDownload = 0
        currentMonthVPNUpload = 0
        currentMonthVPNDownload = 0
        allTimeUpload = 0
        allTimeDownload = 0
        allTimeVPNUpload = 0
        allTimeVPNDownload = 0
        
        // Save reset values
        UserDefaults.standard.set(0, forKey: "data_usage_reset_date")
    }
}