//
//  GeminiInsightsView.swift
//  dimeloc
//
//  Created by Maria Martinez on 15/06/25.
//
//  Vista de análisis detallado de IA para una tienda específica
//

import SwiftUI

struct GeminiInsightsView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiClient = TiendasAPIClient()
    
    @State private var insights: [GeminiInsight] = []
    @State private var analisisGemini: [AnalisisGemini] = []
    @State private var isLoading = false
    @State private var isGeneratingAnalysis = false
    @State private var errorMessage: String?
    @State private var selectedTab = 0
    
    private let tabs = ["Insights Recientes", "Previsita", "Predicciones"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con info de la tienda
            headerSection
            
            // Tab selector
            tabSelector
            
            // Contenido principal
            TabView(selection: $selectedTab) {
                insightsRecentesTab.tag(0)
                analisisDetalladoTab.tag(1)
                prediccionesTab.tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Análisis IA")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Actualizar datos") {
                        Task { await cargarDatos() }
                    }
                    
                    Button("Generar análisis nuevo") {
                        Task { await generarNuevoAnalisis() }
                    }
                    
                    Button("Análisis pre-visita") {
                        Task { await generarAnalisisPrevisita() }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
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
   
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tienda.nombre)
                        .font(.headline)
                        .bold()
                    
                    Text("Análisis de Inteligencia Artificial")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text("Gemini AI")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .bold()
                    }
                    
                    Text("ID: \(tienda.id)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Estado del análisis
            if isLoading || isGeneratingAnalysis {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text(isGeneratingAnalysis ? "Generando análisis..." : "Cargando datos...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
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
                                    .fill(selectedTab == index ? Color.purple : Color(.systemGray6))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var insightsRecentesTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if insights.isEmpty && !isLoading {
                    EmptyInsightsView {
                        Task { await generarNuevoAnalisis() }
                    }
                } else {
                    ForEach(insights) { insight in
                        GeminiInsightCard(insight: insight)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var analisisDetalladoTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let analisisPrevisita = analisisGemini.filter { $0.tipoAnalisis == "previsita" }
                
                if analisisPrevisita.isEmpty && !isLoading {
                    EmptyAnalysisView {
                        Task { await generarAnalisisPrevisita() }
                    }
                } else {
                    ForEach(analisisPrevisita) { analisis in
                        AnalisisDetalladoCard(analisis: analisis)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var prediccionesTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Sección de predicciones
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.orange)
                        Text("Predicciones para \(tienda.nombre)")
                            .font(.headline)
                            .bold()
                    }
                    
                    Button("Generar Predicciones") {
                        Task { await generarPredicciones() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(isGeneratingAnalysis)
                    
                    if isGeneratingAnalysis {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generando predicciones...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    
                    Text("Análisis predictivo basado en historial de 6 meses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
                
                // MOSTRAR PREDICCIONES ENCONTRADAS
                let predicciones = analisisGemini.filter { $0.tipoAnalisis == "prediccion" }
                
                if !predicciones.isEmpty {
                    ForEach(predicciones) { prediccion in
                        PrediccionCard(prediccion: prediccion)
                    }
                } else if !isGeneratingAnalysis {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                        
                        Text("Sin predicciones generadas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Genera predicciones para ver análisis predictivo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Data Loading
    
    private func generarNuevoAnalisis() async {
        isGeneratingAnalysis = true
        
        do {
            _ = try await apiClient.analizarTiendaManualmente(tiendaId: tienda.id)
            // Recargar insights después del análisis
            insights = try await apiClient.obtenerInsights(tiendaId: tienda.id)
        } catch {
            errorMessage = "Error generando análisis: \(error.localizedDescription)"
        }
        
        isGeneratingAnalysis = false
    }
    
    private func generarAnalisisPrevisita() async {
        isGeneratingAnalysis = true
        
        do {
            // ✅ USAR EL MÉTODO REAL
            let colaboradorId = "684e8db898718bc7d62aee7f" // TODO: obtener del usuario actual
            _ = try await apiClient.generarAnalisisPrevisita(
                tiendaId: tienda.id,
                colaboradorId: colaboradorId
            )
            
            // Recargar datos después del análisis
            analisisGemini = try await apiClient.obtenerAnalisisGemini(tiendaId: tienda.id)
            
            print("🔮 Análisis pre-visita completado para tienda \(tienda.id)")
            
        } catch {
            print("❌ Error generando análisis pre-visita: \(error)")
            errorMessage = "Error generando análisis pre-visita: \(error.localizedDescription)"
        }
        
        isGeneratingAnalysis = false
    }
 
    private func generarPredicciones() async {
        isGeneratingAnalysis = true
        
        do {
            // GENERAR PREDICCIONES
            let response = try await apiClient.generarPredicciones(tiendaId: tienda.id)
            
            if response.success {
                print("🔮 Predicciones generadas exitosamente")
                
                // RECARGAR ANÁLISIS GEMINI DESPUÉS DE GENERAR PREDICCIONES
                // Esperar un poco para asegurar que se guarden en BD
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
                
                // Recargar TODOS los análisis Gemini (incluyendo predicciones)
                analisisGemini = try await apiClient.obtenerAnalisisGemini(tiendaId: tienda.id)
                
                print("📊 Análisis Gemini recargados: \(analisisGemini.count)")
                print("🔍 Tipos de análisis encontrados:")
                for analisis in analisisGemini {
                    print("   - \(analisis.tipoAnalisis) - \(analisis.fechaAnalisis)")
                }
                
            } else {
                errorMessage = "Error: Predicciones no pudieron generarse"
            }
            
        } catch {
            print("❌ Error generando predicciones: \(error)")
            errorMessage = "Error generando predicciones: \(error.localizedDescription)"
        }
        
        isGeneratingAnalysis = false
    }
    
    private func cargarDatos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Cargar insights existentes
            insights = try await apiClient.obtenerInsights(tiendaId: tienda.id)
            
            // Cargar análisis Gemini detallados (por ahora vacío)
            analisisGemini = try await apiClient.obtenerAnalisisGemini(tiendaId: tienda.id)
            
            print("📊 Cargados \(insights.count) insights y \(analisisGemini.count) análisis para tienda \(tienda.id)")
        } catch {
            print("❌ Error cargando análisis: \(error)")
            errorMessage = "Error cargando análisis: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct GeminiInsightCard: View {
    let insight: GeminiInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis Gemini")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.purple)
                    
                    Text(insight.fechaAnalisis.displayDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(insight.prioridad.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor(insight.prioridad).opacity(0.2))
                    .foregroundColor(priorityColor(insight.prioridad))
                    .cornerRadius(8)
            }
            
            if let resumen = insight.resumen {
                Text(resumen)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            if !insight.alertas.isEmpty {
                DisclosureGroup("Alertas (\(insight.alertas.count))") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(insight.alertas, id: \.self) { alerta in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                
                                Text(alerta)
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .tint(.red)
            }
            
            if !insight.recomendaciones.isEmpty {
                DisclosureGroup("Recomendaciones (\(insight.recomendaciones.count))") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(insight.recomendaciones, id: \.self) { recomendacion in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text(recomendacion)
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .tint(.green)
            }
            
            if let totalComentarios = insight.totalComentarios {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Basado en \(totalComentarios) comentario(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
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
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "alta", "critica": return .red
        case "media": return .orange
        case "baja": return .green
        default: return .gray
        }
    }
}

struct AnalisisDetalladoCard: View {
    let analisis: AnalisisGemini
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: iconForAnalysisType(analisis.tipoAnalisis))
                        .foregroundColor(colorForAnalysisType(analisis.tipoAnalisis))
                    
                    Text(displayNameForAnalysisType(analisis.tipoAnalisis))
                        .font(.headline)
                        .bold()
                        .foregroundColor(colorForAnalysisType(analisis.tipoAnalisis))
                }
                
                Spacer()
                
                Text(analisis.fechaAnalisis.displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // MOSTRAR CONTENIDO SEGÚN EL TIPO DE ANÁLISIS
            if analisis.tipoAnalisis == "previsita" {
                if let recomendaciones = analisis.recomendaciones {
                    RecomendacionesPrevisitaView(recomendaciones: recomendaciones)
                } else {
                    Text("Recomendaciones pre-visita generadas exitosamente")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else if analisis.tipoAnalisis == "postvisita" {
                if let resultados = analisis.resultados {
                    ResultadosPostvisitaView(resultados: resultados)
                } else {
                    Text("Resultados post-visita generados")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else if analisis.tipoAnalisis == "prediccion" {
                Text("Este análisis corresponde a predicciones")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .italic()
            } else {
                Text("Tipo de análisis: \(analisis.tipoAnalisis)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorForAnalysisType(analisis.tipoAnalisis).opacity(0.3), lineWidth: 1)
        )
    }
    
    // FUNCIONES HELPER PARA MEJORAR LA PRESENTACIÓN
    private func displayNameForAnalysisType(_ tipo: String) -> String {
        switch tipo.lowercased() {
        case "previsita": return "Recomendaciones Pre-Visita"
        case "postvisita": return "📊 Resultados Post-Visita"
        case "prediccion": return "🔮 Predicciones"
        case "tendencias": return "📈 Análisis de Tendencias"
        default: return tipo.capitalized
        }
    }
    
    private func iconForAnalysisType(_ tipo: String) -> String {
        switch tipo.lowercased() {
        case "previsita": return "list.clipboard"
        case "postvisita": return "chart.bar.doc.horizontal"
        case "prediccion": return "chart.line.uptrend.xyaxis"
        case "tendencias": return "chart.xyaxis.line"
        default: return "doc.text"
        }
    }
    
    private func colorForAnalysisType(_ tipo: String) -> Color {
        switch tipo.lowercased() {
        case "previsita": return .blue
        case "postvisita": return .green
        case "prediccion": return .orange
        case "tendencias": return .purple
        default: return .gray
        }
    }
}


struct RecomendacionesPrevisitaView: View {
    let recomendaciones: RecomendacionesPrevisita
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            if !recomendaciones.problemasPendientes.isEmpty {
                Text("⚠️ Problemas pendientes:")
                    .font(.caption)
                    .bold()
                ForEach(recomendaciones.problemasPendientes, id: \.self) { problema in
                    Text("• \(problema)")
                        .font(.caption)
                }
            }
            
            if !recomendaciones.puntosVerificar.isEmpty {
                Text("🔍 Puntos a verificar:")
                    .font(.caption)
                    .bold()
                ForEach(recomendaciones.puntosVerificar, id: \.self) { punto in
                    Text("• \(punto)")
                        .font(.caption)
                }
            }
        }
    }
}

struct ResultadosPostvisitaView: View {
    let resultados: ResultadosPostvisita
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📊 Resultados Post-Visita")
                .font(.subheadline)
                .bold()
            
            Text(resultados.resumenEjecutivo)
                .font(.caption)
                .padding(.bottom, 4)
            
            if !resultados.mejorasImplementadas.isEmpty {
                Text("✅ Mejoras implementadas:")
                    .font(.caption)
                    .bold()
                ForEach(resultados.mejorasImplementadas, id: \.self) { mejora in
                    Text("• \(mejora)")
                        .font(.caption)
                }
            }
        }
    }
}

struct PrediccionCard: View {
    let prediccion: AnalisisGemini
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.orange)
                
                Text("Predicciones IA")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text(prediccion.fechaAnalisis.displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Contenido de predicciones
            if let prediccionesData = parsePredicciones(from: prediccion) {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Nivel de riesgo
                    HStack {
                        Text("Nivel de Riesgo:")
                            .font(.subheadline)
                            .bold()
                        
                        Text(prediccionesData.nivelRiesgo.capitalized)
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(riskColor(prediccionesData.nivelRiesgo).opacity(0.2))
                            .foregroundColor(riskColor(prediccionesData.nivelRiesgo))
                            .cornerRadius(6)
                    }
                    
                    // Problemas potenciales
                    if !prediccionesData.problemasPotenciales.isEmpty {
                        DisclosureGroup("Problemas Potenciales") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(prediccionesData.problemasPotenciales, id: \.self) { problema in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundColor(.red)
                                        Text(problema)
                                            .font(.caption)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .tint(.red)
                    }
                    
                    // Métricas en riesgo
                    if !prediccionesData.metricasEnRiesgo.isEmpty {
                        DisclosureGroup("Métricas en Riesgo") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(prediccionesData.metricasEnRiesgo, id: \.self) { metrica in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundColor(.orange)
                                        Text(metrica)
                                            .font(.caption)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .tint(.orange)
                    }
                    
                    // Acciones preventivas
                    if !prediccionesData.accionesPreventivas.isEmpty {
                        DisclosureGroup("Acciones Preventivas") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(prediccionesData.accionesPreventivas, id: \.self) { accion in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundColor(.green)
                                        Text(accion)
                                            .font(.caption)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .tint(.green)
                    }
                    
                    // Frecuencia sugerida
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        
                        Text("Frecuencia sugerida:")
                            .font(.caption)
                            .bold()
                        
                        Text(prediccionesData.frecuenciaVisitasSugerida)
                            .font(.caption)
                    }
                    .padding(.top, 8)
                }
            } else {
                // Fallback si no hay datos estructurados
                Text("Predicciones generadas el \(prediccion.fechaAnalisis.displayDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Los datos predictivos están siendo procesados...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // FUNCIÓN PARA EXTRAER PREDICCIONES
    private func parsePredicciones(from analisis: AnalisisGemini) -> AnalisisPredicciones? {
        // Si tienes predicciones estructuradas, úsalas
        if let predicciones = analisis.predicciones {
            return predicciones
        }
        
        // Si las predicciones están en otro campo, intenta extraerlas
        // Por ahora, retornar nil para usar el fallback
        return nil
    }
    
    private func riskColor(_ nivel: String) -> Color {
        switch nivel.lowercased() {
        case "alto", "critico": return .red
        case "medio": return .orange
        case "bajo": return .green
        default: return .gray
        }
    }
}


struct EmptyInsightsView: View {
    let onGenerateAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundColor(.purple)
            
            Text("Sin análisis de IA")
                .font(.headline)
            
            Text("No hay insights de Gemini para esta tienda")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generar Análisis") {
                onGenerateAction()
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct EmptyAnalysisView: View {
    let onGenerateAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Sin análisis detallado")
                .font(.headline)
            
            Text("Genera un análisis pre-visita para obtener recomendaciones específicas")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generar Análisis Pre-Visita") {
                onGenerateAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    NavigationView {
        VStack {
            Text("GeminiInsightsView")
                .font(.title)
            Text("Vista de análisis de IA")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Análisis IA")
    }
}
