import Foundation
import SwiftUI

@MainActor
class HabitDetailViewModel: ObservableObject {
    @Published var currentStreak = 0
    @Published var completedDates: Set<DateComponents> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @AppStorage("userId") private var userId: Int = 0
    
    /// opera em utc
    private var utcCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private var isFetchingInitially = false
    
    func fetchHistory(for habitId: Int) {
        guard userId != 0 else { return }
        isFetchingInitially = true
        isLoading = true
        
        NetworkService.shared.fetchHabitHistory(habitId: habitId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.currentStreak = response.currentStreak
                
                self.completedDates = Set(response.completedDates.compactMap { dateString in
                    guard let date = self.dateFormatter.date(from: dateString) else { return nil }
                    return self.utcCalendar.dateComponents([.year, .month, .day], from: date)
                })
            case .failure(let error):
                self.errorMessage = "Falha ao carregar o histórico: \(error.localizedDescription)"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isFetchingInitially = false
            }
        }
    }
    
    func handleDateSelectionChange(oldSelection: Set<DateComponents>, newSelection: Set<DateComponents>, habitId: Int) {
        guard !isFetchingInitially else { return }
        
        let changedDates = newSelection.symmetricDifference(oldSelection)
        
        for dateComponent in changedDates {
            guard let date = self.utcCalendar.date(from: dateComponent) else { continue }
            let dateString = dateFormatter.string(from: date)
            
            NetworkService.shared.toggleHabitCompletion(habitId: habitId, dateString: dateString) { [weak self] result in
                guard let self = self else { return }
                if case .success = result {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.fetchHistory(for: habitId)
                    }
                }
            }
        }
    }
}
