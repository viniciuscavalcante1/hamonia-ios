import Foundation
import Combine
import SwiftUI

@MainActor
class PhysicalActivityViewModel: ObservableObject {
    @Published var recentActivities: [Activity] = []
    @Published var isLoading = false
    
    // Timer
    @Published var selectedActivityType: ActivityType?
    @Published var elapsedTime: TimeInterval = 0
    @Published var isActivityRunning = false
    private var timer: AnyCancellable?
    private var startTime: Date?

    // Manual
    @Published var manualActivityType: ActivityType = .running
    @Published var manualDate: Date = Date()
    @Published var manualHours: Int = 0
    @Published var manualMinutes: Int = 0
    @Published var manualSeconds: Int = 0
    @Published var manualDistanceKm: Int = 0
    @Published var manualDistanceMeters: Int = 0

    var manualDurationAsTimeInterval: TimeInterval {
        TimeInterval((manualHours * 3600) + (manualMinutes * 60) + manualSeconds)
    }
    var manualDistanceAsDouble: Double? {
        let totalDistance = Double(manualDistanceKm) + (Double(manualDistanceMeters) / 100.0)
        return totalDistance > 0 ? totalDistance : nil
    }

    private var networkService = NetworkService.shared
    @AppStorage("userId") private var userId: Int = 1
    
    func fetchActivities() {
        networkService.fetchActivities(for: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let activities):
                    self?.recentActivities = activities.sorted(by: { $0.date > $1.date })
                case .failure(let error):
                    print("Erro ao buscar atividades: \(error.localizedDescription)")
                }
            }
        }
    }

    private func saveActivity(activity: Activity, completion: @escaping () -> Void) {
        isLoading = true
        networkService.saveActivity(activity, for: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    print("Atividade salva com sucesso!")
                    self?.fetchActivities()
                case .failure(let error):
                    print("Erro ao salvar atividade: \(error.localizedDescription)")
                }
                completion()
            }
        }
    }
    
    func startActivity(type: ActivityType) {
        selectedActivityType = type
        startTime = Date()
        elapsedTime = 0
        isActivityRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
    }

    func stopActivity() {
        guard let type = selectedActivityType else { return }
        
        let newActivity = Activity(
            id: nil,
            activityType: type,
            duration: elapsedTime,
            distance: 0,
            date: Date()
        )
        
        saveActivity(activity: newActivity) { [weak self] in
            self?.timer?.cancel()
            self?.isActivityRunning = false
            self?.selectedActivityType = nil
        }
    }
    
    func saveManualActivity(completion: @escaping () -> Void) {
        let newActivity = Activity(
            id: nil,
            activityType: manualActivityType,
            duration: manualDurationAsTimeInterval,
            distance: manualDistanceAsDouble,
            date: manualDate
        )
        
        saveActivity(activity: newActivity) { [weak self] in
            self?.resetManualEntryFields()
            completion()
        }
    }
    
    func resetManualEntryFields() {
        manualActivityType = .running
        manualDate = Date()
        manualHours = 0
        manualMinutes = 0
        manualSeconds = 0
        manualDistanceKm = 0
        manualDistanceMeters = 0
    }

    func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
