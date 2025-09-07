import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: Propriedades
    
    @Published var greeting: String = "Olá!"
    @Published var activitySteps: String = "0"
    @Published var sleepDuration: String = "0h0min"
    @Published var dailyInsight: String = "Carregando insight..."
    @Published var habits: [HabitStatus] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var isAddingHabit = false
    
    @AppStorage("userId") private var userId: Int = 0
    
    // MARK: Ações

    func fetchDashboardData() {
        guard userId != 0 else {
            self.errorMessage = "Não encontramos um usuário. Por favor, faça login novamente."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        NetworkService.shared.fetchDashboardData(userId: userId, date: Date()) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .success(let dashboardData):
                self.greeting = "Oi, \(dashboardData.userName)!"
                self.activitySteps = "\(dashboardData.activity.steps)"
                self.sleepDuration = "\(dashboardData.sleep.duration)"
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
    
    func toggleCompletion(for habit: HabitStatus) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        let originalStatus = habits[index].isCompleted
        habits[index].isCompleted.toggle()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        NetworkService.shared.toggleHabitCompletion(habitId: habit.id, dateString: dateString) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("Hábito '\(habit.name)' atualizado no servidor!")
            case .failure(let error):
                print("Erro ao atualizar o hábito: \(error.localizedDescription)")
                self.habits[index].isCompleted = originalStatus
                self.errorMessage = "Não foi possível salvar a alteração. Tente novamente."
            }
        }
    }
    
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
                print("Hábito '\(newHabit.name)' adicionado!")
                self?.habits.append(newHabit)
            case .failure(let error):
                self?.errorMessage = "Não conseguimos adicionar o hábito. \(error.localizedDescription)"
            }
        }
    }
}
