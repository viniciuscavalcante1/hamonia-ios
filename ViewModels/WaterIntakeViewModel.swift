//
//  WaterIntakeViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 14/09/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class WaterIntakeViewModel: ObservableObject {
    @Published var waterLogs: [WaterLog] = []
    @Published var totalIntakeToday: Int = 0
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    @AppStorage("userId") private var userId: Int = 0
    
    let dailyGoal: Int = 2000
    init() {
        fetchLogsForToday()
    }
    
    func fetchLogsForToday() {
        guard userId != 0 else {
            errorMessage = "ID do usuário não encontrado."
            return
        }
        
        isLoading = true
        NetworkService.shared.fetchWaterLogs(userId: self.userId, date: Date()) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let logs):
                self?.waterLogs = logs
                self?.calculateTotal()
            case .failure(let error):
                self?.errorMessage = "Erro ao buscar dados: \(error.localizedDescription)"
            }
        }
    }
    
    func addWater(amount: Int) {
        guard userId != 0 else { return }
        
        isLoading = true
        NetworkService.shared.addWaterLog(userId: self.userId, amount: amount) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let newLog):
                self?.waterLogs.insert(newLog, at: 0)
                self?.calculateTotal()
            case .failure(let error):
                self?.errorMessage = "Erro ao adicionar: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteLog(at offsets: IndexSet) {
        let logsToDelete = offsets.map { self.waterLogs[$0] }
        
        for log in logsToDelete {
            NetworkService.shared.deleteWaterLog(logId: log.id) { [weak self] result in
                switch result {
                case .success:
                    self?.waterLogs.removeAll { $0.id == log.id }
                    self?.calculateTotal()
                case .failure(let error):
                    self?.errorMessage = "Erro ao deletar: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func calculateTotal() {
        totalIntakeToday = waterLogs.reduce(0) { $0 + $1.amountMl }
    }
}
