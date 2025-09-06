//
//  OnboardingViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 06/09/2025.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var suggestedHabits: [HabitSuggestion] = []
    @Published var isLoading = false
    @AppStorage("userId") private var userId: Int = 0
    
    func fetchSuggestions(for objective: String) {
        isLoading = true
        
        NetworkService.shared.updateUserGoal(goal: objective, userId: userId) { result in
            switch result {
            case .success:
                NetworkService.shared.fetchSuggestedHabits(for: objective) { result in
                    self.isLoading = false
                    switch result {
                    case .success(let habits):
                        self.suggestedHabits = habits
                    case .failure(let error):
                        print("Erro ao buscar sugestões: \(error)")
                    }
                }
            case .failure(let error):
                self.isLoading = false
                print("Erro ao salvar objetivo: \(error)")
            }
        }
    }
    
    func addSuggestedHabits() {
        for habit in suggestedHabits {
            NetworkService.shared.addHabit(userId: userId, name: habit.name, icon: habit.icon) { _ in }
        }
    }
}
