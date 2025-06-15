import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack {
                Image("dimeloc")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 180) // Adjust size as needed
            }
            .frame(width: 280, height: 55.91985)
        }
        .padding(.horizontal, 75)
        .padding(.top, 424)
        .padding(.bottom, 452.08014)
        .frame(width: 430, height: 932, alignment: .top)
        .background(Color(red: 1, green: 0.29, blue: 0.2))
    }
}

#Preview {
    SplashView()
}
