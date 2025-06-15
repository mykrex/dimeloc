//
//  TiendasAPIClient.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import Foundation

class TiendasAPIClient: ObservableObject {
    private let baseURL = "https://dimeloc-backend.onrender.com/api"
    
    func obtenerTiendas() async throws -> [Tienda] {
        guard let url = URL(string: "\(baseURL)/tiendas") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TiendaResponse.self, from: data)
        
        if response.success {
            return response.data
        } else {
            throw APIError.serverError
        }
    }
    
    func obtenerTiendasProblematicas() async throws -> [Tienda] {
        guard let url = URL(string: "\(baseURL)/tiendas/problematicas") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TiendaResponse.self, from: data)
        
        if response.success {
            return response.data
        } else {
            throw APIError.serverError
        }
    }
}
