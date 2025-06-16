//
//  TiendaHistoryView.swift
//  dimeloc
//
//  Created by Maria Martinez on 15/06/25.
// Historial completo de una tienda con datos reales
//

import SwiftUI

struct TiendaHistoryView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiClient = TiendasAPIClient()
    
    @State private var feedbackHistorial: [Feedback] = []
    @State private var feedbackTendero: [FeedbackTendero] = []
    @State private var evaluaciones: [EvaluacionTienda] = []
    @State private var insights: [GeminiInsight] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTab = 0
    
    private let tabs = ["Feedback", "Del Tendero", "Evaluaciones", "Análisis IA"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header de la tienda
                tiendaHeaderSection
                
                // Tabs selector
                tabSelector
                
                // Contenido según tab seleccionado
                TabView(selection: $selectedTab) {
                    feedbackHistorialTab.tag(0)
                    feedbackTenderoTab.tag(1)
                    evaluacionesTab.tag(2)
                    analysisTab.tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actualizar") {
                        Task { await cargarDatos() }
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                Task { await cargarDatos() }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var tiendaHeaderSection: some View {
        VStack(spacing: 12) {
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
            
            // Métricas rápidas
            HStack(spacing: 16) {
                MetricQuickView(title: "Disponibilidad", value: "\(String(format: "%.1f%%", tienda.fillfoundrate))", color: .blue)
                MetricQuickView(title: "Daños", value: "\(String(format: "%.1f%%", tienda.damageRate))", color: tienda.damageRate > 1 ? .red : .green)
                MetricQuickView(title: "Desabasto", value: "\(String(format: "%.1f%%", tienda.outOfStock))", color: tienda.outOfStock > 4 ? .red : .green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Tab Selector
    
    @ViewBuilder
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = index
                        }
                    }) {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(selectedTab == index ? .bold : .regular)
                            .foregroundColor(selectedTab == index ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTab == index ? Color.blue : Color(.systemGray6))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Tab Views
    
    @ViewBuilder
    private var feedbackHistorialTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView("Cargando feedback...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if feedbackHistorial.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "Sin feedback",
                        subtitle: "No hay feedback registrado para esta tienda"
                    )
                } else {
                    ForEach(feedbackHistorial) { feedback in
                        FeedbackHistoryCard(feedback: feedback)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var feedbackTenderoTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView("Cargando feedback del tendero...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if feedbackTendero.isEmpty {
                    EmptyStateView(
                        icon: "person.bubble",
                        title: "Sin feedback del tendero",
                        subtitle: "El tendero no ha enviado feedback"
                    )
                } else {
                    ForEach(feedbackTendero) { feedback in
                        FeedbackTenderoCard(feedback: feedback)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var evaluacionesTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView("Cargando evaluaciones...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if evaluaciones.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.shield",
                        title: "Sin evaluaciones",
                        subtitle: "No hay evaluaciones registradas"
                    )
                } else {
                    ForEach(evaluaciones) { evaluacion in
                        EvaluacionCard(evaluacion: evaluacion)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var analysisTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView("Cargando análisis IA...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if insights.isEmpty {
                    VStack(spacing: 16) {
                        EmptyStateView(
                            icon: "brain.head.profile",
                            title: "Sin análisis IA",
                            subtitle: "No hay análisis de Gemini disponibles"
                        )
                        
                        Button("Generar Análisis") {
                            Task { await generarAnalisisManual() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ForEach(insights) { insight in
                        InsightHistoryCard(insight: insight)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Data Loading
    
    private func cargarDatos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Cargar todos los datos en paralelo
            async let feedbackResult = apiClient.obtenerFeedback(tiendaId: tienda.id)
            async let insightsResult = apiClient.obtenerInsights(tiendaId: tienda.id)
            async let feedbackTenderoResult = apiClient.obtenerFeedbackTendero(tiendaId: tienda.id)
            async let evaluacionesResult = apiClient.obtenerEvaluacionesTienda(tiendaId: tienda.id)
            
            // Esperar resultados
            feedbackHistorial = try await feedbackResult
            insights = try await insightsResult
            feedbackTendero = try await feedbackTenderoResult
            evaluaciones = try await evaluacionesResult
            
            print("📊 Historial cargado para tienda \(tienda.id):")
            print("   - Feedback: \(feedbackHistorial.count)")
            print("   - Insights: \(insights.count)")
            print("   - Feedback tendero: \(feedbackTendero.count)")
            print("   - Evaluaciones: \(evaluaciones.count)")
            
        } catch {
            errorMessage = "Error cargando historial: \(error.localizedDescription)"
            print("❌ Error cargando datos para tienda \(tienda.id): \(error)")
        }
        
        isLoading = false
    }
    
    private func generarAnalisisManual() async {
        isLoading = true
        
        do {
            _ = try await apiClient.analizarTiendaManualmente(tiendaId: tienda.id)
            // Recargar insights después del análisis
            insights = try await apiClient.obtenerInsights(tiendaId: tienda.id)
            print("✅ Análisis manual completado para tienda \(tienda.id)")
        } catch {
            errorMessage = "Error generando análisis: \(error.localizedDescription)"
            print("❌ Error generando análisis para tienda \(tienda.id): \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct MetricQuickView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct FeedbackHistoryCard: View {
    let feedback: Feedback
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feedback.colaborador)
                        .font(.subheadline)
                        .bold()
                    
                    Text(feedback.fecha.displayDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(feedback.categoria.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Text(feedback.urgencia.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(urgencyColor(feedback.urgencia).opacity(0.2))
                        .foregroundColor(urgencyColor(feedback.urgencia))
                        .cornerRadius(4)
                }
            }
            
            Text(feedback.comentario)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Image(systemName: feedback.resuelto ? "checkmark.circle.fill" : "clock.circle")
                    .foregroundColor(feedback.resuelto ? .green : .orange)
                
                Text(feedback.resuelto ? "Resuelto" : "Pendiente")
                    .font(.caption)
                    .foregroundColor(feedback.resuelto ? .green : .orange)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private func urgencyColor(_ urgencia: String) -> Color {
        switch urgencia.lowercased() {
        case "critica", "alta": return .red
        case "media": return .orange
        case "baja": return .green
        default: return .gray
        }
    }
}

struct FeedbackTenderoCard: View {
    let feedback: FeedbackTendero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feedback.titulo)
                        .font(.subheadline)
                        .bold()
                    
                    Text(feedback.fecha.displayDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(feedback.tipo.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                    
                    Text(feedback.urgencia.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(urgencyColor(feedback.urgencia).opacity(0.2))
                        .foregroundColor(urgencyColor(feedback.urgencia))
                        .cornerRadius(4)
                }
            }
            
            Text(feedback.descripcion)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Image(systemName: "person.bubble")
                    .foregroundColor(.blue)
                
                Text("Feedback del tendero • \(feedback.categoria.capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if feedback.seguimientoRequerido {
                    Text("Requiere seguimiento")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private func urgencyColor(_ urgencia: String) -> Color {
        switch urgencia.lowercased() {
        case "critica", "alta": return .red
        case "media": return .orange
        case "baja": return .green
        default: return .gray
        }
    }
}

struct EvaluacionCard: View {
    let evaluacion: EvaluacionTienda
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Evaluación de Tienda")
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Text(evaluacion.fecha.displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Aspectos evaluados
            VStack(alignment: .leading, spacing: 8) {
                EvaluacionAspectoRow(titulo: "Limpieza", calificacion: evaluacion.aspectos.limpieza.calificacion)
                EvaluacionAspectoRow(titulo: "Mobiliario", calificacion: evaluacion.aspectos.mobiliario.calificacion)
                EvaluacionAspectoRow(titulo: "Atención Cliente", calificacion: evaluacion.aspectos.atencionCliente.calificacion)
                EvaluacionAspectoRow(titulo: "Organización", calificacion: evaluacion.aspectos.organizacion.calificacion)
            }
            
            if !evaluacion.observacionesGenerales.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Observaciones:")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    Text(evaluacion.observacionesGenerales)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct EvaluacionAspectoRow: View {
    let titulo: String
    let calificacion: Int
    
    var body: some View {
        HStack {
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= calificacion ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundColor(index <= calificacion ? .yellow : .gray)
                }
            }
        }
    }
}

struct InsightHistoryCard: View {
    let insight: GeminiInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                    Text("Análisis Gemini")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                Text(insight.fechaAnalisis.displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !insight.alertas.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🚨 Alertas:")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.red)
                    
                    ForEach(insight.alertas, id: \.self) { alerta in
                        Text("• \(alerta)")
                            .font(.caption)
                    }
                }
            }
            
            if !insight.insights.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Insights:")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.orange)
                    
                    ForEach(insight.insights, id: \.self) { insightText in
                        Text("• \(insightText)")
                            .font(.caption)
                    }
                }
            }
            
            if !insight.recomendaciones.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("✅ Recomendaciones:")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.green)
                    
                    ForEach(insight.recomendaciones, id: \.self) { recomendacion in
                        Text("• \(recomendacion)")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        Text("TiendaHistoryView Preview")
            .navigationTitle("Historial")
    }
}
