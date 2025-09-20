import SwiftUI
import Foundation
import UIKit

public struct AppTheme {
    
    // MARK: - Theme Enum
    public enum Theme: String, CaseIterable, Codable {
        case light = "light"
        case dark = "dark"
        case aurora = "aurora"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            case .aurora:
                return "Aurora"
            case .system:
                return "System"
            }
        }
    }
    
    // MARK: - Aurora Gradient System
    public struct AuroraGradients {
        // Primary Aurora Gradients
        public static let primary = LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.0, blue: 0.8),  // Deep Purple
                Color(red: 0.0, green: 0.4, blue: 0.9),  // Electric Blue
                Color(red: 0.0, green: 0.8, blue: 0.6)   // Aurora Green
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Connection State Gradients
        public static let connected = RadialGradient(
            colors: [
                Color(red: 0.0, green: 1.0, blue: 0.6).opacity(0.9),
                Color(red: 0.0, green: 0.8, blue: 0.4).opacity(0.7),
                Color(red: 0.0, green: 0.6, blue: 0.3).opacity(0.5)
            ],
            center: .center,
            startRadius: 10,
            endRadius: 80
        )
        
        public static let connecting = AngularGradient(
            colors: [
                Color(red: 1.0, green: 0.6, blue: 0.0),
                Color(red: 1.0, green: 0.4, blue: 0.2),
                Color(red: 1.0, green: 0.8, blue: 0.0),
                Color(red: 1.0, green: 0.6, blue: 0.0)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
        
        public static let disconnected = LinearGradient(
            colors: [
                Color(red: 0.5, green: 0.5, blue: 0.5).opacity(0.6),
                Color(red: 0.3, green: 0.3, blue: 0.3).opacity(0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Glassmorphic Background
        public static let glassmorphicBackground = LinearGradient(
            colors: [
                Color.white.opacity(0.2),
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Dynamic Time-Based Gradient
        public static func timeBasedGradient(hour: Int) -> LinearGradient {
            let colors: [Color]
            
            switch hour {
            case 5...8: // Dawn
                colors = [
                    Color(red: 1.0, green: 0.4, blue: 0.6),
                    Color(red: 0.9, green: 0.6, blue: 0.2),
                    Color(red: 0.4, green: 0.7, blue: 0.9)
                ]
            case 9...16: // Day
                colors = [
                    Color(red: 0.3, green: 0.7, blue: 1.0),
                    Color(red: 0.0, green: 0.5, blue: 0.9),
                    Color(red: 0.2, green: 0.8, blue: 0.6)
                ]
            case 17...20: // Sunset
                colors = [
                    Color(red: 1.0, green: 0.3, blue: 0.5),
                    Color(red: 0.9, green: 0.5, blue: 0.1),
                    Color(red: 0.6, green: 0.2, blue: 0.8)
                ]
            default: // Night
                colors = [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.0, blue: 0.4),
                    Color(red: 0.0, green: 0.2, blue: 0.3)
                ]
            }
            
            return LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Iridescent Effect for Premium Features
        static let iridescent = AngularGradient(
            colors: [
                Color(red: 1.0, green: 0.0, blue: 1.0), // Magenta
                Color(red: 0.0, green: 1.0, blue: 1.0), // Cyan
                Color(red: 1.0, green: 1.0, blue: 0.0), // Yellow
                Color(red: 1.0, green: 0.0, blue: 0.0), // Red
                Color(red: 1.0, green: 0.0, blue: 1.0)  // Magenta
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }
    
    // MARK: - Colors
    public struct Colors {
        // Aurora-inspired Primary Colors
        static let auroraViolet = Color(red: 0.4, green: 0.0, blue: 0.8)
        static let auroraBlue = Color(red: 0.0, green: 0.4, blue: 0.9)
        static let auroraGreen = Color(red: 0.0, green: 0.8, blue: 0.6)
        static let auroraPink = Color(red: 1.0, green: 0.4, blue: 0.6)
        static let auroraGold = Color(red: 1.0, green: 0.8, blue: 0.0)
        
        // Primary Colors (using aurora colors)
        public static let primary = auroraBlue
        static let primaryLight = auroraBlue.opacity(0.7)
        static let primaryDark = Color(red: 0.0, green: 0.2, blue: 0.6)
        
        // Secondary Colors
        public static let secondary = Color("SecondaryColor")
        static let secondaryLight = Color("SecondaryLightColor")
        static let secondaryDark = Color("SecondaryDarkColor")
        
        // Accent Colors (using aurora violet)
        static let accent = auroraViolet
        static let accentLight = auroraViolet.opacity(0.7)
        static let accentDark = Color(red: 0.2, green: 0.0, blue: 0.5)
        
        // Glassmorphic Background Colors
        public static let background = Color("BackgroundColor")
        static let backgroundSecondary = Color("BackgroundSecondaryColor")
        static let cardBackground = Color.white.opacity(0.1)
        static let surface = Color.white.opacity(0.05)
        static let glassEffect = Color.white.opacity(0.2)
        static let glassMorphicFill = Color.white.opacity(0.12)
        static let auroraPalette: [Color] = [auroraBlue, auroraViolet, auroraGreen, auroraPink]
        
        // Text Colors with better contrast
        static let text = Color("TextColor")
        static let textSecondary = Color("TextSecondaryColor")
        static let textTertiary = Color("TextTertiaryColor")
        static let textOnGlass = Color.white.opacity(0.9)
        
        // Enhanced Status Colors
        static let success = Color("SuccessColor")
        static let warning = Color("WarningColor")
        static let error = Color("ErrorColor")
        static let info = Color("InfoColor")
        
        // VPN Status Colors with Breathing Effects
        public static let connected = auroraGreen
        public static let connecting = Color(red: 1.0, green: 0.6, blue: 0.0)
        public static let disconnected = Color.gray
        
        // Protocol Colors with unique aurora tints
        static let shadowsocks = auroraBlue
        static let vmess = auroraViolet
        static let trojan = Color(red: 0.9, green: 0.2, blue: 0.3)
        static let vless = Color(red: 0.2, green: 0.6, blue: 0.9)
        static let wireguard = auroraGreen
        static let ikev2 = auroraGold
        
        // Helper method to get protocol color
        static func protocolColor(for vpnProtocol: VPNProtocol) -> Color {
            switch vpnProtocol {
            case .shadowsocks:
                return shadowsocks
            case .vmess:
                return vmess
            case .trojan:
                return trojan
            case .vless:
                return vless
            case .wireguard:
                return wireguard
            case .ikev2:
                return ikev2
            }
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // Display Fonts
        static let displayLarge = Font.system(size: 57, weight: .regular)
        static let displayMedium = Font.system(size: 45, weight: .regular)
        static let displaySmall = Font.system(size: 36, weight: .regular)
        
        // Headline Fonts
        static let headlineLarge = Font.system(size: 32, weight: .regular)
        static let headlineMedium = Font.system(size: 28, weight: .regular)
        static let headlineSmall = Font.system(size: 24, weight: .regular)
        
        // Title Fonts
        static let titleLarge = Font.system(size: 22, weight: .medium)
        static let titleMedium = Font.system(size: 16, weight: .medium)
        static let titleSmall = Font.system(size: 14, weight: .medium)
        
        // Body Fonts
        static let bodyLarge = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 14, weight: .regular)
        static let bodySmall = Font.system(size: 12, weight: .regular)
        
        // Label Fonts
        static let labelLarge = Font.system(size: 14, weight: .medium)
        static let labelMedium = Font.system(size: 12, weight: .medium)
        static let labelSmall = Font.system(size: 11, weight: .medium)
        
        // Custom Fonts
        static let monospaceLarge = Font.system(size: 16, weight: .regular, design: .monospaced)
        static let monospaceMedium = Font.system(size: 14, weight: .regular, design: .monospaced)
        static let monospaceSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
    }
    
    // MARK: - Spacing
    public struct Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
        public static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    public struct CornerRadius {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let medium: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 20
        public static let xxl: CGFloat = 24
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        static let extraLarge = Shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
        
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Enhanced Animation System
    struct Animation {
        // Basic Animations with improved easing
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let medium = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        
        // Spring Physics Animations
        static let fluidSpring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)
        static let gentleSpring = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
        static let bouncySpring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)
        static let snappySpring = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0)
        
        // Specialized VPN Animations
        static let connectionPulse = SwiftUI.Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        static let breathingGlow = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        static let liquidRipple = SwiftUI.Animation.spring(response: 0.8, dampingFraction: 0.4, blendDuration: 0)
        
        // Magnetic Interaction Animations
        static let magneticAttraction = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
        static let elasticPull = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)
        
        // Wave Flow Animations
        static let waveFlow = SwiftUI.Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: false)
        static let ambientFloat = SwiftUI.Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
        static let auroraFlow = SwiftUI.Animation.easeInOut(duration: 6.0).repeatForever(autoreverses: true)
        
        // Transition Animations
        static let morphTransition = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)
        static let liquidTransition = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.2)
    }
    
    // MARK: - Icon Sizes
    struct IconSize {
        public static let xs: CGFloat = 12
        public static let sm: CGFloat = 16
        public static let md: CGFloat = 20
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
        public static let xxxl: CGFloat = 64
    }
    
    // MARK: - Layout
    struct Layout {
        static let screenPadding: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 12
        static let minimumTouchTarget: CGFloat = 44
        
        // Grid
        static let gridSpacing: CGFloat = 12
        static let maxGridColumns = 3
        static let minGridItemWidth: CGFloat = 120
    }
    
    // MARK: - Blur Effects
    struct BlurEffect {
        static let thin: UIBlurEffect.Style = .systemThinMaterial
        static let regular: UIBlurEffect.Style = .systemMaterial
        static let thick: UIBlurEffect.Style = .systemThickMaterial
        static let chrome: UIBlurEffect.Style = .systemChromeMaterial
        
        // Ultra Thin variants
        static let ultraThinLight: UIBlurEffect.Style = .systemUltraThinMaterialLight
        static let ultraThinDark: UIBlurEffect.Style = .systemUltraThinMaterialDark
    }
    
    // MARK: - Button Styles
    struct ButtonStyles {
        struct Primary: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .fill(AppTheme.AuroraGradients.primary)
                            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                    )
                    .animation(AppTheme.Animation.snappySpring, value: configuration.isPressed)
            }
        }
        
        struct Secondary: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .fill(AppTheme.Colors.accent.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                    .stroke(AppTheme.Colors.accent, lineWidth: 1)
                            )
                            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                    )
                    .animation(AppTheme.Animation.snappySpring, value: configuration.isPressed)
            }
        }
        
        struct Destructive: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .fill(Color.red)
                            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                    )
                    .animation(AppTheme.Animation.snappySpring, value: configuration.isPressed)
            }
        }
        
        struct Compact: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(AppTheme.Typography.labelMedium)
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                            .fill(AppTheme.Colors.accent.opacity(0.1))
                            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                    )
                    .animation(AppTheme.Animation.snappySpring, value: configuration.isPressed)
            }
        }
    }
}

