//
//  InsightsView.swift
//  dimeloc
//
//  Created by Maria Martinez on 15/06/25.
//

import SwiftUI

struct InsightsView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiClient = TiendasAPIClient()
    
    @State private var insights: [GeminiInsight] = []
    @State private var feedback: [Feedback] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header de la tienda
                    TiendaHeaderView(tienda: tienda)
                    
                    if isLoading {
                        ProgressView("Cargando análisis...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        // Sección de insights de Gemini
                        if !insights.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeader(title: "🤖 Análisis de Gemini", icon: "brain.fill")
                                
                                ForEach(insights) { insight in
                                    InsightCard(insight: insight)
                                }
                            }
                        }
                        
                        // Sección de feedback
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "💬 Comentarios Recientes", icon: "bubble.left.and.bubble.right.fill")
                            
                            if feedback.isEmpty {
                                Text("No hay comentarios para esta tienda")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            } else {
                                ForEach(feedback) { comment in
                                    FeedbackCard(feedback: comment)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Análisis y Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actualizar") {
                        Task {
                            await cargarDatos()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                Task {
                    await cargarDatos()
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func cargarDatos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let insightsResult = apiClient.obtenerInsights(tiendaId: tienda.id)
            async let feedbackResult = apiClient.obtenerFeedback(tiendaId: tienda.id)
            
            insights = try await insightsResult
            feedback = try await feedbackResult
            
            print("📊 Cargados \(insights.count) insights y \(feedback.count) comentarios")
        } catch {
            errorMessage = "Error cargando datos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Componentes auxiliares

struct InsightCard: View {
    let insight: GeminiInsight
    
    private var priorityColor: Color {
        switch insight.prioridad.lowercased() {
        case "alta": return .red
        case "media": return .orange
        case "baja": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header del insight
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                    Text("Análisis Gemini")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Prioridad: \(insight.prioridad.capitalized)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.2))
                    .foregroundColor(priorityColor)
                    .cornerRadius(6)
            }
            
            // Fecha del análisis
            Text("Análisis del \(formatDate(insight.fechaAnalisis))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Alertas
            if !insight.alertas.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("Alertas")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.red)
                    }
                    
                    ForEach(Array(insight.alertas.enumerated()), id: \.offset) { index, alerta in
                        Text("• \(alerta)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
            
            // Insights
            if !insight.insights.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Insights")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.orange)
                    }
                    
                    ForEach(Array(insight.insights.enumerated()), id: \.offset) { index, insightText in
                        Text("• \(insightText)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
            
            // Recomendaciones
            if !insight.recomendaciones.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Recomendaciones")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.green)
                    }
                    
                    ForEach(Array(insight.recomendaciones.enumerated()), id: \.offset) { index, recomendacion in
                        Text("• \(recomendacion)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .padding(8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "es_ES")
        
        return displayFormatter.string(from: date)
    }
}

struct FeedbackCard: View {
    let feedback: Feedback
    
    private var urgencyColor: Color {
        switch feedback.urgencia.lowercased() {
        case "alta": return .red
        case "media": return .orange
        case "baja": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(feedback.colaborador)
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Text(feedback.urgencia.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(urgencyColor.opacity(0.2))
                    .foregroundColor(urgencyColor)
                    .cornerRadius(4)
            }
            
            Text(feedback.comentario)
                .font(.caption)
                .foregroundColor(.primary)
            
            HStack {
                Text(feedback.categoria.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(3)
                
                Spacer()
                
                Text(formatDate(feedback.fecha))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "es_ES")
        
        return displayFormatter.string(from: date)
    }
}
