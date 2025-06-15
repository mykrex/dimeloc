import Foundation

// MARK: - Request Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Response Models
struct LoginResponse: Codable {
    let success: Bool
    let message: String?
    let data: UserData?
    let token: String?
}

struct UserData: Codable {
    let id: String
    let nombre: String
    let email: String
    let rol: String
    let telefono: String?
    let activo: Bool
    let fechaRegistro: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nombre, email, rol, telefono, activo
        case fechaRegistro = "fecha_registro"
    }
}

// MARK: - Error Types
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError
    case serverError
    case decodingError
    case invalidURL
    case userNotActive
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Correo o contraseña incorrectos."
        case .networkError:
            return "Error de conexión. Verifica tu internet."
        case .serverError:
            return "Error del servidor. Intenta más tarde."
        case .decodingError:
            return "Error procesando la respuesta."
        case .invalidURL:
            return "URL inválida."
        case .userNotActive:
            return "Usuario inactivo. Contacta al administrador."
        }
    }
}
