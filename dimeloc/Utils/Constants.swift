//
//  Constants.swift
//  dimeloc
//
//  Constantes centralizadas para la aplicación
//

import Foundation
import SwiftUI

struct AppConstants {
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://dimeloc-backend.onrender.com/api"
        static let timeout: TimeInterval = 30.0
        static let retryAttempts = 3
        static let userAgent = "dimeloc-ios/1.0"
    }
    
    // MARK: - Endpoints
    struct Endpoints {
        // Base
        static let health = "/health"
        static let stats = "/stats"
        static let geojson = "/geojson"
        static let tiendasCompletas = "/tiendas-completas"
        
        // Tiendas
        static let tiendas = "/tiendas"
        static let tiendasProblematicas = "/tiendas/problematicas"
        
        // Auth
        static let login = "/auth/login"
        static let profile = "/auth/profile"
        static let colaboradores = "/usuarios/colaboradores"
        
        // Feedback original
        static let feedbackTienda = "/tiendas/{id}/feedback"
        static let insightsTienda = "/tiendas/{id}/insights"
        static let analyzeTienda = "/tiendas/{id}/analyze"
        
        // Feedback bidireccional
        static let feedbackTendero = "/feedback/tendero"
        static let feedbackEvaluacion = "/feedback/tienda"
        
        // Agenda y Visitas
        static let agenda = "/agenda/{userId}"
        static let programarVisita = "/visitas/programar"
        static let confirmarVisita = "/visitas/{id}/confirmar"
        static let iniciarVisita = "/visitas/{id}/iniciar"
        static let finalizarVisita = "/visitas/{id}/finalizar"
        
        // Análisis Gemini
        static let testGemini = "/test-gemini"
        static let analisisPrevisita = "/gemini/previsita/{tiendaId}"
        static let analisisPostvisita = "/gemini/postvisita"
        static let tendencias = "/gemini/tendencias"
        static let predicciones = "/gemini/prediccion/{tiendaId}"
        static let analisisGemini = "/gemini/analisis/{tiendaId}"
        
        // Insights y alertas
        static let tiendasConAlertas = "/insights/problematicas"
        static let analizarTodas = "/insights/analyze-all"
        
        // Evidencias
        static let evidencias = "/evidencias"
        static let evidenciasVisita = "/evidencias/{visitaId}"
        
        // Dashboard
        static let resumenDashboard = "/dashboard/resumen"
        static let notificaciones = "/notificaciones/{userId}"
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaults {
        static let isLoggedIn = "isLoggedIn"
        static let currentUserId = "currentUserId"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let userRole = "userRole"
        static let lastSyncDate = "lastSyncDate"
        static let apiToken = "apiToken"
        static let debugMode = "debugMode"
    }
    
    // MARK: - Categorías de Feedback
    struct FeedbackCategories {
        static let infraestructura = "infraestructura"
        static let inventario = "inventario"
        static let servicio = "servicio"
        static let limpieza = "limpieza"
        static let personal = "personal"
        static let otro = "otro"
        
        static let all = [infraestructura, inventario, servicio, limpieza, personal, otro]
        
        static func displayName(for category: String) -> String {
            switch category {
            case infraestructura: return "Infraestructura"
            case inventario: return "Inventario"
            case servicio: return "Servicio"
            case limpieza: return "Limpieza"
            case personal: return "Personal"
            case otro: return "Otro"
            default: return category.capitalized
            }
        }
        
        static func icon(for category: String) -> String {
            switch category {
            case infraestructura: return "wrench.and.screwdriver"
            case inventario: return "shippingbox"
            case servicio: return "person.2"
            case limpieza: return "sparkles"
            case personal: return "person.badge.key"
            case otro: return "ellipsis.circle"
            default: return "questionmark.circle"
            }
        }
    }
    
    // MARK: - Niveles de Urgencia
    struct UrgencyLevels {
        static let baja = "baja"
        static let media = "media"
        static let alta = "alta"
        static let critica = "critica"
        
        static let all = [baja, media, alta, critica]
        
        static func displayName(for level: String) -> String {
            switch level {
            case baja: return "Baja"
            case media: return "Media"
            case alta: return "Alta"
            case critica: return "Crítica"
            default: return level.capitalized
            }
        }
        
        static func color(for level: String) -> Color {
            switch level {
            case baja: return .green
            case media: return .orange
            case alta: return .red
            case critica: return .purple
            default: return .gray
            }
        }
        
        static func icon(for level: String) -> String {
            switch level {
            case baja: return "checkmark.circle"
            case media: return "exclamationmark.circle"
            case alta: return "exclamationmark.triangle"
            case critica: return "exclamationmark.octagon"
            default: return "questionmark.circle"
            }
        }
    }
    
    // MARK: - Estados de Visitas
    struct VisitStatus {
        static let programada = "programada"
        static let confirmada = "confirmada"
        static let enCurso = "en_curso"
        static let completada = "completada"
        static let cancelada = "cancelada"
        
        static let all = [programada, confirmada, enCurso, completada, cancelada]
        
        static func displayName(for status: String) -> String {
            switch status {
            case programada: return "Programada"
            case confirmada: return "Confirmada"
            case enCurso: return "En Curso"
            case completada: return "Completada"
            case cancelada: return "Cancelada"
            default: return status.capitalized
            }
        }
        
        static func color(for status: String) -> Color {
            switch status {
            case programada: return .orange
            case confirmada: return .blue
            case enCurso: return .green
            case completada: return .gray
            case cancelada: return .red
            default: return .gray
            }
        }
        
        static func icon(for status: String) -> String {
            switch status {
            case programada: return "calendar"
            case confirmada: return "checkmark.circle"
            case enCurso: return "play.circle"
            case completada: return "checkmark.circle.fill"
            case cancelada: return "xmark.circle"
            default: return "questionmark.circle"
            }
        }
    }
    
    // MARK: - Tipos de Visitas
    struct VisitTypes {
        static let regular = "regular"
        static let seguimiento = "seguimiento"
        static let urgente = "urgente"
        static let auditoria = "auditoria"
        static let capacitacion = "capacitacion"
        
        static let all = [regular, seguimiento, urgente, auditoria, capacitacion]
        
        static func displayName(for type: String) -> String {
            switch type {
            case regular: return "Regular"
            case seguimiento: return "Seguimiento"
            case urgente: return "Urgente"
            case auditoria: return "Auditoría"
            case capacitacion: return "Capacitación"
            default: return type.capitalized
            }
        }
        
        static func icon(for type: String) -> String {
            switch type {
            case regular: return "calendar"
            case seguimiento: return "arrow.clockwise"
            case urgente: return "exclamationmark.triangle"
            case auditoria: return "checkmark.shield"
            case capacitacion: return "graduationcap"
            default: return "calendar"
            }
        }
    }
    
    // MARK: - Tipos de Evidencias
    struct EvidenceTypes {
        static let fotoFachada = "foto_fachada"
        static let fotoInterior = "foto_interior"
        static let fotoProductos = "foto_productos"
        static let fotoProblema = "foto_problema"
        static let documento = "documento"
        static let video = "video"
        
        static let all = [fotoFachada, fotoInterior, fotoProductos, fotoProblema, documento, video]
        
        static func displayName(for type: String) -> String {
            switch type {
            case fotoFachada: return "Foto de Fachada"
            case fotoInterior: return "Foto Interior"
            case fotoProductos: return "Foto de Productos"
            case fotoProblema: return "Foto de Problema"
            case documento: return "Documento"
            case video: return "Video"
            default: return type.capitalized
            }
        }
        
        static func icon(for type: String) -> String {
            switch type {
            case fotoFachada: return "building.2"
            case fotoInterior: return "house"
            case fotoProductos: return "shippingbox"
            case fotoProblema: return "exclamationmark.triangle"
            case documento: return "doc"
            case video: return "video"
            default: return "camera"
            }
        }
    }
    
    // MARK: - Roles de Usuario
    struct UserRoles {
        static let admin = "admin"
        static let colaborador = "colaborador"
        static let asesor = "asesor"
        static let supervisor = "supervisor"
        
        static let all = [admin, colaborador, asesor, supervisor]
        
        static func displayName(for role: String) -> String {
            switch role {
            case admin: return "Administrador"
            case colaborador: return "Colaborador"
            case asesor: return "Asesor"
            case supervisor: return "Supervisor"
            default: return role.capitalized
            }
        }
        
        static func permissions(for role: String) -> [String] {
            switch role {
            case admin:
                return ["view_all", "edit_all", "delete_all", "manage_users", "view_analytics"]
            case supervisor:
                return ["view_all", "edit_visits", "view_analytics", "manage_team"]
            case asesor:
                return ["view_assigned", "edit_visits", "create_feedback", "view_insights"]
            case colaborador:
                return ["view_assigned", "create_feedback", "update_visits"]
            default:
                return ["view_assigned"]
            }
        }
    }
    
    // MARK: - Configuración de Performance
    struct Performance {
        static let npsExcelente: Double = 50
        static let npsBueno: Double = 30
        static let damageRateBueno: Double = 0.5
        static let damageRateAceptable: Double = 1.0
        static let outOfStockBueno: Double = 3.0
        static let outOfStockAceptable: Double = 4.0
        static let resolutionTimeExcelente: Double = 24.0
        static let resolutionTimeAceptable: Double = 48.0
        
        static func getPerformanceLevel(nps: Double, damageRate: Double, outOfStock: Double) -> PerformanceLevel {
            if nps >= npsExcelente && damageRate < damageRateBueno && outOfStock < outOfStockBueno {
                return .excelente
            } else if nps >= npsBueno && damageRate < damageRateAceptable && outOfStock < outOfStockAceptable {
                return .bueno
            } else {
                return .necesitaAtencion
            }
        }
        
        enum PerformanceLevel {
            case excelente, bueno, necesitaAtencion
            
            var displayName: String {
                switch self {
                case .excelente: return "Excelente"
                case .bueno: return "Bueno"
                case .necesitaAtencion: return "Necesita Atención"
                }
            }
            
            var color: Color {
                switch self {
                case .excelente: return .green
                case .bueno: return .orange
                case .necesitaAtencion: return .red
                }
            }
            
            var icon: String {
                switch self {
                case .excelente: return "checkmark.circle.fill"
                case .bueno: return "exclamationmark.circle.fill"
                case .necesitaAtencion: return "warning.circle.fill"
                }
            }
        }
    }
    
    // MARK: - Configuraciones de UI
    struct UI {
        // Colores de la app
        struct Colors {
            static let primary = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
            static let secondary = Color(red: 0.2, green: 0.4, blue: 0.8) // #3366CC
            static let accent = Color(red: 1.0, green: 0.6, blue: 0.0) // #FF9900
            static let success = Color.green
            static let warning = Color.orange
            static let error = Color.red
            static let background = Color(.systemGroupedBackground)
            static let surface = Color(.systemBackground)
        }
        
        // Espaciado
        struct Spacing {
            static let xs: CGFloat = 4
            static let sm: CGFloat = 8
            static let md: CGFloat = 16
            static let lg: CGFloat = 24
            static let xl: CGFloat = 32
            static let xxl: CGFloat = 48
        }
        
        // Tamaños de fuente
        struct FontSizes {
            static let caption: CGFloat = 12
            static let body: CGFloat = 16
            static let headline: CGFloat = 18
            static let title: CGFloat = 24
            static let largeTitle: CGFloat = 32
        }
        
        // Radios de esquina
        struct CornerRadius {
            static let small: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
            static let xl: CGFloat = 24
        }
        
        // Animaciones
        struct Animation {
            static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
            static let medium = SwiftUI.Animation.easeInOut(duration: 0.3)
            static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        }
    }
    
    // MARK: - Configuración de Caché
    struct Cache {
        static let maxTiendas = 1000
        static let maxVisitas = 500
        static let maxFeedbacks = 200
        static let cacheTimeout: TimeInterval = 300 // 5 minutos
        static let imageTimeout: TimeInterval = 3600 // 1 hora
    }
    
    // MARK: - Configuración de Mapa
    struct Map {
        // Coordenadas de Monterrey (default)
        static let defaultLatitude: Double = 25.6866
        static let defaultLongitude: Double = -100.3161
        static let defaultSpan: Double = 0.1
        static let maxZoomSpan: Double = 0.01
        static let minZoomSpan: Double = 1.0
    }
    
    // MARK: - Límites y Validaciones
    struct Validation {
        static let minPasswordLength = 6
        static let maxFeedbackLength = 500
        static let maxNotesLength = 1000
        static let maxFileSize = 10 * 1024 * 1024 // 10MB
        static let allowedImageFormats = ["jpg", "jpeg", "png", "heic"]
        static let allowedDocumentFormats = ["pdf", "doc", "docx"]
    }
    
    // MARK: - Mensajes de Error Comunes
    struct ErrorMessages {
        static let networkError = "Error de conexión. Verifica tu internet."
        static let serverError = "Error del servidor. Intenta más tarde."
        static let invalidCredentials = "Email o contraseña incorrectos."
        static let sessionExpired = "Tu sesión ha expirado. Inicia sesión nuevamente."
        static let permissionDenied = "No tienes permisos para esta acción."
        static let dataNotFound = "No se encontraron datos."
        static let invalidInput = "Los datos ingresados no son válidos."
        static let fileTooBig = "El archivo es demasiado grande."
        static let unsupportedFormat = "Formato de archivo no soportado."
    }
    
    // MARK: - Configuración de Notificaciones
    struct Notifications {
        static let visitReminder = "visit_reminder"
        static let feedbackUrgent = "feedback_urgent"
        static let systemAlert = "system_alert"
        static let syncCompleted = "sync_completed"
        
        struct Keys {
            static let visitId = "visit_id"
            static let tiendaId = "tienda_id"
            static let urgencyLevel = "urgency_level"
        }
    }
    
    // MARK: - URLs Externas
    struct ExternalURLs {
        static let support = "https://support.arcacontinental.mx"
        static let privacy = "https://arcacontinental.mx/privacy"
        static let terms = "https://arcacontinental.mx/terms"
        static let documentation = "https://docs.dimeloc.com"
    }
}
