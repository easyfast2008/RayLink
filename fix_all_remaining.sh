#!/bin/bash

echo "🔧 Fixing all remaining type issues..."

# 1. Fix HomeViewModel visibility
echo "Fixing HomeViewModel..."
sed -i '' 's/^final class HomeViewModel/public final class HomeViewModel/' "RayLink/Features/Home/HomeViewModel.swift"

# 2. Fix AppTheme.Spacing visibility and add missing values
echo "Fixing AppTheme.Spacing..."
sed -i '' 's/struct Spacing {/public struct Spacing {/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/struct CornerRadius {/public struct CornerRadius {/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/struct Colors {/public struct Colors {/' "RayLink/Design/Theme/AppTheme.swift"

# Add missing spacing values if not present
if ! grep -q "extraLarge" "RayLink/Design/Theme/AppTheme.swift"; then
    sed -i '' '/static let xxxl: CGFloat = 64/a\
        public static let extraLarge: CGFloat = 40
' "RayLink/Design/Theme/AppTheme.swift"
fi

# 3. Fix all AuroraGradients static properties to be public
echo "Fixing AuroraGradients properties..."
sed -i '' 's/static let primary = /public static let primary = /' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let connected = /public static let connected = /' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let connecting = /public static let connecting = /' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let disconnected = /public static let disconnected = /' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let glassmorphicBackground = /public static let glassmorphicBackground = /' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static func timeBasedGradient/public static func timeBasedGradient/' "RayLink/Design/Theme/AppTheme.swift"

# 4. Fix all Colors static properties to be public
echo "Fixing Colors properties..."
sed -i '' 's/static let primary = /public static let primary = /' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let background = /public static let background = /' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let secondary = /public static let secondary = /' "RayLink/Design/Theme/AppTheme.swift"

# 5. Fix all Spacing static properties to be public
echo "Fixing Spacing properties..."
sed -i '' 's/static let xs:/public static let xs:/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let sm:/public static let sm:/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let md:/public static let md:/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let lg:/public static let lg:/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let xl:/public static let xl:/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let xxl:/public static let xxl:/' "RayLink/Design/Theme/AppTheme.swift"
sed -i '' 's/static let xxxl:/public static let xxxl:/' "RayLink/Design/Theme/AppTheme.swift"

# 6. Fix ConnectionMode enum if needed
if ! grep -q "enum ConnectionMode" "RayLink/Core/RayLinkTypes.swift"; then
    echo "Adding ConnectionMode enum..."
    cat >> "RayLink/Core/RayLinkTypes.swift" << 'EOF'

// MARK: - Connection Mode
public enum ConnectionMode: String, CaseIterable {
    case automatic = "Automatic"
    case manual = "Manual"
    case smart = "Smart"
}
EOF
fi

# 7. Fix VPNManagerProtocol and StorageManagerProtocol
echo "Adding missing protocols..."
if ! grep -q "protocol VPNManagerProtocol" "RayLink/Core/RayLinkTypes.swift"; then
    cat >> "RayLink/Core/RayLinkTypes.swift" << 'EOF'

// MARK: - VPN Manager Protocol
public protocol VPNManagerProtocol {
    func connect(to server: VPNServer) async throws
    func disconnect() async throws
    func getConnectionStatus() -> VPNConnectionStatus
}

// MARK: - Storage Manager Protocol  
public protocol StorageManagerProtocol {
    func saveServer(_ server: VPNServer) throws
    func loadServers() throws -> [VPNServer]
    func deleteServer(_ id: String) throws
}
EOF
fi

echo "✅ All fixes applied!"
echo ""
echo "Now clean and rebuild in Xcode."