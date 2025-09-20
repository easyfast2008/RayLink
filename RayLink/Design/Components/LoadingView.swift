import SwiftUI

// MARK: - Enhanced Loading View with Aurora Effects
struct LoadingView: View {
    let message: String
    let style: LoadingStyle
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    @State private var particlePhase: Double = 0
    @State private var waveOffset: CGFloat = 0
    @State private var aurorePhase: Double = 0
    
    init(message: String = "Loading...", style: LoadingStyle = .aurora) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 24) {
            loadingIndicator
            
            if !message.isEmpty {
                Text(message)
                    .font(AppTheme.Typography.bodyMedium.weight(.medium))
                    .foregroundColor(AppTheme.Colors.textOnGlass)
                    .multilineTextAlignment(.center)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .background(.ultraThinMaterial)
                            .padding(.horizontal, -16)
                            .padding(.vertical, -8)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        switch style {
        case .spinner:
            spinnerView
        case .dots:
            dotsView
        case .pulse:
            pulseView
        case .bounce:
            bounceView
        case .ripple:
            rippleView
        case .aurora:
            auroraLoadingView
        case .particles:
            particleLoadingView
        case .liquidWave:
            liquidWaveView
        case .morphing:
            morphingView
        }
    }
    
    // MARK: - Spinner Loading
    private var spinnerView: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .font(.title)
            .foregroundColor(AppTheme.Colors.accent)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
    
    // MARK: - Dots Loading
    private var dotsView: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 8, height: 8)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: scale
                    )
            }
        }
        .onAppear {
            scale = 1.5
        }
    }
    
    // MARK: - Pulse Loading
    private var pulseView: some View {
        Circle()
            .fill(AppTheme.Colors.accent)
            .frame(width: 40, height: 40)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    scale = 1.2
                    opacity = 0.3
                }
            }
    }
    
    // MARK: - Bounce Loading
    private var bounceView: some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 4, height: 20)
                    .scaleEffect(y: scale)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.1),
                        value: scale
                    )
            }
        }
        .onAppear {
            scale = 0.5
        }
    }
    
    // MARK: - Ripple Loading
    private var rippleView: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(AppTheme.Colors.accent, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(
                        .easeOut(duration: 1.5)
                        .repeatForever()
                        .delay(Double(index) * 0.5),
                        value: scale
                    )
            }
        }
        .onAppear {
            scale = 2.0
            opacity = 0.0
        }
    }
    
    // MARK: - Aurora Loading
    private var auroraLoadingView: some View {
        ZStack {
            // Background aurora glow
            Circle()
                .fill(AppTheme.AuroraGradients.primary)
                .frame(width: 80, height: 80)
                .blur(radius: 20)
                .scaleEffect(1.0 + sin(aurorePhase) * 0.3)
                .opacity(0.6)
            
            // Rotating aurora rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            colors: [
                                AppTheme.Colors.auroraViolet,
                                AppTheme.Colors.auroraBlue,
                                AppTheme.Colors.auroraGreen,
                                AppTheme.Colors.auroraPink
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 50 + CGFloat(index * 15), height: 50 + CGFloat(index * 15))
                    .rotationEffect(.degrees(rotation + Double(index * 120)))
                    .opacity(1.0 - Double(index) * 0.3)
            }
            
            // Central energy core
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .blur(radius: 2)
                .scaleEffect(1.0 + sin(aurorePhase * 2) * 0.5)
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                aurorePhase = .pi * 2
            }
        }
    }
    
    // MARK: - Particle Loading
    private var particleLoadingView: some View {
        ZStack {
            // Central attractor
            Circle()
                .fill(AppTheme.AuroraGradients.primary)
                .frame(width: 20, height: 20)
                .scaleEffect(1.0 + sin(particlePhase) * 0.3)
                .blur(radius: 5)
            
            // Orbiting particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 4, height: 4)
                    .blur(radius: 1)
                    .offset(
                        x: cos(particlePhase + Double(index) * .pi / 4) * 30,
                        y: sin(particlePhase + Double(index) * .pi / 4) * 30
                    )
                    .opacity(0.8)
                    .scaleEffect(0.5 + sin(particlePhase * 2 + Double(index)) * 0.5)
            }
            
            // Floating ambient particles
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: 2)
                    .offset(
                        x: sin(particlePhase * 0.7 + Double(index) * 0.5) * 50,
                        y: cos(particlePhase * 0.3 + Double(index) * 0.3) * 50
                    )
                    .opacity(0.4 + sin(particlePhase + Double(index)) * 0.4)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                particlePhase = .pi * 2
            }
        }
    }
    
    // MARK: - Liquid Wave Loading
    private var liquidWaveView: some View {
        ZStack {
            // Base liquid container
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 80, height: 50)
                .background(.ultraThinMaterial)
            
            // Animated liquid wave
            LiquidWaveShape(offset: Angle(degrees: waveOffset), percent: 0.6)
                .fill(AppTheme.AuroraGradients.primary)
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .frame(width: 76, height: 46)
            
            // Surface shimmer effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 20, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 23))
                .offset(x: sin(waveOffset * .pi / 180) * 30)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                waveOffset = 360
            }
        }
    }
    
    // MARK: - Morphing Loading
    private var morphingView: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.Colors.accent.opacity(0.8))
                    .frame(
                        width: 12 + sin(rotation * .pi / 180 + Double(index) * .pi / 3) * 8,
                        height: 40 + cos(rotation * .pi / 180 + Double(index) * .pi / 3) * 20
                    )
                    .rotationEffect(.degrees(rotation + Double(index * 120)))
                    .animation(AppTheme.Animation.morphTransition, value: rotation)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Wave Shape for Liquid Animation
