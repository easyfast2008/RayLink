import Foundation
// Global types imported via RayLinkTypes
import Combine
import SwiftUI

@MainActor
final class ServerListViewModel: ObservableObject {
    @Published var servers: [VPNServer] = []
    @Published var selectedServer: VPNServer?
    @Published var currentServer: VPNServer?
    @Published var connectionStatus: VPNConnectionStatus = .disconnected
    @Published var isLoading = false
    @Published var isTestingAll = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedServers: Set<String> = []
    @Published var serverGroups: [String: [VPNServer]] = [:]
    @Published var lastRefreshDate: Date?
    @Published var pingUpdateProgress: Double = 0
    
    private var vpnManager: VPNManagerProtocol?
    private var storageManager: StorageManagerProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var pingUpdateTimer: Timer?
    private var activeConnections: Set<String> = []
    
    func setup(vpnManager: VPNManagerProtocol, storageManager: StorageManagerProtocol) {
        self.vpnManager = vpnManager
        self.storageManager = storageManager
        
        setupBindings()
        loadServers()
    }
    
    private func setupBindings() {
        guard let vpnManager = vpnManager else { return }
        
        vpnManager.connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.connectionStatus = status
            }
            .store(in: &cancellables)
    }
    
    func loadServers() {
        guard let storageManager = storageManager else { return }
        
        do {
            servers = try storageManager.loadServers()
            loadSelectedServer()
        } catch {
            showErrorMessage("Failed to load servers: \(error.localizedDescription)")
        }
    }
    
    func addServer(_ server: VPNServer) {
        servers.append(server)
        saveServers()
        
        // Auto-select if it's the first server
        if selectedServer == nil {
            selectServer(server)
        }
    }
    
    func deleteServer(_ server: VPNServer) {
        servers.removeAll { $0.id == server.id }
        
        // Update selected server if deleted
        if selectedServer?.id == server.id {
            selectedServer = servers.first
            saveSelectedServer()
        }
        
        saveServers()
    }
    
    func selectServer(_ server: VPNServer) {
        selectedServer = server
        saveSelectedServer()
    }
    
    func connectToServer(_ server: VPNServer) async {
        guard let vpnManager = vpnManager else { return }
        
        // First select the server
        selectServer(server)
        
        do {
            if connectionStatus.isConnected {
                // Disconnect first if already connected to a different server
                try await vpnManager.disconnect()
                // Wait a moment for clean disconnection
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
            
            try await vpnManager.connect(to: server)
            currentServer = server
        } catch {
            showErrorMessage("Failed to connect: \(error.localizedDescription)")
        }
    }
    
    func refreshAllServers() async {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate server ping testing
        await withTaskGroup(of: Void.self) { group in
            for server in servers {
                group.addTask {
                    await self.pingServer(server)
                }
            }
        }
        
        // Sort servers by ping
        servers.sort { $0.ping < $1.ping }
        saveServers()
    }
    
    private func pingServer(_ server: VPNServer) async {
        // Simulate ping testing
        let randomDelay = Double.random(in: 0.1...2.0)
        try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))
        
        await MainActor.run {
            if let index = servers.firstIndex(where: { $0.id == server.id }) {
                servers[index].ping = Int.random(in: 50...500)
            }
        }
    }
    
    private func loadSelectedServer() {
        guard let storageManager = storageManager else { return }
        
        do {
            if let server = try storageManager.load(VPNServer.self, for: .selectedServer) {
                selectedServer = server
            } else {
                selectedServer = servers.first
                if let firstServer = servers.first {
                    saveSelectedServer()
                }
            }
        } catch {
            selectedServer = servers.first
        }
    }
    
    private func saveServers() {
        guard let storageManager = storageManager else { return }
        
        do {
            try storageManager.saveServers(servers)
        } catch {
            showErrorMessage("Failed to save servers: \(error.localizedDescription)")
        }
    }
    
    private func saveSelectedServer() {
        guard let storageManager = storageManager,
              let selectedServer = selectedServer else { return }
        
        do {
            try storageManager.save(selectedServer, for: .selectedServer)
        } catch {
            showErrorMessage("Failed to save selected server: \(error.localizedDescription)")
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Batch Operations
    func toggleServerSelection(_ serverId: String) {
        if selectedServers.contains(serverId) {
            selectedServers.remove(serverId)
        } else {
            selectedServers.insert(serverId)
        }
    }
    
    func selectAllServers() {
        selectedServers = Set(servers.map { $0.id })
    }
    
    func clearSelection() {
        selectedServers.removeAll()
    }
    
    func isServerSelected(_ serverId: String) -> Bool {
        selectedServers.contains(serverId)
    }
    
    // MARK: - Server Statistics
    func getServerStats() -> (total: Int, connected: Int, fastest: VPNServer?) {
        let connectedCount = servers.filter { server in
            connectionStatus == .connected && server.id == currentServer?.id
        }.count
        
        let fastest = servers.min { $0.ping < $1.ping }
        
        return (servers.count, connectedCount, fastest)
    }
    
    func getGroupStats(for groupName: String) -> (total: Int, avgPing: Int) {
        let groupServers = serverGroups[groupName] ?? []
        let avgPing = groupServers.isEmpty ? 0 : groupServers.reduce(0) { $0 + $1.ping } / groupServers.count
        return (groupServers.count, avgPing)
    }
}

