#!/bin/bash

# Fix RayLink Project Structure and Paths
echo "🔧 Fixing RayLink Project Structure..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Navigate to project directory
cd /Users/alisimacpro/Desktop/RayLink

# Fix the DEVELOPMENT_ASSET_PATHS in the project file
echo "📝 Fixing asset paths in project file..."
sed -i '' 's|DEVELOPMENT_ASSET_PATHS = "\"RayLink/Preview Content\""|DEVELOPMENT_ASSET_PATHS = "\"Preview Content\""|g' RayLink/RayLink.xcodeproj/project.pbxproj

# Ensure Preview Content exists with proper structure
echo "📁 Creating Preview Content directory..."
mkdir -p "RayLink/Preview Content"

# Create Preview Assets if it doesn't exist
if [ ! -f "RayLink/Preview Content/PreviewAssets.xcassets/Contents.json" ]; then
    mkdir -p "RayLink/Preview Content/PreviewAssets.xcassets"
    cat > "RayLink/Preview Content/PreviewAssets.xcassets/Contents.json" << EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    echo -e "${GREEN}✓ Created Preview Assets${NC}"
fi

# Create a sample preview provider file
cat > "RayLink/Preview Content/PreviewProvider.swift" << 'EOF'
import SwiftUI

struct PreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        Text("Preview Content")
            .padding()
    }
}
EOF

# Check if Resources directory exists, if not create it
if [ ! -d "RayLink/Resources" ]; then
    echo "📁 Creating Resources directory..."
    mkdir -p "RayLink/Resources"
fi

# Create Assets.xcassets if it doesn't exist
if [ ! -f "RayLink/Resources/Assets.xcassets/Contents.json" ]; then
    mkdir -p "RayLink/Resources/Assets.xcassets"
    cat > "RayLink/Resources/Assets.xcassets/Contents.json" << EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    
    # Create AppIcon placeholder
    mkdir -p "RayLink/Resources/Assets.xcassets/AppIcon.appiconset"
    cat > "RayLink/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json" << EOF
{
  "images" : [
    {
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
    
    # Create AccentColor
    mkdir -p "RayLink/Resources/Assets.xcassets/AccentColor.colorset"
    cat > "RayLink/Resources/Assets.xcassets/AccentColor.colorset/Contents.json" << EOF
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0xFF",
          "green" : "0x66",
          "red" : "0x00"
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
    echo -e "${GREEN}✓ Created Assets catalog${NC}"
fi

# Update the ASSETCATALOG_COMPILER_APPICON_NAME if needed
echo "🔧 Updating project settings..."
sed -i '' 's|ASSETCATALOG_COMPILER_APPICON_NAME = .*|ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;|g' RayLink/RayLink.xcodeproj/project.pbxproj

# Remove NetworkExtension references if present (for personal Apple ID)
echo "🔧 Removing VPN capabilities for personal Apple ID..."
sed -i '' '/com.apple.developer.networking.networkextension/d' RayLink/RayLink.xcodeproj/project.pbxproj
sed -i '' '/SystemCapabilities/,/};/d' RayLink/RayLink.xcodeproj/project.pbxproj

# Fix bundle identifier to be unique
echo "🔧 Setting unique bundle identifier..."
TIMESTAMP=$(date +%s)
sed -i '' "s|PRODUCT_BUNDLE_IDENTIFIER = .*|PRODUCT_BUNDLE_IDENTIFIER = com.personal.raylink.dev${TIMESTAMP:(-4)};|g" RayLink/RayLink.xcodeproj/project.pbxproj

# Clean derived data
echo "🧹 Cleaning build cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/RayLink-*

echo ""
echo "=============================="
echo -e "${GREEN}✅ Project fixed!${NC}"
echo ""
echo "Next steps:"
echo "1. Open the project:"
echo "   open RayLink/RayLink.xcodeproj"
echo ""
echo "2. In Xcode:"
echo "   - Select your personal Apple ID team"
echo "   - The bundle ID has been set to: com.personal.raylink.dev$(echo ${TIMESTAMP:(-4)})"
echo "   - Build and run (Cmd+R)"
echo ""
echo -e "${YELLOW}Note:${NC} VPN capabilities have been removed for personal Apple ID compatibility"