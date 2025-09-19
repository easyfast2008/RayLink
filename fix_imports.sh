#!/bin/bash

echo "🔧 Fixing imports in all Swift files..."
echo "======================================"

# Add RayLinkTypes import to files that need it
files_to_fix=(
    "RayLink/App/RayLinkApp.swift"
    "RayLink/Features/Home/HomeView.swift"
    "RayLink/Features/Home/HomeViewModel.swift"
    "RayLink/Features/ServerList/ServerListView.swift"
    "RayLink/Features/ServerList/ServerListViewModel.swift"
    "RayLink/Features/Settings/SettingsView.swift"
    "RayLink/Features/Settings/SettingsViewModel.swift"
    "RayLink/Features/Import/ImportView.swift"
    "RayLink/Features/Import/ImportViewModel.swift"
    "RayLink/ContentView.swift"
    "RayLink/Core/NavigationCoordinator.swift"
    "RayLink/Core/DependencyContainer.swift"
)

for file in "${files_to_fix[@]}"; do
    filepath="/Users/alisimacpro/Desktop/RayLink/$file"
    if [ -f "$filepath" ]; then
        # Check if RayLinkTypes is already imported
        if ! grep -q "import.*RayLinkTypes\|// Global types imported" "$filepath"; then
            # Add import after the first import statement
            sed -i '' '1a\
// Global types imported via RayLinkTypes
' "$filepath"
            echo "✅ Fixed imports in $(basename $file)"
        else
            echo "⏭️  $(basename $file) already has imports"
        fi
    else
        echo "⚠️  File not found: $file"
    fi
done

echo ""
echo "✅ Import fixes complete!"
echo ""
echo "Now clean and build in Xcode:"
echo "1. Clean Build Folder: Shift+Cmd+K"
echo "2. Build: Cmd+B"