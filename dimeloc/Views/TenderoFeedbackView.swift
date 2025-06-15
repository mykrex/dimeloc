//
//  TenderoFeedbackView.swift
//  dimeloc
//
//  Capturar feedback del tendero hacia la empresa
//

import SwiftUI

struct TenderoFeedbackView: View {
    let tienda: Tienda
    let visitaId: String?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiClient = TiendasAPIClient()
    
    @State private var colaboradorId = "user123" // TODO: Obtener del usuario actual
    @State private var categoria = "servicio"
    @State private var tipo = "queja"
    @State private var urgencia = "media"
    @State private var titulo = ""
    @State private var descripcion = ""
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    
    let categorias = ["servicio", "entrega", "producto", "facturacion", "otro"]
    let tipos = ["queja", "sugerencia", "felicitacion", "reporte_incidente"]
    let urgencias = ["baja", "media", "alta", "critica"]
    
    var isFormValid: Bool {
        !titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header de la tienda
                    TenderoTiendaHeaderView(tienda: tienda)
                    
                    // Información del tendero
                    infoSection
                    
                    // Formulario
                    VStack(alignment: .leading, spacing: 20) {
                        // Tipo de feedback
                        VStack(alignment: .leading, spacing: 12) {
                            TenderoSectionTitle(title: "Tipo de Feedback", icon: "bubble.left.and.bubble.right.fill")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(tipos, id: \.self) { tipoItem in
                                    FeedbackTypeButton(
                                        title: tipoTexto(tipoItem),
                                        icon: tipoIcon(tipoItem),
                                        isSelected: tipo == tipoItem,
                                        color: tipoColor(tipoItem),
                                        action: { tipo = tipoItem }
                                    )
                                }
                            }
                        }
                        
                        // Categoría
                        VStack(alignment: .leading, spacing: 12) {
                            TenderoSectionTitle(title: "Categoría", icon: "folder.fill")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(categorias, id: \.self) { cat in
                                    TenderoCategoryButton(
                                        title: cat.capitalized,
                                        isSelected: categoria == cat,
                                        action: { categoria = cat }
                                    )
                                }
                            }
                        }
                        
                        // Urgencia
                        VStack(alignment: .leading, spacing: 12) {
                            TenderoSectionTitle(title: "Nivel de Urgencia", icon: "exclamationmark.triangle.fill")
                            
                            HStack(spacing: 8) {
                                ForEach(urgencias, id: \.self) { urg in
                                    TenderoUrgencyButton(
                                        title: urg.capitalized,
                                        level: urg,
                                        isSelected: urgencia == urg,
                                        action: { urgencia = urg }
                                    )
                                }
                            }
                        }
                        
