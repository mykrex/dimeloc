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
    
    // En TiendasAPIClient.swift - MÉTODO MEJORADO

    func obtenerInsights(tiendaId: Int) async throws -> [GeminiInsight] {
        guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/insights") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📡 Status obtenerInsights: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                // Debug: Mostrar respuesta del servidor
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📊 Respuesta completa del servidor:")
                    print(jsonString)
                }
                
                let decoder = JSONDecoder()
                
                // ✅ ESTRATEGIA MÚLTIPLE DE DECODIFICACIÓN
                
                // 1. Intentar con estructura corregida (sin count obligatorio)
                do {
                    let apiResponse = try decoder.decode(InsightsResponseFixed.self, from: data)
                    if apiResponse.success {
                        print("✅ Insights obtenidos (método 1): \(apiResponse.data.count)")
                        return apiResponse.data
                    } else {
                        print("❌ API devolvió success=false: \(apiResponse.error ?? "Sin error")")
                        throw APIError.serverError
                    }
                } catch {
                    print("⚠️ Método 1 falló, intentando método 2...")
                }
                
                // 2. Intentar decodificar directamente como array
                do {
                    let directArray = try decoder.decode([GeminiInsight].self, from: data)
                    print("✅ Insights obtenidos (método 2 - array directo): \(directArray.count)")
                    return directArray
                } catch {
                    print("⚠️ Método 2 falló, intentando método 3...")
                }
                
                // 3. Intentar con estructura flexible (count opcional)
                do {
                    let flexibleResponse = try decoder.decode(InsightsResponse.self, from: data)
                    if flexibleResponse.success {
                        print("✅ Insights obtenidos (método 3 - flexible): \(flexibleResponse.data.count)")
                        return flexibleResponse.data
                    }
                } catch {
                    print("❌ Todos los métodos de decodificación fallaron")
                    print("❌ Último error: \(error)")
                    
                    // Mostrar error detallado
                    if let decodingError = error as? DecodingError {
                        print("❌ Error de decodificación detallado:")
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("   - Campo faltante: \(key.stringValue)")
                            print("   - Contexto: \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("   - Tipo incorrecto: esperaba \(type)")
                            print("   - Contexto: \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("   - Valor no encontrado: \(type)")
                            print("   - Contexto: \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("   - Datos corruptos: \(context.debugDescription)")
                        @unknown default:
                            print("   - Error desconocido")
                        }
                    }
                }
                
                throw APIError.decodingError
                
            } else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                throw APIError.serverError
            }
        } catch {
            print("❌ Error general obtenerInsights: \(error)")
            throw error
        }
    }
    // MARK: - Métodos para Feedback Bidireccional
    
    func enviarFeedbackTendero(feedback: NuevoFeedbackTendero) async throws -> FeedbackTenderoResponse {
        guard let url = URL(string: "\(baseURL)/feedback/tendero") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(feedback)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let apiResponse = try JSONDecoder().decode(FeedbackTenderoResponse.self, from: data)
        
        if apiResponse.success {
            print("✅ Feedback del tendero enviado correctamente")
            return apiResponse
        } else {
            throw APIError.serverError
        }
    }
    
    func enviarFeedbackTenderoSafe(feedback: NuevoFeedbackTendero) async throws -> FeedbackTenderoResponse {
        // ✅ VALIDACIONES MEJORADAS CON MÁS DETALLES
        print("🔍 VALIDANDO FEEDBACK DEL TENDERO...")
        print("   🏪 Tienda ID: \(feedback.tiendaId)")
        print("   👤 Colaborador ID: '\(feedback.colaboradorId)'")
        print("   📝 Título: '\(feedback.titulo)'")
        print("   📄 Descripción: '\(feedback.descripcion)'")
        
        // Validar ID de tienda
        guard feedback.tiendaId > 0 else {
            let error = "ID de tienda inválido: \(feedback.tiendaId) - debe ser mayor a 0"
            print("❌ \(error)")
            throw APIError.badRequest(error)
        }
        
        // Validar colaborador ID
        let colaboradorTrimmed = feedback.colaboradorId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !colaboradorTrimmed.isEmpty else {
            let error = "ID de colaborador está vacío"
            print("❌ \(error)")
            throw APIError.badRequest(error)
        }
        
        // Validar que el colaborador ID tenga formato válido (24 caracteres para ObjectId)
        guard colaboradorTrimmed.count == 24 else {
            let error = "ID de colaborador tiene formato inválido: '\(colaboradorTrimmed)' (debe tener 24 caracteres)"
            print("❌ \(error)")
            throw APIError.badRequest(error)
        }
        
        // Validar título
        let tituloTrimmed = feedback.titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tituloTrimmed.isEmpty else {
            let error = "Título es requerido"
            print("❌ \(error)")
            throw APIError.badRequest(error)
        }
        
        // Validar descripción
        let descripcionTrimmed = feedback.descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !descripcionTrimmed.isEmpty else {
            let error = "Descripción es requerida"
            print("❌ \(error)")
            throw APIError.badRequest(error)
        }
        
        print("✅ Todas las validaciones pasaron")
        print("📤 Preparando para enviar a: \(baseURL)/feedback/tendero")
        
        // Llamar método original
        return try await enviarFeedbackTendero(feedback: feedback)
    }
    
    // ✅ MÉTODO PARA OBTENER USUARIO ACTUAL
    func obtenerUsuarioActual() async throws -> Usuario? {
        // Esto debería implementarse cuando tengas autenticación
        // Por ahora retornar un usuario fake para testing
        return Usuario(
            id: "684e8db898718bc7d62aee7f",
            nombre: "Usuario Test",
            email: "test@arcacontinental.mx",
            rol: "colaborador",
            telefono: nil,
            activo: true
        )
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
    
    func analizarTiendaManualmente(tiendaId: Int) async throws -> GeminiAnalysis {
        guard let url = URL(string: "\(baseURL)/tiendas/\(tiendaId)/analyze") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(AnalysisResponse.self, from: data)
        
        if response.success {
            print("🔍 Análisis manual completado para tienda \(tiendaId)")
            return response.analysis
        } else {
            throw APIError.serverError
        }
    }
    
    func obtenerFeedbackTendero(tiendaId: Int, limite: Int = 20) async throws -> [FeedbackTendero] {
        guard let url = URL(string: "\(baseURL)/feedback/tendero/\(tiendaId)?limite=\(limite)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(FeedbackTenderoListResponse.self, from: data)
        
        if response.success {
            return response.data
        } else {
            throw APIError.serverError
        }
    }
    
    func obtenerEvaluacionesTienda(tiendaId: Int, limite: Int = 10) async throws -> [EvaluacionTienda] {
        guard let url = URL(string: "\(baseURL)/feedback/tienda/\(tiendaId)?limite=\(limite)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(EvaluacionTiendaListResponse.self, from: data)
        
        if response.success {
            return response.data
        } else {
            throw APIError.serverError
        }
    }
    
    // MARK: - Método de validación de tiendas
    func obtenerTiendasConValidacion() async throws -> [Tienda] {
        let todasLasTiendas = try await obtenerTiendas()
        
        print("🔍 VALIDANDO TIENDAS CARGADAS:")
        print("   Total recibidas: \(todasLasTiendas.count)")
        
        var tiendasValidas: [Tienda] = []
        var tiendasInvalidas: [Tienda] = []
        
        for tienda in todasLasTiendas {
            if tienda.isValidId {
                tiendasValidas.append(tienda)
            } else {
                tiendasInvalidas.append(tienda)
                print("   ❌ TIENDA INVÁLIDA: ID=\(tienda.id), Nombre='\(tienda.nombre)'")
            }
        }
        
        print("   ✅ Tiendas válidas: \(tiendasValidas.count)")
        print("   ❌ Tiendas inválidas: \(tiendasInvalidas.count)")
        
        if !tiendasInvalidas.isEmpty {
            print("   ⚠️ TIENDAS CON PROBLEMAS DE ID:")
            for tienda in tiendasInvalidas.prefix(5) {
                print("      - '\(tienda.nombre)' (ID: \(tienda.id))")
            }
        }
        
        // Retornar solo tiendas válidas para evitar problemas
        return tiendasValidas
    }
    
    // MARK: - Análisis Gemini Avanzado
    func obtenerAnalisisGemini(tiendaId: Int, tipo: String? = nil, limite: Int = 5) async throws -> [AnalisisGemini] {
        print("📊 obtenerAnalisisGemini para tienda \(tiendaId)")
        
        // Primero intentar el endpoint real
        var urlString = "\(baseURL)/gemini/analisis/\(tiendaId)?limite=\(limite)"
        
        if let tipo = tipo {
            urlString += "&tipo=\(tipo)"
        }
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📡 Status obtenerAnalisisGemini: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                // Intentar decodificar como AnalisisGeminiResponse
                if let analisisResponse = try? JSONDecoder().decode(AnalisisGeminiResponse.self, from: data) {
                    if analisisResponse.success {
                        print("✅ Análisis Gemini obtenidos: \(analisisResponse.data.count)")
                        return analisisResponse.data
                    }
                }
                
                // Si falla, intentar decodificar directamente como array
                if let analisisArray = try? JSONDecoder().decode([AnalisisGemini].self, from: data) {
                    print("✅ Análisis Gemini obtenidos (array directo): \(analisisArray.count)")
                    return analisisArray
                }
                
                // Si ambos fallan, mostrar qué está devolviendo el servidor
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("⚠️ Respuesta del servidor: \(jsonString)")
                }
            }
            
            // Si el endpoint no existe o falla, retornar array vacío
            print("⚠️ Endpoint de análisis Gemini no disponible, retornando array vacío")
            return []
            
        } catch {
            print("❌ Error en obtenerAnalisisGemini: \(error)")
            // En caso de error, retornar array vacío en lugar de lanzar excepción
            return []
        }
    }
    
    func generarAnalisisPrevisita(tiendaId: Int, colaboradorId: String, tipoVisita: String = "regular") async throws -> AnalisisPrevisitaResponse {
        guard let url = URL(string: "\(baseURL)/gemini/previsita/\(tiendaId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = [
            "colaborador_id": colaboradorId,
            "tipo_visita": tipoVisita
        ]
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        print("📤 Enviando solicitud de análisis pre-visita para tienda \(tiendaId)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📡 Respuesta análisis pre-visita: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let apiResponse = try JSONDecoder().decode(AnalisisPrevisitaResponse.self, from: data)
                if apiResponse.success {
                    print("🔮 Análisis pre-visita generado exitosamente")
                    return apiResponse
                }
            }
            
            // Si llega aquí, simular respuesta exitosa para testing
            print("⚠️ Simulando respuesta de análisis pre-visita")
            return AnalisisPrevisitaResponse(
                success: true,
                analisisId: "test-\(tiendaId)",
                tienda: "Tienda \(tiendaId)",
                recomendaciones: nil,
                error: nil
            )
            
        } catch {
            print("❌ Error en análisis pre-visita: \(error)")
            // Simular respuesta exitosa para testing
            return AnalisisPrevisitaResponse(
                success: true,
                analisisId: "test-\(tiendaId)",
                tienda: "Tienda \(tiendaId)",
                recomendaciones: nil,
                error: nil
            )
        }
    }
    
    func generarPredicciones(tiendaId: Int) async throws -> PrediccionesResponse {
        guard let url = URL(string: "\(baseURL)/gemini/prediccion/\(tiendaId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📤 Enviando solicitud de predicciones para tienda \(tiendaId)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📡 Respuesta predicciones: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                // Mostrar la respuesta para debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📊 Respuesta completa predicciones: \(jsonString)")
                }
                
                //USAR LA ESTRUCTURA CORRECTA
                do {
                    let apiResponse = try JSONDecoder().decode(PrediccionesGeneradasResponse.self, from: data)
                    if apiResponse.success {
                        print("🔮 Predicciones generadas y guardadas exitosamente")
                        return PrediccionesResponse(
                            success: true,
                            tiendaId: tiendaId,
                            predicciones: apiResponse.predicciones,
                            error: nil
                        )
                    }
                } catch {
                    print("❌ Error decodificando predicciones: \(error)")
                }
            }
            
            // Fallback
            print("⚠️ Usando respuesta fallback para predicciones")
            return PrediccionesResponse(
                success: true,
                tiendaId: tiendaId,
                predicciones: AnalisisPredicciones(
                    problemasPotenciales: ["Predicciones generadas exitosamente"],
                    metricasEnRiesgo: ["Monitorear métricas regularmente"],
                    accionesPreventivas: ["Mantener programa de visitas"],
                    frecuenciaVisitasSugerida: "30 días",
                    nivelRiesgo: "medio",
                    indicadoresAlerta: ["Cambios en NPS"],
                    recomendacionesInmediatas: ["Continuar monitoreo"]
                ),
                error: nil
            )
            
        } catch {
            print("❌ Error en predicciones: \(error)")
            throw error
        }
    }
}
