//
//  Tienda.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import Foundation
import CoreLocation
import SwiftUI

struct Tienda: Codable, Identifiable {
    let id: Int
    let nombre: String
    let location: Location
    let nps: Double
    let fillfoundrate: Double
    let damageRate: Double
    let outOfStock: Double
    let complaintResolutionTimeHrs: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nombre
        case location
        case nps
        case fillfoundrate
        case damageRate = "damage_rate"
        case outOfStock = "out_of_stock"
        case complaintResolutionTimeHrs = "complaint_resolution_time_hrs"
    }
}

struct Location: Codable {
    let longitude: Double
    let latitude: Double
}

// Extensiones útiles
extension Tienda {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    var performanceColor: Color {
        if nps >= 50 && damageRate < 0.5 && outOfStock < 3 {
            return .green
        } else if nps >= 30 && damageRate < 1 && outOfStock < 4 {
            return .orange
        } else {
            return .red
        }
    }
    
    var performanceText: String {
        if nps >= 50 && damageRate < 0.5 && outOfStock < 3 {
            return "Excelente"
        } else if nps >= 30 && damageRate < 1 && outOfStock < 4 {
            return "Bueno"
        } else {
            return "Necesita atención"
        }
    }
}
