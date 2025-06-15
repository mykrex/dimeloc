//
//  AuthAPIClient.swift
//  dimeloc
//

import Foundation
import SwiftUI

class AuthAPIClient: ObservableObject {
    private let baseURL = "https://dimeloc-backend.onrender.com/api"
    
    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            password: password.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(loginRequest)
        } catch {
            print("❌ Error encoding login request: \(error)")
            throw AuthError.decodingError
        }
        
        print("📤 Enviando login a: \(url)")
        print("📝 Email: \(loginRequest.email)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 Respuesta del servidor:")
                    print(responseString)
                }
                
                switch httpResponse.statusCode {
                case 200:
                    break
                case 401:
                    throw AuthError.invalidCredentials
                case 403:
                    throw AuthError.userNotActive
                case 500...599:
                    throw AuthError.serverError
                default:
                    throw AuthError.networkError
                }
            }
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            if loginResponse.success {
                print("✅ Login exitoso")
                if let userData = loginResponse.data {
                    print("👤 Usuario: \(userData.nombre) - \(userData.rol)")
                }
                return loginResponse
            } else {
                print("❌ Error del servidor: \(loginResponse.message ?? "Error desconocido")")
                throw AuthError.invalidCredentials
            }
            
        } catch {
            if error is AuthError {
                throw error
            }
            print("❌ Error de red: \(error)")
            throw AuthError.networkError
        }
    }
    
    func validateToken(_ token: String) async throws -> UserData {
        guard let url = URL(string: "\(baseURL)/auth/validate") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                throw AuthError.invalidCredentials
            }
        }
        
        let validationResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        if validationResponse.success, let userData = validationResponse.data {
            return userData
        } else {
            throw AuthError.invalidCredentials
        }
    }
}
