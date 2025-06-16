//
//  Models.swift
//  dimeloc
//
//  Created by Maria Martinez on 15/06/25.
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Tienda y Location (VERSIÓN ÚNICA CORREGIDA)
struct Tienda: Codable, Identifiable {
    // ✅ MANEJO MEJORADO DE ID
    private let _rawId: TiendaIdValue?
    
    // Computed property que maneja diferentes tipos de ID
    var id: Int {
        guard let rawId = _rawId else {
            print("⚠️ Tienda sin ID detectada: \(nombre)")
            return 0
        }
        
        switch rawId {
        case .int(let value):
            return value
        case .string(let stringValue):
            // Intentar convertir string a int
            if let intValue = Int(stringValue) {
                return intValue
            } else {
                print("⚠️ No se pudo convertir ID string '\(stringValue)' a Int para tienda: \(nombre)")
                return 0
            }
        }
    }
    
    let nombre: String
    let location: Location
    private let _nps: Double?
    private let _fillfoundrate: Double?
    private let _damageRate: Double?
    private let _outOfStock: Double?
    private let _complaintResolutionTimeHrs: Double?
    
    // Campos adicionales para TiendaDetailView
    let horaAbre: String?
    let horaCierra: String?
    let direccion: String?
    let colaboradorAsignado: String?
    let fechaUltimaVisita: String?
    
    // Propiedades calculadas con valores seguros
    var nps: Double {
        guard let value = _nps, value.isFinite else { return 0.0 }
        return value
    }
    
    var fillfoundrate: Double {
        guard let value = _fillfoundrate, value.isFinite else { return 0.0 }
        return value
    }
    
    var damageRate: Double {
        guard let value = _damageRate, value.isFinite else { return 0.0 }
        return value
    }
    
    var outOfStock: Double {
        guard let value = _outOfStock, value.isFinite else { return 0.0 }
        return value
    }
    
    var complaintResolutionTimeHrs: Double {
        guard let value = _complaintResolutionTimeHrs, value.isFinite else { return 24.0 }
        return value
    }
    
    // Propiedades de conveniencia para TiendaDetailView
    var horario: String {
        guard let abre = horaAbre, let cierra = horaCierra else {
            return "Horario no disponible"
        }
        if abre == "24hrs" || abre.lowercased().contains("24") {
            return "24 horas"
        }
        return "\(abre) - \(cierra)"
    }
    
    var colaborador: String {
        return colaboradorAsignado?.components(separatedBy: "@").first ?? "Sin asignar"
    }
    
    var ultimaVisita: String {
        guard let fecha = fechaUltimaVisita else {
            return "Sin visitas registradas"
        }
        
        if let date = ISO8601DateFormatter().date(from: fecha) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "es_ES")
            return formatter.string(from: date)
        }
        
        return fecha
    }
    
    // ✅ ENUM para manejar diferentes tipos de ID
    enum TiendaIdValue: Codable {
        case int(Int)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            // Intentar decodificar como Int primero
            if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
                return
            }
            
            // Si falla, intentar como String
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
                return
            }
            
            // Si ambos fallan, lanzar error
            throw DecodingError.typeMismatch(
                TiendaIdValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Int or String for tienda ID"
                )
            )
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .int(let value):
                try container.encode(value)
            case .string(let value):
                try container.encode(value)
            }
        }
    }
    
    // CodingKeys
    enum CodingKeys: String, CodingKey {
        case _rawId = "_id"
        case nombre
        case location
        case _nps = "nps"
        case _fillfoundrate = "fillfoundrate"
        case _damageRate = "damage_rate"
        case _outOfStock = "out_of_stock"
        case _complaintResolutionTimeHrs = "complaint_resolution_time_hrs"
        case horaAbre = "hora_abre"
        case horaCierra = "hora_cierra"
        case direccion
        case colaboradorAsignado = "colaborador_asignado"
        case fechaUltimaVisita = "fecha_ultima_visita"
    }
}

// MARK: - Location
struct Location: Codable {
    private let _longitude: Double?
    private let _latitude: Double?
    
