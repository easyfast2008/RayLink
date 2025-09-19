#!/bin/bash

echo "🔧 Fixing type imports in all Swift files..."

# Add proper imports to RayLinkApp.swift
echo "Fixing RayLinkApp.swift..."
if ! grep -q "import RayLink" "RayLink/App/RayLinkApp.swift" 2>/dev/null; then
    # Add module imports after SwiftUI import
    sed -i '' '/import SwiftUI/a\
import Foundation
' "RayLink/App/RayLinkApp.swift"
fi

# Fix HomeView imports
echo "Fixing HomeView.swift..."
if ! grep -q "struct HomeModel" "RayLink/Features/Home/HomeView.swift" 2>/dev/null; then
    # Add HomeModel definition at the top of the file
    sed -i '' '/import SwiftUI/a\
\
// HomeModel for managing home view state\
struct HomeModel {\
    var isConnected: Bool = false\
    var selectedServer: VPNServer?\
    var connectionTime: TimeInterval = 0\
    var uploadSpeed: String = "0 KB/s"\
    var downloadSpeed: String = "0 KB/s"\
}
' "RayLink/Features/Home/HomeView.swift"
fi

echo "✅ Import fixes applied!"
echo ""
echo "Now cleaning and rebuilding..."