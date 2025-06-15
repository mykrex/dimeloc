import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !authManager.isAuthenticated {
                LoginView()
                    .transition(.opacity)
                    .environmentObject(authManager)
            } else {
                MainView()
                    .transition(.opacity)
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