    var longitude: Double {
        guard let value = _longitude, value.isFinite else { return -100.3161 } // Default Monterrey
        return value
    }
    
    var latitude: Double {
        guard let value = _latitude, value.isFinite else { return 25.6866 } // Default Monterrey
        return value
    }
    
    // Constructor personalizado para TenderoFeedbackView
    init(longitude: Double = -100.3161, latitude: Double = 25.6866) {
        self._longitude = longitude
        self._latitude = latitude
    }
    
    enum CodingKeys: String, CodingKey {
        case _longitude = "longitude"
        case _latitude = "latitude"
    }
}

// MARK: - Usuario (actualizado)
struct Usuario: Codable, Identifiable {
    let id: String
    let nombre: String
    let email: String
    let rol: String
    let telefono: String?
    let activo: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nombre, email, rol, telefono, activo
    }
}

// MARK: - Feedback Models (actualizados para tu API)
struct Feedback: Codable, Identifiable {
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

struct NuevoFeedback: Codable {
    let colaborador: String
    let comentario: String
    let categoria: String
    let urgencia: String
}

// MARK: - NUEVAS ESTRUCTURAS PARA FEEDBACK BIDIRECCIONAL (para TenderoFeedbackView)
struct FeedbackTendero: Codable, Identifiable {
    let id: String
    let visitaId: String?
    let tiendaId: Int
    let colaboradorId: String
    let fecha: String
    let categoria: String
    let tipo: String
    let urgencia: String
    let titulo: String
    let descripcion: String
    let estado: String
    let seguimientoRequerido: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case visitaId = "visita_id"
        case tiendaId = "tienda_id"
        case colaboradorId = "colaborador_id"
        case fecha, categoria, tipo, urgencia, titulo, descripcion, estado
        case seguimientoRequerido = "seguimiento_requerido"
    }
}

struct NuevoFeedbackTendero: Codable {
    let visitaId: String?
    let tiendaId: Int
    let colaboradorId: String
    let categoria: String
    let tipo: String
    let urgencia: String
    let titulo: String
    let descripcion: String
    
    enum CodingKeys: String, CodingKey {
        case visitaId = "visita_id"
        case tiendaId = "tienda_id"
        case colaboradorId = "colaborador_id"
        case categoria, tipo, urgencia, titulo, descripcion
    }
}

struct EvaluacionTienda: Codable, Identifiable {
    let id: String
    let visitaId: String?
    let tiendaId: Int
    let colaboradorId: String
    let fecha: String
    let aspectos: AspectosEvaluacion
    let observacionesGenerales: String
    let puntosFuertes: [String]
    let areasMejora: [String]
    let recomendacionesPrioritarias: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case visitaId = "visita_id"
        case tiendaId = "tienda_id"
        case colaboradorId = "colaborador_id"
        case fecha, aspectos
        case observacionesGenerales = "observaciones_generales"
        case puntosFuertes = "puntos_fuertes"
        case areasMejora = "areas_mejora"
        case recomendacionesPrioritarias = "recomendaciones_prioritarias"
    }
}

struct AspectosEvaluacion: Codable {
    let limpieza: AspectoPuntuado
    let mobiliario: AspectoPuntuado
    let inventario: EvaluacionInventario
    let atencionCliente: AspectoPuntuado
    let organizacion: AspectoPuntuado
    
    enum CodingKeys: String, CodingKey {
        case limpieza, mobiliario, inventario, organizacion
        case atencionCliente = "atencion_cliente"
    }
}

struct AspectoPuntuado: Codable {
    let calificacion: Int
    let comentarios: String
}

struct EvaluacionInventario: Codable {
    let productosEstrella: [String]
    let productosBajaRotacion: [String]
    let faltantesDetectados: [String]
    let sugerenciasNuevosProductos: [String]
    
    enum CodingKeys: String, CodingKey {
        case productosEstrella = "productos_estrella"
        case productosBajaRotacion = "productos_baja_rotacion"
        case faltantesDetectados = "faltantes_detectados"
        case sugerenciasNuevosProductos = "sugerencias_nuevos_productos"
    }
}

