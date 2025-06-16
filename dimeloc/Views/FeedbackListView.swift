//
//  FeedbackListView.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//
import SwiftUI

// MARK: - Enhanced FeedbackListView with sleek design improvements
struct FeedbackListView: View {
    // MARK: - App accent color
    private let accentColor = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
    
    // ✅ TODAS LAS VARIABLES DE ESTADO AGRUPADAS AL INICIO
    @StateObject private var apiClient = TiendasAPIClient()
    @State private var tiendas: [Tienda] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTienda: Tienda?
    @State private var showingFeedback = false
    @State private var searchText = ""
    @State private var showingFeedbackTypeSheet = false
    @State private var showingTenderoFeedback = false
    @State private var showingColaboradorFeedback = false
    @State private var selectedPattern: String = "Todas"

    // Patrón para logos
    private let patterns: [String: [String]] = [
        "oxxo":      ["oxxo", "el primer oxxo"],
        "7eleven":   ["7-eleven", "7 eleven", "7eleven", "7 / eleven"],
        "heb":       ["h-e-b", "heb"],
        "modelorama":["modelorama"],
        "six":       ["six"],
        "soriana":   ["soriana"],
        "walmart":   ["walmart"]
    ]

    /// Filtra tiendas según logo seleccionado
    private var patternFilteredTiendas: [Tienda] {
        if selectedPattern == "Todas" {
            return tiendas
        } else if selectedPattern == "Otras" {
            let allKeys = patterns.values.flatMap { $0 }
            return tiendas.filter { tienda in
                let lower = tienda.nombre.lowercased()
                return !allKeys.contains { lower.contains($0) }
            }
        } else if let keys = patterns[selectedPattern.lowercased()] {
            return tiendas.filter { tienda in
                let lower = tienda.nombre.lowercased()
                return keys.contains { lower.contains($0) }
            }
        } else {
            return tiendas
        }
    }

    /// Filtra por búsqueda sobre el resultado anterior
    private var filteredTiendas: [Tienda] {
        let base = patternFilteredTiendas
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return base }
        return base.filter {
            $0.nombre.localizedCaseInsensitiveContains(term)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: Sleek Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Feedback")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Agregar comentarios")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { Task { await cargarTiendas() } }) {
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

                // MARK: Minimal Search Bar
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("Buscar tienda", text: $searchText)
                            .font(.system(size: 16))
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: Minimal Filter Menu
                HStack {
                    Menu {
                        Button("Todas") { selectedPattern = "Todas" }
                        ForEach(patterns.keys.sorted(), id: \.self) { key in
                            Button(key.capitalized) { selectedPattern = key.capitalized }
                        }
                        Button("Otras") { selectedPattern = "Otras" }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedPattern)
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
                .padding(.bottom, 16)

                // MARK: Content with minimal styling
                Group {
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.primary)
                            
                            Text("Cargando tiendas...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredTiendas.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "storefront")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 8) {
                                Text(searchText.isEmpty ? "No hay tiendas disponibles" : "No se encontraron tiendas")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                if !searchText.isEmpty {
                                    Text("Intenta un término diferente")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(filteredTiendas) { tienda in
                                    TiendaFeedbackRow(tienda: tienda) {
                                        selectedTienda = tienda
                                        showingFeedbackTypeSheet = true
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .refreshable { await cargarTiendas() }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: searchText)
                .animation(.easeInOut(duration: 0.3), value: selectedPattern)

                Spacer(minLength: 0)
            }
            .background(Color(.systemGroupedBackground))
            
            // ActionSheet para seleccionar tipo de feedback
            .confirmationDialog("¿Qué tipo de feedback quieres agregar?", isPresented: $showingFeedbackTypeSheet, titleVisibility: .visible) {
                Button("🏪 Feedback del Tendero") {
                    showingTenderoFeedback = true
                }
                
                Button("👤 Feedback del Colaborador") {
                    showingColaboradorFeedback = true
                }
                
                Button("Cancelar", role: .cancel) {}
            } message: {
                if let tienda = selectedTienda {
                    Text("Selecciona el tipo de feedback para \(tienda.nombre)")
                }
            }
            
            // Sheets para cada tipo de feedback
            .sheet(isPresented: $showingTenderoFeedback) {
                if let tienda = selectedTienda {
                    TenderoFeedbackView(tienda: tienda, visitaId: nil)
                }
            }
            
            .sheet(isPresented: $showingColaboradorFeedback) {
                if let tienda = selectedTienda {
                    FeedbackView(tienda: tienda)
                }
            }
            
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .onAppear { Task { await cargarTiendas() } }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Data loading
    private func cargarTiendas() async {
        isLoading = true
        errorMessage = nil
        do {
            // ✅ FILTRAR tiendas con ID válido
            let todasLasTiendas = try await apiClient.obtenerTiendas()
            
            tiendas = todasLasTiendas.filter { tienda in
                let esValida = tienda.isValidId
                if !esValida {
                    print("⚠️ Filtrando tienda con ID inválido: '\(tienda.nombre)' (ID: \(tienda.id))")
                }
                return esValida
            }
            
            print("✅ Tiendas cargadas: \(tiendas.count) de \(todasLasTiendas.count) son válidas")
            
        } catch {
            errorMessage = "Error cargando tiendas: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

// MARK: - Ultra Minimal TiendaFeedbackRow with enhanced design
struct TiendaFeedbackRow: View {
    // MARK: - App colors
    private let accentColor = Color(red: 1.0, green: 0.294, blue: 0.2) // #FF4B33
    private let aiGradientStart = Color(red: 0.408, green: 0.541, blue: 0.914) // #688AE9
    private let aiGradientEnd = Color(red: 0.776, green: 0.427, blue: 0.482) // #C66D7B
    private let softBlue = Color(red: 0.635, green: 0.824, blue: 1.0) // #A2D2FF
    
    // MARK: – Logo detection for row
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

    let tienda: Tienda
    let onFeedbackTap: () -> Void
    @State private var showingInsights = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Store logo/icon with enhanced minimal design
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
                    // Ultra minimal fallback
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
            
            // Store information with better typography
            VStack(alignment: .leading, spacing: 3) {
                Text(tienda.nombre)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Ultra minimal performance indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(tienda.performanceColor)
                        .frame(width: 4, height: 4)
                    
                    Text(tienda.performanceText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Ultra minimal action buttons with better spacing
            HStack(spacing: 6) {
                // AI Analysis button
                Button(action: {
                    showingInsights = true
                }) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [aiGradientStart, aiGradientEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: aiGradientStart.opacity(0.2), radius: 1, x: 0, y: 0.5)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // ✅ BOTÓN DE FEEDBACK CON VALIDACIÓN
                Button(action: {
                    // ✅ VALIDAR ID antes de permitir feedback
                    if tienda.isValidId {
                        onFeedbackTap()
                    } else {
                        print("❌ No se puede crear feedback para tienda con ID inválido: \(tienda.id)")
                    }
                }) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            tienda.isValidId ? Color.purple.opacity(0.8) : Color.gray.opacity(0.5),
                                            tienda.isValidId ? Color.purple : Color.gray
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color.purple.opacity(0.3), radius: 1, x: 0, y: 0.5)
                }
                .disabled(!tienda.isValidId)
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .sheet(isPresented: $showingInsights) {
            GeminiInsightsView(tienda: tienda)
        }
    }
}

struct FeedbackListView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackListView()
    }
}
