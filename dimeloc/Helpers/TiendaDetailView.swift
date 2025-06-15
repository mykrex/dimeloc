import SwiftUI

struct TiendaDetailView: View {
    let tienda: Tienda
    @Environment(\.dismiss) private var dismiss
    
    // MARK: – Logo detection
    private var logoName: String? {
        let name = tienda.nombre.lowercased()
        let patterns: [String: [String]] = [
            "oxxo":       ["oxxo", "el primer oxxo"],
            "7eleven":    ["7-eleven", "7 eleven", "7eleven", "7 / eleven"],
            "heb":        ["h-e-b"],
            "modelorama": ["modelorama"],
            "six":        ["six"],
            "soriana":    ["soriana"],
            "walmart":    ["walmart"]
        ]
        for (asset, keys) in patterns {
            if keys.contains(where: { name.contains($0) }) {
                return asset
            }
        }
        return nil
    }


    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with name & status
                    // new
                    HStack(spacing: 12) {
                      // logo asset (already circular in assets)
                        if let logo = logoName {
                                Image(logo)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "storefront")
                                      .resizable()                // make the symbol resizable
                                      .scaledToFit()              // preserve aspect
                                      .frame(width:  30, height: 30) // e.g. 30×30, adjust as you like
                                      .foregroundColor(.white)
                                }
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tienda.nombre)
                                .font(.title2).bold()
                            HStack(){
                                Circle()
                                    .stroke(tienda.performanceColor, lineWidth: 2)
                                    .frame(width: 12, height: 12)
                                Text(tienda.performanceText)
                                    .font(.subheadline)
                                    .foregroundColor(tienda.performanceColor)
                            }
                        }

                      Spacer()

                      // status dot as a stroke
                       
                    }
                    .padding(8)
                    .overlay(
                      RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )


                    // Metrics grid
                    VStack(spacing: 16) {
                      // Row 1
                      HStack(spacing: 12) {
                        MetricCard(title: "NPS",            value: String(format: "%.1f", tienda.nps),          color: tienda.performanceColor)
                              .frame(maxWidth: .infinity)

                        MetricCard(title: "Disponibilidad", value: String(format: "%.1f%%", tienda.fillfoundrate), color: .blue)
                              .frame(maxWidth: .infinity)

                      }

                      // Row 2
                      HStack(spacing: 12) {
                        MetricCard(title: "Daños",      value: String(format: "%.2f%%", tienda.damageRate), color: tienda.damageRate > 1 ? .red : .green)
                              .frame(maxWidth: .infinity)

                        MetricCard(title: "Desabasto",  value: String(format: "%.2f%%", tienda.outOfStock),   color: tienda.outOfStock > 4 ? .red : .green)
                              .frame(maxWidth: .infinity)

                      }

                      // Row 3 (full width)
                      MetricCard(
                        title: "Resolución de Quejas",
                        value: String(format: "%.1f horas", tienda.complaintResolutionTimeHrs),
                        color: .orange
                      )
                      .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 16)

                }
                .padding()
            }
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct TiendaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // mock Tienda with id and Location
        let mockTienda = Tienda(
            id: 1,
            nombre: "Mock Tienda",
            location: Location(longitude: -100.3161, latitude: 25.6866),
            nps: 75,
            fillfoundrate: 95,
            damageRate: 0.3,
            outOfStock: 1.0,
            complaintResolutionTimeHrs: 2.5
        )
        return TiendaDetailView(tienda: mockTienda)
    }
}
#endif

