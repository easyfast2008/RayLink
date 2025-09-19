import SwiftUI

// MARK: - Magnetic Interaction Component
struct MagneticInteraction<Content: View>: View {
    let content: () -> Content
    let magneticStrength: CGFloat
    let activationRadius: CGFloat
    let hapticEnabled: Bool
    let onMagneticActivation: (() -> Void)?
    
    @State private var magneticOffset: CGSize = .zero
    @State private var magneticScale: CGFloat = 1.0
    @State private var magneticRotation: Double = 0
    @State private var magneticField: [MagneticFieldParticle] = []
    @State private var isInMagneticField: Bool = false
    @State private var fieldIntensity: CGFloat = 0
    
    @GestureState private var dragLocation: CGPoint = .zero
    
    init(
        magneticStrength: CGFloat = 1.0,
        activationRadius: CGFloat = 80,
        hapticEnabled: Bool = true,
        onMagneticActivation: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.magneticStrength = magneticStrength
        self.activationRadius = activationRadius
        self.hapticEnabled = hapticEnabled
        self.onMagneticActivation = onMagneticActivation
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Magnetic field visualization
                if isInMagneticField && !magneticField.isEmpty {
                    magneticFieldVisualization
                }
                
                // Main content with magnetic effects
                content()
                    .offset(magneticOffset)
                    .scaleEffect(magneticScale)
                    .rotationEffect(.degrees(magneticRotation))
                    .animation(AppTheme.Animation.magneticAttraction, value: magneticOffset)
                    .animation(AppTheme.Animation.elasticPull, value: magneticScale)
                    .animation(AppTheme.Animation.fluidSpring, value: magneticRotation)
            }
            .background(
                // Invisible gesture area
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(coordinateSpace: .local)
                            .updating($dragLocation) { value, state, _ in
                                state = value.location
                                updateMagneticField(at: value.location, in: geometry)
                            }
                            .onEnded { _ in
                                resetMagneticField()
                            }
                    )
            )
            .onAppear {
                generateMagneticFieldParticles()
            }
        }
    }
    
    // MARK: - Magnetic Field Visualization
    private var magneticFieldVisualization: some View {
        ZStack {
            ForEach(magneticField.indices, id: \.self) { index in
                let particle = magneticField[index]
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: particle.blur)
                    .scaleEffect(particle.scale)
                    .animation(
                        AppTheme.Animation.magneticAttraction.delay(Double(index) * 0.02),
                        value: particle.animationTrigger
                    )
            }
            
            // Magnetic field rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        AppTheme.Colors.accent.opacity(0.1 * fieldIntensity),
                        lineWidth: 1 + fieldIntensity
                    )
                    .frame(
                        width: activationRadius + CGFloat(index * 20),
                        height: activationRadius + CGFloat(index * 20)
                    )
                    .position(dragLocation)
                    .scaleEffect(fieldIntensity)
                    .animation(
                        AppTheme.Animation.magneticAttraction.delay(Double(index) * 0.1),
                        value: fieldIntensity
                    )
            }
        }
    }
    
    // MARK: - Magnetic Field Logic
    private func updateMagneticField(at location: CGPoint, in geometry: GeometryProxy) {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        let distance = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
        
        if distance <= activationRadius {
            let normalizedDistance = distance / activationRadius
            let attraction = (1.0 - normalizedDistance) * magneticStrength
            
            // Calculate magnetic offset
            let dx = location.x - center.x
            let dy = location.y - center.y
            
            let magneticForce = attraction * 0.3
            magneticOffset = CGSize(
                width: dx * magneticForce,
                height: dy * magneticForce
            )
            
            // Scale and rotation effects
            magneticScale = 1.0 + attraction * 0.1
            magneticRotation = attraction * 5
            
            // Field intensity
            fieldIntensity = attraction
            
            // Activate magnetic field
            if !isInMagneticField {
                isInMagneticField = true
                onMagneticActivation?()
                
                if hapticEnabled {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                animateMagneticFieldParticles(towards: location)
            } else {
                updateMagneticFieldParticles(towards: location, intensity: attraction)
            }
        } else if isInMagneticField {
            resetMagneticField()
        }
    }
    
    private func resetMagneticField() {
        isInMagneticField = false
        
        withAnimation(AppTheme.Animation.elasticSnap) {
            magneticOffset = .zero
            magneticScale = 1.0
            magneticRotation = 0
            fieldIntensity = 0
        }
        
        // Reset magnetic field particles
        for index in magneticField.indices {
            magneticField[index].animationTrigger.toggle()
            magneticField[index].opacity = 0
            magneticField[index].scale = 0.5
        }
    }
    
    // MARK: - Magnetic Field Particles
    private func generateMagneticFieldParticles() {
        magneticField = (0..<15).map { index in
            MagneticFieldParticle(
                id: index,
                position: CGPoint(
                    x: CGFloat.random(in: 0...200),
                    y: CGFloat.random(in: 0...200)
                ),
                size: CGFloat.random(in: 3...8),
                opacity: 0,
                scale: CGFloat.random(in: 0.5...1.0),
                blur: CGFloat.random(in: 0.5...2.0),
                animationTrigger: false
            )
        }
    }
    
    private func animateMagneticFieldParticles(towards location: CGPoint) {
        for index in magneticField.indices {
            let angle = Double(index) * (2 * .pi / Double(magneticField.count))
            let radius = CGFloat.random(in: 20...60)
            
            magneticField[index].position = CGPoint(
                x: location.x + cos(angle) * radius,
                y: location.y + sin(angle) * radius
            )
            magneticField[index].opacity = Double.random(in: 0.3...0.8)
            magneticField[index].scale = CGFloat.random(in: 0.8...1.2)
            magneticField[index].animationTrigger.toggle()
        }
    }
    
    private func updateMagneticFieldParticles(towards location: CGPoint, intensity: CGFloat) {
        for index in magneticField.indices {
            let currentPosition = magneticField[index].position
            let dx = location.x - currentPosition.x
            let dy = location.y - currentPosition.y
            
            // Move particles towards the magnetic center
            magneticField[index].position = CGPoint(
                x: currentPosition.x + dx * intensity * 0.1,
                y: currentPosition.y + dy * intensity * 0.1
            )
            magneticField[index].opacity = Double(intensity) * 0.8
            magneticField[index].scale = 1.0 + intensity * 0.3
        }
    }
}

