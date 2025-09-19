import SwiftUI
// Global types imported via RayLinkTypes

// Data Usage View
struct DataUsageView: View {
    var body: some View {
        VStack {
            Text("Data Usage")
                .font(.largeTitle)
                .padding()
            
            Text("Track your VPN data usage")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Data Usage")
    }
}

// Trusted Networks View
struct TrustedNetworksView: View {
    var body: some View {
        VStack {
            Text("Trusted Networks")
                .font(.largeTitle)
                .padding()
            
            Text("Manage trusted Wi-Fi networks")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Trusted Networks")
    }
}

// Add Server View
struct AddServerView: View {
    let onSave: (VPNServer) -> Void
    
    var body: some View {
        VStack {
            Text("Add New Server")
                .font(.largeTitle)
                .padding()
            
            Text("Configure a new VPN server")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Add Server")
    }
}