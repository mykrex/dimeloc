import SwiftUI

struct LoginView: View {
    var onLogin: () -> Void

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 60) {
            Text("Login")
                .font(
                    Font.custom("Rethink Sans", size: 40)
                        .weight(.bold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.14))
                .frame(maxWidth: .infinity, alignment: .top)

            VStack(alignment: .center, spacing: 30) {
                VStack(alignment: .trailing, spacing: 12) {
                    inputField(title: "Correo", text: $email, placeholder: "Ingresa tu correo", isSecure: false)

                    inputField(title: "Contrase\u00f1a", text: $password, placeholder: "Ingresa tu contrase\u00f1a", isSecure: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 0)
                .frame(maxWidth: .infinity, alignment: .topTrailing)

                Button(action: onLogin) {
                    HStack(alignment: .center, spacing: 8) {
                        Text("Inicia sesi\u00f3n")
                            .font(Font.custom("Rethink Sans", size: 14).weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(red: 1, green: 0.29, blue: 0.2))
                    .cornerRadius(Constants.RadiusFull)
                }
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .padding(0)
        .frame(width: 390, alignment: .top)
    }

    @ViewBuilder
    private func inputField(title: String, text: Binding<String>, placeholder: String, isSecure: Bool) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(alignment: .center, spacing: 6) {
                Text(title)
                    .font(
                        Font.custom("Rethink Sans", size: 14)
                            .weight(.bold)
                    )
                    .kerning(0.14)
                    .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.14))
                Spacer()
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .center, spacing: 8) {
                if isSecure {
                    SecureField("", text: text, prompt: Text(placeholder)
                        .font(Font.custom("Rethink Sans", size: 14))
                        .kerning(0.14)
                        .foregroundColor(Constants.NeutralN400)
                        .frame(maxWidth: .infinity, alignment: .topLeading))
                } else {
                    TextField("", text: text, prompt: Text(placeholder)
                        .font(Font.custom("Rethink Sans", size: 14))
                        .kerning(0.14)
                        .foregroundColor(Constants.NeutralN400)
                        .frame(maxWidth: .infinity, alignment: .topLeading))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Constants.ShadeWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.75)
                    .stroke(Constants.NeutralN200, lineWidth: 1.5)
            )
        }
        .padding(0)
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
}

struct Constants {
    static let ShadeWhite: Color = .white
    static let NeutralN200: Color = Color(red: 0.89, green: 0.91, blue: 0.94)
    static let NeutralN400: Color = Color(red: 0.58, green: 0.64, blue: 0.72)
    static let RadiusFull: CGFloat = 9999
}

#Preview {
    LoginView(onLogin: {})
}