struct NuevaEvaluacionTienda: Codable {
    let visitaId: String?
    let tiendaId: Int
    let colaboradorId: String
    let aspectos: AspectosEvaluacion
    let puntosFuertes: [String]
    let areasMejora: [String]
    let observacionesGenerales: String
    let recomendacionesPrioritarias: [String]
    
    enum CodingKeys: String, CodingKey {
        case visitaId = "visita_id"
        case tiendaId = "tienda_id"
        case colaboradorId = "colaborador_id"
        case aspectos
        case puntosFuertes = "puntos_fuertes"
        case areasMejora = "areas_mejora"
        case observacionesGenerales = "observaciones_generales"
        case recomendacionesPrioritarias = "recomendaciones_prioritarias"
    }
}

// MARK: - Visitas (actualizadas para tu API)
struct Visita: Codable, Identifiable {
    let id: String
    let tiendaId: Int
    let colaboradorId: String
    let asesorId: String?
    let fechaProgramada: String
    let fechaRealizada: String?
    let estado: String
    let tipo: String
    let confirmaciones: Confirmaciones
    let duracionMinutos: Int?
    let notasPrevias: String?
    let notasFinales: String?
    let completada: Bool
    let fechaCreacion: String
    let tienda: TiendaVisita?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case tiendaId = "tienda_id"
        case colaboradorId = "colaborador_id"
        case asesorId = "asesor_id"
        case fechaProgramada = "fecha_programada"
        case fechaRealizada = "fecha_realizada"
        case estado, tipo, confirmaciones
        case duracionMinutos = "duracion_minutos"
        case notasPrevias = "notas_previas"
        case notasFinales = "notas_finales"
        case completada
        case fechaCreacion = "fecha_creacion"
        case tienda
    }
}

struct Confirmaciones: Codable {
    let colaborador: ConfirmacionDetalle
    let asesor: ConfirmacionDetalle?
}

struct ConfirmacionDetalle: Codable {
    let confirmado: Bool
    let fechaConfirmacion: String?
    
    enum CodingKeys: String, CodingKey {
        case confirmado
        case fechaConfirmacion = "fecha_confirmacion"
    }
}

struct TiendaVisita: Codable {
    let id: String
    let nombre: String
    let direccion: String?
    let horario: String?
}

struct NuevaVisita: Codable {
    let tiendaId: Int
    let colaboradorId: String
    let asesorId: String?
    let fechaProgramada: String
    let tipo: String
    let notas: String
    
    enum CodingKeys: String, CodingKey {
        case tiendaId = "tienda_id"
        case colaboradorId = "colaborador_id"
        case asesorId = "asesor_id"
        case fechaProgramada = "fecha_programada"
        case tipo, notas
    }
}

// MARK: - Gemini Analysis (actualizado para tu API)
struct GeminiInsight: Codable, Identifiable {
    let id: String
    let tiendaId: Int
    let fechaAnalisis: String
    let alertas: [String]
    let insights: [String]
    let recomendaciones: [String]
    let prioridad: String
    let resumen: String?
    let totalComentarios: Int?
    let feedbackAnalizado: [String]?
    let analisisManual: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case tiendaId = "tienda_id"
        case fechaAnalisis = "fecha_analisis"
        case alertas, insights, recomendaciones, prioridad, resumen
        case totalComentarios = "total_comentarios"
        case feedbackAnalizado = "feedback_analizado"
        case analisisManual = "analisis_manual"
    }
}

struct GeminiAnalysis: Codable {
    let alerts: [String]
    let insights: [String]
    let recommendations: [String]
    let priority: String
    let summary: String
    
    enum CodingKeys: String, CodingKey {
        case alerts, insights, recommendations, priority, summary
    }
}

// MARK: - Análisis Pre/Post Visita (NUEVO)
struct AnalisisPrevisita: Codable, Identifiable {
    let id: String
    let tiendaId: Int
    let colaboradorId: String
    let fechaAnalisis: String
    let recomendaciones: RecomendacionesPrevisita
    let utilizado: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case tiendaId = "tienda_id"
        case colaboradorId = "colaborador_id"
        case fechaAnalisis = "fecha_analisis"
        case recomendaciones, utilizado
    }
}

