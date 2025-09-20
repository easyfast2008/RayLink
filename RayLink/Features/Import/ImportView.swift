import SwiftUI
import Combine
import Foundation
// Global types imported via RayLinkTypes
import UniformTypeIdentifiers
// import CodeScanner - Using mock implementation // Commented out for personal Apple ID build

struct ImportView: View {
    @StateObject private var viewModel = ImportViewModel()
    @EnvironmentObject private var container: DependencyContainer
    @State private var showingDocumentPicker = false
    @State private var showingFilePicker = false
    @State private var showingQRScanner = false
    @State private var subscriptionURL = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    importMethodsSection
                    
                    if !viewModel.importedServers.isEmpty {
                        previewSection
                    }
                    
                    if viewModel.isImporting {
                        importingSection
                    }
                }
                .padding()
            }
            .navigationTitle("Import Servers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.importedServers.isEmpty {
                        Button("Import All") {
                            Task {
                                await viewModel.importAllServers()
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.setup(
                    networkService: container.networkService,
                    storageManager: container.storageManager
                )
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { url in
                    Task {
                        await viewModel.importFromFile(url)
                    }
                }
            }
            .sheet(isPresented: $showingQRScanner) {
                QRCodeScannerView { result in
                    Task {
                        await viewModel.importFromQRCode(result)
                    }
                    showingQRScanner = false
                }
            }
            .alert("Import Result", isPresented: $viewModel.showResult) {
                Button("OK") { }
            } message: {
                Text(viewModel.resultMessage)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.accent)
            
            Text("Import VPN Servers")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("Import servers from subscription URLs, configuration files, or clipboard")
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(16)
    }
    
    private var importMethodsSection: some View {
        VStack(spacing: 16) {
            Text("Import Methods")
                .font(.headline)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                importMethodCard(
                    title: "Subscription URL",
                    description: "Import from HTTP/HTTPS subscription",
                    icon: "link",
                    action: {
                        showSubscriptionURLDialog()
                    }
                )
                
                importMethodCard(
                    title: "Configuration File",
                    description: "Import from JSON, YAML, or config files",
                    icon: "doc",
                    action: {
                        showingDocumentPicker = true
                    }
                )
                
                importMethodCard(
                    title: "Clipboard",
                    description: "Import from copied configuration",
                    icon: "doc.on.clipboard",
                    action: {
                        Task {
                            await viewModel.importFromClipboard()
                        }
                    }
                )
                
                importMethodCard(
                    title: "QR Code",
                    description: "Scan QR code containing server config",
                    icon: "qrcode.viewfinder",
                    action: {
                        showingQRScanner = true
                    }
                )
            }
        }
    }
    
    private func importMethodCard(title: String, description: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(AppTheme.Colors.accent)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.Colors.accent.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            .padding()
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Preview (\(viewModel.importedServers.count) servers)")
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Spacer()
                
                Button("Clear") {
                    viewModel.clearImportedServers()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.importedServers.prefix(5)) { server in
                    ImportedServerRowView(server: server)
                }
                
                if viewModel.importedServers.count > 5 {
                    Text("And \(viewModel.importedServers.count - 5) more...")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.secondary)
                        .padding()
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(12)
    }
    
    private var importingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Importing servers...")
                .font(.headline)
                .foregroundColor(AppTheme.Colors.primary)
            
            if !viewModel.importStatus.isEmpty {
                Text(viewModel.importStatus)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
        }
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(12)
    }
    
    private func showSubscriptionURLDialog() {
        let alert = UIAlertController(
            title: "Import from Subscription",
            message: "Enter the subscription URL",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "https://example.com/subscription"
            textField.text = subscriptionURL
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Import", style: .default) { _ in
            if let url = alert.textFields?.first?.text, !url.isEmpty {
                subscriptionURL = url
                Task {
                    await viewModel.importFromSubscription(url)
                }
            }
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

struct ImportedServerRowView: View {
    let server: VPNServer
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("\(server.address):\(server.port)")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            
            Spacer()
            
            Text(server.serverProtocol.rawValue.uppercased())
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(protocolColor.opacity(0.2))
                .foregroundColor(protocolColor)
                .cornerRadius(4)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppTheme.Colors.background)
        .cornerRadius(8)
    }
    
    private var protocolColor: Color {
        switch server.serverProtocol {
        case .shadowsocks:
            return .blue
        case .vmess, .vless:
            return .purple
        case .trojan:
            return .red
        case .ikev2:
            return .orange
        case .wireguard:
            return .green
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            UTType.json,
            UTType.yaml,
            UTType.text,
            UTType.plainText
        ])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onDocumentPicked(url)
        }
    }
}