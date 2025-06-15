//
//  TiendaResponse.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import Foundation

struct TiendaResponse: Codable {
    let success: Bool
    let count: Int?
    let data: [Tienda]
}

enum APIError: Error {
    case invalidURL
    case serverError
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "URL inválida"
        case .serverError: return "Error del servidor"
        case .decodingError: return "Error al procesar datos"
        }
    }
}
