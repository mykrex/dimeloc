//
//  TrendsView.swift
//  dimeloc
//
//  Created by Maria Martinez on 15/06/25.
//  Vista de tendencias y patrones generales

import SwiftUI

struct TrendsView: View {
    @StateObject private var apiClient = TiendasAPIClient()
    
    @State private var tendencias: AnalisisTendencias?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPeriod = "3meses"
    @State private var selectedMetric = "all"
    
    private let periods = [
        ("1mes", "Último mes"),
        ("3meses", "Últimos 3 meses"),
        ("6meses", "Últimos 6 meses"),
        ("1año", "Último año")
    ]
    
    private let metrics = [
        ("all", "Todas las métricas"),
        ("nps", "NPS"),
        ("damage", "Productos dañados"),
        ("stock", "Desabastecimiento"),
        ("service", "Servicio al cliente")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con controles
                    headerSection
                    
                    if isLoading {
                        loadingSection
                    } else if let tendencias = tendencias {
                        // Secciones de análisis
                        tendenciasPrincipalesSection(tendencias)
                        problemasEstacionalesSection(tendencias)
                        oportunidadesSection(tendencias)
                        prediccionesSection(tendencias)
                        alertasSection(tendencias)
                        recomendacionesSection(tendencias)
                    } else {
                        emptyStateSection
                    }
                }
                .padding()
            }
            .navigationTitle("Tendencias y Patrones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actualizar") {
                        Task { await cargarTendencias() }
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                Task { await cargarTendencias() }
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
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis de Tendencias")
                        .font(.title2)
                        .bold()
                    
                    Text("Patrones y predicciones generadas por IA")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            // Filtros
            VStack(spacing: 12) {
                HStack {
                    Text("Período:")
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(periods, id: \.0) { period in
                            Text(period.1).tag(period.0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedPeriod) { _ in
                        Task { await cargarTendencias() }
                    }
                }
                
                HStack {
                    Text("Métrica:")
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
                    Picker("Métrica", selection: $selectedMetric) {
                        ForEach(metrics, id: \.0) { metric in
                            Text(metric.1).tag(metric.0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedMetric) { _ in
                        Task { await cargarTendencias() }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Content Sections
    
    @ViewBuilder
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Analizando tendencias con IA...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Esto puede tomar unos segundos")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    @ViewBuilder
    private func tendenciasPrincipalesSection(_ tendencias: AnalisisTendencias) -> some View {
        TrendsSectionCard(
            title: "📈 Tendencias Principales",
            icon: "chart.line.uptrend.xyaxis",
            color: .blue,
            items: tendencias.tendenciasPrincipales
        )
    }
    
    @ViewBuilder
    private func problemasEstacionalesSection(_ tendencias: AnalisisTendencias) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(.orange)
                
                Text("📅 Problemas Estacionales")
                    .font(.headline)
                    .bold()
            }
            
            if tendencias.problemasEstacionales.isEmpty {
                Text("No se detectaron patrones estacionales específicos")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(tendencias.problemasEstacionales.keys.sorted()), id: \.self) { mes in
                    HStack {
                        Text("Mes \(mes):")
                            .font(.subheadline)
                            .bold()
                        
                        Text(tendencias.problemasEstacionales[mes] ?? "")
                            .font(.subheadline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
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
    
    @ViewBuilder
    private func oportunidadesSection(_ tendencias: AnalisisTendencias) -> some View {
        TrendsSectionCard(
            title: "🎯 Sectores de Oportunidad",
            icon: "target",
            color: .green,
            items: tendencias.sectoresOportunidad
        )
    }
    
    @ViewBuilder
    private func prediccionesSection(_ tendencias: AnalisisTendencias) -> some View {
        TrendsSectionCard(
            title: "🔮 Predicciones 3 Meses",
            icon: "crystal.ball",
            color: .purple,
            items: tendencias.predicciones3Meses
        )
    }
    
    @ViewBuilder
    private func alertasSection(_ tendencias: AnalisisTendencias) -> some View {
        TrendsSectionCard(
            title: "⚠️ Alertas Tempranas",
            icon: "exclamationmark.triangle",
            color: .red,
            items: tendencias.alertasTempranas
        )
    }
    
    @ViewBuilder
    private func recomendacionesSection(_ tendencias: AnalisisTendencias) -> some View {
        TrendsSectionCard(
            title: "💡 Recomendaciones Estratégicas",
            icon: "lightbulb",
            color: .indigo,
            items: tendencias.recomendacionesEstrategicas
        )
    }
    
    @ViewBuilder
    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Sin datos de tendencias")
                .font(.headline)
            
            Text("Genera un análisis de tendencias para ver patrones y predicciones")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generar Análisis") {
                Task { await cargarTendencias() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Data Loading
    
    private func cargarTendencias() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Llamar endpoint de tendencias
            // Por ahora simular la carga
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
            
            // Datos de ejemplo - reemplazar con API real
            tendencias = AnalisisTendencias(
                tendenciasPrincipales: [
                    "Incremento del 15% en reportes de productos dañados en tiendas del sector norte",
                    "Mejora gradual en tiempos de resolución de quejas (promedio 20% más rápido)",
                    "Mayor frecuencia de desabastecimiento en productos de alta rotación los fines de semana"
                ],
                problemasEstacionales: [
                    "6": "Incremento en problemas de refrigeración por temperaturas altas",
                    "12": "Mayor desabasto por temporada navideña",
                    "1": "Problemas de suministro post-fiestas"
                ],
                sectoresOportunidad: [
                    "Mejora en sistemas de refrigeración y mantenimiento preventivo",
                    "Optimización de inventarios para productos de alta demanda",
                    "Capacitación en atención al cliente para tiendas con NPS bajo"
                ],
                predicciones3Meses: [
                    "Se espera un incremento del 10% en visitas requeridas para el sector centro",
                    "Probable mejora en métricas de NPS si se implementan las recomendaciones actuales",
                    "Riesgo de mayor desabastecimiento en temporada de regreso a clases"
                ],
                alertasTempranas: [
                    "5 tiendas muestran patrones de deterioro en múltiples métricas",
                    "Incremento en quejas sobre productos vencidos en 3 zonas específicas",
                    "Tendencia al alza en tiempos de resolución en el último mes"
                ],
                recomendacionesEstrategicas: [
                    "Implementar programa de mantenimiento preventivo para equipos de refrigeración",
                    "Desarrollar sistema de predicción de demanda basado en datos históricos",
                    "Crear programa de capacitación específico para tiendas con bajo rendimiento"
                ]
            )
            
            print("📊 Tendencias cargadas exitosamente")
            
        } catch {
            errorMessage = "Error cargando tendencias: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct TrendsSectionCard: View {
    let title: String
    let icon: String
    let color: Color
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .bold()
            }
            
            if items.isEmpty {
                Text("No hay datos disponibles para este período")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
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
                    .padding(.vertical, 2)
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
    TrendsView()
}
