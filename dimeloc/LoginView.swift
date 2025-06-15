import SwiftUI

struct LoginView: View {
    var onLogin: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Log In")
                .font(.title)
                .padding()
            Button("Go to Home", action: onLogin)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoginView(onLogin: {})
}
