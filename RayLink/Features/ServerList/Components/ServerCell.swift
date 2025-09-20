import SwiftUI

struct ServerCell: View {
    let server: VPNServer
    let isSelected: Bool
    let isConnected: Bool
    let showingBatchSelection: Bool
    let onSelect: () -> Void
    let onConnect: () -> Void
    let onDelete: () -> Void
    let onCopy: () -> Void
    let onShare: () -> Void
    
    @State private var isPressed = false
    @State private var dragOffset = CGSize.zero
    @State private var showingSwipeActions = false
    @State private var isChecked = false
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Batch selection checkbox
            if showingBatchSelection {
                Button(action: {
                    withAnimation(AppTheme.Animation.bouncySpring) {
                        isChecked.toggle()
                    }
                }) {
                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(isChecked ? AppTheme.Colors.accent : AppTheme.Colors.textOnGlass.opacity(0.5))
                        .scaleEffect(isChecked ? 1.1 : 1.0)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Server information
            HStack(spacing: AppTheme.Spacing.md) {
                // Flag/Location indicator
                ZStack {
                    Circle()
                        .fill(AppTheme.AuroraGradients.primary)
                        .opacity(0.1)
                        .frame(width: 40, height: 40)

                    Text(server.flag)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(server.name)
                            .font(AppTheme.Typography.titleSmall)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        // Protocol badge
                        Text(server.serverProtocol.rawValue.uppercased())
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(protocolColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(protocolColor.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(protocolColor.opacity(0.3), lineWidth: 0.5)
                                    )
                            )
                    }
                    
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(server.displayLocation)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.7))
                        
                        if server.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.Colors.aurora.gold)
                        }
                    }
                }
                
                Spacer()
                
                // Ping indicator
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(pingColor)
                            .frame(width: 6, height: 6)
                            .overlay(
                                Circle()
                                    .stroke(pingColor.opacity(0.3), lineWidth: 8)
                                    .scaleEffect(isConnected ? 1.5 : 1.0)
                                    .opacity(isConnected ? 0 : 1)
                                    .animation(
                                        isConnected ? AppTheme.Animation.breathingGlow.repeatForever(autoreverses: true) : .default,
                                        value: isConnected
                                    )
                            )
                        
                        Text("\(server.ping)ms")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(pingColor)
                            .fontWeight(.medium)
                    }
                    
                    if isConnected {
                        Text("Connected")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.success)
                            .fontWeight(.semibold)
                    }
                }
                
                // Quick connect button
                if !showingBatchSelection {
                    Button(action: {
                        withAnimation(AppTheme.Animation.bouncySpring) {
                            onConnect()
                        }
                    }) {
                        Image(systemName: isConnected ? "checkmark.circle.fill" : "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(isConnected ? AppTheme.Colors.success : AppTheme.Colors.accent)
                            .scaleEffect(isPressed ? 0.9 : 1.0)
                    }
                    .disabled(isConnected)
                    .onLongPressGesture(
                        minimumDuration: 0,
                        maximumDistance: .infinity,
                        pressing: { pressing in
                            withAnimation(AppTheme.Animation.gentleSpring) {
                                isPressed = pressing
                            }
                        },
                        perform: { }
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(
                    isSelected ? 
                    AppTheme.Colors.glassMorphicFill.opacity(0.8) :
                    AppTheme.Colors.glassMorphicFill.opacity(0.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            isSelected ?
                            AppTheme.AuroraGradients.primary :
                            Color.clear,
                            lineWidth: 1
                        )
                        .opacity(isSelected ? 0.5 : 1)
                )
        )
        .offset(x: dragOffset.width)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(AppTheme.Animation.fluidSpring) {
                onSelect()
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(AppTheme.Animation.gentleSpring) {
                        dragOffset = CGSize(width: min(0, max(-150, value.translation.width)), height: 0)
                        showingSwipeActions = dragOffset.width < -50
                    }
                }
                .onEnded { _ in
                    withAnimation(AppTheme.Animation.fluidSpring) {
                        if showingSwipeActions {
                            dragOffset = CGSize(width: -100, height: 0)
                        } else {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .overlay(
            // Swipe actions
            HStack(spacing: 0) {
                Spacer()
                
                if showingSwipeActions {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        // Share button
                        Button(action: {
                            withAnimation(AppTheme.Animation.fluidSpring) {
                                dragOffset = .zero
                                showingSwipeActions = false
                            }
                            onShare()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.Colors.info)
                                .cornerRadius(AppTheme.CornerRadius.small)
                        }
                        
                        // Copy button
                        Button(action: {
                            withAnimation(AppTheme.Animation.fluidSpring) {
                                dragOffset = .zero
                                showingSwipeActions = false
                            }
                            onCopy()
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.Colors.warning)
                                .cornerRadius(AppTheme.CornerRadius.small)
                        }
                        
                        // Delete button
                        Button(action: {
                            withAnimation(AppTheme.Animation.fluidSpring) {
                                onDelete()
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.Colors.error)
                                .cornerRadius(AppTheme.CornerRadius.small)
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        )
    }
    
    private var pingColor: Color {
        if server.ping < 50 {
            return AppTheme.Colors.success
        } else if server.ping < 150 {
            return AppTheme.Colors.warning
        } else {
            return AppTheme.Colors.error
        }
    }
    
    private var protocolColor: Color {
        switch server.serverProtocol {
        case .shadowsocks:
            return AppTheme.Colors.aurora.blue
        case .vmess, .vless:
            return AppTheme.Colors.aurora.violet
        case .trojan:
            return AppTheme.Colors.aurora.pink
        case .ikev2:
            return AppTheme.Colors.warning
        case .wireguard:
            return AppTheme.Colors.aurora.green
        }
    }
}