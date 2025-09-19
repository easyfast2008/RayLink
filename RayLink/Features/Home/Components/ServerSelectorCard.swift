import SwiftUI

// MARK: - Server Selector Card Component
struct ServerSelectorCard: View {
    let server: VPNServer?
    let onTap: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var hoverOffset: CGSize = .zero
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            onTap()
        }) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(hoverOffset)
        .animation(AppTheme.Animation.elasticPull, value: isPressed)
        .animation(AppTheme.Animation.magneticAttraction, value: hoverOffset)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
                if pressing {
                    withAnimation(AppTheme.Animation.bouncySpring) {
                        hoverOffset = CGSize(width: 0, height: -2)
                        glowIntensity = 0.6
                    }
                } else {
                    withAnimation(AppTheme.Animation.gentleSpring) {
                        hoverOffset = .zero
                        glowIntensity = 0.3
                    }
                }
            },
            perform: {}
        )
    }
    
    private var cardContent: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Server flag/icon
            serverIcon
            
            // Server information
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                serverNameAndStatus
                serverDetailsRow
            }
            
            Spacer()
            
            // Navigation arrow with subtle animation
            navigationIndicator
        }
        .padding(AppTheme.Spacing.lg)
        .background(glassmorphicBackground)
        .overlay(borderOverlay)
        .cornerRadius(AppTheme.CornerRadius.xl)
        .shadow(color: shadowColor, radius: 15, x: 0, y: 8)
        .shadow(color: accentGlow, radius: 25, x: 0, y: 12)
    }
    
    // MARK: - Server Icon
    private var serverIcon: some View {
        ZStack {
            // Background circle with subtle gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
            
            // Server flag or default icon
            if let server = server {
                // TODO: Replace with actual flag image when available
                Text(countryFlag(for: server.inferredCountry))
                    .font(.system(size: 24))
            } else {
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
            }
        }
        .overlay(
            Circle()
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
    }
    
    // MARK: - Server Name and Status
    private var serverNameAndStatus: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text(server?.name ?? "Select Server")
                .font(AppTheme.Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.textOnGlass)
            
            if let server = server {
                // Connection status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(pingColor(for: server.ping))
                        .frame(width: 6, height: 6)
                        .scaleEffect(glowIntensity > 0.4 ? 1.2 : 1.0)
                        .animation(AppTheme.Animation.breathingGlow, value: glowIntensity)
                    
                    Text("\(server.ping)ms")
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundColor(pingColor(for: server.ping))
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(pingColor(for: server.ping).opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    // MARK: - Server Details Row
    private var serverDetailsRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            if let server = server {
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.6))
                    
                    Text(server.inferredCountry)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                }
                
                // Protocol badge
                protocolBadge(for: server.protocol)
                
                // Premium indicator if needed
                if server.isPremium {
                    premiumBadge
                }
                
                Spacer()
            } else {
                Text("Choose your preferred server location")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.6))
                
                Spacer()
            }
        }
    }
    
    // MARK: - Protocol Badge
    private func protocolBadge(for protocol: VPNProtocol) -> some View {
        Text(`protocol`.rawValue.uppercased())
            .font(AppTheme.Typography.labelSmall)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.protocolColor(for: `protocol`))
                    .shadow(color: AppTheme.Colors.protocolColor(for: `protocol`).opacity(0.4), radius: 4, x: 0, y: 2)
            )
    }
    
    // MARK: - Premium Badge
    private var premiumBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10))
            Text("PRO")
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(AppTheme.AuroraGradients.iridescent)
                .shadow(color: AppTheme.Colors.auroraGold.opacity(0.4), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Navigation Indicator
    private var navigationIndicator: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 32, height: 32)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                .scaleEffect(isPressed ? 1.1 : 1.0)
                .animation(AppTheme.Animation.bouncySpring, value: isPressed)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Glassmorphic Background
    private var glassmorphicBackground: some View {
        ZStack {
            // Base glassmorphic layer
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial)
                .opacity(0.9)
            
            // Subtle color tint based on server
            if let server = server {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                    .fill(AppTheme.Colors.protocolColor(for: server.protocol).opacity(0.05))
            }
        }
    }
    
    // MARK: - Border Overlay
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.6),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
    
    // MARK: - Color Properties
    private var shadowColor: Color {
        if let server = server {
            return AppTheme.Colors.protocolColor(for: server.protocol).opacity(0.2)
        }
        return Color.black.opacity(0.1)
    }
    
    private var accentGlow: Color {
        if let server = server {
            return AppTheme.Colors.protocolColor(for: server.protocol).opacity(glowIntensity)
        }
        return AppTheme.Colors.accent.opacity(glowIntensity)
    }
    
    private func pingColor(for ping: Int) -> Color {
        switch ping {
        case 0..<50:
            return AppTheme.Colors.success
        case 50..<100:
            return AppTheme.Colors.auroraGold
        case 100..<200:
            return AppTheme.Colors.warning
        default:
            return AppTheme.Colors.error
        }
    }
    
    // MARK: - Helper Functions
    private func countryFlag(for country: String) -> String {
        // Simple country to flag emoji mapping
        let flagMap: [String: String] = [
            "United States": "🇺🇸",
            "Canada": "🇨🇦",
            "United Kingdom": "🇬🇧",
            "Germany": "🇩🇪",
            "France": "🇫🇷",
            "Japan": "🇯🇵",
            "Australia": "🇦🇺",
            "Netherlands": "🇳🇱",
            "Singapore": "🇸🇬",
            "Finland": "🇫🇮",
            "Sweden": "🇸🇪",
            "Switzerland": "🇨🇭"
        ]
        
        return flagMap[country] ?? "🌍"
    }
}

