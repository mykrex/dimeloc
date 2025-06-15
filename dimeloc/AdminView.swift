import SwiftUI
import Charts

struct AdminView: View {
    @StateObject private var apiClient = TiendasAPIClient()
    @State private var tiendas: [Tienda] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Filtro de categorías
    enum FilterCategory: String, CaseIterable, Identifiable {
        case problematicas = "Problemáticas"
        case bien = "Bien"
        case excelentes = "Excelentes"
        case todas = "Todas"
        var id: String { rawValue }
    }
    @State private var selectedCategory: FilterCategory = .problematicas

    // Estadísticas calculadas basada en criterios
    private var stats: (excelentes: Int, bien: Int, problematicas: Int) {
        let excelentes = tiendas.filter { $0.nps >= 50 && $0.damageRate < 0.5 && $0.outOfStock < 3 }.count
        let problematicas = tiendas.filter { $0.nps < 30 || $0.damageRate > 1 || $0.outOfStock > 4 }.count
        let bien = tiendas.count - excelentes - problematicas
        return (excelentes, bien, problematicas)
    }

    private struct StatData: Identifiable {
        let id = UUID()
        let category: String
        let value: Int
    }

    private var chartData: [StatData] {
        [
            StatData(category: "Excelentes", value: stats.excelentes),
            StatData(category: "Bien", value: stats.bien),
            StatData(category: "Problemáticas", value: stats.problematicas)
        ]
    }

    // Tiendas filtradas y ordenadas alfabéticamente
    private var filteredTiendas: [Tienda] {
        let list: [Tienda]
        switch selectedCategory {
        case .excelentes:
            list = tiendas.filter { $0.nps >= 50 && $0.damageRate < 0.5 && $0.outOfStock < 3 }
        case .bien:
            list = tiendas.filter { ($0.nps >= 30 && $0.nps < 50) && $0.damageRate <= 1 && $0.outOfStock <= 4 }
        case .problematicas:
            list = tiendas.filter { $0.nps < 30 || $0.damageRate > 1 || $0.outOfStock > 4 }
        case .todas:
            list = tiendas
        }
        return list.sorted { $0.nombre < $1.nombre }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Título
                    Text("Panel de administración")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    // Gráfica de barras
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estado de Tiendas")
                            .font(.headline)
                        Chart(chartData) { item in
                            BarMark(
                                x: .value("Categoría", item.category),
                                y: .value("Tiendas", item.value)
                            )
                            .foregroundStyle(by: .value("Categoría", item.category))
                        }
                        .chartLegend(.hidden)
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Picker de filtro
                    Picker("Filtrar", selection: $selectedCategory) {
                        ForEach(FilterCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Listado de tiendas según filtro
                    VStack(spacing: 12) {
                        if isLoading {
                            ProgressView("Cargando...")
                                .padding()
                        } else {
                            ForEach(filteredTiendas) { tienda in
                                NavigationLink(destination: TiendaDetailView(tienda: tienda)) {
                                    Text(tienda.nombre)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            selectedCategory == .problematicas ? Color.red.opacity(0.1) : Color.blue.opacity(0.1)
                                        )
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.bottom)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .onAppear {
            Task { await loadTiendas() }
        }
    }

    private func loadTiendas() async {
        isLoading = true
        errorMessage = nil
        do {
            tiendas = try await apiClient.obtenerTiendas()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
