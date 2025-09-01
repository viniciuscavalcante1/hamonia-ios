//
//  DashboardViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 01/09/2025.
//

import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: Propriedades
    
    @Published var greeting: String = "Olá!"
    @Published var activitySteps: String = "0"
    @Published var sleepDuration: String = "0h0min"
    @Published var dailyInsight: String = "Carregando insight..."
    @Published var habits: [Habit] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var isAddingHabit = false
    
    
    // MARK: Propriedades AppStorage
    
    // Acessa o userID salvo no login
    @AppStorage("userId") private var userId: Int = 0
    
    // MARK: Ações

    /// Busca dados de dashboard
    func fetchDashboardData() {
        guard userId != 0 else {
            self.errorMessage = "Não encontramos um usuário com este ID. Por favor, faça login novamente."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        NetworkService.shared.fetchDashboardData(userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .success(let dashboardData):
                self.greeting = "Olá, \(dashboardData.userName)!"
                self.activitySteps = "\(dashboardData.activity.steps)"
                self.sleepDuration = dashboardData.sleep.duration
                self.dailyInsight = dashboardData.dailyInsight
                self.habits = dashboardData.habits
                
            case .failure(let error):
                self.errorMessage = "Não foi possível carregar os dados. \(error.localizedDescription)"
            }
        }
    }
    
    func fetchDashboardDataAsync() async {
        fetchDashboardData()
    }
    
    /// Toggle habit
    func toggleCompletion(for habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
            print("Erro: Este hábito não foi encontrado na lista local.")
            return
        }
        
        let originalStatus = habits[index].isCompleted
        habits[index].isCompleted.toggle()
        
        NetworkService.shared.toggleHabitCompletion(habit: habits[index]) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let updatedHabit):
                print("Hábito '\(updatedHabit.name)' atualizado com sucesso no servidor!")
                
            case .failure(let error):
                print("Erro ao atualizar o hábito no servidor: \(error.localizedDescription)")
                self.habits[index].isCompleted = originalStatus
                self.errorMessage = "Não conseguimos salvar a alteração do hábito. Por favor, tente novamente."
            }
        }
    }
    
    /// Adiciona um novo hábito
    func addHabit(name: String, icon: String) {
        guard userId != 0 else {
            errorMessage = "Não é possível adicionar um hábito sem um usuário logado!"
            return
        }
        
        isLoading = true
        NetworkService.shared.addHabit(userId: userId, name: name, icon: icon) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let newHabit):
                print("Hábito '\(newHabit.name)' adicionado com sucesso!")
                // Refresh dashboard
                self?.fetchDashboardData()
            case .failure(let error):
                self?.errorMessage = "Não conseguimos adicionar o hábito. \(error.localizedDescription)"
            }
        }
    }
}
