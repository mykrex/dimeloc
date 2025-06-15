//
//  TiendaDetailView.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import SwiftUI

struct TiendaDetailView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header con imagen de fondo
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: [tienda.performanceColor.opacity(0.6), tienda.performanceColor.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 140)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "storefront.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(tienda.performanceText)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    
                                    Text("ID: \(tienda.id)")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            Text(tienda.nombre)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Text("Lat: \(tienda.location.latitude, specifier: "%.4f"), Lng: \(tienda.location.longitude, specifier: "%.4f")")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Sección de métricas principales
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Métricas de Rendimiento", icon: "chart.bar.fill")
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            MetricCard(
                                title: "NPS Score",
                                value: String(format: "%.1f", tienda.nps),
                                subtitle: "Net Promoter Score",
                                color: npsColor(tienda.nps),
                                icon: "star.fill"
                            )
                            
                            MetricCard(
                                title: "Disponibilidad",
                                value: String(format: "%.1f%%", tienda.fillfoundrate),
                                subtitle: "Fill Found Rate",
                                color: .blue,
                                icon: "checkmark.circle.fill"
                            )
                            
                            MetricCard(
                                title: "Productos Dañados",
                                value: String(format: "%.2f%%", tienda.damageRate),
                                subtitle: "Damage Rate",
                                color: damageColor(tienda.damageRate),
                                icon: "exclamationmark.triangle.fill"
                            )
                            
                            MetricCard(
                                title: "Desabasto",
                                value: String(format: "%.2f%%", tienda.outOfStock),
                                subtitle: "Out of Stock",
                                color: stockColor(tienda.outOfStock),
                                icon: "minus.circle.fill"
                            )
                        }
                    }
                    
                    // Sección de tiempo de resolución
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Tiempo de Resolución", icon: "clock.fill")
                        
                        HStack {
                            Image(systemName: "clock.badge.checkmark")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(String(format: "%.1f", tienda.complaintResolutionTimeHrs)) horas")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.primary)
                                
                                Text("Promedio de resolución de quejas")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Indicador de rendimiento
                                HStack(spacing: 4) {
                                    Image(systemName: tienda.complaintResolutionTimeHrs <= 24 ? "checkmark.circle.fill" :
                                          tienda.complaintResolutionTimeHrs <= 48 ? "exclamationmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(tienda.complaintResolutionTimeHrs <= 24 ? .green :
                                                       tienda.complaintResolutionTimeHrs <= 48 ? .orange : .red)
                                        .font(.caption)
                                    
                                    Text(tienda.complaintResolutionTimeHrs <= 24 ? "Excelente" :
                                         tienda.complaintResolutionTimeHrs <= 48 ? "Aceptable" : "Necesita mejora")
                                        .font(.caption)
                                        .foregroundColor(tienda.complaintResolutionTimeHrs <= 24 ? .green :
                                                       tienda.complaintResolutionTimeHrs <= 48 ? .orange : .red)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Sección de recomendaciones
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Recomendaciones", icon: "lightbulb.fill")
                        
                        VStack(spacing: 8) {
                            if tienda.nps < 30 {
                                RecommendationCard(
                                    title: "NPS Crítico",
                                    description: "Implementar plan de mejora de satisfacción del cliente",
                                    priority: .high
                                )
                            }
                            
                            if tienda.outOfStock > 4 {
                                RecommendationCard(
                                    title: "Desabasto Alto",
                                    description: "Revisar procesos de inventario y reabastecimiento",
                                    priority: .high
                                )
                            }
                            
                            if tienda.damageRate > 1 {
                                RecommendationCard(
                                    title: "Productos Dañados",
                                    description: "Mejorar almacenamiento y manejo de productos",
                                    priority: .medium
                                )
                            }
                            
                            if tienda.complaintResolutionTimeHrs > 48 {
                                RecommendationCard(
                                    title: "Tiempo de Resolución",
                                    description: "Agilizar procesos de atención al cliente",
                                    priority: .medium
                                )
                            }
                            
                            // Si no hay problemas críticos
                            if tienda.nps >= 30 && tienda.outOfStock <= 4 && tienda.damageRate <= 1 && tienda.complaintResolutionTimeHrs <= 48 {
                                RecommendationCard(
                                    title: "Buen Rendimiento",
                                    description: "Mantener estándares actuales y buscar oportunidades de mejora",
                                    priority: .low
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detalle de Tienda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper functions
    
    private func npsColor(_ nps: Double) -> Color {
        if nps >= 50 { return .green }
        else if nps >= 30 { return .orange }
        else { return .red }
    }
    
    private func damageColor(_ rate: Double) -> Color {
        if rate <= 0.5 { return .green }
        else if rate <= 1.0 { return .orange }
        else { return .red }
    }
    
    private func stockColor(_ rate: Double) -> Color {
        if rate <= 3.0 { return .green }
        else if rate <= 4.0 { return .orange }
        else { return .red }
    }
}

// MARK: - Componentes auxiliares

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.headline)
            
            Text(title)
                .font(.headline)
                .bold()
            
            Spacer()
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecommendationCard: View {
    let title: String
    let description: String
    let priority: Priority
    
    enum Priority {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "checkmark.circle.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .high: return "warning.circle.fill"
            }
        }
        
        var text: String {
            switch self {
            case .low: return "Baja"
            case .medium: return "Media"
            case .high: return "Alta"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: priority.icon)
                .foregroundColor(priority.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
                    Text("Prioridad: \(priority.text)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priority.color.opacity(0.2))
                        .foregroundColor(priority.color)
                        .cornerRadius(4)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(priority.color.opacity(0.05))
        .cornerRadius(8)
    }
}
