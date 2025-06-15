//
//  Feedback.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import Foundation

struct Feedback: Codable, Identifiable {
    let id = UUID()
    let tiendaId: Int
    let colaborador: String
    let fecha: String
    let comentario: String
    let categoria: String
    let urgencia: String
    let resuelto: Bool
    
    enum CodingKeys: String, CodingKey {
        case tiendaId = "tienda_id"
        case colaborador, fecha, comentario, categoria, urgencia, resuelto
    }
}

struct NuevoFeedback: Codable {
    let colaborador: String
    let comentario: String
    let categoria: String
    let urgencia: String
}

struct FeedbackResponse: Codable {
    let success: Bool
    let data: [Feedback]
}

struct FeedbackSubmissionResponse: Codable {
    let success: Bool
    let message: String?
    let feedback: FeedbackInfo?
    let analysis: AnalysisInfo?
}

struct FeedbackInfo: Codable {
    let mongoId: String  // _id de MongoDB
    let tiendaId: Int
    let fecha: String
    let colaborador: String
    let comentario: String
    let categoria: String
    let urgencia: String
    let resuelto: Bool
    
    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
        case tiendaId = "tienda_id"
        case fecha, colaborador, comentario, categoria, urgencia, resuelto
    }
}

struct AnalysisInfo: Codable {
    let generated: Bool
    let priority: String?
    let summary: String?
    let reason: String?
}
