import SwiftUI

// MARK: - Glassmorphic Card Component
struct GlassmorphicCard<Content: View>: View {
    let content: () -> Content
    let style: GlassmorphicStyle
    let isPressed: Bool
    let isSelected: Bool
    
    @State private var hoverOffset: CGSize = .zero
    @State private var shimmerPhase: Double = 0
    @State private var glowIntensity: Double = 0.5
    
    init(
        style: GlassmorphicStyle = .primary,
        isPressed: Bool = false,
        isSelected: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.style = style
        self.isPressed = isPressed
        self.isSelected = isSelected
    }
    
    var body: some View {
        content()
            .padding(AppTheme.Layout.cardPadding)
            .background(glassmorphicBackground)
            .cornerRadius(AppTheme.CornerRadius.xl)
            .overlay(glassmorphicBorder)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .offset(hoverOffset)
            .animation(AppTheme.Animation.fluidSpring, value: isPressed)
            .animation(AppTheme.Animation.magneticAttraction, value: hoverOffset)
            .onAppear {
                startAmbientAnimations()
            }
    }
    
    // MARK: - Glassmorphic Background
    private var glassmorphicBackground: some View {
        ZStack {
            // Base glass layer
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(style.backgroundGradient)
                .background(.ultraThinMaterial)
            
            // Shimmer overlay
            if style.hasShimmer {
                shimmerOverlay
            }
            
            // Aurora effect for premium cards
            if style == .premium {
                auroraEffect
            }
            
            // Neumorphic depth for selected state
            if isSelected && style.hasNeumorphism {
                neumorphicLayer
            }
        }
    }
    
    // MARK: - Glassmorphic Border
    private var glassmorphicBorder: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
            .stroke(style.borderGradient, lineWidth: style.borderWidth)
            .opacity(isSelected ? 1.0 : 0.6)
            .animation(AppTheme.Animation.breathingGlow, value: isSelected)
    }
    
    // MARK: - Shimmer Effect
    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 60)
                .offset(x: shimmerPhase * (geometry.size.width + 60) - 60)
                .animation(
                    .linear(duration: 2.5).repeatForever(autoreverses: false),
                    value: shimmerPhase
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl))
    }
    
    // MARK: - Aurora Effect
    private var auroraEffect: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
            .fill(AppTheme.AuroraGradients.iridescent)
            .opacity(0.1)
            .scaleEffect(1.0 + sin(glowIntensity * .pi) * 0.05)
            .animation(
                AppTheme.Animation.auroraFlow,
                value: glowIntensity
            )
    }
    
    // MARK: - Neumorphic Layer
    private var neumorphicLayer: some View {
        ZStack {
            // Inner shadow (pressed effect)
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                .blur(radius: 2)
                .offset(x: 1, y: 1)
            
            // Highlight shadow
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                .blur(radius: 1)
                .offset(x: -1, y: -1)
        }
    }
    
    // MARK: - Shadow Properties
    private var shadowColor: Color {
        switch style {
        case .primary:
            return AppTheme.Colors.accent.opacity(0.2)
        case .secondary:
            return Color.black.opacity(0.1)
        case .success:
            return AppTheme.Colors.connected.opacity(0.3)
        case .warning:
            return AppTheme.Colors.connecting.opacity(0.3)
        case .error:
            return AppTheme.Colors.error.opacity(0.3)
        case .premium:
            return AppTheme.Colors.accent.opacity(0.4)
        }
    }
    
    private var shadowRadius: CGFloat {
        isPressed ? 5 : (isSelected ? 15 : 10)
    }
    
    private var shadowOffset: CGFloat {
        isPressed ? 2 : (isSelected ? 8 : 5)
    }
    
    // MARK: - Animation Control
    private func startAmbientAnimations() {
        // Shimmer animation
        if style.hasShimmer {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.0
            }
        }
        
        // Aurora glow animation
        if style == .premium {
            withAnimation(AppTheme.Animation.auroraFlow) {
                glowIntensity = 1.0
            }
        }
    }
}

// MARK: - Glassmorphic Style Definition
enum GlassmorphicStyle {
    case primary, secondary, success, warning, error, premium
    
