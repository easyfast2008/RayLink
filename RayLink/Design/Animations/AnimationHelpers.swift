import SwiftUI
import Foundation
// MARK: - Enhanced Animation Presets with Fluid Physics
struct AnimationPresets {
    // Basic Animations with improved curves
    static let fastEaseIn = Animation.easeIn(duration: 0.2)
    static let fastEaseOut = Animation.easeOut(duration: 0.2)
    static let fastEaseInOut = Animation.easeInOut(duration: 0.2)
    
    static let mediumEaseIn = Animation.easeIn(duration: 0.3)
    static let mediumEaseOut = Animation.easeOut(duration: 0.3)
    static let mediumEaseInOut = Animation.easeInOut(duration: 0.3)
    
    static let slowEaseIn = Animation.easeIn(duration: 0.5)
    static let slowEaseOut = Animation.easeOut(duration: 0.5)
    static let slowEaseInOut = Animation.easeInOut(duration: 0.5)
    
    // Enhanced Spring Physics System
    static let ultraFluid = Animation.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)
    static let gentleSpring = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    static let responsiveSpring = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    static let bouncySpring = Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)
    static let snappySpring = Animation.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)
    
    // Liquid Motion Animations
    static let liquidBounce = Animation.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.1)
    static let jellyCubic = Animation.timingCurve(0.68, -0.6, 0.32, 1.6, duration: 0.8)
    static let elasticOut = Animation.timingCurve(0.34, 1.56, 0.64, 1, duration: 0.6)
    static let backOut = Animation.timingCurve(0.34, 1.3, 0.64, 1, duration: 0.5)
    
    // Specialized VPN Animations
    static let slideIn = Animation.easeOut(duration: 0.4)
    static let slideOut = Animation.easeIn(duration: 0.3)
    static let fadeIn = Animation.easeOut(duration: 0.3)
    static let fadeOut = Animation.easeIn(duration: 0.2)
    static let scaleIn = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
    static let scaleOut = Animation.easeIn(duration: 0.2)
    
    // Connection Status Animations
    static let connectionPulse = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    static let breathingGlow = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    static let connectingRotation = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
    static let statusTransition = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    
    // Aurora & Particle Animations
    static let auroraFlow = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)
    static let particleOrbit = Animation.linear(duration: 4.0).repeatForever(autoreverses: false)
    static let shimmerEffect = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
    
    // Magnetic & Interactive Animations
    static let magneticPull = Animation.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0)
    static let elasticSnap = Animation.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)
    static let hoverResponse = Animation.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)
}

// MARK: - Custom Animation Modifiers
struct SlideInModifier: ViewModifier {
    let direction: SlideDirection
    let distance: CGFloat
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .opacity(isVisible ? 1 : 0)
    }
    
    private var offset: CGSize {
        guard !isVisible else { return .zero }
        
        switch direction {
        case .top:
            return CGSize(width: 0, height: -distance)
        case .bottom:
            return CGSize(width: 0, height: distance)
        case .leading:
            return CGSize(width: -distance, height: 0)
        case .trailing:
            return CGSize(width: distance, height: 0)
        }
    }
}

struct ScaleInModifier: ViewModifier {
    let isVisible: Bool
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : scale)
            .opacity(isVisible ? 1.0 : 0)
    }
}

struct ShakeModifier: ViewModifier {
    let shakes: Int
    let animatableData: CGFloat
    
    init(shakes: Int) {
        self.shakes = shakes
        self.animatableData = 0
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: sin(animatableData * .pi * 2 * CGFloat(shakes)) * 5)
    }
}

struct PulseModifier: ViewModifier {
    let isAnimating: Bool
    let minScale: CGFloat
    let maxScale: CGFloat
    
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                if isAnimating {
                    startPulse()
                }
            }
            .onChangeCompat(of: isAnimating) { newValue in
                if newValue {
                    startPulse()
                } else {
                    stopPulse()
                }
            }
    }
    
    private func startPulse() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            scale = maxScale
        }
    }
    
    private func stopPulse() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.0
        }
    }
}

struct RotateModifier: ViewModifier {
    let isAnimating: Bool
    let duration: Double
    let clockwise: Bool
    
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                if isAnimating {
                    startRotation()
                }
            }
            .onChangeCompat(of: isAnimating) { newValue in
                if newValue {
                    startRotation()
                } else {
                    stopRotation()
                }
            }
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            rotation = clockwise ? 360 : -360
        }
    }
    
    private func stopRotation() {
        withAnimation(.easeOut(duration: 0.3)) {
            rotation = 0
        }
    }
}

