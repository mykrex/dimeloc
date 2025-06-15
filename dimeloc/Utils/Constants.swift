//
//  Constants.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import Foundation

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
}
