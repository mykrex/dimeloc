//
//  FeedbackListView.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import SwiftUI

struct FeedbackListView: View {
    @StateObject private var apiClient = TiendasAPIClient()
    @State private var tiendas: [Tienda] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTienda: Tienda?
    @State private var showingFeedback = false
    @State private var searchText = ""
    
    var filteredTiendas: [Tienda] {
        if searchText.isEmpty {
            return tiendas
        } else {
            return tiendas.filter { tienda in
                tienda.nombre.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Cargando tiendas...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else if filteredTiendas.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "storefront")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        if searchText.isEmpty {
                            Text("No hay tiendas disponibles")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        } else {
                            VStack(spacing: 8) {
                                Text("No se encontraron tiendas")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Intenta con un término diferente")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                } else {
                    List(filteredTiendas) { tienda in
                        TiendaFeedbackRow(tienda: tienda) {
                            selectedTienda = tienda
                            showingFeedback = true
                        }
                    }
                    .searchable(text: $searchText, prompt: "Buscar tienda...")
                    .refreshable {
                        await cargarTiendas()
                    }
                }
            }
            .navigationTitle("Agregar Feedback")
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
                Task {
                    await cargarTiendas()
                }
            }
            .sheet(isPresented: $showingFeedback) {
                if let tienda = selectedTienda {
                    FeedbackView(tienda: tienda)
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
    
    private func cargarTiendas() async {
        isLoading = true
        errorMessage = nil
        
        do {
            tiendas = try await apiClient.obtenerTiendas()
        } catch {
            errorMessage = "Error cargando tiendas: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Fila de tienda para feedback
struct TiendaFeedbackRow: View {
    let tienda: Tienda
    let onFeedbackTap: () -> Void
    @State private var showingInsights = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Indicador de estado visual
            Circle()
                .fill(tienda.performanceColor)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                // Nombre de la tienda
                Text(tienda.nombre)
                    .font(.headline)
                    .lineLimit(2)
                
                // Información de estado
                HStack(spacing: 8) {
                    Text(tienda.performanceText)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tienda.performanceColor.opacity(0.2))
                        .foregroundColor(tienda.performanceColor)
                        .cornerRadius(4)
                    
                    Text("NPS: \(Int(tienda.nps))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Métricas rápidas
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(tienda.damageRate > 1 ? .red : .green)
                            .font(.caption2)
                        Text("Daños: \(String(format: "%.1f%%", tienda.damageRate))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(tienda.outOfStock > 4 ? .red : .green)
                            .font(.caption2)
                        Text("Desabasto: \(String(format: "%.1f%%", tienda.outOfStock))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // NUEVO: Botones de acción
            VStack(spacing: 8) {
                // Botón de ver insights
                Button(action: {
                    showingInsights = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Análisis IA")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color.purple)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Botón de agregar feedback
                Button(action: onFeedbackTap) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.bubble.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Feedback")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingInsights) {
            InsightsView(tienda: tienda)
        }
    }
}