// MARK: - Transition Extensions
extension AnyTransition {
    // Slide Transitions
    static let slideInFromTop = AnyTransition.move(edge: .top).combined(with: .opacity)
    static let slideInFromBottom = AnyTransition.move(edge: .bottom).combined(with: .opacity)
    static let slideInFromLeading = AnyTransition.move(edge: .leading).combined(with: .opacity)
    static let slideInFromTrailing = AnyTransition.move(edge: .trailing).combined(with: .opacity)
    
    // Scale Transitions
    static let scaleAndFade = AnyTransition.scale.combined(with: .opacity)
    static let scaleDown = AnyTransition.scale(scale: 0.8).combined(with: .opacity)
    static let scaleUp = AnyTransition.scale(scale: 1.2).combined(with: .opacity)
    
    // Custom Transitions
    static let slideUpWithBounce = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .move(edge: .bottom).combined(with: .opacity)
    )
    
    static let flipHorizontal = AnyTransition.modifier(
        active: FlipModifier(flipped: true),
        identity: FlipModifier(flipped: false)
    )
    
    // Connection Status Transitions
    static let connectionStatusChange = AnyTransition.asymmetric(
        insertion: .scale.combined(with: .opacity),
        removal: .scale.combined(with: .opacity)
    )
}

// MARK: - Custom Transition Modifiers
struct FlipModifier: ViewModifier {
    let flipped: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(flipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(flipped ? 0 : 1)
    }
}

// MARK: - Enums
enum SlideDirection {
    case top, bottom, leading, trailing
}

// MARK: - Enhanced View Extensions with Fluid Animations
extension View {
    // MARK: - Basic Animations
    
    // Slide In Animation
    func slideIn(
        from direction: SlideDirection,
        distance: CGFloat = 50,
        isVisible: Bool,
        animation: Animation = AnimationPresets.slideIn
    ) -> some View {
        self
            .modifier(SlideInModifier(direction: direction, distance: distance, isVisible: isVisible))
            .animation(animation, value: isVisible)
    }
    
    // Scale In Animation
    func scaleIn(
        isVisible: Bool,
        scale: CGFloat = 0.8,
        animation: Animation = AnimationPresets.scaleIn
    ) -> some View {
        self
            .modifier(ScaleInModifier(isVisible: isVisible, scale: scale))
            .animation(animation, value: isVisible)
    }
    
    // Shake Animation
    func shake(trigger: some Equatable, shakes: Int = 3) -> some View {
        self
            .modifier(ShakeModifier(shakes: shakes))
            .animation(.easeInOut(duration: 0.5), value: trigger)
    }
    
    // Pulse Animation
    func pulse(
        isAnimating: Bool = true,
        minScale: CGFloat = 0.9,
        maxScale: CGFloat = 1.1
    ) -> some View {
        self
            .modifier(PulseModifier(isAnimating: isAnimating, minScale: minScale, maxScale: maxScale))
    }
    
    // Rotate Animation
    func rotate(
        isAnimating: Bool = true,
        duration: Double = 1.0,
        clockwise: Bool = true
    ) -> some View {
        self
            .modifier(RotateModifier(isAnimating: isAnimating, duration: duration, clockwise: clockwise))
    }
    
    // MARK: - Advanced Fluid Animations
    
    // Liquid Scale Effect
    func liquidScale(isPressed: Bool, intensity: CGFloat = 1.0) -> some View {
        self.modifier(LiquidScaleModifier(isPressed: isPressed, intensity: intensity))
    }
    
    // Magnetic Field Interaction
    func magneticField(strength: CGFloat = 1.0) -> some View {
        self.modifier(MagneticFieldModifier(magneticStrength: strength))
    }
    
    // Parallax Movement
    func parallaxMotion(intensity: CGFloat = 1.0) -> some View {
        self.modifier(ParallaxModifier(intensity: intensity))
    }
    
    // Breathing Glow Effect
    func breathingGlow(color: Color = AppTheme.Colors.accent, isActive: Bool = true, intensity: CGFloat = 1.0) -> some View {
        self.modifier(GlowPulseModifier(color: color, isActive: isActive, intensity: intensity))
    }
    
    // Fluid Morphing
    func fluidMorph(isTransformed: Bool, intensity: CGFloat = 1.0) -> some View {
        self.modifier(FluidMorphModifier(isTransformed: isTransformed, morphIntensity: intensity))
    }
    