// MARK: - Magnetic Field Particle Model
struct MagneticFieldParticle {
    let id: Int
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
    let blur: CGFloat
    var animationTrigger: Bool
}

// MARK: - Magnetic Button Component
struct MagneticButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content
    let magneticStrength: CGFloat
    let style: MagneticButtonStyle
    
    @State private var isPressed: Bool = false
    @State private var isMagneticallyActivated: Bool = false
    
    init(
        magneticStrength: CGFloat = 1.2,
        style: MagneticButtonStyle = .glassmorphic,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.magneticStrength = magneticStrength
        self.style = style
        self.action = action
        self.content = content
    }
    
    var body: some View {
        MagneticInteraction(
            magneticStrength: magneticStrength,
            activationRadius: 60,
            hapticEnabled: true,
            onMagneticActivation: {
                isMagneticallyActivated = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isMagneticallyActivated = false
                }
            }
        ) {
            Button(action: {
                isPressed = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                action()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }) {
                content()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(backgroundView)
                    .cornerRadius(AppTheme.CornerRadius.lg)
                    .overlay(overlayView)
                    .shadow(
                        color: shadowColor,
                        radius: isMagneticallyActivated ? 20 : 10,
                        x: 0,
                        y: isMagneticallyActivated ? 10 : 5
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AppTheme.Animation.bouncySpring, value: isPressed)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .glassmorphic:
            ZStack {
                AppTheme.AuroraGradients.glassmorphicBackground
                Color.white.opacity(isMagneticallyActivated ? 0.2 : 0.1)
                    .background(.ultraThinMaterial)
            }
        case .solid:
            AppTheme.AuroraGradients.primary
                .opacity(isMagneticallyActivated ? 0.9 : 0.8)
        case .outlined:
            Color.clear
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
            .stroke(borderGradient, lineWidth: borderWidth)
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(isMagneticallyActivated ? 0.8 : 0.4),
                AppTheme.Colors.accent.opacity(isMagneticallyActivated ? 0.6 : 0.3),
                Color.white.opacity(isMagneticallyActivated ? 0.4 : 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .glassmorphic:
            return 1
        case .solid:
            return 0
        case .outlined:
            return 2
        }
    }
    
    private var shadowColor: Color {
        isMagneticallyActivated ? 
        AppTheme.Colors.accent.opacity(0.4) : 
        Color.black.opacity(0.2)
    }
}

// MARK: - Magnetic Button Style
enum MagneticButtonStyle {
    case glassmorphic, solid, outlined
}

// MARK: - Orbit Menu Component
struct OrbitMenu: View {
    let centerContent: () -> AnyView
    let menuItems: [OrbitMenuItem]
    let isExpanded: Bool
    let orbitRadius: CGFloat
    
    @State private var itemAngles: [Double] = []
    @State private var itemScales: [CGFloat] = []
    
    init<CenterContent: View>(
        orbitRadius: CGFloat = 80,
        isExpanded: Bool,
        menuItems: [OrbitMenuItem],
        @ViewBuilder centerContent: @escaping () -> CenterContent
    ) {
        self.orbitRadius = orbitRadius
        self.isExpanded = isExpanded
        self.menuItems = menuItems
        self.centerContent = { AnyView(centerContent()) }
    }
    
