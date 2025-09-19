import SwiftUI
import Foundation
struct SubscriptionRowView: View {
    let subscription: VPNSubscription
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.displayName)
                        .font(AppTheme.Typography.titleMedium)
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Text(subscription.url)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(subscription.serverCount) servers")
                        .font(AppTheme.Typography.labelMedium)
                        .foregroundColor(AppTheme.Colors.accent)
                    
                    Text(subscription.lastUpdatedString)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            HStack {
                statusIndicator
                
                Spacer()
                
                Button(action: { showingDetails = true }) {
                    Text("Details")
                        .font(AppTheme.Typography.labelMedium)
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
        }
        .padding()
        .glassmorphicCard()
        .sheet(isPresented: $showingDetails) {
            SubscriptionDetailView(subscription: subscription)
        }
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(subscription.isEnabled ? AppTheme.Colors.connected : AppTheme.Colors.disconnected)
                .frame(width: 8, height: 8)
            
            Text(subscription.isEnabled ? "Active" : "Disabled")
                .font(AppTheme.Typography.bodySmall)
                .foregroundColor(subscription.isEnabled ? AppTheme.Colors.connected : AppTheme.Colors.disconnected)
            
            if subscription.autoUpdate && subscription.isEnabled {
                Text("• Auto-update")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
}

struct SubscriptionDetailView: View {
    let subscription: VPNSubscription
    @Environment(\.dismiss) private var dismiss
    @State private var isEnabled: Bool
    @State private var autoUpdate: Bool
    @State private var selectedInterval: SubscriptionUpdateInterval
    
    init(subscription: VPNSubscription) {
        self.subscription = subscription
        self._isEnabled = State(initialValue: subscription.isEnabled)
        self._autoUpdate = State(initialValue: subscription.autoUpdate)
        self._selectedInterval = State(initialValue: SubscriptionUpdateInterval.from(timeInterval: subscription.updateInterval))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    configurationSection
                    statisticsSection
                    actionsSection
                }
                .padding()
            }
            .auroraBackground()
            .navigationTitle("Subscription Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save changes
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(subscription.displayName)
                .font(AppTheme.Typography.titleLarge)
                .foregroundColor(AppTheme.Colors.text)
            
            Text(subscription.url)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassmorphicCard()
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuration")
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            VStack(spacing: 12) {
                Toggle("Enable Subscription", isOn: $isEnabled)
                    .font(AppTheme.Typography.bodyMedium)
                
                Toggle("Auto Update", isOn: $autoUpdate)
                    .font(AppTheme.Typography.bodyMedium)
                    .disabled(!isEnabled)
                
                if autoUpdate && isEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update Interval")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Picker("Update Interval", selection: $selectedInterval) {
                            ForEach(SubscriptionUpdateInterval.allCases) { interval in
                                Text(interval.displayName).tag(interval)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
        }
        .glassmorphicCard()
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            VStack(spacing: 12) {
                statRow(title: "Server Count", value: "\(subscription.serverCount)")
                statRow(title: "Last Updated", value: subscription.lastUpdatedString)
                statRow(title: "Created", value: formatDate(subscription.createdAt))
            }
        }
        .glassmorphicCard()
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button("Update Now") {
                // Trigger manual update
            }
            .buttonStyle(AppTheme.ButtonStyles.Primary())
            .disabled(!isEnabled)
            
            Button("Test Connection") {
                // Test subscription URL
            }
            .buttonStyle(AppTheme.ButtonStyles.Secondary())
            
            Button("Delete Subscription") {
                // Delete subscription with confirmation
            }
            .buttonStyle(AppTheme.ButtonStyles.Destructive())
        }
        .glassmorphicCard()
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AddSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionURL = ""
    @State private var subscriptionName = ""
    @State private var selectedInterval = SubscriptionUpdateInterval.hour1
    @State private var autoUpdate = true
    @State private var isValidating = false
    @State private var validationError = ""
    
    let onSave: (VPNSubscription) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    urlInputSection
                    configurationSection
                    
                    if !validationError.isEmpty {
                        errorSection
                    }
                }
                .padding()
            }
            .auroraBackground()
            .navigationTitle("Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(subscriptionURL.isEmpty || isValidating)
                }
            }
        }
    }
    
    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscription Details")
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Subscription URL")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.Colors.text)
                    
                    TextField("https://example.com/subscription", text: $subscriptionURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionType(.no)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name (Optional)")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.Colors.text)
                    
                    TextField("My VPN Subscription", text: $subscriptionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .glassmorphicCard()
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Update Settings")
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            VStack(spacing: 12) {
                Toggle("Enable Auto Update", isOn: $autoUpdate)
                    .font(AppTheme.Typography.bodyMedium)
                
                if autoUpdate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update Interval")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Picker("Update Interval", selection: $selectedInterval) {
                            ForEach(SubscriptionUpdateInterval.allCases.filter { $0 != .manual }) { interval in
                                Text(interval.displayName).tag(interval)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
        }
        .glassmorphicCard()
    }
    
    private var errorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text("Validation Error")
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(.red)
            }
            
            Text(validationError)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .glassmorphicCard()
    }
    
    private func saveSubscription() {
        guard !subscriptionURL.isEmpty else { return }
        
        let subscription = VPNSubscription(
            name: subscriptionName,
            url: subscriptionURL,
            updateInterval: selectedInterval.timeInterval,
            autoUpdate: autoUpdate
        )
        
        onSave(subscription)
        dismiss()
    }
}