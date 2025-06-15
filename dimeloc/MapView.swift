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
      // first, category filter
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

    // then, if the user has typed something, further narrow down by name:
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
            // 1) Full-screen map
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,      // ← new
                annotationItems: displayedTiendas) { tienda in
                MapAnnotation(coordinate: tienda.coordinate) {
                    TiendaMarker(tienda: tienda) {
                      // 1) start loader
                      isDetailLoading = true
                      selectedTienda   = tienda

                      // 2) simulate (or perform) your detail fetch
                      Task {
                        // if you need to fetch extra data: await apiClient.fetchDetail(for: tienda)
                        try? await Task.sleep(nanoseconds: 300 * 1_000_000) // small artificial delay
                        isDetailLoading = false
                        showingDetail   = true
                      }
                    }

                }
            }
            .ignoresSafeArea()

            // 2) Search bar + stats panel (flush to top)
            VStack(spacing: 1) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("dlOrange"))
                    TextField(
                        "",
                        text: $searchText,
                        prompt: Text("Buscar tienda")
                            .foregroundColor(Color("dlOrange"))
                    )
                    .disableAutocorrection(true)
                    .foregroundColor(Color("dlOrange"))  // this now only affects the typed text
                    
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .shadow(radius: 1)
                .padding(.horizontal)
                
                // right under your search HStack…
                if !searchText.isEmpty {
                  // container that grows to fit, up to 250pt tall
                  ScrollView {
                    VStack(spacing: 0) {
                      if displayedTiendas.isEmpty {
                        Text("No se encontró ninguna tienda")
                          .foregroundColor(.secondary)
                          .padding()
                      } else {
                        ForEach(displayedTiendas) { tienda in
                          Button {
                            // zoom + show detail
                          } label: {
                            HStack {
                              Text(tienda.nombre)
                              Spacer()
                            }
                            .padding()
                          }
                          // draw a divider except after the last row
                          if tienda.id != displayedTiendas.last?.id {
                            Divider()
                          }
                        }
                      }
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                  }
                  .frame(maxHeight: 250)   // *only* cap the max height
                }

                // Stats
                if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    HStack() {
                        Button { selectedFilter = .total } label: {
                            StatsCard(title: "Total",         value: stats.total,        color: .blue)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .shadow(radius: 1)
                                .overlay(RoundedRectangle(cornerRadius:25)
                                    .stroke(selectedFilter == .total ? Color.accentColor : .clear, lineWidth:3))
                        }
                        
                        Button { selectedFilter = .excelentes } label: {
                            StatsCard(title: "Excelentes",    value: stats.excelentes,   color: .green)
                                .fixedSize()
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .shadow(radius: 1)
                                .overlay(RoundedRectangle(cornerRadius:25)
                                    .stroke(selectedFilter == .excelentes ? Color.accentColor : .clear, lineWidth:3))
                        }
                        
                        Button { selectedFilter = .bien } label: {
                            StatsCard(title: "Bien",          value: stats.bien,         color: .yellow)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .shadow(radius: 1)
                                .frame(maxWidth: .infinity)
                                .overlay(RoundedRectangle(cornerRadius:25)
                                    .stroke(selectedFilter == .bien ? Color.accentColor : .clear, lineWidth:3))
                        }
                        
                        Button { selectedFilter = .problematicas } label: {
                            StatsCard(title: "Problemáticas", value: stats.problematicas, color: .red)
                                .fixedSize()
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .shadow(radius: 1)
                                .overlay(RoundedRectangle(cornerRadius:25)
                                    .stroke(selectedFilter == .problematicas ? Color.accentColor : .clear, lineWidth:3))
                        }
                        
                    }
                    
                    .padding(12)
                    // no background/shadow on the HStack itself
                    
                }
            }
            .padding(.trailing)
            // 3) Detail‐loading overlay
            if isDetailLoading {
              // Dim the entire screen
              Color.black.opacity(0.3)
                .ignoresSafeArea()

              // Centered spinner
              ProgressView("Cargando detalle…")
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }


            // 3) Loading indicator
            if isLoading {
                ProgressView("Cargando tiendas…")
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
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
        .onChange(of: selectedFilter) { _ in            adjustRegion(to: displayedTiendas)
        }
        // somewhere in your view modifiers, e.g. just after onAppear:
        .onChange(of: searchText) { _ in
          adjustRegion(to: displayedTiendas)
        }

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
      let lats   = coords.map(\.latitude), lngs = coords.map(\.longitude)
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
