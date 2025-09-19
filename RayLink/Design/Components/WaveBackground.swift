import SwiftUI

// MARK: - Wave Flow Background Component
struct WaveBackground: View {
    let style: WaveStyle
    let intensity: WaveIntensity
    let isAnimated: Bool
    
    @State private var waveOffset1: CGFloat = 0
    @State private var waveOffset2: CGFloat = 0
    @State private var waveOffset3: CGFloat = 0
    @State private var particlePhase: Double = 0
    @State private var auroraShift: Double = 0
    
    init(
        style: WaveStyle = .aurora,
        intensity: WaveIntensity = .medium,
        isAnimated: Bool = true
    ) {
        self.style = style
        self.intensity = intensity
        self.isAnimated = isAnimated
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient background
                baseBackground
                
                // Multiple wave layers
                waveLayer1(in: geometry)
                waveLayer2(in: geometry)
                waveLayer3(in: geometry)
                
                // Floating particles for aurora style
                if style == .aurora {
                    floatingParticles(in: geometry)
                }
                
                // Ambient light effects
                ambientLightEffects(in: geometry)
            }
        }
        .clipped()
        .onAppear {
            if isAnimated {
                startWaveAnimations()
            }
        }
    }
    
    // MARK: - Base Background
    private var baseBackground: some View {
        Rectangle()
            .fill(style.baseGradient)
            .animation(AppTheme.Animation.auroraFlow, value: auroraShift)
    }
    
    // MARK: - Wave Layers
    private func waveLayer1(in geometry: GeometryProxy) -> some View {
        WaveShape(
            offset: waveOffset1,
            amplitude: intensity.amplitude1,
            frequency: intensity.frequency1,
            phase: 0
        )
        .fill(style.waveGradient1)
        .opacity(style.waveOpacity1)
        .blur(radius: intensity.blurRadius1)
        .animation(
            isAnimated ? AppTheme.Animation.waveFlow : .easeOut(duration: 0.3),
            value: waveOffset1
        )
    }
    
    private func waveLayer2(in geometry: GeometryProxy) -> some View {
        WaveShape(
            offset: waveOffset2,
            amplitude: intensity.amplitude2,
            frequency: intensity.frequency2,
            phase: .pi / 3
        )
        .fill(style.waveGradient2)
        .opacity(style.waveOpacity2)
        .blur(radius: intensity.blurRadius2)
        .animation(
            isAnimated ? AppTheme.Animation.waveFlow.speed(0.8) : .easeOut(duration: 0.3),
            value: waveOffset2
        )
    }
    
    private func waveLayer3(in geometry: GeometryProxy) -> some View {
        WaveShape(
            offset: waveOffset3,
            amplitude: intensity.amplitude3,
            frequency: intensity.frequency3,
            phase: .pi / 1.5
        )
        .fill(style.waveGradient3)
        .opacity(style.waveOpacity3)
        .blur(radius: intensity.blurRadius3)
        .animation(
            isAnimated ? AppTheme.Animation.waveFlow.speed(0.6) : .easeOut(duration: 0.3),
            value: waveOffset3
        )
    }
    
    // MARK: - Floating Particles
    private func floatingParticles(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(AppTheme.Colors.auroraBlue.opacity(0.4))
                    .frame(
                        width: CGFloat.random(in: 2...6),
                        height: CGFloat.random(in: 2...6)
                    )
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .offset(
                        x: sin(particlePhase + Double(index) * 0.3) * 20,
                        y: cos(particlePhase + Double(index) * 0.5) * 15
                    )
                    .opacity(0.3 + sin(particlePhase + Double(index)) * 0.3)
                    .blur(radius: 1)
                    .animation(
                        AppTheme.Animation.ambientFloat.delay(Double(index) * 0.1),
                        value: particlePhase
                    )
            }
        }
    }
    
    // MARK: - Ambient Light Effects
    private func ambientLightEffects(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Top highlight
            LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.05),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            .frame(height: geometry.size.height * 0.3)
            .position(x: geometry.size.width / 2, y: 0)
            
            // Bottom depth shadow
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.05),
                    Color.black.opacity(0.1)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: geometry.size.height * 0.4)
            .position(x: geometry.size.width / 2, y: geometry.size.height)
        }
    }
    
    // MARK: - Animation Control
    private func startWaveAnimations() {
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            waveOffset1 = 2 * .pi
        }
        
        withAnimation(.linear(duration: 12.0).repeatForever(autoreverses: false)) {
            waveOffset2 = 2 * .pi
        }
        
        withAnimation(.linear(duration: 16.0).repeatForever(autoreverses: false)) {
            waveOffset3 = 2 * .pi
        }
        
        withAnimation(AppTheme.Animation.ambientFloat) {
            particlePhase = 2 * .pi
        }
        
        withAnimation(AppTheme.Animation.auroraFlow) {
            auroraShift = 1.0
        }
    }
}

