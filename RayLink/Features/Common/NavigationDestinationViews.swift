import SwiftUI
import UIKit

// MARK: - Server Management
struct ServerDetailView: View {
    let server: VPNServer

    var body: some View {
        List {
            Section("Connection") {
                detailRow(title: "Address", value: server.address)
                detailRow(title: "Port", value: String(server.port))
                detailRow(title: "Protocol", value: server.serverProtocol.rawValue.uppercased())
                if server.ping > 0 {
                    detailRow(title: "Ping", value: "\(server.ping) ms")
                }
            }

            if let country = server.country {
                Section("Location") {
                    detailRow(title: "Country", value: country)
                    if let city = server.city {
                        detailRow(title: "City", value: city)
                    }
                }
            }

            if !server.tags.isEmpty {
                Section("Tags") {
                    Text(server.tags.joined(separator: ", "))
                }
            }
        }
        .navigationTitle(server.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

struct EditServerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var address: String
    @State private var port: String
    @State private var selectedProtocol: VPNProtocol
    @State private var username: String
    @State private var password: String
    @State private var uuid: String

    private let originalServer: VPNServer
    let onSave: (VPNServer) -> Void

    init(server: VPNServer, onSave: @escaping (VPNServer) -> Void) {
        self.originalServer = server
        self._name = State(initialValue: server.name)
        self._address = State(initialValue: server.address)
        self._port = State(initialValue: String(server.port))
        self._selectedProtocol = State(initialValue: server.serverProtocol)
        self._username = State(initialValue: server.username ?? "")
        self._password = State(initialValue: server.password ?? "")
        self._uuid = State(initialValue: server.uuid ?? "")
        self.onSave = onSave
    }

    var body: some View {
        Form {
            Section("Server") {
                TextField("Name", text: $name)
                TextField("Address", text: $address)
                TextField("Port", text: $port)
                    .keyboardType(.numberPad)

                Picker("Protocol", selection: $selectedProtocol) {
                    ForEach(VPNProtocol.allCases, id: \.self) { protocolOption in
                        Text(protocolOption.rawValue.capitalized).tag(protocolOption)
                    }
                }
            }

            Section("Credentials") {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                TextField("UUID", text: $uuid)
            }
        }
        .navigationTitle("Edit Server")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { save() }
                    .disabled(!isValid)
            }
        }
    }

    private var isValid: Bool {
        guard let portValue = Int(port), portValue > 0 && portValue <= 65535 else {
            return false
        }
        return !name.isEmpty && !address.isEmpty
    }

    private func save() {
        guard let portValue = Int(port) else { return }

        let updated = VPNServer(
            id: originalServer.id,
            name: name,
            address: address,
            port: portValue,
            serverProtocol: selectedProtocol,
            username: username.isEmpty ? nil : username,
            password: password.isEmpty ? nil : password,
            uuid: uuid.isEmpty ? nil : uuid,
            ping: originalServer.ping,
            isActive: originalServer.isActive,
            country: originalServer.country,
            city: originalServer.city,
            region: originalServer.region,
            countryCode: originalServer.countryCode,
            provider: originalServer.provider,
            tags: originalServer.tags
        )

        onSave(updated)
        dismiss()
    }
}

struct ImportResultView: View {
    let servers: [VPNServer]

