//
//  APIResponses.swift
//  dimeloc
//
//  Estructuras de respuesta actualizadas para coincidir con tu backend
//

import Foundation

// MARK: - Respuestas Básicas
struct BasicResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
}

struct GenericResponse: Codable {
    let success: Bool
    let message: String
    let error: String?
}

struct GenericDataResponse<T: Codable>: Codable {
    let success: Bool
    let count: Int?
    let data: T
    let error: String?
}

// MARK: - Respuestas de Tiendas
struct TiendaResponse: Codable {
    let success: Bool
    let count: Int?
    let data: [Tienda]
    let error: String?
}

struct TiendaSimpleResponse: Codable {
    let success: Bool
    let data: Tienda
    let error: String?
}

struct TiendasProblematicasResponse: Codable {
    let success: Bool
    let count: Int
    let data: [TiendaProblematica]
    let message: String?
    let error: String?
}

// MARK: - Respuestas de Autenticación
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let user: Usuario?
    let error: String?
    let message: String?
}

struct ProfileResponse: Codable {
    let success: Bool
    let user: Usuario?
    let error: String?
}

struct ColaboradoresResponse: Codable {
    let success: Bool
    let data: [Usuario]
    let error: String?
}

// MARK: - Respuestas de Feedback Original
struct FeedbackResponse: Codable {
    let success: Bool
    let count: Int
    let data: [Feedback]
    let error: String?
}

struct FeedbackSubmissionResponse: Codable {
    let success: Bool
    let message: String?
    let feedback: FeedbackInfo?
    let analysis: AnalysisInfo?
    let error: String?
}

struct FeedbackInfo: Codable {
    let id: String
    let tiendaId: Int
    let colaborador: String
    let fecha: String
    let comentario: String
    let categoria: String
    let urgencia: String
    let resuelto: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case tiendaId = "tienda_id"
        case colaborador, fecha, comentario, categoria, urgencia, resuelto
    }
}

struct AnalysisInfo: Codable {
    let generated: Bool
    let priority: String?
    let summary: String?
    let reason: String?
}

// MARK: - Respuestas de Feedback Bidireccional (NUEVO)
struct FeedbackTenderoResponse: Codable {
    let success: Bool
    let feedbackId: String?
    let message: String
    let seguimientoRequerido: Bool?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, error
        case feedbackId = "feedback_id"
        case seguimientoRequerido = "seguimiento_requerido"
    }
}

struct FeedbackTenderoListResponse: Codable {
    let success: Bool
    let count: Int
    let data: [FeedbackTendero]
    let error: String?
}

struct EvaluacionTiendaResponse: Codable {
    let success: Bool
    let evaluacionId: String?
    let message: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, error
        case evaluacionId = "evaluacion_id"
    }
}

struct EvaluacionTiendaListResponse: Codable {
    let success: Bool
    let count: Int
    let data: [EvaluacionTienda]
    let error: String?
}

// MARK: - Respuestas de Agenda y Visitas
struct AgendaResponse: Codable {
    let success: Bool
    let count: Int
    let data: [Visita]
    let error: String?
}

struct ProgramarVisitaResponse: Codable {
    let success: Bool
    let message: String
    let visita: Visita
    let error: String?
}

struct ConfirmacionResponse: Codable {
    let success: Bool
    let message: String
    let todosConfirmaron: Bool?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, error
        case todosConfirmaron = "todos_confirmaron"
    }
}

struct ConfirmarVisitaRequest: Codable {
    let usuarioId: String
    let rol: String
    
    enum CodingKeys: String, CodingKey {
        case usuarioId = "usuario_id"
        case rol
    }
}

// MARK: - Respuestas de Insights Gemini
struct InsightsResponse: Codable {
    let success: Bool
    let count: Int
    let data: [GeminiInsight]
    let error: String?
}

struct AnalysisResponse: Codable {
    let success: Bool
    let message: String?
    let analysis: GeminiAnalysis
    let feedbackCount: Int?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, analysis, error
        case feedbackCount = "feedback_count"
    }
}