// MARK: - Wave Shape Path
struct WaveShape: Shape {
    var offset: CGFloat
    let amplitude: CGFloat
    let frequency: CGFloat
    let phase: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let sine = sin((relativeX * frequency * 2 * .pi) + offset + phase)
            let y = midHeight + (sine * amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Close the path to fill the bottom
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Wave Style Configuration
enum WaveStyle {
    case aurora, ocean, sunset, night, connection
    
    var baseGradient: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.auroraViolet.opacity(0.3),
                    AppTheme.Colors.auroraBlue.opacity(0.2),
                    AppTheme.Colors.auroraGreen.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ocean:
            return LinearGradient(
                colors: [
                    Color.blue.opacity(0.4),
                    Color.cyan.opacity(0.3),
                    Color.teal.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sunset:
            return LinearGradient(
                colors: [
                    Color.orange.opacity(0.3),
                    Color.pink.opacity(0.2),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .night:
            return LinearGradient(
                colors: [
                    Color.indigo.opacity(0.4),
                    Color.purple.opacity(0.3),
                    Color.black.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .connection:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.connected.opacity(0.3),
                    AppTheme.Colors.primary.opacity(0.2),
                    AppTheme.Colors.accent.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var waveGradient1: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.auroraBlue.opacity(0.6),
                    AppTheme.Colors.auroraViolet.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ocean:
            return LinearGradient(
                colors: [Color.cyan.opacity(0.7), Color.blue.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sunset:
            return LinearGradient(
                colors: [Color.orange.opacity(0.7), Color.pink.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .night:
            return LinearGradient(
                colors: [Color.indigo.opacity(0.6), Color.purple.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .connection:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.connected.opacity(0.6),
                    AppTheme.Colors.primary.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var waveGradient2: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.auroraGreen.opacity(0.5),
                    AppTheme.Colors.auroraBlue.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ocean:
            return LinearGradient(
                colors: [Color.teal.opacity(0.6), Color.cyan.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sunset:
            return LinearGradient(
                colors: [Color.pink.opacity(0.6), Color.purple.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .night:
            return LinearGradient(
                colors: [Color.purple.opacity(0.5), Color.indigo.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .connection:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.5),
                    AppTheme.Colors.connected.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var waveGradient3: LinearGradient {
        switch self {
        case .aurora:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.auroraPink.opacity(0.4),
                    AppTheme.Colors.auroraGreen.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .ocean:
            return LinearGradient(
                colors: [Color.blue.opacity(0.5), Color.teal.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sunset:
            return LinearGradient(
                colors: [Color.purple.opacity(0.5), Color.orange.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .night:
            return LinearGradient(
                colors: [Color.black.opacity(0.4), Color.purple.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .connection:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.primary.opacity(0.4),
                    AppTheme.Colors.accent.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var waveOpacity1: Double { 0.8 }
    var waveOpacity2: Double { 0.6 }
    var waveOpacity3: Double { 0.4 }
}

// MARK: - Wave Intensity Configuration
enum WaveIntensity {
    case subtle, medium, intense
    
    var amplitude1: CGFloat {
        switch self {
        case .subtle: return 20
        case .medium: return 40
        case .intense: return 60
        }
    }
    
    var amplitude2: CGFloat {
        switch self {
        case .subtle: return 15
        case .medium: return 30
        case .intense: return 45
        }
    }
    
    var amplitude3: CGFloat {
        switch self {
        case .subtle: return 10
        case .medium: return 20
        case .intense: return 30
        }
    }
    
    var frequency1: CGFloat {
        switch self {
        case .subtle: return 1.5
        case .medium: return 2.0
        case .intense: return 2.5
        }
    }
    
    var frequency2: CGFloat {
        switch self {
        case .subtle: return 1.8
        case .medium: return 2.3
        case .intense: return 2.8
        }
    }
    
    var frequency3: CGFloat {
        switch self {
        case .subtle: return 2.0
        case .medium: return 2.5
        case .intense: return 3.0
        }
    }
    
    var blurRadius1: CGFloat {
        switch self {
        case .subtle: return 5
        case .medium: return 8
        case .intense: return 12
        }
    }
    
    var blurRadius2: CGFloat {
        switch self {
        case .subtle: return 8
        case .medium: return 12
        case .intense: return 16
        }
    }
    
    var blurRadius3: CGFloat {
        switch self {
        case .subtle: return 12
        case .medium: return 16
        case .intense: return 20
        }
    }
}

// MARK: - View Extensions
extension View {
    func waveBackground(
        style: WaveStyle = .aurora,
        intensity: WaveIntensity = .medium,
        isAnimated: Bool = true
    ) -> some View {
        self.background(
            WaveBackground(
                style: style,
                intensity: intensity,
                isAnimated: isAnimated
            )
        )
    }
}

// MARK: - Preview
struct WaveBackground_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 40) {
                ForEach([
                    ("Aurora", WaveStyle.aurora),
                    ("Ocean", WaveStyle.ocean),
                    ("Sunset", WaveStyle.sunset),
                    ("Night", WaveStyle.night),
                    ("Connection", WaveStyle.connection)
                ], id: \.0) { title, style in
                    VStack {
                        Text(title + " Waves")
                            .font(AppTheme.Typography.headlineMedium)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                            .padding(.bottom, 10)
                        
                        Text("Dynamic wave background with " + title.lowercased() + " theme")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .waveBackground(style: style, intensity: .medium)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                
                // Intensity comparison
                VStack {
                    Text("Intensity Levels")
                        .font(AppTheme.Typography.headlineMedium)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 20) {
                        ForEach([
                            ("Subtle", WaveIntensity.subtle),
                            ("Medium", WaveIntensity.medium),
                            ("Intense", WaveIntensity.intense)
                        ], id: \.0) { title, intensity in
                            VStack {
                                Text(title)
                                    .font(AppTheme.Typography.titleSmall)
                                    .foregroundColor(AppTheme.Colors.textOnGlass)
                            }
                            .frame(width: 100, height: 120)
                            .waveBackground(style: .aurora, intensity: intensity)
                            .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 40)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}