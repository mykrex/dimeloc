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
    private let _nps: Double?
    private let _fillfoundrate: Double?
    private let _damageRate: Double?
    private let _outOfStock: Double?
    private let _complaintResolutionTimeHrs: Double?
    
    // Propiedades calculadas con valores seguros
    var nps: Double {
        guard let value = _nps, value.isFinite else { return 0.0 }
        return value
    }
    
    var fillfoundrate: Double {
        guard let value = _fillfoundrate, value.isFinite else { return 0.0 }
        return value
    }
    
    var damageRate: Double {
        guard let value = _damageRate, value.isFinite else { return 0.0 }
        return value
    }
    
    var outOfStock: Double {
        guard let value = _outOfStock, value.isFinite else { return 0.0 }
        return value
    }
    
    var complaintResolutionTimeHrs: Double {
        guard let value = _complaintResolutionTimeHrs, value.isFinite else { return 24.0 }
        return value
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nombre
        case location
        case _nps = "nps"
        case _fillfoundrate = "fillfoundrate"
        case _damageRate = "damage_rate"
        case _outOfStock = "out_of_stock"
        case _complaintResolutionTimeHrs = "complaint_resolution_time_hrs"
    }
}

struct Location: Codable {
    private let _longitude: Double?
    private let _latitude: Double?
    
    var longitude: Double {
        guard let value = _longitude, value.isFinite else { return -100.3161 } // Default Monterrey
        return value
    }
    
    var latitude: Double {
        guard let value = _latitude, value.isFinite else { return 25.6866 } // Default Monterrey
        return value
    }
    
    enum CodingKeys: String, CodingKey {
        case _longitude = "longitude"
        case _latitude = "latitude"
    }
}

// Extensiones con validación segura
extension Tienda {
    var coordinate: CLLocationCoordinate2D {
        let lat = location.latitude
        let lng = location.longitude
        
        // Validar que las coordenadas estén en rangos válidos
        let safeLat = max(-90, min(90, lat))
        let safeLng = max(-180, min(180, lng))
        
        return CLLocationCoordinate2D(latitude: safeLat, longitude: safeLng)
    }
    
    var performanceColor: Color {
        let safeNPS = nps
        let safeDamage = damageRate
        let safeStock = outOfStock
        
        if safeNPS >= 50 && safeDamage < 0.5 && safeStock < 3 {
            return .green
        } else if safeNPS >= 30 && safeDamage < 1 && safeStock < 4 {
            return .orange
        } else {
            return .red
        }
    }
    
    var performanceText: String {
        let safeNPS = nps
        let safeDamage = damageRate
        let safeStock = outOfStock
        
        if safeNPS >= 50 && safeDamage < 0.5 && safeStock < 3 {
            return "Excelente"
        } else if safeNPS >= 30 && safeDamage < 1 && safeStock < 4 {
            return "Bueno"
        } else {
            return "Necesita atención"
        }
    }
}
