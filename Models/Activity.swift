import Foundation

enum ActivityType: String, CaseIterable, Codable, Identifiable {
    case running = "Corrida"
    case walking = "Caminhada"
    case cycling = "Ciclismo"
    case strengthTraining = "Treino de Força"

    var id: String { self.rawValue }
    var displayName: String { self.rawValue }

    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .strengthTraining: return "figure.strengthtraining.traditional"
        }
    }
}

struct Activity: Codable, Identifiable, Hashable {
    let id: Int?
    let activityType: ActivityType
    let duration: TimeInterval
    let distance: Double?
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id, duration, distance, date
        case activityType = "activity_type"
    }
}