    var backgroundGradient: LinearGradient {
        switch self {
        case .primary:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.25),
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [
                    Color.gray.opacity(0.15),
                    Color.gray.opacity(0.08),
                    Color.gray.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.connected.opacity(0.2),
                    AppTheme.Colors.connected.opacity(0.1),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warning:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.connecting.opacity(0.2),
                    AppTheme.Colors.connecting.opacity(0.1),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .error:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.error.opacity(0.2),
                    AppTheme.Colors.error.opacity(0.1),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .premium:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    AppTheme.Colors.accent.opacity(0.1),
                    AppTheme.Colors.auroraViolet.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var borderGradient: LinearGradient {
        switch self {
        case .primary:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.6),
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [
                    Color.gray.opacity(0.4),
                    Color.gray.opacity(0.2),
                    Color.gray.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.connected.opacity(0.8),
                    AppTheme.Colors.connected.opacity(0.4),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warning:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.connecting.opacity(0.8),
                    AppTheme.Colors.connecting.opacity(0.4),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .error:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.error.opacity(0.8),
                    AppTheme.Colors.error.opacity(0.4),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .premium:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.auroraViolet.opacity(0.6),
                    AppTheme.Colors.auroraBlue.opacity(0.4),
                    AppTheme.Colors.auroraGreen.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .primary, .secondary:
            return 1.0
        case .success, .warning, .error:
            return 1.5
        case .premium:
            return 2.0
        }
    }
    
    var hasShimmer: Bool {
        switch self {
        case .primary, .premium:
            return true
        default:
            return false
        }
    }
    
    var hasNeumorphism: Bool {
        switch self {
        case .primary, .premium:
            return true
        default:
            return false
        }
    }
}

// MARK: - ElasticCard Component (with stretch effect)
struct ElasticCard<Content: View>: View {
    let content: () -> Content
    let style: GlassmorphicStyle
    
    @State private var stretchAmount: CGFloat = 1.0
    @State private var isDragging: Bool = false
    @GestureState private var dragAmount: CGSize = .zero
    
    init(
        style: GlassmorphicStyle = .primary,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.style = style
    }
    
    var body: some View {
        GlassmorphicCard(style: style, isPressed: isDragging) {
            content()
        }
        .scaleEffect(x: stretchAmount, y: 1.0 / stretchAmount)
        .offset(dragAmount)
        .gesture(
            DragGesture()
                .updating($dragAmount) { value, state, _ in
                    state = value.translation
                    
                    let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                    let stretchFactor = min(1.0 + dragDistance * 0.001, 1.2)
                    
                    withAnimation(AppTheme.Animation.elasticPull) {
                        stretchAmount = stretchFactor
                        isDragging = true
                    }
                }
                .onEnded { _ in
                    withAnimation(AppTheme.Animation.elasticSnap) {
                        stretchAmount = 1.0
                        isDragging = false
                    }
                }
        )
    }
}

// MARK: - View Extensions
extension View {
    func glassmorphicCard(
        style: GlassmorphicStyle = .primary,
        isPressed: Bool = false,
        isSelected: Bool = false
    ) -> some View {
        GlassmorphicCard(style: style, isPressed: isPressed, isSelected: isSelected) {
            self
        }
    }
    
    func elasticCard(style: GlassmorphicStyle = .primary) -> some View {
        ElasticCard(style: style) {
            self
        }
    }
}

// MARK: - Preview
struct GlassmorphicCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Aurora background for preview
            AppTheme.AuroraGradients.timeBasedGradient(hour: 10)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach([
                        ("Primary", GlassmorphicStyle.primary),
                        ("Secondary", GlassmorphicStyle.secondary),
                        ("Success", GlassmorphicStyle.success),
                        ("Warning", GlassmorphicStyle.warning),
                        ("Error", GlassmorphicStyle.error),
                        ("Premium", GlassmorphicStyle.premium)
                    ], id: \.0) { title, style in
                        VStack {
                            Text(title + " Card")
                                .font(AppTheme.Typography.headlineSmall)
                                .foregroundColor(AppTheme.Colors.textOnGlass)
                            
                            Text("This is a sample glassmorphic card with aurora effects and fluid animations.")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .glassmorphicCard(style: style)
                        .padding(.horizontal)
                    }
                    
                    // Elastic card example
                    VStack {
                        Text("Elastic Card")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                        
                        Text("Drag me to see the elastic effect!")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .elasticCard(style: .premium)
                    .padding(.horizontal)
                }
                .padding(.vertical, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
}