// MARK: - Enhanced View Extensions for Glassmorphism
extension View {
    func themedBackground(_ color: Color = AppTheme.Colors.background) -> some View {
        self.background(color.ignoresSafeArea())
    }
    
    func glassmorphicCard(padding: CGFloat = AppTheme.Layout.cardPadding) -> some View {
        self
            .padding(padding)
            .background(
                ZStack {
                    // Glassmorphic background
                    AppTheme.AuroraGradients.glassmorphicBackground
                    
                    // Subtle blur effect
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .fill(Color.white.opacity(0.1))
                        .background(.ultraThinMaterial)
                }
            )
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .shadow(color: AppTheme.Colors.accent.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    func neomorphicCard(padding: CGFloat = AppTheme.Layout.cardPadding, isPressed: Bool = false) -> some View {
        self
            .padding(padding)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .shadow(
                color: isPressed ? Color.clear : Color.black.opacity(0.2),
                radius: isPressed ? 5 : 15,
                x: isPressed ? 2 : 5,
                y: isPressed ? 2 : 5
            )
            .shadow(
                color: isPressed ? Color.clear : Color.white.opacity(0.1),
                radius: isPressed ? 3 : 10,
                x: isPressed ? -1 : -3,
                y: isPressed ? -1 : -3
            )
    }
    
    func auroraBackground() -> some View {
        self.background(
            GeometryReader { geometry in
                AppTheme.AuroraGradients.timeBasedGradient(hour: Calendar.current.component(.hour, from: Date()))
                    .ignoresSafeArea()
                    .overlay(
                        // Animated aurora particles
                        ForEach(0..<20, id: \.self) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: .random(in: 2...8), height: .random(in: 2...8))
                                .position(
                                    x: .random(in: 0...geometry.size.width),
                                    y: .random(in: 0...geometry.size.height)
                                )
                                .animation(
                                    AppTheme.Animation.ambientFloat.delay(.random(in: 0...2)),
                                    value: UUID()
                                )
                        }
                    )
            }
        )
    }
    
