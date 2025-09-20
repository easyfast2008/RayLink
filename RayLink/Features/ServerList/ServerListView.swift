import SwiftUI
import Combine
import Foundation
// Global types imported via RayLinkTypes

struct ServerListView: View {
    @StateObject private var viewModel = ServerListViewModel()
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var searchText = ""
    @State private var showingAddServer = false
    @State private var showingBatchSelection = false
    @State private var selectedProtocolFilter: VPNProtocol?
    @State private var refreshing = false
    @State private var dragOffset = CGSize.zero
    @State private var showingTestAllButton = false
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Aurora background continuation from home screen
                    auroraBackground
                    
                    // Main content with staggered animations
                    VStack(spacing: 0) {
                        // Search bar with glassmorphic design
                        ServerSearchBar(
                            searchText: $searchText,
                            selectedProtocol: $selectedProtocolFilter,
                            isVisible: !viewModel.servers.isEmpty
                        )
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        
                        // Content area
                        ZStack {
                            if viewModel.isLoading {
                                loadingView
                                    .transition(.opacity.combined(with: .scale))
                            } else if filteredGroups.isEmpty {
                                EmptyServerState(
                                    onAddServer: { showingAddServer = true },
                                    onImport: { coordinator.navigate(to: .import) }
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            } else {
                                serverGroupsList
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .move(edge: .bottom).combined(with: .opacity)
                                    ))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Floating action button for test all servers
                    if showingTestAllButton && !viewModel.servers.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                floatingTestAllButton
                                    .padding(.trailing, AppTheme.Spacing.lg)
                                    .padding(.bottom, AppTheme.Spacing.xl)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("Servers")
                            .font(AppTheme.Typography.headlineMedium)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                            .fontWeight(.semibold)
                        
                        if !viewModel.servers.isEmpty {
                            Text("(\(viewModel.servers.count))")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        if !viewModel.servers.isEmpty {
                            Button(action: { 
                                withAnimation(AppTheme.Animation.fluidSpring) {
                                    showingBatchSelection.toggle()
                                }
                            }) {
                                Image(systemName: showingBatchSelection ? "checkmark.circle.fill" : "checklist")
                                    .foregroundColor(AppTheme.Colors.textOnGlass)
                                    .font(.system(size: 18, weight: .medium))
                            }
                        }
                        
                        Menu {
                            Button("Add Server") { 
                                showingAddServer = true 
                            }
                            Button("Import from URL") { 
                                coordinator.navigate(to: .import) 
                            }
                            Divider()
                            Button("Refresh All") { 
                                Task { await refreshAllWithAnimation() }
                            }
                            if showingBatchSelection {
                                Button("Delete Selected", role: .destructive) {
                                    // TODO: Implement batch delete
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(AppTheme.Colors.textOnGlass)
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddServer) {
                AddServerView { server in
                    withAnimation(AppTheme.Animation.fluidSpring) {
                        viewModel.addServer(server)
                    }
                }
            }
            .onAppear {
                viewModel.setup(
                    vpnManager: container.vpnManager,
                    storageManager: container.storageManager
                )
                
                // Staggered appearance animation
                withAnimation(AppTheme.Animation.fluidSpring.delay(0.1)) {
                    showingTestAllButton = !viewModel.servers.isEmpty
                }
            }
            .onChange(of: viewModel.servers) { servers in
                withAnimation(AppTheme.Animation.gentleSpring) {
                    showingTestAllButton = !servers.isEmpty
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Aurora Background
    private var auroraBackground: some View {
        AppTheme.AuroraGradients.timeBasedGradient(hour: Calendar.current.component(.hour, from: Date()))
            .ignoresSafeArea()
            .overlay(
                // Animated wave particles
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.02...0.08)))
                        .frame(
                            width: CGFloat.random(in: 20...60),
                            height: CGFloat.random(in: 20...60)
                        )
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .animation(
                            AppTheme.Animation.ambientFloat
                                .delay(Double.random(in: 0...3))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
            )
    }
    
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Pulsating aurora loading indicator
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            AppTheme.AuroraGradients.primary,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 50 + CGFloat(index * 20))
                        .opacity(0.6 - Double(index) * 0.2)
                        .scaleEffect(refreshing ? 1.2 : 0.8)
                        .animation(
                            AppTheme.Animation.connectionPulse.delay(Double(index) * 0.2),
                            value: refreshing
                        )
                }
                
                // Center dot
                Circle()
                    .fill(AppTheme.AuroraGradients.primary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(refreshing ? 1.5 : 1.0)
                    .animation(AppTheme.Animation.breathingGlow, value: refreshing)
            }
            .onAppear {
                refreshing = true
            }
            
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Loading servers...")
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(AppTheme.Colors.textOnGlass)
                
                Text("Discovering available connections")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassmorphicCard()
        .padding(AppTheme.Spacing.lg)
    }
    
    // Empty state is now handled by EmptyServerState component
    
    private var serverGroupsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(Array(filteredGroups.enumerated()), id: \.offset) { index, group in
                    ServerGroupView(
                        group: group,
                        viewModel: viewModel,
                        showingBatchSelection: $showingBatchSelection,
                        animationNamespace: animationNamespace
                    )
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity)
                                .delay(Double(index) * 0.1),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        )
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .refreshable {
            await refreshAllWithAnimation()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { _ in
                    withAnimation(AppTheme.Animation.fluidSpring) {
                        dragOffset = .zero
                    }
                }
        )
    }
    