                        // Título
                        VStack(alignment: .leading, spacing: 12) {
                            TenderoSectionTitle(title: "Título del Feedback", icon: "textformat")
                            
                            TextField("Ej: Problemas con entregas tardías", text: $titulo)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.sentences)
                        }
                        
                        // Descripción
                        VStack(alignment: .leading, spacing: 12) {
                            TenderoSectionTitle(title: "Descripción Detallada", icon: "text.bubble.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Describe la situación desde tu perspectiva como tendero")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $descripcion)
                                        .frame(minHeight: 120)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    
                                    if descripcion.isEmpty {
                                        Text("Ej: Las entregas han estado llegando 2-3 horas tarde durante la última semana. Esto está afectando la disponibilidad de productos frescos...")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                }
                                
                                Text("\(descripcion.count)/500 caracteres")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        
                        // Botón de envío
                        Button(action: {
                            Task { await enviarFeedback() }
                        }) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isSubmitting ? "Enviando..." : "Enviar Feedback del Tendero")
                                    .font(.headline)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid && !isSubmitting ? Color.purple : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || isSubmitting)
                        
                        // Nota informativa
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.purple)
                            
                            Text("Este feedback será enviado directamente al equipo de la empresa para su seguimiento.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Feedback del Tendero")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .alert("¡Feedback Enviado!", isPresented: $showingSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("El feedback del tendero ha sido enviado y será revisado por el equipo correspondiente.")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("Reintentar") { errorMessage = nil }
            Button("Cancelar", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    // MARK: - Info Section
    
    @ViewBuilder
    private var infoSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.title2)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Feedback del Tendero")
                    .font(.headline)
                    .bold()
                
                Text("Comparte tu experiencia y sugerencias con la empresa")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Functions
    
    private func tipoTexto(_ tipo: String) -> String {
        switch tipo {
        case "queja": return "Queja"
        case "sugerencia": return "Sugerencia"
        case "felicitacion": return "Felicitación"
        case "reporte_incidente": return "Incidente"
        default: return tipo.capitalized
        }
    }
    
    private func tipoIcon(_ tipo: String) -> String {
        switch tipo {
        case "queja": return "exclamationmark.circle"
        case "sugerencia": return "lightbulb"
        case "felicitacion": return "hand.thumbsup"
        case "reporte_incidente": return "exclamationmark.triangle"
        default: return "bubble"
        }
    }
    
    private func tipoColor(_ tipo: String) -> Color {
        switch tipo {
        case "queja": return .red
        case "sugerencia": return .blue
        case "felicitacion": return .green
        case "reporte_incidente": return .orange
        default: return .gray
        }
    }
    
    // MARK: - Data Submission
    
    private func enviarFeedback() async {
        isSubmitting = true
        
        do {
            // Validar tienda antes de continuar
            guard tienda.isValidId else {
                errorMessage = "Error: ID de tienda inválido (\(tienda.id))"
                isSubmitting = false
                return
            }
            
            let nuevoFeedback = NuevoFeedbackTendero(
                visitaId: visitaId,
                tiendaId: tienda.id,
                colaboradorId: colaboradorId,
                categoria: categoria,
                tipo: tipo,
                urgencia: urgencia,
                titulo: titulo.trimmingCharacters(in: .whitespacesAndNewlines),
                descripcion: descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            print("📝 Enviando feedback del tendero para tienda \(tienda.id) (\(tienda.nombre))...")
            print("   Tipo: \(tipoTexto(tipo))")
            print("   Categoría: \(categoria)")
            print("   Urgencia: \(urgencia)")
            print("   Título: \(titulo)")
            print("   Descripción: \(descripcion)")
            
            // Por ahora simular el envío - cuando tengas el endpoint funcionando, descomenta esto:
            // let response = try await apiClient.enviarFeedbackTenderoSafe(feedback: nuevoFeedback)
            
            // Simulación del envío
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            print("✅ Feedback del tendero enviado exitosamente")
            showingSuccess = true
            
        } catch {
            print("❌ Error enviando feedback del tendero: \(error)")
            errorMessage = "Error al enviar feedback: \(error.localizedDescription)"
        }
        
        isSubmitting = false
    }
}

// MARK: - Supporting Views (Componentes únicos para evitar conflictos)

struct TenderoTiendaHeaderView: View {
    let tienda: Tienda
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "storefront.fill")
                .font(.title)
                .foregroundColor(.purple)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.1))
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

struct TenderoSectionTitle: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.headline)
            
            Text(title)
                .font(.headline)
                .bold()
        }
    }
}

struct TenderoCategoryButton: View {
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
                .background(isSelected ? Color.purple : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TenderoUrgencyButton: View {
    let title: String
    let level: String
    let isSelected: Bool
    let action: () -> Void
    
    private var color: Color {
        switch level {
        case "baja": return .green
        case "media": return .orange
        case "alta": return .red
        case "critica": return .purple
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

struct FeedbackTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : color)
                
                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color : Color(.systemGray5))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct TenderoFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        TenderoFeedbackView(tienda: Tienda.preview(), visitaId: nil)
    }
}
