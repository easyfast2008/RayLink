import SwiftUI

// MARK: - Connection Mode Enum
enum ConnectionMode: String, CaseIterable, Identifiable {
    case automatic = "AUTOMATIC"
    case global = "GLOBAL"
    case direct = "DIRECT"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .automatic:
            return "Smart routing based on destination"
        case .global:
            return "Route all traffic through VPN"
        case .direct:
            return "Direct connection for local traffic"
        }
    }
    
    var icon: String {
        switch self {
        case .automatic:
            return "brain"
        case .global:
            return "globe"
        case .direct:
            return "arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .automatic:
            return AppTheme.Colors.auroraBlue
        case .global:
            return AppTheme.Colors.auroraViolet
        case .direct:
            return AppTheme.Colors.auroraGreen
        }
    }
}

// MARK: - Connection Mode Selector Component
struct ConnectionModeSelector: View {
    @Binding var selectedMode: ConnectionMode
    
    @State private var selectorOffset: CGFloat = 0
    @State private var selectorWidth: CGFloat = 0
    @State private var ripplePhase: CGFloat = 0
    @State private var liquidScale: CGFloat = 1.0
    @State private var backgroundPhase: CGFloat = 0
    
    private let modes = ConnectionMode.allCases
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Mode selector
            ZStack {
                // Background with flowing liquid effect
                liquidBackground
                
                // Liquid selection indicator
                liquidSelector
                
                // Mode buttons
                HStack(spacing: 0) {
                    ForEach(modes) { mode in
                        modeButton(for: mode)
                    }
                }
            }
            .frame(height: 50)
            .background(selectorBackground)
            .cornerRadius(AppTheme.CornerRadius.xl)
            .overlay(borderOverlay)
            .shadow(color: selectedMode.color.opacity(0.3), radius: 8, x: 0, y: 4)
            .onAppear {
                updateSelectorPosition(animated: false)
                startBackgroundAnimation()
            }
            .onChange(of: selectedMode) { _ in
                updateSelectorPosition(animated: true)
                triggerHapticFeedback()
            }
            
            // Selected mode description
            modeDescription
        }
    }
    
    // MARK: - Liquid Background
    private var liquidBackground: some View {
        GeometryReader { geometry in
            // Animated wave patterns
            ForEach(0..<3, id: \.self) { index in
                DynamicWaveShape(
                    frequency: Double(index + 1) * 0.5,
                    amplitude: 8 + Double(index) * 4,
                    phase: backgroundPhase + Double(index) * .pi / 3
                )
                .fill(
                    LinearGradient(
                        colors: [
                            selectedMode.color.opacity(0.1 + Double(index) * 0.05),
                            selectedMode.color.opacity(0.05 + Double(index) * 0.02)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(y: CGFloat(index) * 2)
                .animation(
                    .linear(duration: 3.0 + Double(index) * 0.5)
                        .repeatForever(autoreverses: false),
                    value: backgroundPhase
                )
            }
        }
        .clipped()
    }
    
    // MARK: - Liquid Selector
    private var liquidSelector: some View {
        GeometryReader { geometry in
            ZStack {
                // Main liquid blob
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(liquidSelectorGradient)
                    .frame(width: selectorWidth, height: 42)
                    .scaleEffect(liquidScale)
                    .offset(x: selectorOffset)
                    .shadow(color: selectedMode.color.opacity(0.4), radius: 12, x: 0, y: 6)
                    .animation(AppTheme.Animation.liquidTransition, value: selectorOffset)
                    .animation(AppTheme.Animation.bouncySpring, value: liquidScale)
                
                // Ripple effect on selection
                if ripplePhase > 0 {
                    Circle()
                        .stroke(selectedMode.color.opacity(0.6), lineWidth: 2)
                        .scaleEffect(ripplePhase)
                        .opacity(1.0 - ripplePhase)
                        .frame(width: selectorWidth, height: selectorWidth)
                        .offset(x: selectorOffset + selectorWidth / 2)
                        .animation(.easeOut(duration: 0.6), value: ripplePhase)
                }
            }
        }
    }
    
    // MARK: - Mode Button
    private func modeButton(for mode: ConnectionMode) -> some View {
        GeometryReader { geometry in
            Button(action: {
                selectedMode = mode
                triggerRippleEffect()
            }) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textColor(for: mode))
                    
                    Text(mode.displayName)
                        .font(AppTheme.Typography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor(for: mode))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(selectedMode == mode ? 1.05 : 1.0)
                .animation(AppTheme.Animation.bouncySpring, value: selectedMode)
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                if selectorWidth == 0 {
                    selectorWidth = geometry.size.width
                }
            }
        }
    }
    
    // MARK: - Mode Description
    private var modeDescription: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: selectedMode.icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(selectedMode.color)
            
            Text(selectedMode.description)
                .font(AppTheme.Typography.bodySmall)
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
            
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .transition(.opacity.combined(with: .scale))
        .animation(AppTheme.Animation.gentleSpring, value: selectedMode)
    }
    
    // MARK: - Background Elements
    private var selectorBackground: some View {
        ZStack {
            // Base glass background
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial)
            
            // Subtle color tint
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(selectedMode.color.opacity(0.03))
        }
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.1),
                        selectedMode.color.opacity(0.2),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
    
    // MARK: - Computed Properties
    private var liquidSelectorGradient: some View {
        LinearGradient(
            colors: [
                selectedMode.color.opacity(0.9),
                selectedMode.color.opacity(0.7),
                selectedMode.color.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func textColor(for mode: ConnectionMode) -> Color {
        selectedMode == mode 
            ? .white 
            : AppTheme.Colors.textOnGlass.opacity(0.7)
    }
    
    // MARK: - Animation Methods
    private func updateSelectorPosition(animated: Bool) {
        let index = modes.firstIndex(of: selectedMode) ?? 0
        let newOffset = CGFloat(index) * selectorWidth
        
        if animated {
            withAnimation(AppTheme.Animation.liquidTransition) {
                selectorOffset = newOffset
            }
        } else {
            selectorOffset = newOffset
        }
    }
    
    private func triggerRippleEffect() {
        ripplePhase = 0
        withAnimation(.easeOut(duration: 0.6)) {
            ripplePhase = 2.0
        }
        
        // Liquid scale effect
        liquidScale = 1.2
        withAnimation(AppTheme.Animation.bouncySpring.delay(0.1)) {
            liquidScale = 1.0
        }
    }
    
    private func triggerHapticFeedback() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    private func startBackgroundAnimation() {
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            backgroundPhase = 2 * .pi
        }
    }
}

// MARK: - Wave Shape
struct DynamicWaveShape: Shape {
    let frequency: Double
    let amplitude: Double
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepSize = rect.width / 100
        
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        for x in stride(from: 0, through: rect.width, by: stepSize) {
            let relativeX = x / rect.width
            let sine = sin(relativeX * frequency * 2 * .pi + phase)
            let y = rect.midY + sine * amplitude
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Complete the shape
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview
struct ConnectionModeSelector_Previews: PreviewProvider {
    @State static var selectedMode: ConnectionMode = .global
    
    static var previews: some View {
        ZStack {
            AppTheme.AuroraGradients.timeBasedGradient(hour: 20)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                ConnectionModeSelector(selectedMode: $selectedMode)
                
                // Preview all states
                VStack(spacing: 20) {
                    ForEach(ConnectionMode.allCases) { mode in
                        ConnectionModeSelector(selectedMode: .constant(mode))
                    }
                }
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }
}