//
//  PreVisitView.swift - FIXED
//  dimeloc
//
//  Recomendaciones de Gemini antes de la visita
//

import SwiftUI

struct PreVisitView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiClient = TiendasAPIClient()
    
    @State private var recomendaciones: RecomendacionesPrevisita?
    @State private var isLoading = false
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var colaboradorId = "user123" // TODO: Obtener del usuario actual
    @State private var tipoVisita = "regular"
    
    private let tiposVisita = ["regular", "seguimiento", "emergencia", "auditoria"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header de la tienda
                TiendaHeaderView(tienda: tienda)
                
                if isLoading || isGenerating {
                    loadingSection
                } else if let recomendaciones = recomendaciones {
                    recomendacionesSection(recomendaciones)
                } else {
                    emptyStateSection
                }
            }
            .padding()
        }
        .navigationTitle("Análisis Pre-Visita")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Generar") {
                    Task { await generarAnalisis() }
                }
                .disabled(isGenerating)
            }
        }
        .onAppear {
            Task { await cargarAnalisisExistente() }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    // MARK: - Loading Section
    
    @ViewBuilder
    private var loadingSection: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(isGenerating ? "Generando recomendaciones con IA..." : "Cargando análisis...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Esto puede tomar unos segundos")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            // Selector de tipo de visita
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Tipo de Visita", icon: "calendar")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(tiposVisita, id: \.self) { tipo in
                        Button(action: { tipoVisita = tipo }) {
                            Text(tipo.capitalized)
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(tipoVisita == tipo ? Color.purple : Color(.systemGray5))
                                .foregroundColor(tipoVisita == tipo ? .white : .primary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                Text("Sin análisis pre-visita")
                    .font(.headline)
                
                Text("Genera recomendaciones de IA basadas en el historial de esta tienda")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Generar Análisis con IA") {
                    Task { await generarAnalisis() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(isGenerating)
            }
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Recomendaciones Section
    
    @ViewBuilder
    private func recomendacionesSection(_ rec: RecomendacionesPrevisita) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Prioridad y tiempo estimado
            HStack(spacing: 16) {
                PriorityBadge(priority: rec.prioridadVisita)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tiempo estimado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(rec.tiempoEstimado)
                        .font(.subheadline)
                        .bold()
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Problemas pendientes
            if !rec.problemasPendientes.isEmpty {
                SimpleRecommendationCard(
                    title: "⚠️ Problemas Pendientes",
                    items: rec.problemasPendientes,
                    color: .red
                )
            }
            
            // Puntos a verificar
            if !rec.puntosVerificar.isEmpty {
                SimpleRecommendationCard(
                    title: "🔍 Puntos a Verificar",
                    items: rec.puntosVerificar,
                    color: .blue
                )
            }
            
            // Preguntas para el tendero
            if !rec.preguntasTendero.isEmpty {
                SimpleRecommendationCard(
                    title: "❓ Preguntas al Tendero",
                    items: rec.preguntasTendero,
                    color: .orange
                )
            }
            
            // Evidencias a capturar
            if !rec.evidenciasCapturar.isEmpty {
                SimpleRecommendationCard(
                    title: "📸 Evidencias a Capturar",
                    items: rec.evidenciasCapturar,
                    color: .green
                )
            }
            
            // Áreas de oportunidad
            if !rec.areasOportunidad.isEmpty {
                SimpleRecommendationCard(
                    title: "🎯 Áreas de Oportunidad",
                    items: rec.areasOportunidad,
                    color: .purple
                )
            }
            
            // Preparación especial
            if !rec.preparacionEspecial.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle(title: "🎒 Preparación Especial", icon: "briefcase.fill")
                    
                    Text(rec.preparacionEspecial)
                        .font(.body)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            // Botón para nueva generación
            Button("Generar Nuevo Análisis") {
                Task { await generarAnalisis() }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple.opacity(0.1))
            .foregroundColor(.purple)
            .cornerRadius(12)
            .disabled(isGenerating)
        }
    }
    
    // MARK: - Data Loading
    
    private func cargarAnalisisExistente() async {
        isLoading = true
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {
            print("ℹ️ No hay análisis pre-visita existente")
        }
        
        isLoading = false
    }
    
    private func generarAnalisis() async {
        isGenerating = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            
            // Datos de ejemplo
            recomendaciones = RecomendacionesPrevisita(
                problemasPendientes: [
                    "Revisar estado del refrigerador principal reportado hace 3 días",
                    "Verificar productos vencidos en sección lácteos"
                ],
                puntosVerificar: [
                    "Estado general de equipos de refrigeración",
                    "Organización del inventario",
                    "Limpieza de áreas de alto tráfico"
                ],
                preguntasTendero: [
                    "¿Ha notado problemas con el refrigerador?",
                    "¿Qué productos se han agotado más frecuentemente?",
                    "¿Ha recibido quejas de clientes recientemente?"
                ],
                evidenciasCapturar: [
                    "Foto del estado actual del refrigerador",
                    "Imagen del área de lácteos",
                    "Foto general de la organización de la tienda"
                ],
                areasOportunidad: [
                    "Mejorar rotación de productos perecederos",
                    "Optimizar disposición de productos de alta demanda"
                ],
                prioridadVisita: "alta",
                tiempoEstimado: "45-60 minutos",
                preparacionEspecial: "Llevar termómetro para verificar temperatura de refrigeradores"
            )
            
            print("✅ Análisis pre-visita generado para tienda \(tienda.id)")
            
        } catch {
            errorMessage = "Error generando análisis: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
}

// MARK: - Supporting Views

struct PriorityBadge: View {
    let priority: String
    
    private var color: Color {
        switch priority.lowercased() {
        case "alta", "critica": return .red
        case "media": return .orange
        case "baja": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text("Prioridad \(priority.capitalized)")
                .font(.caption)
                .bold()
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SimpleRecommendationCard: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(color)
            
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(color)
                    
                    Text(item)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        PreVisitView(tienda: .preview())
    }
}
