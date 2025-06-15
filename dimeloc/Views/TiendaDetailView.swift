//
//  TiendaDetailView.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct TiendaDetailView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    @State private var direccion: String = "Cargando dirección..."
    @State private var comentarios: [Feedback] = []
    @State private var isLoadingComments = false
    @StateObject private var apiClient = TiendasAPIClient()
    
    // Logo detection para mostrar el ícono correcto
    private var logoName: String? {
        let lower = tienda.nombre.lowercased()
        let patterns: [String: [String]] = [
            "oxxo":       ["oxxo", "el primer oxxo"],
            "7eleven":    ["7-eleven", "7 eleven", "7eleven", "7 / eleven"],
            "heb":        ["h-e-b", "heb"],
            "modelorama": ["modelorama"],
            "six":        ["six"],
            "soriana":    ["soriana"],
            "walmart":    ["walmart"]
        ]
        for (asset, keys) in patterns {
            if keys.contains(where: { lower.contains($0) }) {
                return asset
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Barrita de swipe down en la parte superior
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header con imagen de fondo neutral y logo
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5)) // Color neutral
                            .frame(height: 140)
                        
                        HStack(spacing: 16) {
                            // Logo de la tienda a la izquierda
                            ZStack {
                                if let asset = logoName {
                                    Image(asset)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                        )
                                } else {
                                    Circle()
                                        .fill(Color(.systemGray4))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "storefront")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(.secondary)
                                        )
                                }
                            }
                            
                            // Información de la tienda
                            VStack(alignment: .leading, spacing: 8) {
                                Text(tienda.nombre)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.primary)
                                    .lineLimit(3) // Permitir más líneas para nombres largos
                                
                                Text(direccion)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                // Horarios del local
                                HStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(tienda.horaAbre ?? "07:00") - \(tienda.horaCierra ?? "22:00")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // Botón para navegar en Apple Maps
                    Button(action: {
                        abrirEnMapas()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Navegar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
                        
                        // Status badge movido aquí, debajo de las recomendaciones
                        HStack {
                            Spacer()
                            Text("Estado actual: \(tienda.performanceText)")
                                .font(.subheadline)
                                .bold()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(tienda.performanceColor.opacity(0.15))
                                .foregroundColor(tienda.performanceColor)
                                .cornerRadius(16)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    
                    // Nueva sección de comentarios
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            SectionHeader(title: "Comentarios", icon: "bubble.left.and.bubble.right.fill")
                            
                            Spacer()
                            
                            if isLoadingComments {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        
                        if comentarios.isEmpty && !isLoadingComments {
                            HStack {
                                Image(systemName: "bubble.left")
                                    .font(.title2)
                                    .foregroundColor(.secondary.opacity(0.6))
                                
                                Text("No hay comentarios recientes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            ForEach(comentarios.prefix(5)) { comentario in
                                ComentarioCard(feedback: comentario)
                            }
                            
                            if comentarios.count > 5 {
                                Text("Mostrando 5 de \(comentarios.count) comentarios")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 8)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            obtenerDireccion()
            cargarComentarios()
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
    
    // MARK: - Geocoding para obtener dirección
    private func obtenerDireccion() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: tienda.location.latitude, longitude: tienda.location.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error obteniendo dirección: \(error.localizedDescription)")
                    direccion = "Dirección no disponible"
                } else if let placemark = placemarks?.first {
                    // Construir dirección legible
                    var addressComponents: [String] = []
                    
                    if let streetNumber = placemark.subThoroughfare {
                        addressComponents.append(streetNumber)
                    }
                    if let streetName = placemark.thoroughfare {
                        addressComponents.append(streetName)
                    }
                    if let locality = placemark.locality {
                        addressComponents.append(locality)
                    }
                    if let adminArea = placemark.administrativeArea {
                        addressComponents.append(adminArea)
                    }
                    
                    direccion = addressComponents.isEmpty ? "Dirección no disponible" : addressComponents.joined(separator: ", ")
                } else {
                    direccion = "Dirección no disponible"
                }
            }
        }
    }
    
    // MARK: - Cargar comentarios
    private func cargarComentarios() {
        isLoadingComments = true
        
        Task {
            do {
                let feedbacks = try await apiClient.obtenerFeedback(tiendaId: tienda.id)
                DispatchQueue.main.async {
                    self.comentarios = feedbacks.sorted { $0.fecha > $1.fecha } // Más recientes primero
                    self.isLoadingComments = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error cargando comentarios: \(error.localizedDescription)")
                    self.comentarios = []
                    self.isLoadingComments = false
                }
            }
        }
    }
    
    // MARK: - Abrir en Apple Maps
    private func abrirEnMapas() {
        let coordinate = CLLocationCoordinate2D(latitude: tienda.location.latitude, longitude: tienda.location.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = tienda.nombre
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
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

// MARK: - Componente para mostrar comentarios

struct ComentarioCard: View {
    let feedback: Feedback
    
    private var urgencyColor: Color {
        switch feedback.urgencia.lowercased() {
        case "alta": return .red
        case "media": return .orange
        case "baja": return .green
        case "critica": return .purple
        default: return .gray
        }
    }
    
    private var categoryIcon: String {
        switch feedback.categoria.lowercased() {
        case "infraestructura": return "wrench.and.screwdriver"
        case "inventario": return "shippingbox"
        case "servicio": return "person.2"
        case "limpieza": return "sparkles"
        case "personal": return "person.badge.key"
        default: return "ellipsis.circle"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: categoryIcon)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(feedback.categoria.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(feedback.urgencia.capitalized)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(urgencyColor.opacity(0.2))
                    .foregroundColor(urgencyColor)
                    .cornerRadius(4)
            }
            
            Text(feedback.comentario)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            HStack {
                Text(feedback.colaborador)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatearFecha(feedback.fecha))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func formatearFecha(_ fechaString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: fechaString) else { return fechaString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "es_ES")
        
        return displayFormatter.string(from: date)
    }
}
