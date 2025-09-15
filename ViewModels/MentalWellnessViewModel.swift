import Foundation
import SwiftUI

enum Mood: String, CaseIterable, Identifiable, Hashable {
    case feliz = "feliz"
    case bem = "bem"
    case neutro = "neutro"
    case mal = "mal"
    case triste = "triste"
    
    var id: String { self.rawValue }
    
    var emoji: String {
        switch self {
        case .feliz: return "😄"
        case .bem: return "🙂"
        case .neutro: return "😐"
        case .mal: return "😕"
        case .triste: return "😢"
        }
    }
}

@MainActor
class MentalWellnessViewModel: ObservableObject {
    
    // MARK: - Propriedades de Estado (Tela Principal)
    
    @Published var selectedMood: Mood? {
        didSet {
            if oldValue != selectedMood {
                saveJournalEntry(isMoodTriggered: true)
            }
        }
    }
    
    @Published var journalText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // MARK: - Props
    
    @Published var journalHistory: [JournalEntry] = []
    @Published var isHistoryLoading: Bool = false
    @Published var historyErrorMessage: String?
    
    @AppStorage("userId") private var userId: Int = 0
    
    // MARK: - Funções
    
    /// Pode ser executada automaticamente pela seleção de humor ou pelo botão de salvar
    func saveJournalEntry(isMoodTriggered: Bool = false) {
        // Precisa ter um humor selecionado para salvar
        guard let currentMood = selectedMood else { return }
        
        if !isMoodTriggered && journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.errorMessage = "O diário não pode estar vazio."
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        NetworkService.shared.saveJournalEntry(
            userId: userId,
            mood: currentMood.rawValue,
            content: journalText.isEmpty ? nil : journalText,
            date: Date()
        ) { [weak self] result in
            
            self?.isLoading = false
            switch result {
            case .success:
                let message = isMoodTriggered ? "Humor salvo!" : "Diário salvo com sucesso!"
                self?.successMessage = message
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.successMessage = nil
                }
                
            case .failure(let error):
                self?.errorMessage = "Não foi possível salvar. Tente novamente."
                print("Erro ao salvar registro: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchJournalHistory() {
        isHistoryLoading = true
        historyErrorMessage = nil
        
        NetworkService.shared.fetchJournalEntries(userId: userId) { [weak self] result in
            self?.isHistoryLoading = false
            switch result {
            case .success(let entries):
                self?.journalHistory = entries
            case .failure(let error):
                self?.historyErrorMessage = "Não foi possível carregar o histórico."
                print("DEBUG: Erro ao buscar histórico: \(error.localizedDescription)")
            }
        }
    }
}
