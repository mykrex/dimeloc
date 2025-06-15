//
//  TiendasAPIClient.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import Foundation
import SwiftUI

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
    
    // MTODOS PARA FEEDBACK
    func enviarFeedback(tiendaId: Int, feedback: NuevoFeedback) async throws -> FeedbackSubmissionResponse {
        guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/feedback") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(feedback)
        
        print("📤 Enviando feedback a: \(url)")
        print("📝 Payload: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "Error encoding")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Verificar status code HTTP
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                throw APIError.serverError
            }
        }
        
        // Debug: Ver respuesta completa del servidor
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔍 Respuesta del servidor:")
            print(responseString)
        }
        
        // Intentar decodificar la respuesta
        do {
            let submissionResponse = try JSONDecoder().decode(FeedbackSubmissionResponse.self, from: data)
            
            if submissionResponse.success {
                print("✅ Feedback enviado correctamente")
                if let analysis = submissionResponse.analysis {
                    print("🤖 Análisis generado: \(analysis.generated ? "Sí" : "No")")
                    if analysis.generated {
                        print("🎯 Prioridad: \(analysis.priority ?? "N/A")")
                        print("📝 Resumen: \(analysis.summary ?? "N/A")")
                    }
                }
                return submissionResponse
            } else {
                print("❌ Error del servidor: \(submissionResponse.message ?? "Error desconocido")")
                throw APIError.serverError
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            print("❌ Error de decodificación - Campo faltante: \(key)")
            print("📍 Context: \(context)")
            print("📄 JSON recibido: \(String(data: data, encoding: .utf8) ?? "No data")")
            throw APIError.decodingError
        } catch DecodingError.typeMismatch(let type, let context) {
            print("❌ Error de tipo en decodificación: \(type)")
            print("📍 Context: \(context)")
            throw APIError.decodingError
        } catch {
            print("❌ Error general de decodificación: \(error)")
            throw APIError.decodingError
        }
    }
        
        func obtenerFeedback(tiendaId: Int) async throws -> [Feedback] {
            guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/feedback") else {
                throw APIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(FeedbackResponse.self, from: data)
            
            if response.success {
                print("📊 Obtenidos \(response.data.count) comentarios para tienda \(tiendaId)")
                return response.data
            } else {
                throw APIError.serverError
            }
        }
        
        func obtenerInsights(tiendaId: Int) async throws -> [GeminiInsight] {
            guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/insights") else {
                throw APIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(InsightsResponse.self, from: data)
            
            if response.success {
                print("🤖 Obtenidos \(response.data.count) insights para tienda \(tiendaId)")
                return response.data
            } else {
                throw APIError.serverError
            }
        }
        
        func obtenerTiendasConAlertas() async throws -> [TiendaProblematica] {
            guard let url = URL(string: "\(baseURL)/insights/problematicas") else {
                throw APIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TiendasProblematicasResponse.self, from: data)
            
            if response.success {
                print("⚠️ Encontradas \(response.data.count) tiendas con alertas")
                return response.data
            } else {
                throw APIError.serverError
            }
        }
        
        func analizarTiendaManualmente(tiendaId: Int) async throws -> GeminiAnalysis {
            guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/analyze") else {
                throw APIError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(AnalysisResponse.self, from: data)
            
            if response.success {
                print("🔍 Análisis manual completado para tienda \(tiendaId)")
                return response.analysis
            } else {
                throw APIError.serverError
            }
        }
        
        // MÉTODO DE PRUEBA
    func testGemini() async throws -> String {
        guard let url = URL(string: "\(baseURL)/test-gemini") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(GeminiTestResponse.self, from: data)
        
        if response.success {
            return response.analysis
        } else {
            throw APIError.serverError
        }
    }
}