    func breathingGlow(color: Color = AppTheme.Colors.accent, isActive: Bool = true) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(color.opacity(isActive ? 0.3 : 0.1))
                    .scaleEffect(isActive ? 1.05 : 1.0)
                    .blur(radius: 10)
                    .animation(
                        isActive ? AppTheme.Animation.breathingGlow : .easeOut(duration: 0.3),
                        value: isActive
                    )
            )
    }
    
    func liquidButton(isPressed: Bool = false) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(AppTheme.AuroraGradients.primary)
                    .scaleEffect(isPressed ? 1.1 : 1.0)
                    .blur(radius: isPressed ? 8 : 0)
                    .opacity(isPressed ? 0.8 : 1.0)
            )
            .animation(AppTheme.Animation.liquidRipple, value: isPressed)
    }
    
    func magneticEffect(offset: CGSize) -> some View {
        self
            .offset(offset)
            .animation(AppTheme.Animation.magneticAttraction, value: offset)
    }
    
    func themedShadow(_ shadow: AppTheme.Shadow = AppTheme.Shadow.medium) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    // Legacy support
    func themedCard(padding: CGFloat = AppTheme.Layout.cardPadding) -> some View {
        self.glassmorphicCard(padding: padding)
    }
}

// MARK: - Color Assets
// These would typically be defined in Assets.xcassets, but we're providing fallbacks here