struct RecomendacionesPrevisita: Codable {
    let problemasPendientes: [String]
    let puntosVerificar: [String]
    let preguntasTendero: [String]
    let evidenciasCapturar: [String]
    let areasOportunidad: [String]
    let prioridadVisita: String
    let tiempoEstimado: String
    let preparacionEspecial: String
    
    enum CodingKeys: String, CodingKey {
        case problemasPendientes = "problemas_pendientes"
        case puntosVerificar = "puntos_verificar"
        case preguntasTendero = "preguntas_tendero"
        case evidenciasCapturar = "evidencias_capturar"
        case areasOportunidad = "areas_oportunidad"
        case prioridadVisita = "prioridad_visita"
        case tiempoEstimado = "tiempo_estimado"
        case preparacionEspecial = "preparacion_especial"
    }
}

struct AnalisisPostvisita: Codable, Identifiable {
    let id: String
    let visitaId: String
    let tiendaId: Int
    let fechaAnalisis: String
    let resultados: ResultadosPostvisita
    let seguimientoRequerido: Bool
    let accionesRecomendadas: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case visitaId = "visita_id"
        case tiendaId = "tienda_id"
        case fechaAnalisis = "fecha_analisis"
        case resultados
        case seguimientoRequerido = "seguimiento_requerido"
        case accionesRecomendadas = "acciones_recomendadas"
    }
}

struct ResultadosPostvisita: Codable {
    let resumenEjecutivo: String
    let mejorasImplementadas: [String]
    let nuevosProblemas: [String]
    let seguimientoRequerido: [String]
    let efectividadRecomendaciones: String
    let proximasAcciones: [String]
    let nivelSeguimiento: String
    let fechaProximaVisita: String
    let accionesInmediatas: [String]
    
    enum CodingKeys: String, CodingKey {
        case resumenEjecutivo = "resumen_ejecutivo"
        case mejorasImplementadas = "mejoras_implementadas"
        case nuevosProblemas = "nuevos_problemas"
        case seguimientoRequerido = "seguimiento_requerido"
        case efectividadRecomendaciones = "efectividad_recomendaciones"
        case proximasAcciones = "proximas_acciones"
        case nivelSeguimiento = "nivel_seguimiento"
        case fechaProximaVisita = "fecha_proxima_visita"
        case accionesInmediatas = "acciones_inmediatas"
    }
}

// MARK: - Evidencias (NUEVO)
struct Evidencia: Codable, Identifiable {
    let id: String
    let visitaId: String
    let tipo: String
    let url: String
    let descripcion: String
    let coordenadas: Coordenadas?
    let timestamp: String
    let subidoPor: String?
    let tamañoBytes: Int?
    let formato: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case visitaId = "visita_id"
        case tipo, url, descripcion, coordenadas, timestamp
        case subidoPor = "subido_por"
        case tamañoBytes = "tamaño_bytes"
        case formato
    }
}

struct Coordenadas: Codable {
    let latitud: Double
    let longitud: Double
}

struct NuevaEvidencia: Codable {
    let visitaId: String
    let tipo: String
    let url: String
    let descripcion: String
    let coordenadas: Coordenadas?
    
    enum CodingKeys: String, CodingKey {
        case visitaId = "visita_id"
        case tipo, url, descripcion, coordenadas
    }
}

// MARK: - Tiendas Problemáticas (actualizado)
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

// MARK: - Dashboard y Notificaciones (NUEVO)
struct ResumenDashboard: Codable {
    let visitasRealizadas: Int
    let visitasPendientes: Int
    let feedbackCritico: Int
    let tiendasProblematicas: Int
    let analisisGeminiGenerados: Int
    let totalTiendas: Int
    
    enum CodingKeys: String, CodingKey {
        case visitasRealizadas = "visitas_realizadas"
        case visitasPendientes = "visitas_pendientes"
        case feedbackCritico = "feedback_critico"
        case tiendasProblematicas = "tiendas_problematicas"
        case analisisGeminiGenerados = "analisis_gemini_generados"
        case totalTiendas = "total_tiendas"
    }
}