    // MARK: - Connection State Animations
    
    // VPN Connection Pulse
    func connectionPulse(isConnected: Bool, color: Color = AppTheme.Colors.connected) -> some View {
        self.breathingGlow(color: color, isActive: isConnected, intensity: 0.8)
    }
    
    // Server Selection Ripple
    func selectionRipple(isSelected: Bool) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(AppTheme.Colors.accent.opacity(isSelected ? 0.2 : 0.0))
                    .scaleEffect(isSelected ? 1.0 : 0.9)
                    .animation(AnimationPresets.elasticOut, value: isSelected)
            )
    }
    
    // MARK: - Utility Animations
    
    // Animated Visibility with Fluid Motion
    func fluidVisibility(
        isVisible: Bool,
        animation: Animation = AnimationPresets.ultraFluid
    ) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1.0 : 0.9)
            .animation(animation, value: isVisible)
    }
    
    // Conditional Animation
    func conditionalAnimation<T: Equatable>(
        _ animation: Animation?,
        value: T,
        condition: Bool
    ) -> some View {
        self.animation(condition ? animation : nil, value: value)
    }
    
    // Staggered Animation with Fluid Motion
    func staggeredFluidAnimation(
        delay: Double,
        animation: Animation = AnimationPresets.ultraFluid
    ) -> some View {
        self.animation(animation.delay(delay), value: UUID())
    }
    
    // MARK: - Interactive Feedback
    
    // Haptic Feedback with Animation
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, trigger: some Equatable) -> some View {
        self
            .onChangeCompat(of: trigger) { _ in
                let impactFeedback = UIImpactFeedbackGenerator(style: style)
                impactFeedback.impactOccurred()
            }
    }
    
    // Spring Press Effect
    func springPress(isPressed: Bool, scale: CGFloat = 0.95) -> some View {
        self
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(AnimationPresets.bouncySpring, value: isPressed)
    }
    
    // MARK: - Legacy Support
    
    // Animated Visibility (legacy)
    func animatedVisibility(
        isVisible: Bool,
        animation: Animation = AnimationPresets.mediumEaseInOut
    ) -> some View {
        self.fluidVisibility(isVisible: isVisible, animation: animation)
    }
    
    // Staggered Animation (legacy)
    func staggeredAnimation(
        delay: Double,
        animation: Animation = AnimationPresets.mediumEaseOut
    ) -> some View {
        self.staggeredFluidAnimation(delay: delay, animation: animation)
    }
}

// MARK: - Advanced Liquid Animation Modifiers
struct LiquidScaleModifier: ViewModifier {
    let isPressed: Bool
    let intensity: CGFloat
    
    @State private var liquidScale: CGFloat = 1.0
    @State private var liquidBlur: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(liquidScale)
            .blur(radius: liquidBlur)
            .onChangeCompat(of: isPressed) { pressed in
                if pressed {
                    withAnimation(AnimationPresets.liquidBounce) {
                        liquidScale = 1.0 + intensity * 0.2
                        liquidBlur = intensity * 3
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(AnimationPresets.elasticOut) {
                            liquidScale = 1.0
                            liquidBlur = 0
                        }
                    }
                }
            }
    }
}

struct MagneticFieldModifier: ViewModifier {
    let magneticStrength: CGFloat
    @State private var magneticOffset: CGSize = .zero
    @State private var isActivated: Bool = false
    
    func body(content: Content) -> some View {
        content
            .offset(magneticOffset)
            .scaleEffect(isActivated ? 1.05 : 1.0)
            .animation(AnimationPresets.magneticPull, value: magneticOffset)
            .animation(AnimationPresets.hoverResponse, value: isActivated)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        let maxDistance: CGFloat = 50
                        
                        if distance < maxDistance {
                            let strength = (maxDistance - distance) / maxDistance * magneticStrength
                            magneticOffset = CGSize(
                                width: value.translation.width * strength * 0.3,
                                height: value.translation.height * strength * 0.3
                            )
                            isActivated = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(AnimationPresets.elasticSnap) {
                            magneticOffset = .zero
                            isActivated = false
                        }
                    }
            )
    }
}

struct ParallaxModifier: ViewModifier {
    let intensity: CGFloat
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(y: offset * intensity)
                .onAppear {
                    withAnimation(AnimationPresets.auroraFlow) {
                        offset = 20
                    }
                }
        }
    }
}

