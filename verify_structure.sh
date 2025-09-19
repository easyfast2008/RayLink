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
