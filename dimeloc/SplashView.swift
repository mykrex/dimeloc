import SwiftUI

struct SplashView: View {
    var body: some View {
        Text("Splash")
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
}

#Preview {
    SplashView()
}
