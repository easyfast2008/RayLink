#!/bin/bash

echo "📦 Installing RayLink Dependencies"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "This script will help you add the CodeScanner dependency to your project."
echo ""

echo "Option 1: Add CodeScanner via Swift Package Manager (Recommended)"
echo "================================================================"
echo ""
echo "1. In Xcode, go to File → Add Package Dependencies"
echo "2. Enter this URL: https://github.com/twostraws/CodeScanner"
echo "3. Click 'Add Package'"
echo "4. Select 'CodeScanner' and click 'Add Package'"
echo ""
echo "Option 2: Use Mock Implementation (For Testing)"
echo "=============================================="
echo ""

read -p "Would you like to use the mock implementation instead? (y/n): " use_mock

if [ "$use_mock" = "y" ] || [ "$use_mock" = "Y" ]; then
    echo ""
    echo "Creating mock QR scanner..."
    
    # Create a mock QRCodeScannerView
    cat > /Users/alisimacpro/Desktop/RayLink/RayLink/Features/Import/QRCodeScannerView.swift << 'EOF'
import SwiftUI
import AVFoundation

// Mock QR Scanner for builds without CodeScanner dependency
struct QRCodeScannerView: View {
    let completion: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var mockCode = ""
    @State private var showingMockInput = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Camera preview placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppTheme.AuroraGradients.primary, lineWidth: 2)
                        )
                    
                    VStack(spacing: 20) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("QR Scanner")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("(Mock Mode - Camera not available)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 300)
                .padding()
                
                // Manual input for testing
                VStack(spacing: 16) {
                    Text("Enter server URL manually for testing:")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    TextField("vless://...", text: $mockCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !mockCode.isEmpty {
                            completion(mockCode)
                            dismiss()
                        }
                    }) {
                        Text("Import")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.AuroraGradients.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(mockCode.isEmpty)
                }
                
                Spacer()
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// For compatibility with CodeScanner API if needed
struct CodeScannerView: View {
    let codeTypes: [AVMetadataObject.ObjectType]
    let simulatedData: String?
    let completion: (Result<String, Error>) -> Void
    
    init(codeTypes: [AVMetadataObject.ObjectType] = [.qr], 
         simulatedData: String? = nil, 
         completion: @escaping (Result<String, Error>) -> Void) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.completion = completion
    }
    
    var body: some View {
        QRCodeScannerView { code in
            completion(.success(code))
        }
    }
}

enum ScanError: Error {
    case cancelled
    case failed
}
EOF
    
    echo -e "${GREEN}✅ Created mock QR scanner${NC}"
    echo ""
    
    # Update ImportView to use the mock
    sed -i '' 's|// import CodeScanner|// import CodeScanner - Using mock implementation|' /Users/alisimacpro/Desktop/RayLink/RayLink/Features/Import/ImportView.swift
    
    echo -e "${GREEN}✅ Mock implementation ready!${NC}"
    echo ""
    echo "The app will now build with a mock QR scanner that allows manual URL input."
    
else
    echo ""
    echo -e "${YELLOW}Instructions to add CodeScanner:${NC}"
    echo ""
    echo "1. Open Xcode"
    echo "2. Go to File → Add Package Dependencies"
    echo "3. Enter: https://github.com/twostraws/CodeScanner"
    echo "4. Click 'Add Package'"
    echo "5. Select your app target and click 'Add Package'"
    echo ""
    echo "After adding the package, uncomment the import statement:"
    echo "   Change: // import CodeScanner"
    echo "   To:     import CodeScanner"
fi

echo ""
echo "=================================="
echo "✅ Setup Complete!"
echo ""
echo "Now you can build the app:"
echo "1. Clean Build Folder: Shift+Cmd+K"
echo "2. Build: Cmd+B"