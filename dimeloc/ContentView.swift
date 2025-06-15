import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var loggedIn = false

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !loggedIn {
                LoginView(onLogin: { loggedIn = true })
                    .transition(.opacity)
            } else {
                MainView()
                    .transition(.opacity)
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
