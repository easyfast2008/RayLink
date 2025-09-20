import SwiftUI

// MARK: - Glassmorphic Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    init(isEnabled: Bool = true, size: ButtonSize = .medium) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font.weight(.medium))
            .foregroundColor(AppTheme.Colors.textOnGlass)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(
                ZStack {
                    // Aurora gradient background
                    if isEnabled {
                        AppTheme.AuroraGradients.primary
                            .opacity(configuration.isPressed ? 0.8 : 1.0)
                    } else {
                        Color.gray.opacity(0.3)
                    }
                    
                    // Glassmorphic overlay
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(Color.white.opacity(0.1))
                        .background(.ultraThinMaterial)
                }
            )
            .cornerRadius(size.cornerRadius)
            .overlay(
                // Glassmorphic border
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: isEnabled ? AppTheme.Colors.accent.opacity(0.3) : Color.clear,
                radius: configuration.isPressed ? 5 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 5
            )
            .animation(AppTheme.Animation.fluidSpring, value: configuration.isPressed)
    }
}

// MARK: - Glassmorphic Button Style
struct GlassmorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(AppTheme.Colors.textOnGlass)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(AppTheme.Colors.glassMorphicFill)
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                            .stroke(
                                AppTheme.AuroraGradients.primary,
                                lineWidth: 1
                            )
                            .opacity(configuration.isPressed ? 0.45 : 0.3)
                    )
            )
            .shadow(
                color: AppTheme.Colors.accent.opacity(configuration.isPressed ? 0.15 : 0.25),
                radius: configuration.isPressed ? 6 : 12,
                x: 0,
                y: configuration.isPressed ? 3 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AppTheme.Animation.fluidSpring, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    init(isEnabled: Bool = true, size: ButtonSize = .medium) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundColor(foregroundForState(configuration: configuration))
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(backgroundForState(configuration: configuration))
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(borderColorForState(configuration: configuration), lineWidth: 1)
            )
            .cornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.fast, value: configuration.isPressed)
    }
    
    private func foregroundForState(configuration: Configuration) -> Color {
        if !isEnabled {
            return AppTheme.Colors.secondary
        } else {
            return AppTheme.Colors.primary
        }
    }
    
    private func backgroundForState(configuration: Configuration) -> Color {
        if configuration.isPressed {
            return AppTheme.Colors.primary.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    private func borderColorForState(configuration: Configuration) -> Color {
        if !isEnabled {
            return AppTheme.Colors.secondary.opacity(0.3)
        } else {
            return AppTheme.Colors.primary
        }
    }
}

// MARK: - Accent Button Style
struct AccentButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    init(isEnabled: Bool = true, size: ButtonSize = .medium) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundColor(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(backgroundForState(configuration: configuration))
            .cornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(AppTheme.Animation.fast, value: configuration.isPressed)
    }
    
    private func backgroundForState(configuration: Configuration) -> Color {
        if !isEnabled {
            return AppTheme.Colors.secondary.opacity(0.3)
        } else if configuration.isPressed {
            return AppTheme.Colors.accentDark
        } else {
            return AppTheme.Colors.accent
        }
    }
}

// MARK: - Destructive Button Style
struct DestructiveButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    init(isEnabled: Bool = true, size: ButtonSize = .medium) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundColor(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(backgroundForState(configuration: configuration))
            .cornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(AppTheme.Animation.fast, value: configuration.isPressed)
    }
    
    private func backgroundForState(configuration: Configuration) -> Color {
        if !isEnabled {
            return AppTheme.Colors.secondary.opacity(0.3)
        } else if configuration.isPressed {
            return AppTheme.Colors.error.opacity(0.8)
        } else {
            return AppTheme.Colors.error
        }
    }
}

// MARK: - Ghost Button Style
struct GhostButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    init(isEnabled: Bool = true, size: ButtonSize = .medium) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundColor(foregroundForState(configuration: configuration))
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(backgroundForState(configuration: configuration))
            .cornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.fast, value: configuration.isPressed)
    }
    
    private func foregroundForState(configuration: Configuration) -> Color {
        if !isEnabled {
            return AppTheme.Colors.secondary
        } else {
            return AppTheme.Colors.primary
        }
    }
    
    private func backgroundForState(configuration: Configuration) -> Color {
        if configuration.isPressed {
            return AppTheme.Colors.primary.opacity(0.1)
        } else {
            return Color.clear
        }
    }
}

