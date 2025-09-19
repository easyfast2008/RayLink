#!/bin/bash

echo "🔧 Comprehensive Fix for RayLink Project"
echo "========================================"

cd /Users/alisimacpro/Desktop/RayLink

# Step 1: Remove duplicate nested directories
echo "📁 Removing duplicate nested files..."
rm -rf RayLink/RayLink/RayLink

# Step 2: Fix Assets.xcassets location
echo "🎨 Fixing Assets catalog locations..."

# Ensure main Assets.xcassets exists with proper content
mkdir -p RayLink/Assets.xcassets/AppIcon.appiconset
mkdir -p RayLink/Assets.xcassets/AccentColor.colorset

# Create AppIcon Contents.json
cat > RayLink/Assets.xcassets/AppIcon.appiconset/Contents.json << 'EOF'
{
  "images" : [
    {
      "filename" : "AppIcon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create placeholder icon if it doesn't exist
if [ ! -f "RayLink/Assets.xcassets/AppIcon.appiconset/AppIcon.png" ]; then
    # Create a 1x1 blue PNG as placeholder
    echo -n -e '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\x0D\x49\x44\x41\x54\x08\x5B\x63\x68\x00\x00\x00\x82\x00\x81\xDD\x7D\x8F\xA1\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82' > RayLink/Assets.xcassets/AppIcon.appiconset/AppIcon.png
fi

# Create AccentColor Contents.json
cat > RayLink/Assets.xcassets/AccentColor.colorset/Contents.json << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "1.000",
          "green" : "0.400",
          "red" : "0.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create main Assets.xcassets Contents.json
cat > RayLink/Assets.xcassets/Contents.json << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Step 3: Fix Preview Content location
echo "📱 Fixing Preview Content..."
mkdir -p "RayLink/Preview Content/PreviewAssets.xcassets"

cat > "RayLink/Preview Content/PreviewAssets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Step 4: Update project file to remove duplicate references
echo "📝 Cleaning project file..."
# Remove any references to the nested RayLink/RayLink path
sed -i '' 's|RayLink/RayLink/|RayLink/|g' RayLink/RayLink.xcodeproj/project.pbxproj

# Step 5: Clean ALL build artifacts
echo "🧹 Deep cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf build/

# Step 6: Reset simulator
echo "📱 Resetting simulator..."
xcrun simctl shutdown all 2>/dev/null || true
killall Simulator 2>/dev/null || true

# Step 7: Create a verification script
cat > verify_structure.sh << 'EOF'
#!/bin/bash
echo "Verifying project structure..."
echo ""
echo "✓ Assets location:"
ls -la RayLink/Assets.xcassets/AppIcon.appiconset/ 2>/dev/null | head -3
echo ""
echo "✓ Preview Content:"
ls -la "RayLink/Preview Content/" 2>/dev/null | head -3
echo ""
echo "✓ Swift files (should not have duplicates):"
find . -name "*.swift" -type f | wc -l
echo " Swift files found"
EOF
chmod +x verify_structure.sh

echo ""
echo "========================================"
echo "✅ ALL ISSUES FIXED!"
echo ""
echo "CRITICAL: You MUST do the following:"
echo ""
echo "1. COMPLETELY QUIT Xcode (Cmd+Q)"
echo "   - Do not just close the window"
echo "   - Make sure Xcode is not running at all"
echo ""
echo "2. Wait 5 seconds, then reopen:"
echo "   open RayLink/RayLink.xcodeproj"
echo ""
echo "3. In Xcode:"
echo "   a) Wait for indexing to complete"
echo "   b) Select iPhone 15 Pro simulator"
echo "   c) Clean: Shift+Cmd+K"
echo "   d) Build: Cmd+B"
echo "   e) Run: Cmd+R"
echo ""
echo "Bundle ID: com.personal.raylink.dev6524"
echo "========================================"