    var body: some View {
        ZStack {
            // Menu items orbiting around center
            ForEach(menuItems.indices, id: \.self) { index in
                let item = menuItems[index]
                let angle = itemAngles.count > index ? itemAngles[index] : 0
                let scale = itemScales.count > index ? itemScales[index] : 0
                
                MagneticButton(
                    magneticStrength: 0.8,
                    style: .glassmorphic,
                    action: item.action
                ) {
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textOnGlass)
                }
                .offset(
                    x: isExpanded ? cos(angle) * orbitRadius : 0,
                    y: isExpanded ? sin(angle) * orbitRadius : 0
                )
                .scaleEffect(scale)
                .opacity(isExpanded ? 1.0 : 0.0)
                .animation(
                    AppTheme.Animation.elasticOut.delay(Double(index) * 0.1),
                    value: isExpanded
                )
            }
            
            // Center content
            centerContent()
        }
        .onAppear {
            setupOrbitAngles()
        }
        .onChange(of: isExpanded) { expanded in
            animateOrbitItems(expanded: expanded)
        }
    }
    
    private func setupOrbitAngles() {
        let angleStep = 2 * .pi / Double(menuItems.count)
        itemAngles = menuItems.indices.map { index in
            angleStep * Double(index) - .pi / 2 // Start from top
        }
        itemScales = Array(repeating: 0.0, count: menuItems.count)
    }
    
    private func animateOrbitItems(expanded: Bool) {
        for index in itemScales.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(AppTheme.Animation.elasticOut) {
                    itemScales[index] = expanded ? 1.0 : 0.0
                }
            }
        }
    }
}

// MARK: - Orbit Menu Item Model
struct OrbitMenuItem {
    let icon: String
    let action: () -> Void
}

// MARK: - View Extensions
extension View {
    func magneticInteraction(
        strength: CGFloat = 1.0,
        activationRadius: CGFloat = 80,
        hapticEnabled: Bool = true,
        onActivation: (() -> Void)? = nil
    ) -> some View {
        MagneticInteraction(
            magneticStrength: strength,
            activationRadius: activationRadius,
            hapticEnabled: hapticEnabled,
            onMagneticActivation: onActivation
        ) {
            self
        }
    }
}

// MARK: - Preview
struct MagneticInteraction_Previews: PreviewProvider {
    @State static var isMenuExpanded: Bool = false
    
    static var previews: some View {
        ZStack {
            // Aurora background
            AppTheme.AuroraGradients.timeBasedGradient(hour: 15)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 60) {
                    // Magnetic Buttons
                    VStack(spacing: 30) {
                        Text("Magnetic Buttons")
                            .font(AppTheme.Typography.headlineLarge)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                        
                        HStack(spacing: 30) {
                            MagneticButton(
                                magneticStrength: 1.5,
                                style: .glassmorphic,
                                action: { print("Glassmorphic tapped") }
                            ) {
                                HStack {
                                    Image(systemName: "wifi")
                                    Text("Connect")
                                }
                                .foregroundColor(AppTheme.Colors.textOnGlass)
                            }
                            
                            MagneticButton(
                                magneticStrength: 1.2,
                                style: .solid,
                                action: { print("Solid tapped") }
                            ) {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("Settings")
                                }
                                .foregroundColor(.white)
                            }
                            
                            MagneticButton(
                                magneticStrength: 1.0,
                                style: .outlined,
                                action: { print("Outlined tapped") }
                            ) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("Info")
                                }
                                .foregroundColor(AppTheme.Colors.textOnGlass)
                            }
                        }
                    }
                    
                    // Orbit Menu
                    VStack(spacing: 30) {
                        Text("Orbit Menu")
                            .font(AppTheme.Typography.headlineLarge)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                        
                        OrbitMenu(
                            orbitRadius: 100,
                            isExpanded: isMenuExpanded,
                            menuItems: [
                                OrbitMenuItem(icon: "wifi", action: { print("WiFi") }),
                                OrbitMenuItem(icon: "gear", action: { print("Settings") }),
                                OrbitMenuItem(icon: "info.circle", action: { print("Info") }),
                                OrbitMenuItem(icon: "person.circle", action: { print("Profile") }),
                                OrbitMenuItem(icon: "heart", action: { print("Favorites") }),
                                OrbitMenuItem(icon: "star", action: { print("Premium") })
                            ]
                        ) {
                            Button(action: {
                                withAnimation(AppTheme.Animation.bouncySpring) {
                                    isMenuExpanded.toggle()
                                }
                            }) {
                                Image(systemName: isMenuExpanded ? "xmark" : "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(AppTheme.AuroraGradients.primary)
                                    .clipShape(Circle())
                                    .rotationEffect(.degrees(isMenuExpanded ? 45 : 0))
                            }
                        }
                        .frame(height: 220)
                    }
                    
                    // Simple Magnetic Interaction
                    VStack(spacing: 20) {
                        Text("Magnetic Cards")
                            .font(AppTheme.Typography.headlineLarge)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                        
                        VStack {
                            Text("Drag near this card")
                                .font(AppTheme.Typography.titleMedium)
                                .foregroundColor(AppTheme.Colors.textOnGlass)
                            
                            Text("Feel the magnetic attraction!")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.8))
                        }
                        .magneticInteraction(
                            strength: 1.5,
                            activationRadius: 100,
                            hapticEnabled: true
                        ) {
                            print("Magnetic field activated!")
                        }
                        .glassmorphicCard(style: .premium)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 60)
            }
        }
        .preferredColorScheme(.dark)
    }
}