import SwiftUI
import Foundation
struct EmptyServerState: View {
    let onAddServer: () -> Void
    let onImport: () -> Void
    
    @State private var particlePositions: [CGPoint] = []
    @State private var illustrationScale = 0.8
    @State private var illustrationOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var buttonsScale = 0.9
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            
            // Animated illustration
            ZStack {
                // Floating particles background
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(
                            AppTheme.AuroraGradients.primary
                                .opacity(Double.random(in: 0.1...0.3))
                        )
                        .frame(
                            width: CGFloat.random(in: 10...30),
                            height: CGFloat.random(in: 10...30)
                        )
                        .blur(radius: CGFloat.random(in: 0...2))
                        .offset(
                            x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -100...100)
                        )
                        .animation(
                            AppTheme.Animation.ambientFloat
                                .delay(Double(index) * 0.2)
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
                
                // Main illustration
                VStack(spacing: AppTheme.Spacing.md) {
                    // Server icon with aurora glow
                    ZStack {
                        // Outer glow rings
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    AppTheme.AuroraGradients.primary.opacity(0.3 - Double(index) * 0.1),
                                    lineWidth: 2
                                )
                                .frame(
                                    width: 80 + CGFloat(index * 30),
                                    height: 80 + CGFloat(index * 30)
                                )
                                .scaleEffect(illustrationScale)
                                .animation(
                                    AppTheme.Animation.breathingGlow
                                        .delay(Double(index) * 0.2)
                                        .repeatForever(autoreverses: true),
                                    value: illustrationScale
                                )
                        }
                        
                        // Center icon
                        Image(systemName: "server.rack")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(
                                AppTheme.AuroraGradients.primary
                            )
                            .overlay(
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .offset(x: 20, y: -20)
                            )
                    }
                    
                    // Connection dots animation
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(AppTheme.Colors.textOnGlass.opacity(0.3))
                                .frame(width: 4, height: 4)
                                .scaleEffect(illustrationScale)
                                .animation(
                                    AppTheme.Animation.gentleSpring
                                        .delay(Double(index) * 0.1)
                                        .repeatForever(autoreverses: true),
                                    value: illustrationScale
                                )
                        }
                    }
                }
                .scaleEffect(illustrationScale)
                .opacity(illustrationOpacity)
            }
            .frame(height: 200)
            
            // Text content
            VStack(spacing: AppTheme.Spacing.md) {
                Text("No Servers Yet")
                    .font(AppTheme.Typography.headlineMedium)
                    .foregroundColor(AppTheme.Colors.textOnGlass)
                    .fontWeight(.semibold)
                
                Text("Add your first server to start\nprotecting your connection")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(textOpacity)
            
            // Action buttons
            VStack(spacing: AppTheme.Spacing.md) {
                // Primary action - Add Server
                Button(action: onAddServer) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                        
                        Text("Add Server Manually")
                            .font(AppTheme.Typography.labelLarge)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                            .fill(AppTheme.AuroraGradients.primary)
                            .shadow(
                                color: AppTheme.Colors.accent.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                }
                .buttonStyle(LiquidButtonStyle())
                
                // Secondary action - Import
                Button(action: onImport) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 18, weight: .medium))
                        
                        Text("Import from URL or QR")
                            .font(AppTheme.Typography.labelMedium)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppTheme.Colors.textOnGlass)
                    .frame(maxWidth: 280)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                            .fill(AppTheme.Colors.glassMorphicFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                                    .stroke(
                                        AppTheme.AuroraGradients.primary.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(GlassmorphicButtonStyle())
            }
            .scaleEffect(buttonsScale)
            .opacity(textOpacity)
            
            Spacer()
            
            // Help text
            Text("You can also paste server links from clipboard")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.5))
                .multilineTextAlignment(.center)
                .opacity(textOpacity)
        }
        .padding(AppTheme.Spacing.lg)
        .onAppear {
            animateAppearance()
        }
    }
    
    private func animateAppearance() {
        // Staggered animation sequence
        withAnimation(AppTheme.Animation.fluidSpring.delay(0.1)) {
            illustrationScale = 1.0
            illustrationOpacity = 1.0
        }
        
        withAnimation(AppTheme.Animation.gentleSpring.delay(0.3)) {
            textOpacity = 1.0
        }
        
        withAnimation(AppTheme.Animation.bouncySpring.delay(0.5)) {
            buttonsScale = 1.0
        }
        
        // Start continuous animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(
                AppTheme.Animation.breathingGlow
                    .repeatForever(autoreverses: true)
            ) {
                illustrationScale = 1.05
            }
        }
    }
}