    private var filteredGroups: [ServerGroup] {
        let filtered = filteredServers
        return groupServers(filtered)
    }
    
    private var filteredServers: [VPNServer] {
        var servers = viewModel.servers
        
        // Apply protocol filter
        if let protocolFilter = selectedProtocolFilter {
            servers = servers.filter { $0.protocol == protocolFilter }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            servers = servers.filter { server in
                server.name.localizedCaseInsensitiveContains(searchText) ||
                server.address.localizedCaseInsensitiveContains(searchText) ||
                server.serverProtocol.rawValue.localizedCaseInsensitiveContains(searchText) ||
                server.displayLocation.localizedCaseInsensitiveContains(searchText) ||
                (server.provider?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return servers
    }
    
    // MARK: - Floating Test All Button
    private var floatingTestAllButton: some View {
        Button(action: {
            Task {
                await testAllServersWithAnimation()
            }
        }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Test All")
                    .font(AppTheme.Typography.labelMedium)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule()
                    .fill(AppTheme.AuroraGradients.primary)
                    .shadow(color: AppTheme.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(viewModel.isTestingAll ? 0.95 : 1.0)
        .animation(AppTheme.Animation.bouncySpring, value: viewModel.isTestingAll)
        .disabled(viewModel.isTestingAll)
    }
    
    // MARK: - Helper Methods
    private func groupServers(_ servers: [VPNServer]) -> [ServerGroup] {
        let grouped = Dictionary(grouping: servers) { server in
            server.provider ?? "Manual"
        }
        
        return grouped.map { (key, servers) in
            ServerGroup(
                name: key,
                servers: servers.sorted { $0.ping < $1.ping },
                isExpanded: true // Default to expanded, can be managed by user preference
            )
        }.sorted { $0.name < $1.name }
    }
    
    private func refreshAllWithAnimation() async {
        withAnimation(AppTheme.Animation.fluidSpring) {
            refreshing = true
        }
        
        await viewModel.refreshAllServers()
        
        withAnimation(AppTheme.Animation.gentleSpring.delay(0.5)) {
            refreshing = false
        }
    }
    
    private func testAllServersWithAnimation() async {
        await viewModel.testAllServers()
    }
}

// MARK: - Server Group Model
struct ServerGroup: Identifiable {
    let id = UUID()
    let name: String
    let servers: [VPNServer]
    var isExpanded: Bool
}

// MARK: - Server Group View
struct ServerGroupView: View {
    let group: ServerGroup
    let viewModel: ServerListViewModel
    @Binding var showingBatchSelection: Bool
    let animationNamespace: Namespace.ID
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ServerGroupHeader(
                group: group,
                isExpanded: $isExpanded,
                onTestAll: {
                    Task {
                        await viewModel.testGroupServers(group.servers)
                    }
                },
                onDeleteGroup: {
                    withAnimation(AppTheme.Animation.fluidSpring) {
                        group.servers.forEach { viewModel.deleteServer($0) }
                    }
                }
            )
            
            if isExpanded {
                LazyVStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(Array(group.servers.enumerated()), id: \.element.id) { index, server in
                        ServerCell(
                            server: server,
                            isSelected: server.id == viewModel.selectedServer?.id,
                            isConnected: viewModel.connectionStatus == .connected && server.id == viewModel.currentServer?.id,
                            showingBatchSelection: showingBatchSelection,
                            onSelect: {
                                withAnimation(AppTheme.Animation.fluidSpring) {
                                    viewModel.selectServer(server)
                                }
                            },
                            onConnect: {
                                Task {
                                    await viewModel.connectToServer(server)
                                }
                            },
                            onDelete: {
                                withAnimation(AppTheme.Animation.fluidSpring) {
                                    viewModel.deleteServer(server)
                                }
                            },
                            onCopy: {
                                // TODO: Implement server URL copying
                                UIPasteboard.general.string = server.connectionURL
                            },
                            onShare: {
                                // TODO: Implement server sharing
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity)
                                    .delay(Double(index) * 0.05),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassmorphicCard()
    }
}

struct ServerRowView: View {
    let server: VPNServer
    let isSelected: Bool
    let isConnected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onConnect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("\(server.address):\(server.port)")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Circle()
                        .fill(pingColor)
                        .frame(width: 8, height: 8)
                    Text("\(server.ping)ms")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                Text(server.serverProtocol.rawValue.uppercased())
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(protocolColor.opacity(0.2))
                    .foregroundColor(protocolColor)
                    .cornerRadius(4)
            }
            
            VStack(spacing: 8) {
                if isConnected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else if isSelected {
                    Image(systemName: "circle.fill")
                        .foregroundColor(AppTheme.Colors.accent)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(AppTheme.Colors.secondary)
                        .font(.title3)
                }
                
                Button(action: onConnect) {
                    Text(isConnected ? "Connected" : "Connect")
                        .font(.caption)
                        .foregroundColor(isConnected ? .green : AppTheme.Colors.accent)
                }
                .disabled(isConnected)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
    
    private var pingColor: Color {
        if server.ping < 100 {
            return .green
        } else if server.ping < 200 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var protocolColor: Color {
        switch server.serverProtocol {
        case .shadowsocks:
            return .blue
        case .vmess, .vless:
            return .purple
        case .trojan:
            return .red
        case .ikev2:
            return .orange
        case .wireguard:
            return .green
        }
    }
}

// MARK: - Legacy Server Row View (kept for compatibility)
struct AddServerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var address = ""
    @State private var port = ""
    @State private var selectedProtocol = VPNProtocol.shadowsocks
    @State private var username = ""
    @State private var password = ""
    @State private var uuid = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let onSave: (VPNServer) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Server Name", text: $name)
                    TextField("Server Address", text: $address)
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                    
                    Picker("Protocol", selection: $selectedProtocol) {
                        ForEach(VPNProtocol.allCases, id: \.self) { protocol in
                            Text(protocol.rawValue.capitalized).tag(protocol)
                        }
                    }
                }
                
                Section("Authentication") {
                    if needsUsername {
                        TextField("Username", text: $username)
                    }
                    
                    if needsPassword {
                        SecureField("Password", text: $password)
                    }
                    
                    if needsUUID {
                        TextField("UUID", text: $uuid)
                    }
                }
            }
            .navigationTitle("Add Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveServer()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var needsUsername: Bool {
        selectedProtocol == .ikev2
    }
    
    private var needsPassword: Bool {
        [.shadowsocks, .trojan, .ikev2].contains(selectedProtocol)
    }
    
    private var needsUUID: Bool {
        [.vmess, .vless].contains(selectedProtocol)
    }
    
    private var isValid: Bool {
        !name.isEmpty && !address.isEmpty && !port.isEmpty &&
        Int(port) != nil && Int(port)! > 0 && Int(port)! <= 65535
    }
    
    private func saveServer() {
        guard isValid else {
            errorMessage = "Please fill in all required fields"
            showingError = true
            return
        }
        
        let server = VPNServer(
            id: UUID().uuidString,
            name: name,
            address: address,
            port: Int(port) ?? 0,
            serverProtocol: selectedProtocol,
            username: needsUsername ? username : nil,
            password: needsPassword ? password : nil,
            uuid: needsUUID ? uuid : nil,
            ping: 0,
            isActive: true
        )
        
        onSave(server)
        dismiss()
    }
}