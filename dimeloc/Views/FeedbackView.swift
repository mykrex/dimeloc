//
//  FeedbackView.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

// Views/FeedbackView.swift

import SwiftUI

struct FeedbackView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiClient = TiendasAPIClient()
    
    @State private var colaborador = ""
    @State private var comentario = ""
    @State private var categoria = "infraestructura"
    @State private var urgencia = "media"
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    
    let categorias = ["infraestructura", "inventario", "servicio", "limpieza", "personal", "otro"]
    let urgencias = ["baja", "media", "alta"]
    
    var isFormValid: Bool {
        !colaborador.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !comentario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header de la tienda
                    TiendaHeaderView(tienda: tienda)
                    
                    // Formulario
                    VStack(alignment: .leading, spacing: 20) {
                        // Información del colaborador
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: "Información del Colaborador", icon: "person.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nombre completo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Ej: Juan Pérez", text: $colaborador)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                            }
                        }
                        
                        // Categoría del feedback
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: "Categoría del Feedback", icon: "folder.fill")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(categorias, id: \.self) { cat in
                                    CategoryButton(
                                        title: cat.capitalized,
                                        isSelected: categoria == cat,
                                        action: { categoria = cat }
                                    )
                                }
                            }
                        }
                        
                        // Nivel de urgencia
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: "Nivel de Urgencia", icon: "exclamationmark.triangle.fill")
                            
                            HStack(spacing: 12) {
                                ForEach(urgencias, id: \.self) { urg in
                                    UrgencyButton(
                                        title: urg.capitalized,
                                        level: urg,
                                        isSelected: urgencia == urg,
                                        action: { urgencia = urg }
                                    )
                                }
                            }
                        }
                        
                        // Comentario
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: "Comentario Detallado", icon: "text.bubble.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Describe la situación observada")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $comentario)
                                        .frame(minHeight: 120)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    if comentario.isEmpty {
                                        Text("Ej: El refrigerador principal no está funcionando desde hace 3 días. Los productos lácteos están a temperatura ambiente...")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                }
                                
                                Text("\(comentario.count)/500 caracteres")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        
                        // Botón de envío
                        Button(action: {
                            Task {
                                await enviarFeedback()
                            }
                        }) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isSubmitting ? "Enviando..." : "Enviar Feedback")
                                    .font(.headline)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid && !isSubmitting ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || isSubmitting)
                        
                        // Nota informativa
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            
                            Text("Este feedback será analizado automáticamente y compartido con el equipo correspondiente.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Agregar Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("¡Feedback Enviado!", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Tu feedback ha sido enviado correctamente y será analizado por el sistema.")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("Reintentar") {
                    errorMessage = nil
                }
                Button("Cancelar", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func enviarFeedback() async {
        isSubmitting = true
        
        do {
            let nuevoFeedback = NuevoFeedback(
                colaborador: colaborador.trimmingCharacters(in: .whitespacesAndNewlines),
                comentario: comentario.trimmingCharacters(in: .whitespacesAndNewlines),
                categoria: categoria,
                urgencia: urgencia
            )
            
            print("📝 Enviando feedback para tienda \(tienda.id)...")
            
            let response = try await apiClient.enviarFeedback(tiendaId: tienda.id, feedback: nuevoFeedback)
            
            if response.success {
                print("✅ Feedback enviado exitosamente")
                
                // Mostrar información del análisis si está disponible
                if let analysis = response.analysis, analysis.generated {
                    print("🤖 Gemini generó análisis - Prioridad: \(analysis.priority ?? "N/A")")
                }
                
                showingSuccess = true
            } else {
                errorMessage = response.message ?? "No se pudo enviar el feedback. Intenta nuevamente."
            }
        } catch {
            print("❌ Error enviando feedback: \(error)")
            errorMessage = "Error al enviar feedback: \(error.localizedDescription)"
        }
        
        isSubmitting = false
    }
}

// MARK: - Componentes auxiliares

struct TiendaHeaderView: View {
    let tienda: Tienda
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "storefront.fill")
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tienda.nombre)
                    .font(.headline)
                    .bold()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(tienda.performanceColor)
                        .frame(width: 8, height: 8)
                    
                    Text(tienda.performanceText)
                        .font(.caption)
                        .foregroundColor(tienda.performanceColor)
                    
                    Text("• NPS: \(Int(tienda.nps))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SectionTitle: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.headline)
            
            Text(title)
                .font(.headline)
                .bold()
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UrgencyButton: View {
    let title: String
    let level: String
    let isSelected: Bool
    let action: () -> Void
    
    private var color: Color {
        switch level {
        case "baja": return .green
        case "media": return .orange
        case "alta": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

