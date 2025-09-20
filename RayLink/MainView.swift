import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                Text("RayLink")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Starter project bootstrapped for further development.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
