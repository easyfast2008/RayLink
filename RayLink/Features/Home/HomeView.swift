import SwiftUI
import Foundation
// Global types imported via RayLinkTypes
import Combine

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    @State private var waveOffset: CGFloat = 0
    @State private var particleOffset: CGFloat = 0
    @State private var headerOpacity: Double = 1.0
    
    public var body: some View {
        ZStack {
            // Aurora wave background
            auroraBackground
            
            // Main content
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.xl) {
                    // Header with logo/status
                    headerSection
                        .opacity(headerOpacity)
                    
                    // Server selector card
                    serverSelectorSection
                    
                    // Connection mode selector
                    connectionModeSection
                    
                    // Main connection button
                    connectionButtonSection
                    
                    // Connection stats (when connected)
                    if viewModel.connectionStatus == .connected {
                        connectionStatsSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
            .coordinateSpace(name: "scroll")
            .refreshable {
                await viewModel.refresh()
            }
            .onScrollOffsetChanged { offset in
                withAnimation(.easeOut(duration: 0.2)) {
                    headerOpacity = max(0.3, 1.0 - offset / 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.setup(
                vpnManager: container.vpnManager,
                storageManager: container.storageManager
            )
            startBackgroundAnimations()
        }
        .alert("Connection Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Aurora Background
    private var auroraBackground: some View {
        ZStack {
            // Base aurora gradient
            AppTheme.AuroraGradients.timeBasedGradient(
                hour: Calendar.current.component(.hour, from: Date())
            )
            .ignoresSafeArea()
            
            // Animated wave layers
            ForEach(0..<3, id: \.self) { index in
                WaveShape(
                    frequency: 1.5 + Double(index) * 0.5,
                    amplitude: 30 + Double(index) * 15,
                    offset: waveOffset + Double(index) * .pi / 2
                )
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.auroraBlue.opacity(0.1 + Double(index) * 0.05),
                            AppTheme.Colors.auroraViolet.opacity(0.05 + Double(index) * 0.03),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(y: CGFloat(index) * 50)
                .animation(
                    .linear(duration: 8.0 + Double(index) * 2.0)
                        .repeatForever(autoreverses: false),
                    value: waveOffset
                )
            }
            
            // Floating particles
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: CGFloat.random(in: 2...6),
                        height: CGFloat.random(in: 2...6)
                    )
                    .offset(
                        x: CGFloat.random(in: -200...200) + sin(particleOffset + Double(index)) * 50,
                        y: CGFloat.random(in: -400...400) + cos(particleOffset + Double(index)) * 30
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: particleOffset
                    )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // Settings button
            Button(action: {
                coordinator.navigate(to: .settings)
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textOnGlass)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .background(.ultraThinMaterial)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // App logo/connection status
            VStack(spacing: AppTheme.Spacing.xs) {
                ZStack {
                    // RayLink logo with dynamic state
                    Image(systemName: logoIcon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(logoColor)
                        .scaleEffect(viewModel.connectionStatus == .connecting ? 0.9 : 1.0)
                        .animation(
                            viewModel.connectionStatus == .connecting 
                                ? AppTheme.Animation.breathingGlow
                                : .easeOut(duration: 0.3),
                            value: viewModel.connectionStatus
                        )
                }
                
                Text("RayLink")
                    .font(AppTheme.Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textOnGlass)
            }
            
            Spacer()
            
            // Add/Import button
            Button(action: {
                coordinator.navigate(to: .import)
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textOnGlass)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .background(.ultraThinMaterial)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.top, AppTheme.Spacing.lg)
    }
    
    // MARK: - Server Selector Section
    private var serverSelectorSection: some View {
        ServerSelectorCard(
            server: viewModel.currentServer
        ) {
            coordinator.navigate(to: .serverList)
        }
    }
    
    // MARK: - Connection Mode Section
    private var connectionModeSection: some View {
        ConnectionModeSelector(
            selectedMode: Binding(
                get: { viewModel.connectionMode },
                set: { viewModel.updateConnectionMode($0) }
            )
        )
    }
    
    // MARK: - Connection Button Section
    private var connectionButtonSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Main connection button using PulseRingButton
            PulseRingButton(
                connectionState: viewModel.vpnConnectionState,
                size: .extraLarge,
                icon: connectionIcon
            ) {
                Task {
                    await viewModel.toggleConnection()
                }
            }
            .disabled(viewModel.isLoading)
            
            // Connection status text
            Text(connectionStatusText)
                .font(AppTheme.Typography.titleMedium)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.textOnGlass)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .animation(AppTheme.Animation.gentleSpring, value: viewModel.connectionStatus)
        }
        .padding(.vertical, AppTheme.Spacing.xl)
    }
    
    // MARK: - Connection Stats Section
    private var connectionStatsSection: some View {
        ConnectionStats(
            statistics: viewModel.connectionStatistics,
            isConnected: viewModel.connectionStatus == .connected
        )
        .glassmorphicCard()
    }
    
    // MARK: - Computed Properties
    private var logoIcon: String {
        switch viewModel.connectionStatus {
        case .connected:
            return "checkmark.shield.fill"
        case .connecting, .disconnecting, .reasserting:
            return "arrow.triangle.2.circlepath"
        case .disconnected, .invalid:
            return "shield"
        }
    }
    
    private var logoColor: Color {
        switch viewModel.connectionStatus {
        case .connected:
            return AppTheme.Colors.connected
        case .connecting, .disconnecting, .reasserting:
            return AppTheme.Colors.connecting
        case .disconnected, .invalid:
            return AppTheme.Colors.textOnGlass.opacity(0.7)
        }
    }
    
    private var connectionIcon: String {
        if viewModel.isLoading {
            return "arrow.triangle.2.circlepath"
        }
        
        switch viewModel.connectionStatus {
        case .connected:
            return "stop.fill"
        case .connecting, .disconnecting, .reasserting:
            return "arrow.triangle.2.circlepath"
        case .disconnected, .invalid:
            return "power"
        }
    }
    
    private var connectionStatusText: String {
        switch viewModel.connectionStatus {
        case .connected:
            return "Secured & Protected\nYour connection is encrypted"
        case .connecting:
            return "Connecting...\nEstablishing secure connection"
        case .disconnecting:
            return "Disconnecting...\nClosing secure connection"
        case .reasserting:
            return "Reconnecting...\nRestoring secure connection"
        case .disconnected:
            return "Not Protected\nTap to connect securely"
        case .invalid:
            return "Configuration Error\nPlease check your settings"
        }
    }
    
    // MARK: - Animation Methods
    private func startBackgroundAnimations() {
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
            waveOffset = 2 * .pi
        }
        
        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
            particleOffset = 2 * .pi
        }
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    let frequency: Double
    let amplitude: Double
    var offset: Double
    
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepSize = rect.width / 200
        
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        for x in stride(from: 0, through: rect.width, by: stepSize) {
            let relativeX = x / rect.width
            let sine = sin(relativeX * frequency * 2 * .pi + offset)
            let y = rect.midY + sine * amplitude
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Complete the shape to fill
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Scroll Offset Preference
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - View Extension for Scroll Offset
extension View {
    func onScrollOffsetChanged(action: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            action(-value)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(DependencyContainer())
            .environmentObject(NavigationCoordinator())
            .preferredColorScheme(.dark)
    }
}