struct Notificacion: Codable, Identifiable {
    let id: String
    let tipo: String
    let titulo: String
    let mensaje: String
    let fecha: String
    let leida: Bool
    let datos: [String: String]?
}

// MARK: - ✅ EXTENSIONES DE TIENDA
extension Tienda {
    var coordinate: CLLocationCoordinate2D {
        let lat = location.latitude
        let lng = location.longitude
        
        // Validar que las coordenadas estén en rangos válidos
        let safeLat = max(-90, min(90, lat))
        let safeLng = max(-180, min(180, lng))
        
        return CLLocationCoordinate2D(latitude: safeLat, longitude: safeLng)
    }
    
    var performanceColor: Color {
        let safeNPS = nps
        let safeDamage = damageRate
        let safeStock = outOfStock
        
        if safeNPS >= 50 && safeDamage < 0.5 && safeStock < 3 {
            return .green
        } else if safeNPS >= 30 && safeDamage < 1 && safeStock < 4 {
            return .orange
        } else {
            return .red
        }
    }
    
    var performanceText: String {
        let safeNPS = nps
        let safeDamage = damageRate
        let safeStock = outOfStock
        
        if safeNPS >= 50 && safeDamage < 0.5 && safeStock < 3 {
            return "Excelente"
        } else if safeNPS >= 30 && safeDamage < 1 && safeStock < 4 {
            return "Bueno"
        } else {
            return "Necesita atención"
        }
    }
    
    // ✅ VALIDACIÓN MEJORADA
    var isValidId: Bool {
        return id > 0
    }
    
    // Validar que las métricas no sean NaN
    var hasValidMetrics: Bool {
        return nps.isFinite &&
               fillfoundrate.isFinite &&
               damageRate.isFinite &&
               outOfStock.isFinite &&
               complaintResolutionTimeHrs.isFinite
    }
    
    // ✅ Preview para SwiftUI
    static func preview() -> Tienda {
        return Tienda(
            _rawId: .int(1),
            nombre: "OXXO Centro",
            location: Location(longitude: -100.3161, latitude: 25.6866),
            _nps: 45.0,
            _fillfoundrate: 95.0,
            _damageRate: 0.8,
            _outOfStock: 2.5,
            _complaintResolutionTimeHrs: 24.0,
            horaAbre: "06:00",
            horaCierra: "23:00",
            direccion: "Av. Universidad 123, Centro, Monterrey",
            colaboradorAsignado: "maria.martinez@arcacontinental.mx",
            fechaUltimaVisita: "2025-06-10T10:30:00Z"
        )
    }
}

// MARK: - Extensiones de UI para Visita
extension Visita {
    // Fecha como Date para usar en Calendar
    var fechaProgramadaDate: Date {
        ISO8601DateFormatter().date(from: fechaProgramada) ?? Date()
    }
    
    // Hora formateada
    var horaVisita: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: fechaProgramadaDate)
    }
    
    // Color según estado
    var estadoColor: Color {
        switch estado {
        case "programada": return .orange
        case "confirmada": return .blue
        case "en_curso": return .green
        case "completada": return .gray
        default: return .gray
        }
    }
    
    // Texto del estado
    var estadoTexto: String {
        switch estado {
        case "programada": return "Programada"
        case "confirmada": return "Confirmada"
        case "en_curso": return "En curso"
        case "completada": return "Completada"
        default: return estado.capitalized
        }
    }
    
    // ¿Necesita confirmación?
    var necesitaConfirmacion: Bool {
        return estado == "programada" && !confirmaciones.colaborador.confirmado
    }
    
    // ¿Es visita con asesor?
    var esVisitaConAsesor: Bool {
        return asesorId != nil
    }
    
    // ¿Está confirmada por todos?
    var confirmadaPorTodos: Bool {
        let colaboradorOk = confirmaciones.colaborador.confirmado
        let asesorOk = asesorId == nil || (confirmaciones.asesor?.confirmado ?? false)
        return colaboradorOk && asesorOk
    }
}
