import SwiftUI

// MARK: - Pulse Ring Button Component
struct PulseRingButton: View {
    let action: () -> Void
    let connectionState: VPNConnectionState
    let size: PulseRingSize
    let icon: String
    
    @State private var pulseScale: [CGFloat] = [1.0, 1.0, 1.0, 1.0]
    @State private var pulseOpacity: [Double] = [0.8, 0.6, 0.4, 0.2]
    @State private var rotationAngle: Double = 0
    @State private var breathingScale: CGFloat = 1.0
    @State private var energyParticles: [EnergyParticle] = []
    @State private var isPressed: Bool = false
    
    init(
        connectionState: VPNConnectionState,
        size: PulseRingSize = .large,
        icon: String = "power",
        action: @escaping () -> Void
    ) {
        self.connectionState = connectionState
        self.size = size
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        ZStack {
            // Background pulse rings
            pulseRings
            
            // Energy particles for connected state
            if connectionState == .connected {
                energyParticleSystem
            }
            
            // Connecting rotation ring
            if connectionState == .connecting {
                connectingRing
            }
            
            // Main button
            mainButton
        }
        .frame(width: size.totalFrameSize, height: size.totalFrameSize)
        .onAppear {
            initializeParticles()
            startAnimations()
        }
        .onChange(of: connectionState) { _ in
            updateAnimationsForState()
        }
    }
    
