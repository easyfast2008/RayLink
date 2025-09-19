import SwiftUI
import Foundation
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
