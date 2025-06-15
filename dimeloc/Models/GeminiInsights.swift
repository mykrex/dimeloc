//
//  GeminiInsights.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import Foundation

struct GeminiInsight: Codable, Identifiable {
    let id = UUID()
    let tiendaId: Int
    let fechaAnalisis: String
    let alertas: [String]
    let insights: [String]
    let recomendaciones: [String]
    let prioridad: String
    
    enum CodingKeys: String, CodingKey {
        case tiendaId = "tienda_id"
        case fechaAnalisis = "fecha_analisis"
        case alertas, insights, recomendaciones, prioridad
    }
}

struct InsightsResponse: Codable {
    let success: Bool
    let data: [GeminiInsight]
}

struct GeminiAnalysis: Codable {
    let alerts: [String]
    let insights: [String]
    let recommendations: [String]
    let priority: String
    let summary: String
}

struct AnalysisResponse: Codable {
    let success: Bool
    let message: String?
    let analysis: GeminiAnalysis
    let feedbackCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case success, message, analysis
        case feedbackCount = "feedback_count"
    }
}

struct GeminiTestResponse: Codable {
    let success: Bool
    let analysis: String
}