struct GeminiTestResponse: Codable {
    let success: Bool
    let analysis: String
    let error: String?
}

// MARK: - Respuestas de Análisis Pre/Post Visita (NUEVO)
struct AnalisisPrevisitaResponse: Codable {
    let success: Bool
    let analisisId: String?
    let tienda: String?
    let recomendaciones: RecomendacionesPrevisita?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, tienda, recomendaciones, error
        case analisisId = "analisis_id"
    }
}

struct AnalisisPostvisitaResponse: Codable {
    let success: Bool
    let visitaId: String?
    let analisis: ResultadosPostvisita?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, analisis, error
        case visitaId = "visita_id"
    }
}

struct TendenciasResponse: Codable {
    let success: Bool
    let periodo: String
    let dataPoints: Int
    let tendencias: AnalisisTendencias
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, periodo, tendencias, error
        case dataPoints = "data_points"
    }
}

struct AnalisisTendencias: Codable {
    let tendenciasPrincipales: [String]
    let problemasEstacionales: [String: String]
    let sectoresOportunidad: [String]
    let predicciones3Meses: [String]
    let alertasTempranas: [String]
    let recomendacionesEstrategicas: [String]
    
    enum CodingKeys: String, CodingKey {
        case tendenciasPrincipales = "tendencias_principales"
        case problemasEstacionales = "problemas_estacionales"
        case sectoresOportunidad = "sectores_oportunidad"
        case predicciones3Meses = "predicciones_3meses"
        case alertasTempranas = "alertas_tempranas"
        case recomendacionesEstrategicas = "recomendaciones_estrategicas"
    }
}

struct PrediccionesResponse: Codable {
    let success: Bool
    let tiendaId: Int
    let predicciones: AnalisisPredicciones
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, predicciones, error
        case tiendaId = "tienda_id"
    }
}

struct AnalisisPredicciones: Codable {
    let problemasPotenciales: [String]
    let metricasEnRiesgo: [String]
    let accionesPreventivas: [String]
    let frecuenciaVisitasSugerida: String
    let nivelRiesgo: String
    let indicadoresAlerta: [String]
    let recomendacionesInmediatas: [String]
    
    enum CodingKeys: String, CodingKey {
        case problemasPotenciales = "problemas_potenciales"
        case metricasEnRiesgo = "metricas_en_riesgo"
        case accionesPreventivas = "acciones_preventivas"
        case frecuenciaVisitasSugerida = "frecuencia_visitas_sugerida"
        case nivelRiesgo = "nivel_riesgo"
        case indicadoresAlerta = "indicadores_alerta"
        case recomendacionesInmediatas = "recomendaciones_inmediatas"
    }
}

// MARK: - Respuestas de Evidencias (NUEVO)
struct EvidenciaResponse: Codable {
    let success: Bool
    let evidenciaId: String?
    let message: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message, error
        case evidenciaId = "evidencia_id"
    }
}

struct EvidenciasResponse: Codable {
    let success: Bool
    let count: Int
    let data: [Evidencia]
    let error: String?
}

// MARK: - Respuestas de Dashboard (NUEVO)
struct DashboardResponse: Codable {
    let success: Bool
    let periodoDias: Int
    let resumen: ResumenDashboard
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, resumen, error
        case periodoDias = "periodo_dias"
    }
}

struct NotificacionesResponse: Codable {
    let success: Bool
    let count: Int
    let data: [Notificacion]
    let error: String?
}

// MARK: - Respuestas de Estadísticas (NUEVO)
struct EstadisticasResponse: Codable {
    let success: Bool
    let data: EstadisticasGenerales
    let error: String?
}

struct EstadisticasGenerales: Codable {
    let totalTiendas: Int
    let npsPromedio: Double
    let npsMaximo: Double
    let npsMinimo: Double
    let damageRatePromedio: Double
    let outOfStockPromedio: Double
    let tiempoQuejasPromedio: Double
    let tiendasProblematicas: Int
    