    // MARK: - Pulse Rings
    private var pulseRings: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(
                        ringColor.opacity(pulseOpacity[index]),
                        lineWidth: size.ringLineWidth
                    )
                    .frame(
                        width: size.buttonSize + CGFloat(index * 20),
                        height: size.buttonSize + CGFloat(index * 20)
                    )
                    .scaleEffect(pulseScale[index])
                    .animation(
                        connectionState == .connected ?
                        .easeInOut(duration: 2.0 + Double(index) * 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2)
                        : .easeOut(duration: 0.3),
                        value: pulseScale[index]
                    )
            }
        }
    }
    
    // MARK: - Energy Particle System
    private var energyParticleSystem: some View {
        ZStack {
            ForEach(energyParticles.indices, id: \.self) { index in
                let particle = energyParticles[index]
                Circle()
                    .fill(AppTheme.Colors.connected)
                    .frame(width: particle.size, height: particle.size)
                    .offset(particle.offset)
                    .opacity(particle.opacity)
                    .blur(radius: particle.blur)
                    .scaleEffect(particle.scale)
                    .animation(
                        .easeInOut(duration: particle.duration)
                            .repeatForever(autoreverses: true)
                            .delay(particle.delay),
                        value: particle.animationTrigger
                    )
            }
        }
    }
    
    // MARK: - Connecting Ring
    private var connectingRing: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AngularGradient(
                    colors: [
                        AppTheme.Colors.connecting.opacity(0.9),
                        AppTheme.Colors.connecting.opacity(0.3),
                        Color.clear
                    ],
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                style: StrokeStyle(lineWidth: size.ringLineWidth + 1, lineCap: .round)
            )
            .frame(width: size.buttonSize + 25, height: size.buttonSize + 25)
            .rotationEffect(.degrees(rotationAngle))
            .animation(
                .linear(duration: 1.5).repeatForever(autoreverses: false),
                value: rotationAngle
            )
    }
    
    // MARK: - Main Button
    private var mainButton: some View {
        Button(action: {
            isPressed = true
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            // Execute action
            action()
            
            // Reset press state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            ZStack {
                // Background with glassmorphic effect
                Circle()
                    .fill(buttonBackgroundStyle)
                    .frame(width: size.buttonSize, height: size.buttonSize)
                
                // Inner glow
                Circle()
                    .fill(innerGlowGradient)
                    .frame(width: size.buttonSize - 4, height: size.buttonSize - 4)
                    .opacity(0.6)
                
                // Icon with breathing effect
                Image(systemName: icon)
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundColor(iconColor)
                    .scaleEffect(breathingScale)
                    .animation(
                        connectionState == .connected ?
                        AppTheme.Animation.breathingGlow : .easeOut(duration: 0.3),
                        value: breathingScale
                    )
            }
            .overlay(
                Circle()
                    .stroke(borderGradient, lineWidth: 2)
                    .frame(width: size.buttonSize, height: size.buttonSize)
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .shadow(
                color: shadowColor,
                radius: isPressed ? 8 : 15,
                x: 0,
                y: isPressed ? 4 : 8
            )
            .animation(AppTheme.Animation.bouncySpring, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Color Properties
    private var ringColor: Color {
        switch connectionState {
        case .connected:
            return AppTheme.Colors.connected
        case .connecting:
            return AppTheme.Colors.connecting
        case .disconnected:
            return AppTheme.Colors.disconnected
        }
    }
    
    private var buttonBackgroundStyle: AnyShapeStyle {
        switch connectionState {
        case .connected:
            return AnyShapeStyle(AppTheme.AuroraGradients.connected)
        case .connecting:
            return AnyShapeStyle(AppTheme.AuroraGradients.connecting)
        case .disconnected:
            return AnyShapeStyle(AppTheme.AuroraGradients.disconnected)
        }
    }
    
    private var innerGlowGradient: RadialGradient {
        RadialGradient(
            colors: [
                ringColor.opacity(0.6),
                ringColor.opacity(0.2),
                Color.clear
            ],
            center: .center,
            startRadius: 5,
            endRadius: size.buttonSize / 2
        )
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.6),
                ringColor.opacity(0.4),
                Color.white.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconColor: Color {
        switch connectionState {
        case .connected:
            return .white
        case .connecting:
            return .white
        case .disconnected:
            return Color.white.opacity(0.7)
        }
    }
    
    private var shadowColor: Color {
        switch connectionState {
        case .connected:
            return AppTheme.Colors.connected.opacity(0.4)
        case .connecting:
            return AppTheme.Colors.connecting.opacity(0.4)
        case .disconnected:
            return Color.black.opacity(0.2)
        }
    }
    
    // MARK: - Animation Control
    private func initializeParticles() {
        energyParticles = (0..<12).map { index in
            EnergyParticle(
                id: index,
                offset: CGSize(
                    width: cos(Double(index) * .pi / 6) * Double.random(in: 40...60),
                    height: sin(Double(index) * .pi / 6) * Double.random(in: 40...60)
                ),
                size: CGFloat.random(in: 2...4),
                opacity: Double.random(in: 0.4...0.8),
                scale: CGFloat.random(in: 0.5...1.0),
                blur: CGFloat.random(in: 0.5...1.5),
                duration: Double.random(in: 1.5...3.0),
                delay: Double.random(in: 0...2.0),
                animationTrigger: false
            )
        }
    }
    
    private func startAnimations() {
        updateAnimationsForState()
    }
    
    private func updateAnimationsForState() {
        switch connectionState {
        case .connected:
            startConnectedAnimations()
        case .connecting:
            startConnectingAnimations()
        case .disconnected:
            stopAllAnimations()
        }
    }
    
    private func startConnectedAnimations() {
        // Pulse rings
        for index in pulseScale.indices {
            withAnimation(
                .easeInOut(duration: 2.0 + Double(index) * 0.3)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.2)
            ) {
                pulseScale[index] = 1.5
                pulseOpacity[index] = 0.0
            }
        }
        
        // Breathing effect
        withAnimation(AppTheme.Animation.breathingGlow) {
            breathingScale = 1.1
        }
        
        // Energy particles
        for index in energyParticles.indices {
            energyParticles[index].animationTrigger.toggle()
        }
    }
    
    private func startConnectingAnimations() {
        // Stop pulse rings
        for index in pulseScale.indices {
            withAnimation(.easeOut(duration: 0.3)) {
                pulseScale[index] = 1.0
                pulseOpacity[index] = connectionState == .disconnected ? 0.0 : 0.3
            }
        }
        
        // Start rotation
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Reset breathing
        withAnimation(.easeOut(duration: 0.3)) {
            breathingScale = 1.0
        }
    }
    
    private func stopAllAnimations() {
        // Stop pulse rings
        for index in pulseScale.indices {
            withAnimation(.easeOut(duration: 0.5)) {
                pulseScale[index] = 1.0
                pulseOpacity[index] = 0.0
            }
        }
        
        // Stop rotation
        withAnimation(.easeOut(duration: 0.5)) {
            rotationAngle = 0
        }
        
        // Reset breathing
        withAnimation(.easeOut(duration: 0.3)) {
            breathingScale = 1.0
        }
    }
}

// MARK: - Pulse Ring Size Configuration
enum PulseRingSize {
    case small, medium, large, extraLarge
    
    var buttonSize: CGFloat {
        switch self {
        case .small: return 60
        case .medium: return 80
        case .large: return 100
        case .extraLarge: return 120
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 20
        case .medium: return 24
        case .large: return 28
        case .extraLarge: return 32
        }
    }
    
    var ringLineWidth: CGFloat {
        switch self {
        case .small: return 2
        case .medium: return 2.5
        case .large: return 3
        case .extraLarge: return 3.5
        }
    }
    
    var totalFrameSize: CGFloat {
        return buttonSize + 80 // Extra space for pulse rings
    }
}

// MARK: - Energy Particle Model
struct EnergyParticle {
    let id: Int
    var offset: CGSize
    let size: CGFloat
    let opacity: Double
    let scale: CGFloat
    let blur: CGFloat
    let duration: Double
    let delay: Double
    var animationTrigger: Bool
}

// MARK: - Preview
struct PulseRingButton_Previews: PreviewProvider {
    @State static var connectionState: VPNConnectionState = .disconnected
    
    static var previews: some View {
        ZStack {
            // Aurora background for preview
            AppTheme.AuroraGradients.timeBasedGradient(hour: 20)
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                VStack(spacing: 20) {
                    Text("Connection States")
                        .font(AppTheme.Typography.headlineMedium)
                        .foregroundColor(AppTheme.Colors.textOnGlass)
                    
                    HStack(spacing: 40) {
                        VStack {
                            PulseRingButton(
                                connectionState: .disconnected,
                                size: .medium,
                                icon: "power"
                            ) {
                                print("Disconnected button tapped")
                            }
                            Text("Disconnected")
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                        }
                        
                        VStack {
                            PulseRingButton(
                                connectionState: .connecting,
                                size: .medium,
                                icon: "arrow.triangle.2.circlepath"
                            ) {
                                print("Connecting button tapped")
                            }
                            Text("Connecting")
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                        }
                        
                        VStack {
                            PulseRingButton(
                                connectionState: .connected,
                                size: .medium,
                                icon: "checkmark.shield.fill"
                            ) {
                                print("Connected button tapped")
                            }
                            Text("Connected")
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                        }
                    }
                }
                
                VStack(spacing: 30) {
                    Text("Different Sizes")
                        .font(AppTheme.Typography.headlineMedium)
                        .foregroundColor(AppTheme.Colors.textOnGlass)
                    
                    HStack(spacing: 30) {
                        PulseRingButton(
                            connectionState: .connected,
                            size: .small,
                            icon: "power"
                        ) { }
                        
                        PulseRingButton(
                            connectionState: .connected,
                            size: .medium,
                            icon: "power"
                        ) { }
                        
                        PulseRingButton(
                            connectionState: .connected,
                            size: .large,
                            icon: "power"
                        ) { }
                    }
                }
            }
            .padding(40)
        }
        .preferredColorScheme(.dark)
    }
}
