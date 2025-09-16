//
//  Activity.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 15/09/2025.
//

// Models/Activity.swift

import Foundation

// Enum para os tipos de atividade
enum ActivityType: String, CaseIterable, Codable, Identifiable {
    case running = "Corrida"
    case walking = "Caminhada"
    case cycling = "Ciclismo"
    case strengthTraining = "Treino de Força"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.bike"
        case .strengthTraining: return "figure.strengthtraining.traditional"
        }
    }
}

// Struct para representar um registro de atividade
struct Activity: Codable, Identifiable, Hashable {
    var id: UUID? // Opcional, virá do backend
    let activityType: ActivityType
    let duration: TimeInterval // Em segundos
    let distance: Double? // Em km, opcional
    let date: Date
}