extension Color {
    init(_ name: String) {
        // Try to load from asset catalog first, fall back to predefined colors
        if let color = UIColor(named: name) {
            self.init(uiColor: color)
        } else {
            // Fallback colors
            switch name {
            case "PrimaryColor":
                self.init(red: 0.0, green: 0.48, blue: 1.0) // SF Blue
            case "PrimaryLightColor":
                self.init(red: 0.4, green: 0.68, blue: 1.0)
            case "PrimaryDarkColor":
                self.init(red: 0.0, green: 0.28, blue: 0.8)
            case "AccentColor":
                self.init(red: 1.0, green: 0.584, blue: 0.0) // SF Orange
            case "BackgroundColor":
                self.init(.systemBackground)
            case "CardBackgroundColor":
                self.init(.secondarySystemBackground)
            case "TextColor":
                self.init(.label)
            case "SecondaryColor":
                self.init(.systemGray)
            case "SuccessColor":
                self.init(.systemGreen)
            case "ErrorColor":
                self.init(.systemRed)
            case "WarningColor":
                self.init(.systemOrange)
            case "ConnectedColor":
                self.init(.systemGreen)
            case "ConnectingColor":
                self.init(.systemOrange)
            case "DisconnectedColor":
                self.init(.systemGray)
            case "ShadowsocksColor":
                self.init(.systemBlue)
            case "VmessColor":
                self.init(.systemPurple)
            case "TrojanColor":
                self.init(.systemRed)
            case "VlessColor":
                self.init(.systemIndigo)
            case "WireguardColor":
                self.init(.systemGreen)
            case "Ikev2Color":
                self.init(.systemOrange)
            default:
                self.init(.label)
            }
        }
    }
}