import SwiftUI
import Foundation
struct ServerSearchBar: View {
    @Binding var searchText: String
    @Binding var selectedProtocol: VPNProtocol?
    let isVisible: Bool
    
    @State private var isSearchFocused = false
    @State private var placeholderIndex = 0
    @State private var showClearButton = false
    
    private let placeholders = [
        "Search servers...",
        "Find by name...",
        "Filter by location...",
        "Search protocol..."
    ]
    
    var body: some View {
        if isVisible {
            VStack(spacing: AppTheme.Spacing.sm) {
                // Search field
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.6))
                        .scaleEffect(isSearchFocused ? 1.1 : 1.0)
                        .animation(AppTheme.Animation.gentleSpring, value: isSearchFocused)
                    
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text(placeholders[placeholderIndex])
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.4))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .animation(AppTheme.Animation.fluidSpring, value: placeholderIndex)
                        }
                        
                        TextField("", text: $searchText)
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textOnGlass)
                            .onSubmit {
                                isSearchFocused = false
                            }
                            .onChangeCompat(of: searchText) { newValue in
                                withAnimation(AppTheme.Animation.gentleSpring) {
                                    showClearButton = !newValue.isEmpty
                                }
                            }
                    }
                    
                    if showClearButton {
                        Button(action: {
                            withAnimation(AppTheme.Animation.fluidSpring) {
                                searchText = ""
                                showClearButton = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textOnGlass.opacity(0.5))
                                .rotationEffect(.degrees(showClearButton ? 0 : 90))
                                .scaleEffect(showClearButton ? 1.0 : 0.8)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(AppTheme.Colors.glassMorphicFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(
                                    isSearchFocused ? 
                                    AppTheme.AuroraGradients.primary.opacity(0.5) :
                                    Color.clear,
                                    lineWidth: 1
                                )
                        )
                )
                .onTapGesture {
                    isSearchFocused = true
                }
                
                // Protocol filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        // All protocols chip
                        FilterChip(
                            title: "All",
                            isSelected: selectedProtocol == nil,
                            color: AppTheme.Colors.textOnGlass
                        ) {
                            withAnimation(AppTheme.Animation.fluidSpring) {
                                selectedProtocol = nil
                            }
                        }
                        
                        // Individual protocol chips
                        ForEach(VPNProtocol.allCases, id: \.self) { vpnProtocol in
                            FilterChip(
                                title: vpnProtocol.rawValue.capitalized,
                                isSelected: selectedProtocol == vpnProtocol,
                                color: protocolColor(for: vpnProtocol)
                            ) {
                                withAnimation(AppTheme.Animation.fluidSpring) {
                                    selectedProtocol = selectedProtocol == vpnProtocol ? nil : vpnProtocol
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                startPlaceholderAnimation()
            }
        }
    }
    
    private func startPlaceholderAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(AppTheme.Animation.fluidSpring) {
                placeholderIndex = (placeholderIndex + 1) % placeholders.count
            }
        }
    }
    
    private func protocolColor(for vpnProtocol: VPNProtocol) -> Color {
        AppTheme.Colors.protocolColor(for: vpnProtocol)
    }


}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.labelSmall)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(
                    Capsule()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [AppTheme.Colors.glassMorphicFill],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? Color.clear : color.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(AppTheme.Animation.bouncySpring, value: isPressed)
        }
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: { }
        )
    }
}