    enum CodingKeys: String, CodingKey {
        case totalTiendas = "total_tiendas"
        case npsPromedio = "nps_promedio"
        case npsMaximo = "nps_maximo"
        case npsMinimo = "nps_minimo"
        case damageRatePromedio = "damage_rate_promedio"
        case outOfStockPromedio = "out_of_stock_promedio"
        case tiempoQuejasPromedio = "tiempo_quejas_promedio"
        case tiendasProblematicas = "tiendas_problematicas"
    }
}

// MARK: - Respuestas GeoJSON (NUEVO)
struct GeoJSONResponse: Codable {
    let success: Bool
    let data: GeoJSONFeatureCollection?
    let error: String?
}

struct GeoJSONFeatureCollection: Codable {
    let type: String
    let features: [GeoJSONFeature]
}

struct GeoJSONFeature: Codable {
    let type: String
    let geometry: GeoJSONGeometry
    let properties: GeoJSONProperties
}

struct GeoJSONGeometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct GeoJSONProperties: Codable {
    let col0: String
    let nombre: String
    let nps: Double?
    let fillfoundrate: Double?
    let damageRate: Double?
    let outOfStock: Double?
    let complaintResolutionTimeHrs: Double?
    let fechaUltimaVisita: String?
    let colaboradorAsignado: String?
    let horaAbre: String?
    let horaCierra: String?
    let direccion: String?
    
    enum CodingKeys: String, CodingKey {
        case col0, nombre, nps, fillfoundrate, direccion
        case damageRate = "damage_rate"
        case outOfStock = "out_of_stock"
        case complaintResolutionTimeHrs = "complaint_resolution_time_hrs"
        case fechaUltimaVisita = "fecha_ultima_visita"
        case colaboradorAsignado = "colaborador_asignado"
        case horaAbre = "hora_abre"
        case horaCierra = "hora_cierra"
    }
}

// MARK: - Respuestas de Análisis Gemini por Tienda
struct AnalisisGeminiResponse: Codable {
    let success: Bool
    let count: Int
    let data: [AnalisisGemini]
    let error: String?
}

struct AnalisisGemini: Codable, Identifiable {
    let id: String
    let tiendaId: Int
    let tipoAnalisis: String
    let fechaAnalisis: String
    let recomendaciones: RecomendacionesPrevisita?
    let resultados: ResultadosPostvisita?
    let utilizado: Bool?
    let seguimientoRequerido: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case tiendaId = "tienda_id"
        case tipoAnalisis = "tipo_analisis"
        case fechaAnalisis = "fecha_analisis"
        case recomendaciones, resultados, utilizado
        case seguimientoRequerido = "seguimiento_requerido"
    }
}

// MARK: - Errores de API
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError
    case decodingError
    case networkError
    case authenticationError
    case notFound
    case badRequest(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .serverError:
            return "Error del servidor"
        case .decodingError:
            return "Error procesando datos"
        case .networkError:
            return "Error de conexión"
        case .authenticationError:
            return "Error de autenticación"
        case .notFound:
            return "Recurso no encontrado"
        case .badRequest(let message):
            return "Solicitud inválida: \(message)"
        }
    }
}

// MARK: - Helpers de Fecha
extension DateFormatter {
    static let iso8601Full: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
}

// MARK: - Extensiones de Utilidad
extension String {
    var toDate: Date? {
        return DateFormatter.iso8601Full.date(from: self)
    }
    
    var displayDate: String {
        guard let date = self.toDate else { return self }
        return DateFormatter.displayDate.string(from: date)
    }
}

extension Date {
    var iso8601String: String {
        return DateFormatter.iso8601Full.string(from: self)
    }
    
    var displayString: String {
        return DateFormatter.displayDate.string(from: self)
    }
    
    var timeString: String {
        return DateFormatter.shortTime.string(from: self)
    }
}
