//
//  ProfileViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 01/09/2025.
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    
    // Propriedades da view
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Propriedades do appStorage
    @AppStorage("userId") private var userId: Int = 0
    @AppStorage("isUserAuthenticated") private var isUserAuthenticated: Bool = false

    /// Busca o usuário
    func fetchUserDetails() {
        guard userId != 0 else {
            errorMessage = "Não encontramos nenhum usuário com este ID."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        NetworkService.shared.fetchUserDetails(userId: userId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let user):
                self?.user = user
            case .failure(let error):
                self?.errorMessage = "Não conseguimos carregar os dados do perfil. \(error.localizedDescription)"
            }
        }
    }
    
    /// Faz logout
    func logout() {
        userId = 0
        isUserAuthenticated = false
    }
    
    /// Gera iniciais do usuário pro avatar
    var userInitials: String {
        guard let user = user else { return "?" }
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: user.name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return "?"
    }
}
