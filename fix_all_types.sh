#!/bin/bash

echo "🔧 Fixing all type definitions and imports..."

# Function to add import to a file if it doesn't exist
add_import() {
    local file="$1"
    local import_line="$2"
    
    if [ -f "$file" ]; then
        if ! grep -q "$import_line" "$file"; then
            # Add import after the first import SwiftUI line
            sed -i '' "/import SwiftUI/a\\
$import_line" "$file"
            echo "  ✅ Added import to $(basename "$file")"
        fi
    fi
}

# Add Foundation import to all Swift files that need it
echo "Adding Foundation imports..."
find RayLink -name "*.swift" -type f | while read file; do
    if grep -q "TimeInterval\|Date\|UUID\|URL" "$file" 2>/dev/null; then
        add_import "$file" "import Foundation"
    fi
done

# Add Combine import where needed
echo "Adding Combine imports..."
find RayLink -name "*.swift" -type f | while read file; do
    if grep -q "@Published\|@StateObject\|ObservableObject" "$file" 2>/dev/null; then
        add_import "$file" "import Combine"
    fi
done

# Clean DerivedData
echo ""
echo "🧹 Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/RayLink-*

echo ""
echo "✅ All type fixes applied!"
echo ""
echo "Now please:"
echo "1. Open Xcode"
echo "2. Clean Build Folder (Shift+Cmd+K)"
echo "3. Build (Cmd+B)"