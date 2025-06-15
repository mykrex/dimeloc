import SwiftUI

struct LoginView: View {
    var onLogin: () -> Void

    @StateObject private var authManager = AuthManager()
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 60) {
            Text("Login")
                .font(.system(size: 40, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.14))
                .frame(maxWidth: .infinity, alignment: .top)

            VStack(alignment: .center, spacing: 30) {
                VStack(alignment: .trailing, spacing: 12) {
                    inputField(title: "Correo", text: $email, placeholder: "Ingresa tu correo", isSecure: false)
                    inputField(title: "Contraseña", text: $password, placeholder: "Ingresa tu contraseña", isSecure: true)

                    if let error = authManager.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .topTrailing)

                Button(action: handleLogin) {
                    HStack(alignment: .center, spacing: 8) {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Inicia sesión")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(red: 1, green: 0.29, blue: 0.2))
                    .cornerRadius(Constants.Style.RadiusFull)
                }
                .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                .opacity(authManager.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .top)
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                onLogin()
            }
        }
    }

    private func handleLogin() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validaciones locales (mantener la misma lógica visual)
        if trimmedEmail.isEmpty && trimmedPassword.isEmpty {
            authManager.errorMessage = "Necesitas ingresar tus datos."
            return
        } else if trimmedEmail.isEmpty {
            authManager.errorMessage = "Falta el correo electrónico."
            return
        } else if trimmedPassword.isEmpty {
            authManager.errorMessage = "Falta la contraseña."
            return
        }

        // Limpiar errores y hacer login real
        authManager.clearError()
        
        Task {
            await authManager.login(email: trimmedEmail, password: trimmedPassword)
        }
    }

    @ViewBuilder
    private func inputField(title: String, text: Binding<String>, placeholder: String, isSecure: Bool) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(alignment: .center, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .kerning(0.14)
                    .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.14))
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .center, spacing: 8) {
                if isSecure {
                    SecureField("", text: text, prompt: Text(placeholder)
                        .font(.system(size: 14))
                        .kerning(0.14)
                        .foregroundColor(Constants.Style.NeutralN400))
                } else {
                    TextField("", text: text, prompt: Text(placeholder)
                        .font(.system(size: 14))
                        .kerning(0.14)
                        .foregroundColor(Constants.Style.NeutralN400))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Constants.Style.ShadeWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.75)
                    .stroke(Constants.Style.NeutralN200, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    LoginView(onLogin: {})
}
