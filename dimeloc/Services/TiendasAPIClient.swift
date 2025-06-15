//
//  TiendasAPIClient.swift
//  dimeloc
//
//  APIClient limpio sin errores de compilación
//

import Foundation
import SwiftUI

class TiendasAPIClient: ObservableObject {
    private let baseURL = "https://dimeloc-backend.onrender.com/api"
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        return URLSession(configuration: config)
    }()
    
    // MARK: - Métodos Básicos que SÍ funcionan
    
    func obtenerTiendas() async throws -> [Tienda] {
        guard let url = URL(string: "\(baseURL)/tiendas") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📡 Status obtenerTiendas: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            throw APIError.serverError
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(TiendaResponse.self, from: data)
            
            if apiResponse.success {
                print("✅ Obtenidas \(apiResponse.data.count) tiendas")
                return apiResponse.data
            } else {
                print("❌ Error del servidor: \(apiResponse.error ?? "Error desconocido")")
                throw APIError.serverError
            }
        } catch {
            print("❌ Error decodificando tiendas: \(error)")
            throw APIError.decodingError
        }
    }
    
    func obtenerTiendasProblematicas() async throws -> [Tienda] {
        guard let url = URL(string: "\(baseURL)/tiendas/problematicas") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let apiResponse = try JSONDecoder().decode(TiendaResponse.self, from: data)
        
        if apiResponse.success {
            print("⚠️ Obtenidas \(apiResponse.data.count) tiendas problemáticas")
            return apiResponse.data
        } else {
            throw APIError.serverError
        }
    }
    
    func enviarFeedback(tiendaId: Int, feedback: NuevoFeedback) async throws -> FeedbackSubmissionResponse {
        guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/feedback") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(feedback)
        
        print("📤 Enviando feedback a tienda \(tiendaId)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Error HTTP enviando feedback")
            throw APIError.serverError
        }
        
        let submissionResponse = try JSONDecoder().decode(FeedbackSubmissionResponse.self, from: data)
        
        if submissionResponse.success {
            print("✅ Feedback enviado correctamente")
            if let analysis = submissionResponse.analysis, analysis.generated {
                print("🤖 Análisis generado - Prioridad: \(analysis.priority ?? "N/A")")
            }
        }
        
        return submissionResponse
    }
    
    func obtenerFeedback(tiendaId: Int) async throws -> [Feedback] {
        guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/feedback") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
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
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(InsightsResponse.self, from: data)
        
        if response.success {
            print("🤖 Obtenidos \(response.data.count) insights para tienda \(tiendaId)")
            return response.data
        } else {
            throw APIError.serverError
        }
    }
    
    func healthCheck() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return false
            }
            
            let healthResponse = try JSONDecoder().decode(BasicResponse.self, from: data)
            return healthResponse.success
        } catch {
            print("❌ Health check falló: \(error)")
            return false
        }
    }
    
    // MARK: - Método de testing simple
    func quickTest() async {
        print("🧪 === INICIANDO TEST RÁPIDO ===")
        
        // Test 1: Health Check
        print("\n1. Health Check...")
        do {
            let isHealthy = try await healthCheck()
            print(isHealthy ? "✅ Health Check: OK" : "❌ Health Check: FAIL")
        } catch {
            print("❌ Health Check Error: \(error.localizedDescription)")
        }
        
        // Test 2: Obtener tiendas
        print("\n2. Obteniendo tiendas...")
        do {
            let tiendas = try await obtenerTiendas()
            print("✅ Tiendas obtenidas: \(tiendas.count)")
            
            if let primera = tiendas.first {
                print("   📍 Primera tienda: \(primera.nombre)")
                print("   📊 NPS: \(primera.nps)")
            }
        } catch {
            print("❌ Error obteniendo tiendas: \(error.localizedDescription)")
        }
        
        print("\n🏁 === TEST RÁPIDO COMPLETADO ===")
    }
    
    func getConnectionInfo() async -> (isConnected: Bool, latency: TimeInterval?) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let isHealthy = try await healthCheck()
            let latency = CFAbsoluteTimeGetCurrent() - startTime
            return (isHealthy, latency)
        } catch {
            return (false, nil)
        }
    }
}
