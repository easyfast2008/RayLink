import SwiftUI
import Combine
import Foundation
struct NewSettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    configurationSection
                    toolsSection
                    generalSection
                }
                .padding()
            }
            .auroraBackground()
            .navigationTitle("Setting")
            .navigationBarTitleDisplayMode(.inline)
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
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // VIP Membership Banner
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Backup Membership via Telegram Bot")
                            .font(AppTheme.Typography.titleMedium)
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Spacer()
                        
                        Text("VIP")
                            .font(AppTheme.Typography.labelSmall)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Backup your membership to get deals on new apps. Available only for Permanent VIP and Year VIP. Note: Your device ID will be uploaded to our server and we will not share your device information with any organization or individual.")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.leading)
                        
                        Text("Starting with version 1.6, you will not be able to purchase VIP services.")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .padding()
            .glassmorphicCard()
        }
    }
    
    private var configurationSection: some View {
        VStack(spacing: 16) {
            // Configuration Section
            VStack(spacing: 0) {
                NavigationLink(destination: RoutingSettingsView()) {
                    settingsRow(
                        title: "Routings",
                        icon: "arrow.triangle.branch",
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(AppTheme.Colors.textSecondary.opacity(0.2))
                    .padding(.leading, 56)
                
                NavigationLink(destination: DNSSettingsView()) {
                    settingsRow(
                        title: "DNS",
                        icon: "network",
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .glassmorphicCard()
        }
    }
    
    private var toolsSection: some View {
        VStack(spacing: 16) {
            // Tools Section
            VStack(spacing: 0) {
                Button(action: { 
                    coordinator.showSpeedTest() 
                }) {
                    settingsRow(
                        title: "Speed Test",
                        subtitle: "Test Xray configs, measure their delays.",
                        icon: "speedometer",
                        iconColor: .red,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(AppTheme.Colors.textSecondary.opacity(0.2))
                    .padding(.leading, 56)
                
                Button(action: { 
                    viewModel.cleanConfigs() 
                }) {
                    settingsRow(
                        title: "Clean Configs",
                        subtitle: "Test Xray configs, find the unreachable servers in these configs, and delete them.",
                        icon: "trash",
                        iconColor: .red,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(AppTheme.Colors.textSecondary.opacity(0.2))
                    .padding(.leading, 56)
                
                NavigationLink(destination: SubscriptionManagerView()) {
                    settingsRow(
                        title: "Subscriptions",
                        icon: "link",
                        iconColor: .red,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(AppTheme.Colors.textSecondary.opacity(0.2))
                    .padding(.leading, 56)
                
                NavigationLink(destination: AppIconSettingsView()) {
                    settingsRow(
                        title: "App Icon",
                        icon: "app.badge",
                        iconColor: .red,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .glassmorphicCard()
        }
    }
    
    private var generalSection: some View {
        VStack(spacing: 16) {
            // Additional Tools
            VStack(spacing: 0) {
                NavigationLink(destination: ToolBoxView()) {
                    settingsRow(
                        title: "ToolBox",
                        icon: "wrench.and.screwdriver",
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(AppTheme.Colors.textSecondary.opacity(0.2))
                    .padding(.leading, 56)
                
                NavigationLink(destination: GroupAndOrderView()) {
                    settingsRow(
                        title: "Group and Order",
                        icon: "list.bullet",
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(AppTheme.Colors.textSecondary.opacity(0.2))
                    .padding(.leading, 56)
                
                NavigationLink(destination: LogView()) {
                    settingsRow(
                        title: "Log",
                        icon: "doc.text",
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .glassmorphicCard()
        }
    }
    
    // Helper method to create consistent settings rows
    private func settingsRow(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = AppTheme.Colors.accent,
        showChevron: Bool = false
    ) -> some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(AppTheme.Colors.text)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Additional Views

struct RoutingSettingsView: View {
    var body: some View {
        VStack {
            Text("Routing Settings")
                .font(.title2)
                .padding()
            
            Text("Configure routing rules for different destinations")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Routings")
        .navigationBarTitleDisplayMode(.inline)
        .auroraBackground()
    }
}

struct DNSSettingsView: View {
    @State private var primaryDNS = "8.8.8.8"
    @State private var secondaryDNS = "8.8.4.4"
    @State private var enableDoH = false
    @State private var enableDoT = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // DNS Servers Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("DNS Servers")
                        .font(AppTheme.Typography.titleLarge)
                        .foregroundColor(AppTheme.Colors.text)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Primary DNS")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.text)
                            
                            Spacer()
                            
                            TextField("8.8.8.8", text: $primaryDNS)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                        
                        HStack {
                            Text("Secondary DNS")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.text)
                            
                            Spacer()
                            
                            TextField("8.8.4.4", text: $secondaryDNS)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                        }
                    }
                }
                .glassmorphicCard()
                
                // Security Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Security")
                        .font(AppTheme.Typography.titleLarge)
                        .foregroundColor(AppTheme.Colors.text)
                    
                    VStack(spacing: 12) {
                        Toggle("DNS over HTTPS (DoH)", isOn: $enableDoH)
                            .font(AppTheme.Typography.bodyMedium)
                        
                        Toggle("DNS over TLS (DoT)", isOn: $enableDoT)
                            .font(AppTheme.Typography.bodyMedium)
                    }
                }
                .glassmorphicCard()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("DNS")
        .navigationBarTitleDisplayMode(.inline)
        .auroraBackground()
    }
}

struct SubscriptionManagerView: View {
    @State private var subscriptions: [VPNSubscription] = []
    @State private var showingAddSubscription = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if subscriptions.isEmpty {
                    emptyStateView
                } else {
                    subscriptionsList
                }
            }
            .padding()
        }
        .navigationTitle("Subscriptions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSubscription = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView { subscription in
                subscriptions.append(subscription)
            }
        }
        .auroraBackground()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "link")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.accent)
            
            Text("No Subscriptions")
                .font(AppTheme.Typography.titleLarge)
                .foregroundColor(AppTheme.Colors.text)
            
            Text("Add subscription URLs to automatically import and update server configurations")
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Add Subscription") {
                showingAddSubscription = true
            }
            .buttonStyle(AppTheme.ButtonStyles.Primary())
        }
        .glassmorphicCard()
    }
    
    private var subscriptionsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(subscriptions) { subscription in
                SubscriptionRowView(subscription: subscription)
            }
        }
    }
}

struct AppIconSettingsView: View {
    var body: some View {
        VStack {
            Text("App Icon Settings")
                .font(.title2)
                .padding()
            
            Text("Choose your preferred app icon")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .auroraBackground()
    }
}

struct ToolBoxView: View {
    var body: some View {
        VStack {
            Text("ToolBox")
                .font(.title2)
                .padding()
            
            Text("Additional tools and utilities")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("ToolBox")
        .navigationBarTitleDisplayMode(.inline)
        .auroraBackground()
    }
}

struct GroupAndOrderView: View {
    var body: some View {
        VStack {
            Text("Group and Order")
                .font(.title2)
                .padding()
            
            Text("Organize and sort your servers")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Group and Order")
        .navigationBarTitleDisplayMode(.inline)
        .auroraBackground()
    }
}

struct LogView: View {
    var body: some View {
        VStack {
            Text("Application Logs")
                .font(.title2)
                .padding()
            
            Text("View application logs and debug information")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Log")
        .navigationBarTitleDisplayMode(.inline)
        .auroraBackground()
    }
}