// MARK: - Icon Button Style
struct IconButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: IconButtonSize
    let backgroundColor: Color?
    
    init(isEnabled: Bool = true, size: IconButtonSize = .medium, backgroundColor: Color? = nil) {
        self.isEnabled = isEnabled
        self.size = size
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.iconSize, weight: .medium))
            .foregroundColor(foregroundForState(configuration: configuration))
            .frame(width: size.frameSize, height: size.frameSize)
            .background(backgroundForState(configuration: configuration))
            .cornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppTheme.Animation.fast, value: configuration.isPressed)
    }
    
    private func foregroundForState(configuration: Configuration) -> Color {
        if !isEnabled {
            return AppTheme.Colors.secondary
        } else {
            return AppTheme.Colors.primary
        }
    }
    
    private func backgroundForState(configuration: Configuration) -> Color {
        if let backgroundColor = backgroundColor {
            return configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor
        } else if configuration.isPressed {
            return AppTheme.Colors.primary.opacity(0.1)
        } else {
            return Color.clear
        }
    }
}

// MARK: - Floating Action Button Style
struct FloatingActionButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: FloatingButtonSize
    
    init(isEnabled: Bool = true, size: FloatingButtonSize = .regular) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.iconSize, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: size.frameSize, height: size.frameSize)
            .background(backgroundForState(configuration: configuration))
            .cornerRadius(size.frameSize / 2)
            .themedShadow(AppTheme.Shadow.large)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppTheme.Animation.bouncySpring, value: configuration.isPressed)
    }
    
    private func backgroundForState(configuration: Configuration) -> Color {
        if !isEnabled {
            return AppTheme.Colors.secondary.opacity(0.3)
        } else if configuration.isPressed {
            return AppTheme.Colors.accentDark
        } else {
            return AppTheme.Colors.accent
        }
    }
}

// MARK: - Button Size Enums
enum ButtonSize {
    case small, medium, large
    
    var font: Font {
        switch self {
        case .small:
            return AppTheme.Typography.labelMedium
        case .medium:
            return AppTheme.Typography.labelLarge
        case .large:
            return AppTheme.Typography.titleMedium
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 16
        case .large:
            return 20
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small:
            return 8
        case .medium:
            return 12
        case .large:
            return 16
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small:
            return AppTheme.CornerRadius.sm
        case .medium:
            return AppTheme.CornerRadius.md
        case .large:
            return AppTheme.CornerRadius.lg
        }
    }
}

enum IconButtonSize {
    case small, medium, large
    
    var frameSize: CGFloat {
        switch self {
        case .small:
            return 32
        case .medium:
            return 44
        case .large:
            return 56
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small:
            return 16
        case .medium:
            return 20
        case .large:
            return 24
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small:
            return 8
        case .medium:
            return 12
        case .large:
            return 16
        }
    }
}

enum FloatingButtonSize {
    case mini, regular, large
    
    var frameSize: CGFloat {
        switch self {
        case .mini:
            return 40
        case .regular:
            return 56
        case .large:
            return 72
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .mini:
            return 16
        case .regular:
            return 24
        case .large:
            return 32
        }
    }
}

// MARK: - Magnetic Button Style
struct MagneticButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    @State private var magneticOffset: CGSize = .zero
    @State private var isHovering: Bool = false
    
    init(isEnabled: Bool = true, size: ButtonSize = .medium) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font.weight(.semibold))
            .foregroundColor(AppTheme.Colors.textOnGlass)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(
                ZStack {
                    // Liquid background effect
                    Capsule()
                        .fill(AppTheme.AuroraGradients.primary)
                        .scaleEffect(configuration.isPressed ? 1.1 : isHovering ? 1.05 : 1.0)
                        .blur(radius: configuration.isPressed ? 3 : 0)
                    
                    // Glassmorphic surface
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .offset(magneticOffset)
            .shadow(
                color: AppTheme.Colors.accent.opacity(0.4),
                radius: configuration.isPressed ? 15 : 8,
                x: 0,
                y: configuration.isPressed ? 8 : 4
            )
            .animation(AppTheme.Animation.magneticAttraction, value: configuration.isPressed)
            .animation(AppTheme.Animation.elasticPull, value: magneticOffset)
    }
}

// MARK: - Liquid Button Style
struct LiquidButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let size: ButtonSize
    
    @State private var liquidScale: CGFloat = 1.0
    @State private var liquidBlur: CGFloat = 0
    
    init(isEnabled: Bool = true, size: ButtonSize = .medium) {
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font.weight(.medium))
            .foregroundColor(AppTheme.Colors.textOnGlass)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(
                ZStack {
                    // Base liquid layer
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(AppTheme.AuroraGradients.primary)
                        .scaleEffect(liquidScale)
                        .blur(radius: liquidBlur)
                    
                    // Surface tension effect
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(Color.white.opacity(0.2))
                        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                }
            )
            .cornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.liquidRipple, value: configuration.isPressed)
            .onChangeCompat(of: configuration.isPressed) { pressed in
                if pressed {
                    // Liquid ripple effect
                    withAnimation(AppTheme.Animation.liquidRipple) {
                        liquidScale = 1.2
                        liquidBlur = 8
                    }
                    
                    // Return to normal
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(AppTheme.Animation.fluidSpring) {
                            liquidScale = 1.0
                            liquidBlur = 0
                        }
                    }
                }
            }
    }
}

