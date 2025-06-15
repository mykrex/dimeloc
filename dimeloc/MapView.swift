import SwiftUI
import MapKit

struct MapView: View {
    @State private var isDetailLoading = false
    @State private var trackingMode: MapUserTrackingMode = .follow
    @StateObject private var apiClient       = TiendasAPIClient()
    @StateObject private var locationManager = LocationManager()
    @State private var tiendas               = [Tienda]()
    @State private var isLoading             = false
    @State private var errorMessage: String?
    @State private var selectedTienda: Tienda?
    @State private var showingDetail         = false
    @State private var searchText            = ""
    enum FilterCategory { case total, excelentes, bien, problematicas }
    @State private var selectedFilter: FilterCategory = .total

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span:   MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.05)
    )

    private var stats: (total: Int, excelentes: Int, bien: Int, problematicas: Int) {
        let total        = tiendas.count
        let excelentes   = tiendas.filter { $0.nps >= 50 && $0.damageRate < 0.5 && $0.outOfStock < 3 }.count
        let problematicas = tiendas.filter { $0.nps < 30 || $0.damageRate > 1 || $0.outOfStock > 4 }.count
        let bien         = total - excelentes - problematicas
        return (total, excelentes, bien, problematicas)
    }

    private var displayedTiendas: [Tienda] {
      // apply category filter
      let byCategory: [Tienda]
      switch selectedFilter {
      case .total:
        byCategory = tiendas
      case .excelentes:
        byCategory = tiendas.filter { $0.nps >= 50 && $0.damageRate < 0.5 && $0.outOfStock < 3 }
      case .bien:
        byCategory = tiendas.filter { t in
          t.nps >= 30 && t.nps < 50
          && t.damageRate <= 1
          && t.outOfStock <= 4
        }
      case .problematicas:
        byCategory = tiendas.filter { $0.nps < 30 || $0.damageRate > 1 || $0.outOfStock > 4 }
      }

      // then apply search filter
     guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
       return byCategory
     }
     return byCategory.filter {
       $0.nombre
         .localizedCaseInsensitiveContains(searchText.trimmingCharacters(in: .whitespaces))
     }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 1) Map display
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: displayedTiendas) { tienda in
                MapAnnotation(coordinate: tienda.coordinate) {
                    TiendaMarker(tienda: tienda) {
                      isDetailLoading = true
                      selectedTienda   = tienda
                      Task {
                        try? await Task.sleep(nanoseconds: 300 * 1_000_000)
                        isDetailLoading = false
                        showingDetail   = true
                      }
                    }
                }
            }
            .ignoresSafeArea()

            // 2) Floating search bar and filters
            VStack(spacing: 16) {
                // Floating search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar tienda", text: $searchText)
                        .font(.system(size: 16))
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Search suggestions
                if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    VStack(spacing: 0) {
                        if displayedTiendas.isEmpty {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                Text("No se encontró '\(searchText)'")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        } else {
                            ForEach(displayedTiendas.prefix(5)) { tienda in
                                Button {
                                    // Center map on selected tienda and show detail
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        region.center = tienda.coordinate
                                        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    }
                                    selectedTienda = tienda
                                    searchText = ""
                                    
                                    // Show detail after a brief delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        showingDetail = true
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(tienda.nombre)
                                                .foregroundColor(.primary)
                                                .font(.system(size: 15, weight: .medium))
                                                .lineLimit(1)
                                            
                                            Text("\(String(format: "%.4f", tienda.location.latitude)), \(String(format: "%.4f", tienda.location.longitude))")
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 12))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.left")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 12))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if tienda.id != displayedTiendas.prefix(5).last?.id {
                                    Divider()
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                }

                // Filter buttons with flexible width
                if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    HStack(spacing: 8) {
                        MapFilterChip(
                            title: "Todos",
                            count: stats.total,
                            isSelected: selectedFilter == .total,
                            filterType: .total
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = .total
                            }
                        }
                        
                        MapFilterChip(
                            title: "Excelentes",
                            count: stats.excelentes,
                            isSelected: selectedFilter == .excelentes,
                            filterType: .excelentes
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = .excelentes
                            }
                        }
                        
                        MapFilterChip(
                            title: "Bien",
                            count: stats.bien,
                            isSelected: selectedFilter == .bien,
                            filterType: .bien
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = .bien
                            }
                        }
                        
                        MapFilterChip(
                            title: "Problemáticas",
                            count: stats.problematicas,
                            isSelected: selectedFilter == .problematicas,
                            filterType: .problematicas
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = .problematicas
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }

            // 3) Loading overlays
            if isDetailLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView("Cargando detalle…")
                    .padding(20)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }

            if isLoading {
                ProgressView("Cargando tiendas…")
                    .padding(20)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
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
        .onAppear {
            locationManager.requestPermission()
            Task { await cargarTiendas() }
        }
        .onChange(of: selectedFilter) { _ in adjustRegion(to: displayedTiendas) }
        .onChange(of: searchText) { _ in adjustRegion(to: displayedTiendas) }
    }

    private func cargarTiendas() async {
        isLoading = true
        errorMessage = nil
        do {
            tiendas = try await apiClient.obtenerTiendas()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func adjustRegion(to items: [Tienda]) {
      guard !items.isEmpty else { return }
      let coords = items.map { $0.coordinate }
      let lats   = coords.map(\ .latitude), lngs = coords.map(\ .longitude)
      let center = CLLocationCoordinate2D(
        latitude: (lats.min()! + lats.max()!) / 2,
        longitude:(lngs.min()! + lngs.max()!) / 2
      )
      let span = MKCoordinateSpan(
        latitudeDelta: max((lats.max()! - lats.min()!) * 1.2, 0.01),
        longitudeDelta: max((lngs.max()! - lngs.min()!) * 1.2, 0.01)
      )
      withAnimation { region = MKCoordinateRegion(center: center, span: span) }
    }
}

// MARK: - Map Filter Chip Component
struct MapFilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let filterType: MapView.FilterCategory
    let action: () -> Void
    
    private var filterColor: Color {
        switch filterType {
        case .total:
            return .blue
        case .excelentes:
            return .green
        case .bien:
            return .orange
        case .problematicas:
            return .red
        }
    }
    
    // Dynamic width based on title length
    private var chipWidth: CGFloat {
        switch filterType {
        case .problematicas:
            return 95  // Wider for "Problemáticas"
        default:
            return 80  // Standard width for other buttons
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? .white : filterColor)
            }
            .frame(width: chipWidth, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? filterColor : Color(.systemGray6))
            )
            .shadow(
                color: isSelected ? filterColor.opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 6 : 2,
                x: 0,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
