#!/bin/bash

echo "🔍 Verifying RayLink project structure..."
echo ""

# Check if we're in the right directory
if [ ! -f "RayLink/RayLink.xcodeproj/project.pbxproj" ]; then
    echo "❌ RayLink.xcodeproj not found in expected location"
    exit 1
fi

echo "✅ Project file found"
echo ""

# Check essential directories
echo "📁 Checking directories:"
directories=(
    "RayLink"
    "RayLink/App"
    "RayLink/Core"
    "RayLink/Features"
    "RayLink/Design"
    "RayLink/Services"
    "RayLink/Models"
    "RayLink/Assets.xcassets"
    "Preview Content"
)

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir"
    else
        echo "  ❌ $dir (missing)"
    fi
done

echo ""
echo "📄 Checking essential files:"

# Check essential files
files=(
    "RayLink/App/RayLinkApp.swift"
    "RayLink/ContentView.swift"
    "RayLink/Core/RayLinkTypes.swift"
    "RayLink/Core/NavigationCoordinator.swift"
    "RayLink/Core/DependencyContainer.swift"
    "RayLink/Features/Home/HomeView.swift"
    "RayLink/Features/ServerList/ServerListView.swift"
    "RayLink/Features/Settings/SettingsView.swift"
    "RayLink/Features/Import/ImportView.swift"
    "RayLink/Core/VPN/MockVPNManager.swift"
    "RayLink/Assets.xcassets/AppIcon.appiconset/Contents.json"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
    fi
done

echo ""
echo "🔨 Build preparation:"
echo "  1. Open Xcode"
echo "  2. Clean Build Folder (Shift+Cmd+K)"
echo "  3. Build (Cmd+B)"
echo ""
echo "If errors persist, run: ./fix_remaining_errors.sh"