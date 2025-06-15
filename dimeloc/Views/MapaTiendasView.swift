//
//  MapaTiendasView.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapaTiendasView: View {
    @StateObject private var apiClient = TiendasAPIClient()
    @StateObject private var locationManager = LocationManager()
    @State private var tiendas: [Tienda] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTienda: Tienda?
    @State private var showingDetail = false
    
    // Configuración del mapa centrado en Monterrey
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                // Mapa principal
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: tiendas) { tienda in
                    MapAnnotation(coordinate: tienda.coordinate) {
                        TiendaMarker(tienda: tienda) {
                            selectedTienda = tienda
                            showingDetail = true
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Indicador de carga
                if isLoading {
                    VStack {
                        ProgressView("Cargando tiendas...")
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                    }
                }
                
                // Panel de información superior
                VStack {
                    TiendasInfoPanel(tiendas: tiendas)
                    Spacer()
                }
                .padding()
                
                // Botones flotantes
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            // Botón de ubicación
                            Button(action: {
                                centerOnUserLocation()
                            }) {
                                Image(systemName: locationManager.userLocation != nil ? "location.fill" : "location")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        locationManager.authorizationStatus == .authorizedWhenInUse ||
                                        locationManager.authorizationStatus == .authorizedAlways ?
                                        Color.blue : Color.gray
                                    )
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            // Botón para centrar en todas las tiendas
                            Button(action: {
                                centerOnAllStores()
                            }) {
                                Image(systemName: "map")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.green)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Mapa de Tiendas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actualizar") {
                        Task {
                            await cargarTiendas()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                locationManager.requestPermission()
                Task {
                    await cargarTiendas()
                }
            }
            .sheet(isPresented: $showingDetail) {
                if let tienda = selectedTienda {
                    TiendaDetailView(tienda: tienda)
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
    
    // MARK: - Funciones helper
    
    private func centerOnUserLocation() {
        if let userLocation = locationManager.userLocation {
            withAnimation(.easeInOut(duration: 0.8)) {
                region.center = userLocation
                region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            }
        } else {
            locationManager.requestPermission()
        }
    }
    
    private func centerOnAllStores() {
        guard !tiendas.isEmpty else { return }
        
        let coordinates = tiendas.map { $0.coordinate }
        let minLat = coordinates.map { $0.latitude }.min() ?? 25.6866
        let maxLat = coordinates.map { $0.latitude }.max() ?? 25.6866
        let minLng = coordinates.map { $0.longitude }.min() ?? -100.3161
        let maxLng = coordinates.map { $0.longitude }.max() ?? -100.3161
        
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        let spanLat = abs(maxLat - minLat) * 1.3
        let spanLng = abs(maxLng - minLng) * 1.3
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
                span: MKCoordinateSpan(
                    latitudeDelta: max(spanLat, 0.01),
                    longitudeDelta: max(spanLng, 0.01)
                )
            )
        }
    }
    
    private func cargarTiendas() async {
        isLoading = true
        errorMessage = nil
        
        do {
            tiendas = try await apiClient.obtenerTiendas()
            
            // Ajustar la región del mapa para mostrar todas las tiendas
            if !tiendas.isEmpty {
                let coordinates = tiendas.map { $0.coordinate }
                let minLat = coordinates.map { $0.latitude }.min() ?? 25.6866
                let maxLat = coordinates.map { $0.latitude }.max() ?? 25.6866
                let minLng = coordinates.map { $0.longitude }.min() ?? -100.3161
                let maxLng = coordinates.map { $0.longitude }.max() ?? -100.3161
                
                let centerLat = (minLat + maxLat) / 2
                let centerLng = (minLng + maxLng) / 2
                let spanLat = abs(maxLat - minLat) * 1.2
                let spanLng = abs(maxLng - minLng) * 1.2
                
                withAnimation {
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
                        span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.01), longitudeDelta: max(spanLng, 0.01))
                    )
                }
            }
        } catch {
            errorMessage = "Error cargando tiendas: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Location Manager (igual que antes)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                print("Ubicación denegada")
            case .notDetermined:
                self.requestPermission()
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Componentes del mapa (iguales que antes)
struct TiendaMarker: View {
    let tienda: Tienda
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(tienda.performanceColor)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 3)
                
                Image(systemName: "storefront")
                    .foregroundColor(.white)
                    .font(.caption)
                    .bold()
            }
            
            Text("\(Int(tienda.nps))")
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(4)
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct TiendasInfoPanel: View {
    let tiendas: [Tienda]
    
    private var stats: (total: Int, excelentes: Int, problematicas: Int) {
        let total = tiendas.count
        let excelentes = tiendas.filter { $0.nps >= 50 && $0.damageRate < 0.5 && $0.outOfStock < 3 }.count
        let problematicas = tiendas.filter { $0.nps < 30 || $0.outOfStock > 4 || $0.damageRate > 1 }.count
        return (total, excelentes, problematicas)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            StatCard(title: "Total", value: "\(stats.total)", color: .blue)
            StatCard(title: "Excelentes", value: "\(stats.excelentes)", color: .green)
            StatCard(title: "Problemáticas", value: "\(stats.problematicas)", color: .red)
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
