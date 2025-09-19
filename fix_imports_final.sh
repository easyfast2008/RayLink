#!/bin/bash

echo "🔧 Fixing malformed imports..."

# Fix SettingsView.swift
if [ -f "RayLink/Features/Settings/SettingsView.swift" ]; then
    sed -i '' 's/import Combineimport Foundation/import Combine\
import Foundation/' "RayLink/Features/Settings/SettingsView.swift"
    echo "✅ Fixed SettingsView.swift"
fi

# Fix SettingsViewModel.swift
if [ -f "RayLink/Features/Settings/SettingsViewModel.swift" ]; then
    sed -i '' 's/import Combineimport StoreKit/import Combine\
import StoreKit/' "RayLink/Features/Settings/SettingsViewModel.swift"
    echo "✅ Fixed SettingsViewModel.swift"
fi

# Fix NewSettingsView.swift
if [ -f "RayLink/Features/Settings/NewSettingsView.swift" ]; then
    sed -i '' 's/import Combineimport Foundation/import Combine\
import Foundation/' "RayLink/Features/Settings/NewSettingsView.swift"
    echo "✅ Fixed NewSettingsView.swift"
fi

# Fix HomeView.swift
if [ -f "RayLink/Features/Home/HomeView.swift" ]; then
    sed -i '' 's/import Foundation\/\/ Global types/import Foundation\
\/\/ Global types/' "RayLink/Features/Home/HomeView.swift"
    echo "✅ Fixed HomeView.swift"
fi

# Fix QRCodeScannerView.swift
if [ -f "RayLink/Features/Import/QRCodeScannerView.swift" ]; then
    sed -i '' 's/import Foundationimport AVFoundation/import Foundation\
import AVFoundation/' "RayLink/Features/Import/QRCodeScannerView.swift"
    echo "✅ Fixed QRCodeScannerView.swift"
fi

# Fix ImportView.swift
if [ -f "RayLink/Features/Import/ImportView.swift" ]; then
    sed -i '' 's/import Combineimport Foundation/import Combine\
import Foundation/' "RayLink/Features/Import/ImportView.swift"
    echo "✅ Fixed ImportView.swift"
fi

echo ""
echo "✅ All import issues fixed!"
echo ""
echo "Now clean and rebuild in Xcode."