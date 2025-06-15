import SwiftUI

struct DarFeedbackView: View {
    @StateObject private var apiClient = TiendasAPIClient()
    @State private var tiendas: [Tienda] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    // Filtra las tiendas según el texto de búsqueda
    private var filteredTiendas: [Tienda] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return tiendas
        }
        return tiendas.filter {
            $0.nombre.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    ProgressView("Cargando tiendas…")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if filteredTiendas.isEmpty {
                    Text("No se encontró ninguna tienda")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filteredTiendas) { tienda in
                        NavigationLink(destination: FeedbackView(tienda: tienda)) {
                            HStack {
                                Text(tienda.nombre)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Buscar tienda")
            .navigationTitle("Dar Feedback")
            .onAppear {
                loadTiendas()
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

    private func loadTiendas() {
        isLoading = true
        Task {
            do {
                tiendas = try await apiClient.obtenerTiendas()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct DarFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        DarFeedbackView()
    }
}