    var body: some View {
        List {
            Section("Imported Servers") {
                ForEach(servers) { server in
                    VStack(alignment: .leading) {
                        Text(server.name)
                            .font(.headline)
                        Text("\(server.address):\(server.port)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Import Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SpeedTestResultView: View {
    let result: SpeedTestResult

    var body: some View {
        List {
            Section("Performance") {
                detailRow("Download", value: result.downloadSpeedFormatted)
                detailRow("Upload", value: result.uploadSpeedFormatted)
                detailRow("Latency", value: "\(result.ping) ms")
                detailRow("Grade", value: result.grade.rawValue)
            }

            Section("Timestamp") {
                detailRow("Completed", value: format(date: result.timestamp))
            }
        }
        .navigationTitle("Speed Test Result")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Informational Views
struct LogsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("Diagnostics Logs")
                .font(.title2.bold())

            Text("Log collection is not yet available in this build. Connect to a server and return later to view runtime information.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Logs")
    }
}

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        List {
            Section("RayLink") {
                LabeledContent("Version", value: appVersion)
                LabeledContent("Build", value: buildNumber)
            }

            Section("Credits") {
                Text("RayLink is an open-source VPN client prototype showcasing modern SwiftUI techniques and a modular architecture.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section("Support") {
                Label("Visit Documentation", systemImage: "book")
                Label("Contact Support", systemImage: "envelope")
                Label("Join the Community", systemImage: "person.2")
            }
        }
        .navigationTitle("Help")
    }
}

struct SubscriptionView: View {
    @EnvironmentObject private var container: DependencyContainer
    @State private var subscriptions: [VPNSubscription] = []
    @State private var isLoading = false

    var body: some View {
        List {
            if subscriptions.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "link")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("No subscriptions yet")
                            .font(.headline)
                        Text("Add a subscription to keep your server list up to date.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
            } else {
                Section("Subscriptions") {
                    ForEach(subscriptions) { subscription in
                        SubscriptionRowView(subscription: subscription)
                    }
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .navigationTitle("Subscriptions")
        .task(load)
    }

    private func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            if let stored = try container.storageManager.load([VPNSubscription].self, for: .subscriptions) {
                await MainActor.run { subscriptions = stored }
            } else {
                await MainActor.run { subscriptions = [] }
            }
        } catch {
            await MainActor.run { subscriptions = [] }
        }
    }
}

struct RoutingRulesView: View {
    var body: some View {
        List {
            Section("Routing") {
                Text("Custom routing rules are not yet available in this build.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
        .navigationTitle("Routing Rules")
    }
}

struct PrivacyView: View {
    var body: some View {
        List {
            Section("Privacy") {
                Toggle("Send Anonymous Diagnostics", isOn: .constant(false))
                Toggle("Share Usage Data", isOn: .constant(false))
            }
        }
        .navigationTitle("Privacy")
    }
}

struct DiagnosticsView: View {
    var body: some View {
        List {
            Section("Environment") {
                LabeledContent("iOS Version", value: UIDevice.current.systemVersion)
                LabeledContent("Device", value: UIDevice.current.model)
            }

            Section("Status") {
                Text("Diagnostics collection is under development.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Diagnostics")
    }
}

struct BackupView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "externaldrive.badge.icloud")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("Backup & Restore")
                .font(.title2.bold())

            Text("Use iCloud Drive to export your configuration. This feature is planned for a future milestone.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Backup")
    }
}

// MARK: - Settings Sections
struct ConnectionSettingsView: View {
    @State private var autoConnect = false
    @State private var connectOnDemand = false
    @State private var selectedProtocol = VPNProtocol.shadowsocks

    var body: some View {
        Form {
            Toggle("Auto Connect", isOn: $autoConnect)
            Toggle("Connect on Demand", isOn: $connectOnDemand)

            Picker("Preferred Protocol", selection: $selectedProtocol) {
                ForEach(VPNProtocol.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized).tag(option)
                }
            }
        }
        .navigationTitle("Connection")
    }
}

struct PrivacySettingsView: View {
    @State private var analyticsEnabled = false
    @State private var crashReportsEnabled = true

    var body: some View {
        Form {
            Toggle("Share Analytics", isOn: $analyticsEnabled)
            Toggle("Crash Reports", isOn: $crashReportsEnabled)

            Section("Data Retention") {
                Toggle("Keep Usage History", isOn: .constant(true))
                Toggle("Clear Logs on Disconnect", isOn: .constant(true))
            }
        }
        .navigationTitle("Privacy")
    }
}

struct AdvancedSettingsView: View {
    @State private var enableParallelConnections = false
    @State private var enableDomainStrategy = false

    var body: some View {
        Form {
            Toggle("Parallel Connections", isOn: $enableParallelConnections)
            Toggle("Advanced Routing", isOn: $enableDomainStrategy)

            Section("Debug") {
                Toggle("Verbose Logging", isOn: .constant(false))
            }
        }
        .navigationTitle("Advanced")
    }
}

struct AppearanceSettingsView: View {
    @State private var useDarkMode = true
    @State private var showAnimations = true

    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $useDarkMode)
            Toggle("Animated Backgrounds", isOn: $showAnimations)

            Section("Theme") {
                Picker("Accent", selection: .constant("Aurora")) {
                    Text("Aurora").tag("Aurora")
                    Text("Ocean").tag("Ocean")
                    Text("Sunset").tag("Sunset")
                }
            }
        }
        .navigationTitle("Appearance")
    }
}

struct NotificationSettingsView: View {
    @State private var connectionAlerts = true
    @State private var subscriptionAlerts = true

    var body: some View {
        Form {
            Toggle("Connection Alerts", isOn: $connectionAlerts)
            Toggle("Subscription Updates", isOn: $subscriptionAlerts)

            Section("Quiet Hours") {
                Toggle("Enable", isOn: .constant(false))
            }
        }
        .navigationTitle("Notifications")
    }
}

struct SubscriptionSettingsView: View {
    @State private var autoRefresh = true
    @State private var refreshInterval = SubscriptionUpdateInterval.hours6

    var body: some View {
        Form {
            Toggle("Auto Refresh", isOn: $autoRefresh)

            Picker("Interval", selection: $refreshInterval) {
                ForEach(SubscriptionUpdateInterval.allCases) { interval in
                    Text(interval.displayName).tag(interval)
                }
            }
            .disabled(!autoRefresh)
        }
        .navigationTitle("Subscriptions")
    }
}