struct GlowPulseModifier: ViewModifier {
    let color: Color
    let isActive: Bool
    let intensity: CGFloat
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.5
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(pulseOpacity))
                    .scaleEffect(pulseScale)
                    .blur(radius: 10 * intensity)
            )
            .onAppear {
                if isActive {
                    startGlow()
                }
            }
            .onChangeCompat(of: isActive) { active in
                if active {
                    startGlow()
                } else {
                    stopGlow()
                }
            }
    }
    
    private func startGlow() {
        withAnimation(AnimationPresets.breathingGlow) {
            pulseScale = 1.0 + intensity * 0.3
            pulseOpacity = 0.1
        }
    }
    
    private func stopGlow() {
        withAnimation(AnimationPresets.fastEaseOut) {
            pulseScale = 1.0
            pulseOpacity = 0.5
        }
    }
}

struct FluidMorphModifier: ViewModifier {
    let isTransformed: Bool
    let morphIntensity: CGFloat
    
    @State private var morphScale: CGFloat = 1.0
    @State private var morphRotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(x: morphScale, y: 1.0 / morphScale)
            .rotationEffect(.degrees(morphRotation))
            .animation(AnimationPresets.jellyCubic, value: isTransformed)
            .onChangeCompat(of: isTransformed) { transformed in
                if transformed {
                    morphScale = 1.0 + morphIntensity * 0.3
                    morphRotation = morphIntensity * 10
                } else {
                    morphScale = 1.0
                    morphRotation = 0
                }
            }
    }
}

// MARK: - Enhanced Animation Sequence Helper
struct FluidAnimationSequence {
    private var animations: [(delay: Double, animation: Animation, action: () -> Void)] = []
    
    mutating func addFluid(delay: Double = 0, animation: Animation = AnimationPresets.ultraFluid, _ action: @escaping () -> Void) {
        animations.append((delay: delay, animation: animation, action: action))
    }
    
    mutating func addElastic(delay: Double = 0, _ action: @escaping () -> Void) {
        animations.append((delay: delay, animation: AnimationPresets.elasticOut, action: action))
    }
    
    mutating func addSpring(delay: Double = 0, response: Double = 0.5, damping: Double = 0.8, _ action: @escaping () -> Void) {
        let springAnimation = Animation.spring(response: response, dampingFraction: damping, blendDuration: 0)
        animations.append((delay: delay, animation: springAnimation, action: action))
    }
    
    func executeSequence() {
        var cumulativeDelay: Double = 0
        
        for item in animations {
            DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeDelay + item.delay) {
                withAnimation(item.animation) {
                    item.action()
                }
            }
            cumulativeDelay += item.delay
        }
    }
}

// MARK: - Legacy Animation Sequence Helper (for backward compatibility)
struct AnimationSequence {
    private var animations: [(delay: Double, duration: Double, animation: () -> Void)] = []
    
    mutating func add(delay: Double = 0, duration: Double = 0.3, _ animation: @escaping () -> Void) {
        animations.append((delay: delay, duration: duration, animation: animation))
    }
    
    func execute() {
        var totalDelay: Double = 0
        
        for item in animations {
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + item.delay) {
                withAnimation(.easeInOut(duration: item.duration)) {
                    item.animation()
                }
            }
            totalDelay += item.delay + item.duration
        }
    }
}

// MARK: - Connection Animation Views
struct ConnectionPulseView: View {
    let isConnected: Bool
    let color: Color
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 2)
                .frame(width: 60, height: 60)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Inner circle
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
        }
        .onAppear {
            if isConnected {
                startPulse()
            }
        }
        .onChangeCompat(of: isConnected) { connected in
            if connected {
                startPulse()
            } else {
                stopPulse()
            }
        }
    }
    
    private func startPulse() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            scale = 1.5
            opacity = 0.0
        }
    }
    
    private func stopPulse() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.0
            opacity = 0.8
        }
    }
}

struct ConnectingSpinnerView: View {
    let isConnecting: Bool
    let color: Color
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .font(.title)
            .foregroundColor(color)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                if isConnecting {
                    startSpinning()
                }
            }
            .onChangeCompat(of: isConnecting) { connecting in
                if connecting {
                    startSpinning()
                } else {
                    stopSpinning()
                }
            }
    }
    
    private func startSpinning() {
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
    
    private func stopSpinning() {
        withAnimation(.easeOut(duration: 0.3)) {
            rotation = 0
        }
    }
}