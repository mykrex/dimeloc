//
//  SafeTestView.swift
//  dimeloc
//
//  Created by Maria Martinez on 15/06/25.
//

import SwiftUI

struct SafeTestView: View {
    @StateObject private var apiClient = TiendasAPIClient()
    @State private var isLoading = false
    @State private var testResults: [String] = []
    @State private var connectionStatus = "🔵 No probado"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("🧪 Test de API")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                // Status
                Text(connectionStatus)
                    .font(.headline)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                // API Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("🔗 Backend URL:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("dimeloc-backend.onrender.com")
                        .font(.caption)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Buttons
                VStack(spacing: 16) {
                    Button("🔍 Health Check") {
                        testHealthCheck()
                    }
                    .buttonStyle(TestButtonStyle(color: .blue))
                    .disabled(isLoading)
                    
                    Button("📊 Obtener Tiendas") {
                        testGetTiendas()
                    }
                    .buttonStyle(TestButtonStyle(color: .green))
                    .disabled(isLoading)
                    
                    Button("💬 Test Feedback") {
                        testFeedback()
                    }
                    .buttonStyle(TestButtonStyle(color: .purple))
                    .disabled(isLoading)
                }
                
                // Results
                if !testResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("📋 Resultados:")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            ForEach(Array(testResults.enumerated()), id: \.offset) { index, result in
                                Text(result)
                                    .font(.caption)
                                    .foregroundColor(getResultColor(result))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxHeight: 200)
                }
                
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Probando...")
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Test Functions
    
    private func testHealthCheck() {
        guard !isLoading else { return }
        
        isLoading = true
        connectionStatus = "🟡 Probando health check..."
        
        Task {
            do {
                let isHealthy = try await apiClient.healthCheck()
                
                await MainActor.run {
                    if isHealthy {
                        connectionStatus = "🟢 Servidor OK"
                        testResults.append("✅ Health check exitoso")
                    } else {
                        connectionStatus = "🔴 Servidor no responde"
                        testResults.append("❌ Health check falló")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "🔴 Error de conexión"
                    testResults.append("❌ Error: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    private func testGetTiendas() {
        guard !isLoading else { return }
        
        isLoading = true
        connectionStatus = "🟡 Obteniendo tiendas..."
        
        Task {
            do {
                let tiendas = try await apiClient.obtenerTiendas()
                
                await MainActor.run {
                    connectionStatus = "🟢 \(tiendas.count) tiendas obtenidas"
                    testResults.append("✅ Tiendas: \(tiendas.count)")
                    
                    if let primera = tiendas.first {
                        testResults.append("   📍 Primera: \(primera.nombre)")
                        testResults.append("   📊 NPS: \(primera.nps)")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "🔴 Error obteniendo tiendas"
                    testResults.append("❌ Error tiendas: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    private func testFeedback() {
        guard !isLoading else { return }
        
        isLoading = true
        connectionStatus = "🟡 Probando feedback..."
        
        Task {
            let feedback = NuevoFeedback(
                colaborador: "Test iOS",
                comentario: "Prueba desde iOS app",
                categoria: "infraestructura",
                urgencia: "baja"
            )
            
            do {
                let response = try await apiClient.enviarFeedback(tiendaId: 1, feedback: feedback)
                
                await MainActor.run {
                    if response.success {
                        connectionStatus = "🟢 Feedback enviado OK"
                        testResults.append("✅ Feedback enviado correctamente")
                        
                        if let analysis = response.analysis, analysis.generated {
                            testResults.append("   🤖 Análisis IA generado")
                        }
                    } else {
                        connectionStatus = "🔴 Error en feedback"
                        testResults.append("❌ Feedback falló")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "🔴 Error enviando feedback"
                    testResults.append("❌ Error feedback: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    }
    
    private func getResultColor(_ result: String) -> Color {
        if result.contains("✅") {
            return .green
        } else if result.contains("❌") {
            return .red
        } else if result.contains("🤖") {
            return .purple
        } else {
            return .primary
        }
    }
}

// MARK: - Custom Button Style
struct TestButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    SafeTestView()
}
