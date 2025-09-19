import Foundation
// Global types imported via RayLinkTypes
import Combine
import SwiftUI
import UIKit

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var connectionStatus: VPNConnectionStatus = .disconnected
    @Published var currentServer: VPNServer?
    @Published var bytesReceived: Int64 = 0
    @Published var bytesSent: Int64 = 0
    @Published var uploadSpeed: Int64 = 0
    @Published var downloadSpeed: Int64 = 0
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var connectionStartTime: Date?
    @Published var connectionMode: ConnectionMode = .automatic
    @Published var currentLocation: String = "Unknown"
    @Published var serverPing: Int = 0
    
    private var vpnManager: VPNManagerProtocol?
    private var storageManager: StorageManagerProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var speedUpdateTimer: Timer?
    private var lastBytesReceived: Int64 = 0
    private var lastBytesSent: Int64 = 0
    private var lastSpeedUpdateTime: Date = Date()
    
    public init() {
        // Public initializer for SwiftUI
    }
    
    var connectionDuration: TimeInterval {
        guard let startTime = connectionStartTime, connectionStatus == .connected else {
            return 0
        }
        
        return Date().timeIntervalSince(startTime)
    }
    
    var connectionStatistics: ConnectionStatistics {
        ConnectionStatistics(
            uploadSpeed: uploadSpeed,
            downloadSpeed: downloadSpeed,
            totalUploaded: bytesSent,
            totalDownloaded: bytesReceived,
            connectionDuration: connectionDuration,
            location: currentLocation,
            serverName: currentServer?.name ?? "Unknown"
        )
    }
    
    var vpnConnectionState: VPNConnectionState {
        switch connectionStatus {
        case .connected:
            return .connected
        case .connecting, .disconnecting, .reasserting:
            return .connecting
        case .disconnected, .invalid:
            return .disconnected
        }
    }
    
    func setup(vpnManager: VPNManagerProtocol, storageManager: StorageManagerProtocol) {
        self.vpnManager = vpnManager
        self.storageManager = storageManager
        
        setupBindings()
        loadCurrentServer()
    }
    
    private func setupBindings() {
        guard let vpnManager = vpnManager else { return }
        
        // Observe connection status
        vpnManager.connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.connectionStatus = status
                
                if status == .connected && self?.connectionStartTime == nil {
                    self?.connectionStartTime = Date()
                    self?.startSpeedMonitoring()
                } else if status == .disconnected {
                    self?.connectionStartTime = nil
                    self?.stopSpeedMonitoring()
                    self?.resetStatistics()
                }
            }
            .store(in: &cancellables)
        
        // Update basic statistics and ping periodically
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.connectionStatus == .connected {
                    self?.updateBasicStatistics()
                    self?.updateServerPing()
                } else {
                    self?.updateLocation()
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleConnection() async {
        guard let vpnManager = vpnManager else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if connectionStatus.isConnected {
                try await vpnManager.disconnect()
            } else {
                guard let server = currentServer else {
                    showErrorMessage("No server selected. Please select a server first.")
                    return
                }
                try await vpnManager.connect(to: server)
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    func refresh() async {
        loadCurrentServer()
        updateStatistics()
    }
    
    func runSpeedTest() async {
        guard connectionStatus == .connected else {
            showErrorMessage("Please connect to a VPN server first")
            return
        }
        
        // Implement speed test functionality
        // This would typically involve downloading/uploading test data
        // For now, just show a placeholder message
        showErrorMessage("Speed test feature coming soon!")
    }
    
    private func loadCurrentServer() {
        guard let storageManager = storageManager else { return }
        
        do {
            if let serverData = try storageManager.load([String: Any].self, for: .selectedServer),
               let server = VPNServer.from(dictionary: serverData) {
                currentServer = server
                serverPing = server.ping
                updateLocation()
            } else {
                // Load the first available server if no server is selected
                let servers = try storageManager.loadServers()
                currentServer = servers.first
                if let firstServer = servers.first {
                    serverPing = firstServer.ping
                }
                updateLocation()
            }
        } catch {
            print("Failed to load current server: \(error)")
        }
        
        // Load saved connection mode
        loadConnectionMode()
    }
    
    private func loadConnectionMode() {
        guard let storageManager = storageManager else { return }
        
        do {
            if let modeRawValue = try storageManager.load(String.self, for: .connectionMode),
               let mode = ConnectionMode(rawValue: modeRawValue) {
                connectionMode = mode
            }
        } catch {
            print("Failed to load connection mode: \(error)")
        }
    }
    
    private func updateBasicStatistics() {
        // In a real implementation, you would get these statistics from the VPN manager
        // For now, we'll simulate increasing values when connected
        if connectionStatus == .connected {
            bytesReceived += Int64.random(in: 1024...8192)
            bytesSent += Int64.random(in: 512...4096)
        }
    }
    
    private func startSpeedMonitoring() {
        lastBytesReceived = bytesReceived
        lastBytesSent = bytesSent
        lastSpeedUpdateTime = Date()
        
        speedUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateSpeedStatistics()
        }
    }
    
    private func stopSpeedMonitoring() {
        speedUpdateTimer?.invalidate()
        speedUpdateTimer = nil
        uploadSpeed = 0
        downloadSpeed = 0
    }
    
    private func updateSpeedStatistics() {
        let currentTime = Date()
        let timeDiff = currentTime.timeIntervalSince(lastSpeedUpdateTime)
        
        guard timeDiff > 0 else { return }
        
        // Calculate speeds based on byte differences
        let bytesDiff = bytesReceived - lastBytesReceived
        let sentDiff = bytesSent - lastBytesSent
        
        downloadSpeed = Int64(Double(bytesDiff) / timeDiff)
        uploadSpeed = Int64(Double(sentDiff) / timeDiff)
        
        // Add some realistic variation
        if connectionStatus == .connected {
            let downloadVariation = Int64.random(in: -downloadSpeed/10...downloadSpeed/10)
            let uploadVariation = Int64.random(in: -uploadSpeed/10...uploadSpeed/10)
            
            downloadSpeed = max(0, downloadSpeed + downloadVariation)
            uploadSpeed = max(0, uploadSpeed + uploadVariation)
        }
        
        lastBytesReceived = bytesReceived
        lastBytesSent = bytesSent
        lastSpeedUpdateTime = currentTime
    }
    
    private func resetStatistics() {
        bytesReceived = 0
        bytesSent = 0
        uploadSpeed = 0
        downloadSpeed = 0
        lastBytesReceived = 0
        lastBytesSent = 0
    }
    
    private func updateServerPing() {
        guard let server = currentServer else { return }
        
        // Simulate realistic ping variations
        let basePing = server.ping
        let variation = Int.random(in: -10...15)
        serverPing = max(1, basePing + variation)
    }
    
    private func updateLocation() {
        if let server = currentServer {
            currentLocation = server.inferredCountry
        } else {
            // Get user's approximate location when disconnected
            currentLocation = "Local Network"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Public Methods
    
    func updateConnectionMode(_ mode: ConnectionMode) {
        connectionMode = mode
        
        // Save to storage
        guard let storageManager = storageManager else { return }
        
        do {
            try storageManager.save(mode.rawValue, for: .connectionMode)
        } catch {
            print("Failed to save connection mode: \(error)")
        }
        
        // Provide haptic feedback
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    func selectServer(_ server: VPNServer) {
        currentServer = server
        serverPing = server.ping
        updateLocation()
        
        // Save to storage
        guard let storageManager = storageManager else { return }
        
        do {
            try storageManager.save(server.toDictionary(), for: .selectedServer)
        } catch {
            print("Failed to save selected server: \(error)")
        }
    }
    
    deinit {
        speedUpdateTimer?.invalidate()
    }
}