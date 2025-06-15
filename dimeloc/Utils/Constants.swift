import Foundation
import SwiftUI

struct Constants {
    struct API {
        static let baseURL = "https://dimeloc-backend.onrender.com/api"

        struct Endpoints {
            static let tiendas = "/tiendas"
            static let problematicas = "/tiendas/problematicas"
            static let stats = "/stats"
        }
    }

    struct Map {
        static let monterreyCenter = (lat: 25.6866, lng: -100.3161)
        static let defaultSpan = (lat: 0.1, lng: 0.1)
    }

    struct Style {
        static let ShadeWhite: Color = .white
        static let NeutralN200: Color = Color(red: 0.89, green: 0.91, blue: 0.94)
        static let NeutralN400: Color = Color(red: 0.58, green: 0.64, blue: 0.72)
        static let RadiusFull: CGFloat = 9999
    }
}