// MARK: - Pulse Ring Connection Button Style
struct PulseRingConnectionStyle: ButtonStyle {
    let connectionState: VPNConnectionState
    let isEnabled: Bool
    let size: FloatingButtonSize
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.8
    @State private var ringRotation: Double = 0
    
    init(connectionState: VPNConnectionState, isEnabled: Bool = true, size: FloatingButtonSize = .regular) {
        self.connectionState = connectionState
        self.isEnabled = isEnabled
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.iconSize, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: size.frameSize, height: size.frameSize)
            .background(
                ZStack {
                    // Connection state background
                    backgroundGradient
                        .clipShape(Circle())
                    
                    // Pulse rings for connected state
                    if connectionState == .connected {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(AppTheme.Colors.connected.opacity(0.3), lineWidth: 2)
                                .frame(width: size.frameSize + CGFloat(index * 20), height: size.frameSize + CGFloat(index * 20))
                                .scaleEffect(pulseScale)
                                .opacity(pulseOpacity - Double(index) * 0.2)
                                .animation(
                                    AppTheme.Animation.connectionPulse.delay(Double(index) * 0.3),
                                    value: pulseScale
                                )
                        }
                    }
                    
                    // Rotating ring for connecting state
                    if connectionState == .connecting {
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(AppTheme.Colors.connecting, lineWidth: 3)
                            .frame(width: size.frameSize + 10, height: size.frameSize + 10)
                            .rotationEffect(.degrees(ringRotation))
                            .animation(
                                .linear(duration: 1.0).repeatForever(autoreverses: false),
                                value: ringRotation
                            )
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppTheme.Animation.bouncySpring, value: configuration.isPressed)
            .onAppear {
                startConnectionAnimation()
            }
            .onChangeCompat(of: connectionState) { _ in
                startConnectionAnimation()
            }
    }
    
    @ViewBuilder
    private var backgroundGradient: some View {
        switch connectionState {
        case .connected:
            AppTheme.AuroraGradients.connected
        case .connecting:
            AppTheme.AuroraGradients.connecting
        case .disconnected:
            AppTheme.AuroraGradients.disconnected
        }
    }
    
    private func startConnectionAnimation() {
        switch connectionState {
        case .connected:
            withAnimation(AppTheme.Animation.connectionPulse) {
                pulseScale = 1.5
                pulseOpacity = 0.0
            }
        case .connecting:
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        case .disconnected:
            pulseScale = 1.0
            pulseOpacity = 0.8
            ringRotation = 0
        }
    }
}

// MARK: - VPN Connection State Enum
enum VPNConnectionState {
    case connected, connecting, disconnected
}

// MARK: - Button Extensions
extension Button {
    func primaryStyle(isEnabled: Bool = true, size: ButtonSize = .medium) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    func secondaryStyle(isEnabled: Bool = true, size: ButtonSize = .medium) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    func accentStyle(isEnabled: Bool = true, size: ButtonSize = .medium) -> some View {
        self.buttonStyle(AccentButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    func destructiveStyle(isEnabled: Bool = true, size: ButtonSize = .medium) -> some View {
        self.buttonStyle(DestructiveButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    func ghostStyle(isEnabled: Bool = true, size: ButtonSize = .medium) -> some View {
        self.buttonStyle(GhostButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    func iconStyle(isEnabled: Bool = true, size: IconButtonSize = .medium, backgroundColor: Color? = nil) -> some View {
        self.buttonStyle(IconButtonStyle(isEnabled: isEnabled, size: size, backgroundColor: backgroundColor))
            .disabled(!isEnabled)
    }
    
    func floatingStyle(isEnabled: Bool = true, size: FloatingButtonSize = .regular) -> some View {
        self.buttonStyle(FloatingActionButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    // New Styles
    func magneticStyle(isEnabled: Bool = true, size: ButtonSize = .medium) -> some View {
        self.buttonStyle(MagneticButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    func liquidStyle(isEnabled: Bool = true, size: ButtonSize = .medium) -> some View {
        self.buttonStyle(LiquidButtonStyle(isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
    
    func pulseRingConnectionStyle(connectionState: VPNConnectionState, isEnabled: Bool = true, size: FloatingButtonSize = .regular) -> some View {
        self.buttonStyle(PulseRingConnectionStyle(connectionState: connectionState, isEnabled: isEnabled, size: size))
            .disabled(!isEnabled)
    }
}