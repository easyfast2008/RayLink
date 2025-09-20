import Foundation
import Combine

// MARK: - Mock VPN Manager for Development
// This mock manager simulates VPN functionality for testing without a paid developer account
final class MockVPNManager: VPNManagerProtocol, ObservableObject {
    @Published private var currentStatus: VPNConnectionStatus = .disconnected
    @Published var currentServer: VPNServer?
    @Published var connectionStartTime: Date?
    @Published var bytesReceived: Int64 = 0
    @Published var bytesSent: Int64 = 0
    
    private let statusSubject = CurrentValueSubject<VPNConnectionStatus, Never>(.disconnected)
    private var connectionTimer: Timer?
    private var statsTimer: Timer?
    
    var connectionStatus: AnyPublisher<VPNConnectionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    var isConnected: Bool {
        currentStatus.isConnected
    }
    
    init() {
        print("🔧 Using Mock VPN Manager for development")
        print("ℹ️  All UI features work normally")
        print("⚠️  Actual VPN connection requires paid developer account")
    }
    
    deinit {
        connectionTimer?.invalidate()
        statsTimer?.invalidate()
    }
    
    // MARK: - Mock Connection Methods
    func connect(to server: VPNServer) async throws {
        guard currentStatus != .connected && currentStatus != .connecting else {
            throw VPNError.alreadyConnected
        }
        
        print("🔄 Mock: Connecting to \(server.name)...")
        
        // Simulate connection process
        await updateStatus(.connecting)
        currentServer = server
        
        // Simulate connection delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Simulate successful connection
        await updateStatus(.connected)
        connectionStartTime = Date()
        
        // Start mock stats updates
        startMockStatsUpdates()
        
        print("✅ Mock: Connected to \(server.name)")
    }
    
    func disconnect() async throws {
        guard currentStatus == .connected || currentStatus == .connecting else {
            throw VPNError.notConnected
        }
        
        print("🔄 Mock: Disconnecting...")
        
        await updateStatus(.disconnecting)
        
        // Simulate disconnection delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await updateStatus(.disconnected)
        currentServer = nil
        connectionStartTime = nil
        
        // Stop stats updates
        stopMockStatsUpdates()
        
        // Reset stats
        bytesReceived = 0
        bytesSent = 0
        
        print("✅ Mock: Disconnected")
    }
    
    func loadConfigurations() async throws {
        print("📋 Mock: Loading configurations")
        // Mock successful load
    }
    
    func removeAllConfigurations() async throws {
        print("🗑 Mock: Removing all configurations")
        currentServer = nil
        await updateStatus(.disconnected)
    }
    
    // MARK: - Mock Statistics
    private func startMockStatsUpdates() {
        statsTimer?.invalidate()
        statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.currentStatus == .connected else { return }
            
            // Simulate data transfer
            Task { @MainActor in
                self.bytesReceived += Int64.random(in: 1024...10240) // 1KB to 10KB per second
                self.bytesSent += Int64.random(in: 512...5120) // 0.5KB to 5KB per second
            }
        }
    }
    
    private func stopMockStatsUpdates() {
        statsTimer?.invalidate()
        statsTimer = nil
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func updateStatus(_ status: VPNConnectionStatus) {
        currentStatus = status
        statusSubject.send(status)
    }
    
    // MARK: - Mock Test Methods
    func testConnection() async -> (success: Bool, latency: Int) {
        print("🧪 Mock: Testing connection...")
        
        // Simulate network test
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return mock results
        let latency = Int.random(in: 20...150)
        let success = Bool.random() || true // Mostly successful
        
        print("📊 Mock Test Result: \(success ? "Success" : "Failed"), Latency: \(latency)ms")
        return (success, latency)
    }
    
    func getMockServerList() -> [VPNServer] {
        // Return sample servers for testing
        return [
            VPNServer(
                id: "mock-1",
                name: "Mock US Server",
                address: "us.mock.vpn",
                port: 443,
                serverProtocol: .vmess,
                ping: 45,
                isActive: true,
                country: "United States",
                flag: "🇺🇸"
            ),
            VPNServer(
                id: "mock-2",
                name: "Mock EU Server",
                address: "eu.mock.vpn",
                port: 443,
                serverProtocol: .vless,
                ping: 65,
                isActive: true,
                country: "Germany",
                flag: "🇩🇪"
            ),
            VPNServer(
                id: "mock-3",
                name: "Mock Asia Server",
                address: "asia.mock.vpn",
                port: 443,
                serverProtocol: .trojan,
                ping: 120,
                isActive: true,
                country: "Singapore",
                flag: "🇸🇬"
            )
        ]
    }
}