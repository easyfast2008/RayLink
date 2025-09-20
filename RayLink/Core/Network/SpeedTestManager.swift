import Foundation
import Network
import os.log
import SwiftUI

@MainActor
class SpeedTestManager: ObservableObject {
    static let shared = SpeedTestManager()
    
    @Published var isRunning = false
    @Published var progress: Double = 0.0
    @Published var currentTest: String = ""
    @Published var results: [SpeedTestMeasurement] = []
    
    private let logger = Logger(subsystem: "com.raylink.app", category: "SpeedTestManager")
    private var currentTestTask: Task<Void, Never>?
    
    private init() {}
    
    // MARK: - Public Interface
    
    func testServer(_ server: VPNServer) async -> SpeedTestMeasurement {
        logger.info("Testing server: \(server.name)")
        
        let startTime = Date()
        var latency: Int = -1
        var downloadSpeed: Double = 0
        var uploadSpeed: Double = 0
        var isReachable = false
        
        // Test connectivity and latency
        currentTest = "Testing connectivity..."
        progress = 0.1

        latency = await measureLatency(server: server)
        isReachable = latency != -1

        if isReachable {
            // Test download speed
            currentTest = "Testing download speed..."
            progress = 0.4
            downloadSpeed = await measureDownloadSpeed(server: server)

            // Test upload speed
            currentTest = "Testing upload speed..."
            progress = 0.7
            uploadSpeed = await measureUploadSpeed(server: server)
        }
        
        progress = 1.0
        currentTest = "Completed"
        
        let result = SpeedTestMeasurement(
            server: server,
            latency: latency,
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            isReachable: isReachable,
            testDate: startTime,
            duration: Date().timeIntervalSince(startTime)
        )
        
        return result
    }
    
