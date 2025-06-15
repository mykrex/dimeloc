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
    case serverError      // ← SIN parámetros
    case decodingError
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .serverError:
            return "Error del servidor"
        case .decodingError:
            return "Error al procesar datos"
        case .networkError:
            return "Error de conexión"
        }
    }
}

struct BasicResponse: Codable {
    let success: Bool
    let message: String?
}

struct TiendasProblematicasResponse: Codable {
    let success: Bool
    let count: Int
    let data: [TiendaProblematica]
    let message: String
}

struct TiendaProblematica: Codable, Identifiable {
    let id = UUID()
    let tiendaId: Int
    let tiendaNombre: String
    let alertas: [String]
    let resumen: String
    let fechaAnalisis: String
    let totalComentarios: Int
    
    enum CodingKeys: String, CodingKey {
        case tiendaId = "tienda_id"
        case tiendaNombre = "tienda_nombre"
        case alertas, resumen
        case fechaAnalisis = "fecha_analisis"
        case totalComentarios = "total_comentarios"
    }
}

struct ErrorResponse: Codable {
    let success: Bool
    let error: String
}