struct LiquidWaveShape: Shape {
    var offset: Angle
    var percent: Double
    
    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let lowestWave = 0.02
        let highestWave = 1.00
        
        let newPercent = lowestWave + (highestWave - lowestWave) * percent
        let waveHeight = 0.015 * rect.height
        let yOffset = CGFloat(1 - newPercent) * rect.height
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 360)
        
        path.move(to: CGPoint(x: 0, y: yOffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 5) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            path.addLine(to: CGPoint(x: x, y: yOffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Loading Style Enum
enum LoadingStyle {
    case spinner
    case dots
    case pulse
    case bounce
    case ripple
    case aurora          // New: Aurora-inspired loading with rotating gradients
    case particles       // New: Orbital particle system
    case liquidWave      // New: Liquid wave animation
    case morphing        // New: Morphing geometric shapes
}

// MARK: - Overlay Loading View
struct OverlayLoadingView: View {
    let message: String
    let style: LoadingStyle
    let backgroundColor: Color
    
    init(
        message: String = "Loading...",
        style: LoadingStyle = .spinner,
        backgroundColor: Color = Color.black.opacity(0.3)
    ) {
        self.message = message
        self.style = style
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                LoadingView(message: message, style: style)
            }
            .padding(24)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .themedShadow(AppTheme.Shadow.large)
            .padding(40)
        }
    }
}

// MARK: - Button Loading State
struct LoadingButton<Label: View>: View {
    let isLoading: Bool
    let action: () -> Void
    let label: () -> Label
    
    init(
        isLoading: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.isLoading = isLoading
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    label()
                }
            }
            .frame(minHeight: 44)
        }
        .disabled(isLoading)
        .primaryStyle(isEnabled: !isLoading)
    }
}

// MARK: - Skeleton Loading
struct SkeletonView: View {
    let cornerRadius: CGFloat
    
    @State private var opacity: Double = 0.3
    
    init(cornerRadius: CGFloat = AppTheme.CornerRadius.sm) {
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Rectangle()
            .fill(AppTheme.Colors.secondary.opacity(opacity))
            .cornerRadius(cornerRadius)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 0.6
                }
            }
    }
}

// MARK: - Skeleton Text Lines
struct SkeletonText: View {
    let lines: Int
    let lineHeight: CGFloat
    let spacing: CGFloat
    
    init(lines: Int = 3, lineHeight: CGFloat = 16, spacing: CGFloat = 8) {
        self.lines = lines
        self.lineHeight = lineHeight
        self.spacing = spacing
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<lines, id: \.self) { index in
                SkeletonView()
                    .frame(height: lineHeight)
                    .frame(maxWidth: index == lines - 1 ? .infinity * 0.7 : .infinity)
            }
        }
    }
}

// MARK: - Loading State Wrapper
struct LoadingStateView<Content: View, LoadingContent: View, ErrorContent: View>: View {
    let state: LoadingState
    let content: () -> Content
    let loadingContent: () -> LoadingContent
    let errorContent: (String) -> ErrorContent
    
    init(
        state: LoadingState,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent = { LoadingView() },
        @ViewBuilder errorContent: @escaping (String) -> ErrorContent = { error in
            ErrorView(message: error)
        }
    ) {
        self.state = state
        self.content = content
        self.loadingContent = loadingContent
        self.errorContent = errorContent
    }
    
    var body: some View {
        switch state {
        case .idle, .loaded:
            content()
        case .loading:
            loadingContent()
        case .error(let message):
            errorContent(message)
        }
    }
}

// MARK: - Loading State Enum
enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(AppTheme.Colors.error)
            
            Text("Error")
                .font(AppTheme.Typography.titleMedium)
                .foregroundColor(AppTheme.Colors.text)
            
            Text(message)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                Button("Retry", action: retryAction)
                    .primaryStyle()
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - View Extensions
extension View {
    func loadingOverlay(
        isLoading: Bool,
        message: String = "Loading...",
        style: LoadingStyle = .spinner
    ) -> some View {
        ZStack {
            self
            
            if isLoading {
                OverlayLoadingView(message: message, style: style)
            }
        }
    }
    
    func skeleton(when condition: Bool, cornerRadius: CGFloat = AppTheme.CornerRadius.sm) -> some View {
        ZStack {
            if condition {
                SkeletonView(cornerRadius: cornerRadius)
            } else {
                self
            }
        }
    }
}