// MARK: - VPNServer Extension
extension VPNServer {
    var inferredCountry: String {
        // Use the existing country field if available
        if let country = country, !country.isEmpty {
            return country
        }
        
        // Fallback: Extract country from server name or use a mapping
        if name.contains("US") || name.contains("United States") {
            return "United States"
        } else if name.contains("UK") || name.contains("United Kingdom") {
            return "United Kingdom"
        } else if name.contains("Canada") || name.contains("CA") {
            return "Canada"
        } else if name.contains("Germany") || name.contains("DE") {
            return "Germany"
        } else if name.contains("France") || name.contains("FR") {
            return "France"
        } else if name.contains("Japan") || name.contains("JP") {
            return "Japan"
        } else if name.contains("Australia") || name.contains("AU") {
            return "Australia"
        } else if name.contains("Netherlands") || name.contains("NL") {
            return "Netherlands"
        } else if name.contains("Singapore") || name.contains("SG") {
            return "Singapore"
        } else if name.contains("Finland") || name.contains("FI") {
            return "Finland"
        } else if name.contains("Sweden") || name.contains("SE") {
            return "Sweden"
        } else if name.contains("Switzerland") || name.contains("CH") {
            return "Switzerland"
        }
        
        // Default fallback - could be enhanced with a proper country mapping
        return name.components(separatedBy: " ").first ?? "Unknown"
    }
    
    var isPremium: Bool {
        // This would typically be a property from the server data
        // For now, we'll use a simple heuristic
        return name.lowercased().contains("pro") || 
               name.lowercased().contains("premium") ||
               name.lowercased().contains("plus")
    }
}

// MARK: - Preview
struct ServerSelectorCard_Previews: PreviewProvider {
    static var sampleServer = VPNServer(
        id: "1",
        name: "ViperFastFinland",
        address: "fi1.example.com",
        port: 443,
        protocol: .shadowsocks,
        ping: 45,
        isActive: true
    )
    
    static var previews: some View {
        ZStack {
            AppTheme.AuroraGradients.timeBasedGradient(hour: 20)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // With server
                ServerSelectorCard(server: sampleServer) {
                    print("Server card tapped")
                }
                
                // Without server
                ServerSelectorCard(server: nil) {
                    print("Select server tapped")
                }
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }
}