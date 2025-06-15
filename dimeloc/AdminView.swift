import SwiftUI
import Charts

struct AdminView: View {
    // MARK: - App colors matching FeedbackListView
    private let accentColor = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
    
    @StateObject private var apiClient = TiendasAPIClient()
    @State private var tiendas: [Tienda] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    
    // Enhanced filter categories with better naming
    enum FilterCategory: String, CaseIterable, Identifiable {
        case problematicas = "Problemáticas"
        case bien = "Bien"
        case excelentes = "Excelentes"
        case todas = "Todas"
        var id: String { rawValue }
        
        // Color coding for categories
        var color: Color {
            switch self {
            case .excelentes: return Color(red: 0.133, green: 0.694, blue: 0.298) // Green
            case .bien: return Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow
            case .problematicas: return Color(red: 1.0, green: 0.231, blue: 0.188) // Red
            case .todas: return .primary
            }
        }
        
        var icon: String {
            switch self {
            case .excelentes: return "star.fill"
            case .bien: return "checkmark.circle.fill"
            case .problematicas: return "exclamationmark.triangle.fill"
            case .todas: return "square.grid.2x2"
            }
        }
    }
    @State private var selectedCategory: FilterCategory = .problematicas

    // Enhanced statistics calculation
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
        let color: Color
    }

    private var chartData: [StatData] {
        [
            StatData(category: "Excelentes", value: stats.excelentes, color: Color(red: 0.133, green: 0.694, blue: 0.298)),
            StatData(category: "Bien", value: stats.bien, color: Color(red: 1.0, green: 0.8, blue: 0.0)),
            StatData(category: "Problemáticas", value: stats.problematicas, color: Color(red: 1.0, green: 0.231, blue: 0.188))
        ]
    }

    // Enhanced filtering with search
    private var filteredTiendas: [Tienda] {
        let categoryFiltered: [Tienda]
        switch selectedCategory {
        case .excelentes:
            categoryFiltered = tiendas.filter { $0.nps >= 50 && $0.damageRate < 0.5 && $0.outOfStock < 3 }
        case .bien:
            categoryFiltered = tiendas.filter { ($0.nps >= 30 && $0.nps < 50) && $0.damageRate <= 1 && $0.outOfStock <= 4 }
        case .problematicas:
            categoryFiltered = tiendas.filter { $0.nps < 30 || $0.damageRate > 1 || $0.outOfStock > 4 }
        case .todas:
            categoryFiltered = tiendas
        }
        
        let searchFiltered: [Tienda]
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if term.isEmpty {
            searchFiltered = categoryFiltered
        } else {
            searchFiltered = categoryFiltered.filter {
                $0.nombre.localizedCaseInsensitiveContains(term)
            }
        }
        
        return searchFiltered.sorted { $0.nombre < $1.nombre }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Sleek Header matching FeedbackListView
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Administración")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Panel de control de tiendas")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { Task { await loadTiendas() } }) {
                        Image(systemName: isLoading ? "hourglass" : "arrow.clockwise")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Enhanced Statistics Cards
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            StatCard(title: "Excelentes", value: stats.excelentes, color: .green, icon: "star.fill")
                            StatCard(title: "Bien", value: stats.bien, color: .blue, icon: "checkmark.circle.fill")
                            StatCard(title: "Problemáticas", value: stats.problematicas, color: .red, icon: "exclamationmark.triangle.fill")
                        }
                        .padding(.horizontal, 20)

                        // MARK: - Enhanced Chart Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(accentColor)
                                
                                Text("Distribución de Tiendas")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            Chart(chartData) { item in
                                BarMark(
                                    x: .value("Categoría", item.category),
                                    y: .value("Tiendas", item.value)
                                )
                                .foregroundStyle(item.color)
                                .cornerRadius(6)
                            }
                            .chartLegend(.hidden)
                            .frame(height: 180)
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                        )
                        .padding(.horizontal, 20)

                        // MARK: - Search Bar matching FeedbackListView
                        HStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("Buscar tienda", text: $searchText)
                                    .font(.system(size: 16))
                                    .disableAutocorrection(true)
                                
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary.opacity(0.6))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.horizontal, 20)

                        // MARK: - Filter Menu matching FeedbackListView
                        HStack {
                            Menu {
                                ForEach(FilterCategory.allCases) { category in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategory = category
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: category.icon)
                                            Text("\(category.rawValue) (\(countForCategory(category)))")
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(selectedCategory.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        // MARK: - Enhanced Store List
                        LazyVStack(spacing: 8) {
                            if isLoading {
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .tint(.primary)
                                    
                                    Text("Cargando tiendas...")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else if filteredTiendas.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "storefront")
                                        .font(.system(size: 48, weight: .light))
                                        .foregroundColor(.secondary)
                                    
                                    VStack(spacing: 8) {
                                        Text(searchText.isEmpty ? "No hay tiendas en esta categoría" : "No se encontraron tiendas")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        if !searchText.isEmpty {
                                            Text("Intenta un término diferente")
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 40)
                            } else {
                                ForEach(filteredTiendas) { tienda in
                                    EnhancedTiendaRow(tienda: tienda, category: selectedCategory)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.3), value: filteredTiendas.count)
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            Task { await loadTiendas() }
        }
    }
    
    // MARK: - Helper Functions
    private func countForCategory(_ category: FilterCategory) -> Int {
        switch category {
        case .excelentes: return stats.excelentes
        case .bien: return stats.bien
        case .problematicas: return stats.problematicas
        case .todas: return tiendas.count
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

// MARK: - Enhanced Statistics Card Component
struct StatCard: View {
    let title: String
    let value: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Enhanced Filter Button Component
struct FilterButton: View {
    let category: AdminView.FilterCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                
                if count > 0 {
                    Text("(\(count))")
                        .font(.system(size: 12, weight: .regular))
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? category.color.opacity(0.15) : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? category.color : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? category.color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced Store Row Component
struct EnhancedTiendaRow: View {
    let tienda: Tienda
    let category: AdminView.FilterCategory
    
    // Logo detection matching FeedbackListView
    private var logoName: String? {
        let lower = tienda.nombre.lowercased()
        let patterns: [String: [String]] = [
            "oxxo":       ["oxxo", "el primer oxxo"],
            "7eleven":    ["7-eleven", "7 eleven", "7eleven", "7 / eleven"],
            "heb":         ["h-e-b", "heb"],
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
        NavigationLink(destination: TiendaDetailView(tienda: tienda)) {
            HStack(spacing: 14) {
                // Store logo/icon
                ZStack {
                    if let asset = logoName {
                        Image(asset)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )
                    } else {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "storefront")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                
                // Store information
                VStack(alignment: .leading, spacing: 4) {
                    Text(tienda.nombre)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        // Performance indicator
                        HStack(spacing: 4) {
                            Circle()
                                .fill(performanceColor)
                                .frame(width: 6, height: 6)
                            
                            Text(performanceText)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        // Key metrics
                        Text("NPS: \(Int(tienda.nps))")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Category indicator
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(category.color)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.systemGray6).opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var performanceColor: Color {
        if tienda.nps >= 50 && tienda.damageRate < 0.5 && tienda.outOfStock < 3 {
            return Color(red: 0.133, green: 0.694, blue: 0.298) // Green
        } else if tienda.nps < 30 || tienda.damageRate > 1 || tienda.outOfStock > 4 {
            return Color(red: 1.0, green: 0.231, blue: 0.188) // Red
        } else {
            return Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow
        }
    }
    
    private var performanceText: String {
        if tienda.nps >= 50 && tienda.damageRate < 0.5 && tienda.outOfStock < 3 {
            return "Excelente"
        } else if tienda.nps < 30 || tienda.damageRate > 1 || tienda.outOfStock > 4 {
            return "Problemática"
        } else {
            return "Bien"
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
