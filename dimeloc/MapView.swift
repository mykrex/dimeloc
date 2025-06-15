import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
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
                    ProgressView("Cargando tiendas...")
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
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
                            Button(action: centerOnUserLocation) {
                                Image(systemName: locationManager.userLocation != nil ? "location.fill" : "location")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        (locationManager.authorizationStatus == .authorizedWhenInUse ||
                                         locationManager.authorizationStatus == .authorizedAlways)
                                        ? Color.blue : Color.gray
                                    )
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            // Botón para centrar en todas las tiendas
                            Button(action: centerOnAllStores) {
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
                        Task { await cargarTiendas() }
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                locationManager.requestPermission()
                Task { await cargarTiendas() }
            }
            .sheet(isPresented: $showingDetail) {
                if let tienda = selectedTienda {
                    TiendaDetailView(tienda: tienda)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
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
        let coords = tiendas.map { $0.coordinate }
        let lats = coords.map(
            \ .latitude)
        let lngs = coords.map(
            \ .longitude)
        let centerLat = (lats.min()! + lats.max()!) / 2
        let centerLng = (lngs.min()! + lngs.max()!) / 2
        let spanLat = (lats.max()! - lats.min()!) * 1.3
        let spanLng = (lngs.max()! - lngs.min()!) * 1.3
        withAnimation(.easeInOut) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
                span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.01), longitudeDelta: max(spanLng, 0.01))
            )
        }
    }
    
    private func cargarTiendas() async {
        isLoading = true
        errorMessage = nil
        do {
            tiendas = try await apiClient.obtenerTiendas()
            if !tiendas.isEmpty { centerOnAllStores() }
        } catch {
            errorMessage = "Error cargando tiendas: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
