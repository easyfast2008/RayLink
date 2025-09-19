#!/bin/bash

echo "🚀 Preparing RayLink for build..."
echo ""

# Clean DerivedData
echo "🧹 Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/RayLink-*
echo "✅ DerivedData cleaned"
echo ""

# Verify structure
echo "📁 Verifying project structure..."
./verify_build.sh
echo ""

# Open Xcode project
echo "📱 Opening Xcode project..."
open RayLink/RayLink.xcodeproj

echo ""
echo "================================"
echo "📌 FINAL BUILD STEPS IN XCODE:"
echo "================================"
echo ""
echo "1. Wait for Xcode to fully load and index"
echo "2. Select a simulator (iPhone 15 Pro recommended)"
echo "3. Press Shift+Cmd+K (Clean Build Folder)"
echo "4. Press Cmd+B (Build)"
echo ""
echo "If you see errors about missing types:"
echo "  - Check that RayLinkTypes.swift is included in the target"
echo "  - Ensure all files have '// Global types imported via RayLinkTypes' comment"
echo ""
echo "✨ The app should now build successfully!"
echo ""
echo "Note: VPN functionality will be simulated (MockVPNManager)"
echo "since you're using a personal Apple ID."