    func testServers(_ servers: [VPNServer]) async {
        guard !isRunning else { return }
        
        isRunning = true
        results.removeAll()
        
        currentTestTask = Task {
            let totalServers = servers.count
            
            for (index, server) in servers.enumerated() {
                guard !Task.isCancelled else { break }
                
                currentTest = "Testing \(server.name)..."
                progress = Double(index) / Double(totalServers)
                
                let result = await testServer(server)
                results.append(result)
                
                // Small delay between tests to avoid overwhelming servers
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            
            isRunning = false
            currentTest = ""
            progress = 0.0
        }
        
        await currentTestTask?.value
    }
    
    func cancelTests() {
        currentTestTask?.cancel()
        currentTestTask = nil
        isRunning = false
        currentTest = ""
        progress = 0.0
    }
    
    func testSingleServer(_ server: VPNServer) async {
        guard !isRunning else { return }
        
        isRunning = true
        
        let result = await testServer(server)
        
        // Update or add result
        if let index = results.firstIndex(where: { $0.server.id == server.id }) {
            results[index] = result
        } else {
            results.append(result)
        }
        
        isRunning = false
    }
    
    func sortedResults(by sortType: SpeedTestSortType) -> [SpeedTestMeasurement] {
        switch sortType {
        case .latency:
            return results.sorted { (a, b) in
                if a.latency == -1 && b.latency == -1 { return false }
                if a.latency == -1 { return false }
                if b.latency == -1 { return true }
                return a.latency < b.latency
            }
        case .downloadSpeed:
            return results.sorted { $0.downloadSpeed > $1.downloadSpeed }
        case .uploadSpeed:
            return results.sorted { $0.uploadSpeed > $1.uploadSpeed }
        case .name:
            return results.sorted { $0.server.name < $1.server.name }
        case .testDate:
            return results.sorted { $0.testDate > $1.testDate }
        }
    }
    
    func clearResults() {
        results.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func measureLatency(server: VPNServer) async -> Int {
        let attempts = 3
        var latencies: [Double] = []
        
        for _ in 0..<attempts {
            let latency = await performSinglePing(to: server.address, port: server.port)
            if latency != -1 {
                latencies.append(latency)
            }
        }
        
        guard !latencies.isEmpty else { return -1 }
        
        // Return average latency
        let average = latencies.reduce(0, +) / Double(latencies.count)
        return Int(average)
    }
    
    private func performSinglePing(to address: String, port: Int) async -> Double {
        return await withCheckedContinuation { continuation in
            let startTime = CFAbsoluteTimeGetCurrent()
            
            let connection = NWConnection(
                host: NWEndpoint.Host(address),
                port: NWEndpoint.Port(integerLiteral: UInt16(port)),
                using: .tcp
            )
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    let latency = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
                    connection.cancel()
                    continuation.resume(returning: latency)
                    
                case .failed, .cancelled:
                    connection.cancel()
                    continuation.resume(returning: -1)
                    
                default:
                    break
                }
            }
            
            // Set timeout
            DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
                connection.cancel()
                continuation.resume(returning: -1)
            }
            
            connection.start(queue: .global())
        }
    }
    
    private func measureDownloadSpeed(server: VPNServer) async -> Double {
        // For real implementation, you would:
        // 1. Connect through the VPN server
        // 2. Download a test file from a speed test server
        // 3. Measure the download speed
        
        // Simulated implementation
        do {
            let testURL = URL(string: "http://speedtest.ftp.otenet.gr/files/test10Mb.db")!
            let startTime = Date()
            
            let (data, _) = try await URLSession.shared.data(from: testURL)
            let duration = Date().timeIntervalSince(startTime)
            let bytes = Double(data.count)
            let bitsPerSecond = (bytes * 8) / duration
            let mbps = bitsPerSecond / 1_000_000
            
            return mbps
            
        } catch {
            logger.error("Download speed test failed: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func measureUploadSpeed(server: VPNServer) async -> Double {
        // For real implementation, you would:
        // 1. Connect through the VPN server
        // 2. Upload test data to a speed test server
        // 3. Measure the upload speed
        
        // Simulated implementation
        do {
            let testData = Data(count: 1024 * 1024) // 1MB of test data
            let testURL = URL(string: "https://httpbin.org/post")!
            
            var request = URLRequest(url: testURL)
            request.httpMethod = "POST"
            request.httpBody = testData
            
            let startTime = Date()
            let (_, _) = try await URLSession.shared.data(for: request)
            let duration = Date().timeIntervalSince(startTime)
            
            let bytes = Double(testData.count)
            let bitsPerSecond = (bytes * 8) / duration
            let mbps = bitsPerSecond / 1_000_000
            
            return mbps
            
        } catch {
            logger.error("Upload speed test failed: \(error.localizedDescription)")
            return 0
        }
    }
}

// MARK: - Supporting Types

struct SpeedTestMeasurement: Identifiable, Codable {
    let id = UUID()
    let server: VPNServer
    let latency: Int // in milliseconds, -1 if failed
    let downloadSpeed: Double // in Mbps
    let uploadSpeed: Double // in Mbps
    let isReachable: Bool
    let testDate: Date
    let duration: TimeInterval // test duration in seconds
    
    var latencyString: String {
        if latency == -1 {
            return "Timeout"
        }
        return "\(latency) ms"
    }
    
    var downloadSpeedString: String {
        if downloadSpeed == 0 {
            return "N/A"
        }
        return String(format: "%.2f Mbps", downloadSpeed)
    }
    
    var uploadSpeedString: String {
        if uploadSpeed == 0 {
            return "N/A"
        }
        return String(format: "%.2f Mbps", uploadSpeed)
    }
    
    var statusColor: String {
        if !isReachable {
            return "red"
        } else if latency < 100 {
            return "green"
        } else if latency < 300 {
            return "orange"
        } else {
            return "red"
        }
    }
    
    var qualityScore: Int {
        if !isReachable { return 0 }
        
        var score = 0
        
        // Latency score (0-40 points)
        if latency < 50 {
            score += 40
        } else if latency < 100 {
            score += 30
        } else if latency < 200 {
            score += 20
        } else if latency < 500 {
            score += 10
        }
        
        // Download speed score (0-40 points)
        if downloadSpeed > 50 {
            score += 40
        } else if downloadSpeed > 20 {
            score += 30
        } else if downloadSpeed > 10 {
            score += 20
        } else if downloadSpeed > 5 {
            score += 10
        }
        
        // Upload speed score (0-20 points)
        if uploadSpeed > 20 {
            score += 20
        } else if uploadSpeed > 10 {
            score += 15
        } else if uploadSpeed > 5 {
            score += 10
        } else if uploadSpeed > 1 {
            score += 5
        }
        
        return score
    }
    
    var qualityGrade: String {
        let score = qualityScore
        if score >= 90 {
            return "Excellent"
        } else if score >= 70 {
            return "Good"
        } else if score >= 50 {
            return "Fair"
        } else if score >= 30 {
            return "Poor"
        } else {
            return "Very Poor"
        }
    }
}

enum SpeedTestSortType: String, CaseIterable {
    case latency = "Latency"
    case downloadSpeed = "Download Speed"
    case uploadSpeed = "Upload Speed"
    case name = "Server Name"
    case testDate = "Test Date"
}

// MARK: - Speed Test View

struct SpeedTestView: View {
    @StateObject private var speedTestManager = SpeedTestManager.shared
    @EnvironmentObject private var container: DependencyContainer
    @State private var servers: [VPNServer] = []
    @State private var sortType: SpeedTestSortType = .latency
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                if speedTestManager.isRunning {
                    testingSection
                }
                
                if !speedTestManager.results.isEmpty {
                    resultsSection
                } else {
                    emptyStateSection
                }
            }
            .padding()
            .navigationTitle("Speed Test")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Sort") {
                        ForEach(SpeedTestSortType.allCases, id: \.self) { type in
                            Button(type.rawValue) {
                                sortType = type
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SpeedTestSettingsView()
            }
            .onAppear {
                loadServers()
            }
        }
        .auroraBackground()
    }
    
    private var testingSection: some View {
        VStack(spacing: 16) {
            ProgressView(value: speedTestManager.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.Colors.accent))
            
            Text(speedTestManager.currentTest)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            Button("Cancel") {
                speedTestManager.cancelTests()
            }
            .buttonStyle(AppTheme.ButtonStyles.Secondary())
        }
        .glassmorphicCard()
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Test Results")
                    .font(AppTheme.Typography.titleLarge)
                    .foregroundColor(AppTheme.Colors.text)
                
                Spacer()
                
                Button("Clear") {
                    speedTestManager.clearResults()
                }
                .font(AppTheme.Typography.labelMedium)
                .foregroundColor(AppTheme.Colors.accent)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(speedTestManager.sortedResults(by: sortType)) { result in
                    SpeedTestMeasurementRow(result: result)
                }
            }
        }
        .glassmorphicCard()
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "speedometer")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.accent)
            
            Text("Speed Test")
                .font(AppTheme.Typography.titleLarge)
                .foregroundColor(AppTheme.Colors.text)
            
            Text("Test your servers to find the fastest connection")
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Test All Servers") {
                Task {
                    await speedTestManager.testServers(servers)
                }
            }
            .buttonStyle(AppTheme.ButtonStyles.Primary())
            .disabled(servers.isEmpty || speedTestManager.isRunning)
        }
        .glassmorphicCard()
    }
    
    private func loadServers() {
        do {
            servers = try container.storageManager.loadServers()
        } catch {
            print("Failed to load servers: \(error)")
        }
    }
}

struct SpeedTestMeasurementRow: View {
    let result: SpeedTestMeasurement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.server.name)
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(result.server.address)
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(result.latencyString)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(color(for: result.statusColor))
                
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("↓ \(result.downloadSpeedString)")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Text("↑ \(result.uploadSpeedString)")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Text(result.qualityGrade)
                        .font(AppTheme.Typography.labelSmall)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color(for: result.statusColor).opacity(0.2))
                        .foregroundColor(color(for: result.statusColor))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(8)
    }
    
    private func color(for status: String) -> Color {
        switch status {
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        default: return AppTheme.Colors.textSecondary
        }
    }
}

struct SpeedTestSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Speed Test Settings")
                    .font(AppTheme.Typography.titleLarge)
                    .padding()
                
                Text("Configure speed test parameters")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .auroraBackground()
    }
}