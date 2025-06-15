import SwiftUI

struct HomeView: View {
    // Mock user data
    var userName: String = "Maruca"

    // Mock data models
    struct PendingVisit: Identifiable {
        let id = UUID()
        let storeName: String
        let visitDate: Date
    }
    struct PendingStore: Identifiable {
        let id = UUID()
        let storeName: String
    }

    // Example mock data
    var pendingVisits: [PendingVisit] = [
        PendingVisit(storeName: "Tienda A", visitDate: DateComponents(calendar: .current, year: 2025, month: 6, day: 10).date!),
        PendingVisit(storeName: "Tienda B", visitDate: DateComponents(calendar: .current, year: 2025, month: 6, day: 15).date!),
        PendingVisit(storeName: "Tienda C", visitDate: DateComponents(calendar: .current, year: 2025, month: 6, day: 20).date!)
    ]
    var pendingStores: [PendingStore] = [
        PendingStore(storeName: "Tienda X"),
        PendingStore(storeName: "Tienda Y"),
        PendingStore(storeName: "Tienda Z")
    ]

    private let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Greeting
                Text("Hola, \(userName)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Gemini Insights Card
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gemini Insights")
                            .font(.headline)
                        Text("\(userName) tienes \(pendingVisits.count) visitas pendientes este mes. Para tu siguiente visita, recomiendo checar el tema del refri agregado en el abarrote \(pendingVisits.first?.storeName ?? "Tienda A").")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Section: Pending Visits
                Text("Visitas pendientes este mes")
                    .font(.headline)

                VStack(spacing: 16) {
                    ForEach(pendingVisits) { visit in
                        HStack {
                            Text(visit.storeName)
                                .font(.body)
                            Spacer()
                            Text(dateFormatter.string(from: visit.visitDate))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                // Section: Pending Stores
                Text("Tiendas pendientes de visita")
                    .font(.headline)

                VStack(spacing: 16) {
                    ForEach(pendingStores) { store in
                        HStack {
                            Text(store.storeName)
                                .font(.body)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewDisplayName("Mock Data with Insights")
    }
}
