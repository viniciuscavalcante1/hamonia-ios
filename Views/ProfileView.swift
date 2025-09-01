//
//  ProfileView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 01/09/2025.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("A carregar perfil...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Erro: \(errorMessage)")
                } else if let user = viewModel.user {
                    List {
                        Section {
                            HStack {
                                // Avatar
                                Text(viewModel.userInitials)
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .frame(width: 70, height: 70)
                                    .background(Color.accentColor.opacity(0.2))
                                    .clipShape(Circle())
                                    .foregroundStyle(Color.accentColor)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(user.email)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Logout
                        Section {
                            Button(role: .destructive) {
                                viewModel.logout()
                            } label: {
                                Text("Sair (Logout)")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Perfil")
            .onAppear {
                viewModel.fetchUserDetails()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
