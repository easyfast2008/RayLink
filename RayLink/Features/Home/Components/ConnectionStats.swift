import SwiftUI
import Foundation
// MARK: - Connection Statistics Model
struct ConnectionMetrics {
    let uploadSpeed: Int64      // bytes per second
    let downloadSpeed: Int64    // bytes per second
    let totalUploaded: Int64    // total bytes uploaded
    let totalDownloaded: Int64  // total bytes downloaded
    let connectionDuration: TimeInterval
    let location: String
    let serverName: String
    
    static let empty = ConnectionMetrics(
        uploadSpeed: 0,
        downloadSpeed: 0,
        totalUploaded: 0,
        totalDownloaded: 0,
        connectionDuration: 0,
        location: "Unknown",
        serverName: "No Server"
    )
}

// MARK: - Connection Stats Component
struct ConnectionStats: View {
    let statistics: ConnectionMetrics
    let isConnected: Bool
    
    @State private var animationPhase: Double = 0
    @State private var progressAnimationPhase: Double = 0
    @State private var counterAnimationTrigger: Bool = false
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            if isConnected {
                connectedStats
            } else {
                disconnectedPlaceholder
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: isConnected) { connected in
            if connected {
                startAnimations()
            }
        }
        .onChange(of: statistics.uploadSpeed) { _ in
            triggerCounterAnimation()
        }
        .onChange(of: statistics.downloadSpeed) { _ in
            triggerCounterAnimation()
        }
    }
    
    // MARK: - Connected Stats
    private var connectedStats: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Connection timer and location
            connectionHeader
            
            // Speed indicators
            speedIndicators
            
            // Data usage rings
            dataUsageRings
        }
    }
    
    // MARK: - Connection Header
    private var connectionHeader: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            // Connection timer
            Text(formattedDuration)
                .font(AppTheme.Typography.displayMedium)
                .fontWeight(.light)
                .foregroundColor(AppTheme.Colors.textOnGlass)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(AppTheme.Animation.gentleSpring, value: statistics.connectionDuration)
            
            // Location with flag
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.connected)
                
                Text(statistics.location)
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.8))
                    .fontWeight(.medium)
            }
            .scaleEffect(glowIntensity > 0.4 ? 1.05 : 1.0)
            .animation(AppTheme.Animation.breathingGlow, value: glowIntensity)
        }
    }
    
    // MARK: - Speed Indicators
    private var speedIndicators: some View {
        HStack(spacing: AppTheme.Spacing.xl) {
            // Download speed
            speedCard(
                title: "Download",
                speed: statistics.downloadSpeed,
                icon: "arrow.down.circle.fill",
                color: AppTheme.Colors.connected,
                isDownload: true
            )
            
            // Upload speed  
            speedCard(
                title: "Upload", 
                speed: statistics.uploadSpeed,
                icon: "arrow.up.circle.fill",
                color: AppTheme.Colors.auroraBlue,
                isDownload: false
            )
        }
    }
    
    // MARK: - Speed Card
    private func speedCard(
        title: String,
        speed: Int64,
        icon: String,
        color: Color,
        isDownload: Bool
    ) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Icon with pulse effect
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(speed > 0 ? 1.2 : 1.0)
                    .opacity(speed > 0 ? 0.8 : 0.4)
                    .animation(
                        speed > 0 ? AppTheme.Animation.breathingGlow : .easeOut(duration: 0.3),
                        value: speed
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                    .scaleEffect(counterAnimationTrigger ? 1.1 : 1.0)
                    .animation(AppTheme.Animation.bouncySpring, value: counterAnimationTrigger)
            }
            
            // Title
            Text(title)
                .font(AppTheme.Typography.labelMedium)
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                .fontWeight(.medium)
            
            // Speed value with animated counter
            AnimatedCounter(
                value: speed,
                formatter: { formatSpeed($0) }
            )
            .font(AppTheme.Typography.titleLarge)
            .fontWeight(.bold)
            .foregroundColor(color)
            .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .background(speedCardBackground)
        .cornerRadius(AppTheme.CornerRadius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Data Usage Rings
    private var dataUsageRings: some View {
        HStack(spacing: AppTheme.Spacing.xl) {
            // Downloaded data ring
            dataRing(
                title: "Downloaded",
                value: statistics.totalDownloaded,
                color: AppTheme.Colors.connected,
                progress: downloadProgress
            )
            
            // Uploaded data ring
            dataRing(
                title: "Uploaded",
                value: statistics.totalUploaded,
                color: AppTheme.Colors.auroraBlue,
                progress: uploadProgress
            )
        }
    }
    
    // MARK: - Data Ring
    private func dataRing(
        title: String,
        value: Int64,
        color: Color,
        progress: Double
    ) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Progress ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [
                                color.opacity(0.3),
                                color,
                                color.opacity(0.8)
                            ],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        AppTheme.Animation.gentleSpring.delay(0.2),
                        value: progress
                    )
                
                // Center value
                VStack(spacing: 2) {
                    Text(formatBytes(value))
                        .font(AppTheme.Typography.labelMedium)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .monospacedDigit()
                    
                    Text(progress > 0.8 ? "High" : progress > 0.4 ? "Med" : "Low")
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.6))
                }
            }
            
            // Title
            Text(title)
                .font(AppTheme.Typography.labelMedium)
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Disconnected Placeholder
    private var disconnectedPlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.3))
                .scaleEffect(animationPhase > 0.5 ? 1.1 : 1.0)
                .opacity(animationPhase > 0.5 ? 0.5 : 0.3)
                .animation(AppTheme.Animation.ambientFloat, value: animationPhase)
            
            Text("Connect to view statistics")
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.6))
                .fontWeight(.medium)
            
            Text("Real-time data usage and connection metrics")
                .font(AppTheme.Typography.bodySmall)
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.xl)
    }
    
    // MARK: - Background Elements
    private var speedCardBackground: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Computed Properties
    private var formattedDuration: String {
        let hours = Int(statistics.connectionDuration) / 3600
        let minutes = (Int(statistics.connectionDuration) % 3600) / 60
        let seconds = Int(statistics.connectionDuration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private var downloadProgress: Double {
        // Simulate progress based on downloaded data
        let maxData: Int64 = 1024 * 1024 * 1024 // 1GB as max for progress calculation
        return min(Double(statistics.totalDownloaded) / Double(maxData), 1.0)
    }
    
    private var uploadProgress: Double {
        // Simulate progress based on uploaded data
        let maxData: Int64 = 256 * 1024 * 1024 // 256MB as max for progress calculation
        return min(Double(statistics.totalUploaded) / Double(maxData), 1.0)
    }
    
    // MARK: - Helper Methods
    private func formatSpeed(_ bytesPerSecond: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.includesUnit = false
        formatter.includesCount = true
        
        let speed = formatter.string(fromByteCount: bytesPerSecond)
        return "\(speed)/s"
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.includesUnit = true
        formatter.includesCount = true
        
        return formatter.string(fromByteCount: bytes)
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: true)) {
            animationPhase = 1.0
        }
        
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
            glowIntensity = 0.6
        }
    }
    
    private func triggerCounterAnimation() {
        counterAnimationTrigger.toggle()
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Int64
    let formatter: (Int64) -> String
    
    @State private var displayValue: Int64 = 0
    @State private var animationWorkItem: DispatchWorkItem?
    
    var body: some View {
        Text(formatter(displayValue))
            .contentTransition(.numericText(value: Double(displayValue)))
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                if displayValue != value {
                    animateToValue()
                }
            }
            .onAppear {
                displayValue = value
            }
    }
    
    private func animateToValue() {
        // Cancel previous animation
        animationWorkItem?.cancel()
        
        let difference = abs(value - displayValue)
        let step = max(difference / 20, 1) // Smooth animation over 20 steps
        
        if displayValue < value {
            displayValue = min(displayValue + step, value)
        } else if displayValue > value {
            displayValue = max(displayValue - step, value)
        }
        
        // Schedule next update if needed
        if displayValue != value {
            let workItem = DispatchWorkItem {
                animateToValue()
            }
            animationWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: workItem)
        }
    }
}

// MARK: - Preview
struct ConnectionStats_Previews: PreviewProvider {
    static let sampleStats = ConnectionMetrics(
        uploadSpeed: 1024 * 1024 * 5,    // 5 MB/s
        downloadSpeed: 1024 * 1024 * 25, // 25 MB/s
        totalUploaded: 1024 * 1024 * 150,   // 150 MB
        totalDownloaded: 1024 * 1024 * 500, // 500 MB
        connectionDuration: 3725, // 1h 2m 5s
        location: "Finland",
        serverName: "ViperFastFinland"
    )
    
    static var previews: some View {
        ZStack {
            AppTheme.AuroraGradients.timeBasedGradient(hour: 20)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Connected state
                    VStack {
                        Text("Connected State")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                        
                        ConnectionStats(
                            statistics: sampleStats,
                            isConnected: true
                        )
                    }
                    
                    // Disconnected state
                    VStack {
                        Text("Disconnected State")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                        
                        ConnectionStats(
                            statistics: .empty,
                            isConnected: false
                        )
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }
}