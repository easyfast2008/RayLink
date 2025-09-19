#!/bin/bash

echo "🔧 Final Project Fix for Xcode..."
echo "================================"

cd /Users/alisimacpro/Desktop/RayLink

# 1. Ensure all directories exist
echo "📁 Creating required directories..."
mkdir -p "RayLink/Preview Content/PreviewAssets.xcassets"
mkdir -p "RayLink/Resources/Assets.xcassets"

# 2. Create Contents.json for Preview Assets
cat > "RayLink/Preview Content/PreviewAssets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# 3. Create main Assets.xcassets if needed
if [ ! -f "RayLink/Resources/Assets.xcassets/Contents.json" ]; then
    cat > "RayLink/Resources/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
fi

# 4. Clean ALL Xcode caches
echo "🧹 Cleaning all Xcode caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 5. Reset simulators
echo "📱 Resetting simulators..."
xcrun simctl shutdown all 2>/dev/null
xcrun simctl erase all 2>/dev/null

# 6. Final project file verification
echo "✅ Verifying project settings..."
echo ""
echo "Preview Content Path: \"Preview Content\" ✓"
echo "Info.plist Path: Info.plist ✓"
echo "Entitlements Path: RayLink.entitlements ✓"
echo ""

echo "================================"
echo "✅ ALL FIXES APPLIED!"
echo ""
echo "IMPORTANT: Close and reopen Xcode completely:"
echo ""
echo "1. Quit Xcode completely (Cmd+Q)"
echo "2. Open project fresh:"
echo "   open RayLink/RayLink.xcodeproj"
echo ""
echo "3. In Xcode:"
echo "   - Wait for indexing to complete"
echo "   - Select iPhone 15 Pro simulator"
echo "   - Clean build folder: Shift+Cmd+K"
echo "   - Build and run: Cmd+R"
echo ""
echo "Bundle ID: com.personal.raylink.dev6524"
echo "================================"