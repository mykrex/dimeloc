//
//  APIConfig.swift
//  dimeloc
//
//  Configuración simple para testing
//

import Foundation

// MARK: - Configuración de API
struct APIConfig {
    static let baseURL = "https://dimeloc-backend.onrender.com/api"
    static let timeout: TimeInterval = 30.0
    static let debugMode = true
    
    // Usuarios de prueba para testing
    struct TestUsers {
        static let colaborador = TestUser(
            email: "colaborador@arcacontinental.mx",
            password: "password123",
            rol: "colaborador"
        )
    }
    
    struct TestUser {
        let email: String
        let password: String
        let rol: String
    }
    
    // Tiendas de prueba (basadas en tus datos reales)
    struct TestStores {
        static let oxxo1 = 1
        static let oxxo2 = 2
    }
}

// MARK: - Helper para testing de API
class APITester {
    private let apiClient = TiendasAPIClient()
    
    /// Test completo de conectividad
    func runConnectivityTest() async {
        print("🧪 === INICIANDO TESTS DE CONECTIVIDAD ===")
        
        // 1. Health Check
        print("\n1. Testing Health Check...")
        do {
            let isHealthy = try await apiClient.healthCheck()
            print(isHealthy ? "✅ Health Check: OK" : "❌ Health Check: FAIL")
        } catch {
            print("❌ Health Check Error: \(error)")
        }
        
        // 2. Obtener tiendas
        print("\n2. Testing Obtener Tiendas...")
        do {
            let tiendas = try await apiClient.obtenerTiendas()
            print("✅ Tiendas obtenidas: \(tiendas.count)")
            
            if let primeraTienda = tiendas.first {
                print("   📍 Primera tienda: \(primeraTienda.nombre)")
                print("   📊 NPS: \(primeraTienda.nps)")
            }
        } catch {
            print("❌ Error obteniendo tiendas: \(error)")
        }
        
        // 3. Test de tiendas problemáticas
        print("\n3. Testing Tiendas Problemáticas...")
        do {
            let problematicas = try await apiClient.obtenerTiendasProblematicas()
            print("✅ Tiendas problemáticas: \(problematicas.count)")
        } catch {
            print("❌ Error obteniendo tiendas problemáticas: \(error)")
        }
        
        print("\n🧪 === TESTS DE CONECTIVIDAD COMPLETADOS ===")
    }
    
    /// Test de funcionalidad de feedback
    func runFeedbackTest() async {
        print("🧪 === INICIANDO TESTS DE FEEDBACK ===")
        
        let tiendaTest = APIConfig.TestStores.oxxo1
        
        // 1. Test enviar feedback tradicional
        print("\n1. Testing Enviar Feedback Tradicional...")
        let nuevoFeedback = NuevoFeedback(
            colaborador: "Test User",
            comentario: "Test de conectividad - El refrigerador necesita mantenimiento",
            categoria: "infraestructura",
            urgencia: "media"
        )
        
        do {
            let response = try await apiClient.enviarFeedback(tiendaId: tiendaTest, feedback: nuevoFeedback)
            print("✅ Feedback enviado: \(response.success)")
            if let analysis = response.analysis {
                print("   🤖 Análisis generado: \(analysis.generated)")
                print("   🎯 Prioridad: \(analysis.priority ?? "N/A")")
            }
        } catch {
            print("❌ Error enviando feedback: \(error)")
        }
        
        // 2. Test obtener feedback
        print("\n2. Testing Obtener Feedback...")
        do {
            let feedbacks = try await apiClient.obtenerFeedback(tiendaId: tiendaTest)
            print("✅ Feedbacks obtenidos: \(feedbacks.count)")
        } catch {
            print("❌ Error obteniendo feedback: \(error)")
        }
        
        // 3. Test insights
        print("\n3. Testing Obtener Insights...")
        do {
            let insights = try await apiClient.obtenerInsights(tiendaId: tiendaTest)
            print("✅ Insights obtenidos: \(insights.count)")
        } catch {
            print("❌ Error obteniendo insights: \(error)")
        }
        
        print("\n🧪 === TESTS DE FEEDBACK COMPLETADOS ===")
    }
    
    /// Test completo de todas las funcionalidades
    func runFullTest() async {
        print("🚀 === INICIANDO TESTS COMPLETOS DE API ===\n")
        
        await runConnectivityTest()
        await runFeedbackTest()
        
        print("\n🚀 === TODOS LOS TESTS COMPLETADOS ===")
        print("✨ Revisa los logs para ver qué funcionalidades están trabajando correctamente.")
    }
}

// MARK: - Extensión para facilitar el debugging
extension TiendasAPIClient {
    /// Función de conveniencia para testing rápido
    func quickTestExtension() async {
        let tester = APITester()
        await tester.runConnectivityTest()
    }
    
    /// Verificar si la API está respondiendo
    func isAPIResponding() async -> Bool {
        do {
            return try await healthCheck()
        } catch {
            return false
        }
    }
}
