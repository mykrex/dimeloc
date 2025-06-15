import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authClient = AuthAPIClient()
    private let tokenKey = "dimeloc_auth_token"
    
    init() {
        checkAuthStatus()
    }
    
    // MARK: - Login
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authClient.login(email: email, password: password)
            
            if let token = response.token, let userData = response.data {
                UserDefaults.standard.set(token, forKey: tokenKey)
                currentUser = userData
                isAuthenticated = true
                print("✅ Login completado - Usuario: \(userData.nombre)")
            } else {
                errorMessage = "Error en la respuesta del servidor"
            }
        } catch let error as AuthError {
            errorMessage = error.errorDescription
            print("❌ Error de autenticación: \(error.errorDescription ?? "Unknown")")
        } catch {
            errorMessage = "Error inesperado"
            print("❌ Error inesperado: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
        print("👋 Usuario desconectado")
    }
    
    // MARK: - Check Auth Status
    private func checkAuthStatus() {
        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
            print("🔍 No hay token guardado")
            return
        }
        
        print("🔍 Token encontrado, validando...")
        
        Task {
            do {
                let userData = try await authClient.validateToken(token)
                currentUser = userData
                isAuthenticated = true
                print("✅ Token válido - Usuario: \(userData.nombre)")
            } catch {
                print("❌ Token inválido, eliminando...")
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    // MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
}
