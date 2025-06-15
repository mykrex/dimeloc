import SwiftUI
import MapKit

struct TiendaMarker: View {
    let tienda: Tienda
    let onTap: () -> Void

    /// Return the matching logo asset name if available
    private var logoName: String? {
        let name = tienda.nombre.lowercased()
        // map each asset → list of substrings it should match
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
        VStack(spacing: 2) {
            if let logo = logoName {
                // Show store logo if available
                Image(logo)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            } else {
                // Fallback marker
                ZStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                    Image(systemName: "storefront")
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                }
            }
        }
        .onTapGesture(perform: onTap)
    }
}
