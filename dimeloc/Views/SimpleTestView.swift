//
//  SimpleTestView.swift
//  dimeloc
//
//  Created by Maria Martinez on 15/06/25.
//

import SwiftUI

struct SimpleTestView: View {
    @StateObject private var apiClient = TiendasAPIClient()
    @State private var isLoading = false
    @State private var testMessage = "Presiona el botón para probar la API"
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🧪 Test de API")
                .font(.largeTitle)
                .bold()
            
            Text(testMessage)
                .multilineTextAlignment(.center)
                .padding()
            
            if isLoading {
                ProgressView("Probando...")
                    .scaleEffect(1.2)
            } else {
                Button("Probar Conectividad") {
                    Task {
                        await testAPI()
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func testAPI() async {
        isLoading = true
        testMessage = "Probando conectividad..."
        
        // Test básico
        do {
            let isHealthy = try await apiClient.healthCheck()
            if isHealthy {
                testMessage = "✅ Servidor respondiendo correctamente"
                
                // Intentar obtener tiendas
                let tiendas = try await apiClient.obtenerTiendas()
                testMessage = "✅ API funcionando!\n\n📊 \(tiendas.count) tiendas obtenidas\n\nTu backend está listo para el frontend 🚀"
            } else {
                testMessage = "❌ Servidor no responde correctamente"
            }
        } catch {
            testMessage = "❌ Error de conectividad:\n\(error.localizedDescription)\n\nVerifica que tu backend esté corriendo"
        }
        
        isLoading = false
    }
}

#Preview {
    SimpleTestView()
}
