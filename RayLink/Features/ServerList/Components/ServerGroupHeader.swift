import SwiftUI
import Foundation
struct ServerGroupHeader: View {
    let group: ServerGroup
    @Binding var isExpanded: Bool
    let onTestAll: () -> Void
    let onDeleteGroup: () -> Void
    
    @State private var rotationAngle: Double = 0
    @State private var showingDeleteConfirmation = false
    @State private var isTestingAll = false
    @State private var lastUpdateTime: Date?
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Expand/Collapse indicator with smooth rotation
            Button(action: toggleExpansion) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textOnGlass)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(AppTheme.Animation.fluidSpring, value: isExpanded)
            }
            
            // Group name and server count
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text(group.name)
                        .font(AppTheme.Typography.titleSmall)
                        .foregroundColor(AppTheme.Colors.textOnGlass)
                        .fontWeight(.semibold)
                    
                    // Server count badge
                    Text("\(group.servers.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppTheme.Colors.glassMorphicFill)
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.AuroraGradients.primary.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                // Last update timestamp for subscriptions
                if let lastUpdate = lastUpdateTime {
                    Text("Updated \(timeAgoString(from: lastUpdate))")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: AppTheme.Spacing.sm) {
                // Test all button
                Button(action: {
                    withAnimation(AppTheme.Animation.bouncySpring) {
                        isTestingAll = true
                    }
                    onTestAll()
                    
                    // Reset animation after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(AppTheme.Animation.gentleSpring) {
                            isTestingAll = false
                        }
                    }
                }) {
                    Image(systemName: isTestingAll ? "bolt.fill" : "bolt")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.aurora.green)
                        .scaleEffect(isTestingAll ? 1.2 : 1.0)
                        .rotationEffect(.degrees(isTestingAll ? 360 : 0))
                        .animation(
                            isTestingAll ? AppTheme.Animation.fluidSpring.repeatCount(3, autoreverses: false) : .default,
                            value: isTestingAll
                        )
                }
                .buttonStyle(GlassmorphicButtonStyle())
                .disabled(isTestingAll)
                
                // Delete group button
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.error.opacity(0.8))
                }
                .buttonStyle(GlassmorphicButtonStyle())
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.glassMorphicFill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(
                            isExpanded ? AppTheme.AuroraGradients.primary.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            toggleExpansion()
        }
        .confirmationDialog(
            "Delete Group",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete All \(group.servers.count) Servers", role: .destructive) {
                withAnimation(AppTheme.Animation.fluidSpring) {
                    onDeleteGroup()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all servers in the \"\(group.name)\" group.")
        }
    }
    
    private func toggleExpansion() {
        withAnimation(AppTheme.Animation.fluidSpring) {
            isExpanded.toggle()
            rotationAngle = isExpanded ? 90 : 0
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}