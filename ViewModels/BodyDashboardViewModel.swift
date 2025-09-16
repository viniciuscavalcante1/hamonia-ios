import Foundation
import SwiftUI

@MainActor
class BodyDashboardViewModel: ObservableObject {
    @Published var activitySummary = "..."
    @Published var nutritionSummary = "..."
    @Published var hydrationSummary = "..."
    @Published var sleepSummary = "..."

    func fetchSummaryData() {
        activitySummary = "7.890 Passos"
        nutritionSummary = "1.250 kcal"
        hydrationSummary = "1.250 ml"
        sleepSummary = "7h 15m"
    }
}
