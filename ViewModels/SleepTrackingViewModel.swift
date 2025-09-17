//
//  SleepTrackingViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 14/09/2025.
//

import Foundation
import SwiftUI

@MainActor
class SleepTrackingViewModel: ObservableObject {
    @Published var recentLogs: [SleepLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var startTime: Date = Date().addingTimeInterval(-8 * 3600)
    @Published var endTime: Date = Date()
    @Published var selectedQuality: SleepQuality? = .bom
    
    @AppStorage("userId") private var userId: Int = 0
    
    init() {
        fetchRecentSleepLogs()
    }
    
    func fetchRecentSleepLogs() {
        guard userId != 0 else { return }
        
        isLoading = true
        NetworkService.shared.fetchSleepLogs(userId: userId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let logs):
                self?.recentLogs = logs
            case .failure(let error):
                self?.errorMessage = "Falha ao carregar histórico: \(error.localizedDescription)"
            }
        }
    }
    
    func saveSleepLog() {
        guard userId != 0 else {
            errorMessage = "ID do usuário não encontrado."
            return
        }
        
        isLoading = true
        let newLog = SleepLogCreate(startTime: startTime, endTime: endTime, quality: selectedQuality)
        
        NetworkService.shared.addSleepLog(userId: userId, log: newLog) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let savedLog):
                self?.recentLogs.insert(savedLog, at: 0)
                self?.resetForm()
            case .failure(let error):
                self?.errorMessage = "Falha ao salvar: \(error.localizedDescription)"
            }
        }
    }
    
    private func resetForm() {
        startTime = Date().addingTimeInterval(-8 * 3600)
        endTime = Date()
        selectedQuality = .bom
    }
    
    func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}
