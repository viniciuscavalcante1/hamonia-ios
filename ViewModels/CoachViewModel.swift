//
//  CoachViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 01/09/2025.
//

import Foundation
import SwiftUI

@MainActor
class CoachViewModel: ObservableObject {
    
    // Propriedades da view
    @Published var messages: [ChatMessage] = [
        ChatMessage(content: "Olá! Lembre-se: sou seu coach de saúde IA! Como posso te ajudar hoje? :)", isUser: false)
    ]
    @Published var userMessage: String = ""
    @Published var isLoading: Bool = false
    
    // Propriedades AppStorage
    @AppStorage("userId") private var userId: Int = 0

    /// Envia mensagem pro back
    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        
        // Adiciona a mensagem à lista de mensagens e limpa o box
        let userPrompt = userMessage
        messages.append(ChatMessage(content: userPrompt, isUser: true))
        userMessage = ""
        isLoading = true
        
        guard userId != 0 else {
            isLoading = false
            let errorMessage = "Erro: Não encontramos um usuário. Por favor, faça login novamente."
            messages.append(ChatMessage(content: errorMessage, isUser: false))
            return
        }
        
        let historyPayload = messages.dropLast().suffix(6).map { message -> ChatMessagePayload in
                let role = message.isUser ? "user" : "model"
                return ChatMessagePayload(role: role, content: message.content)
            }

        NetworkService.shared.askCoach(currentMessage: userPrompt, history: Array(historyPayload), userId: userId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let answer):
                self?.messages.append(ChatMessage(content: answer, isUser: false))
            case .failure(let error):
                let errorMessage = "Peço desculpas pelo inconveniente, mas ocorreu um erro em meus sistemas internosß. Por favor, tente novamente. (\(error.localizedDescription))"
                self?.messages.append(ChatMessage(content: errorMessage, isUser: false))
            }
        }
    }
}
