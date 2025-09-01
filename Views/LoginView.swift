//
//  LoginView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 30/08/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    // Salva o estado de autenticação e userID no AppStorage
    @AppStorage("isUserAuthenticated") private var isUserAuthenticated: Bool = false
    @AppStorage("userId") private var userId: Int = 0

    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        ZStack {
            // Interface da tela de login
            VStack(spacing: 40) {
                Spacer()
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                
                Text("Harmonia")
                    .font(.largeTitle.bold())
                
                Text("Saúde integrada, vida simplificada.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Botão "Sign in with Apple".
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: handleSignIn
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 55)
                .clipShape(Capsule())
                .disabled(isLoading)
                
                Text("Ao continuar, você concorda com os nossos Termos de Serviço e Política de Privacidade.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            // Loading
            if isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Entrando...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .scaleEffect(1.5)
            }
        }
        // Alerta se erro de login
        .alert("Erro de login", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Ocorreu um erro desconhecido.")
        }
    }
    
    /// Handle sign in with apple
    private func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let email = appleIDCredential.email else {
                showError(message: "Não conseguimos obter seu e-mail e nome com o Apple ID. Por favor, tente novamente!")
                return
            }
            
            let fullName = appleIDCredential.fullName
            let name = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")".trimmingCharacters(in: .whitespaces)

            loginToServer(name: name.isEmpty ? "Usuário Harmonia" : name, email: email)
            
        case .failure(let error):
            // Cancelamento
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                
                // PS: Lógica especial que só roda em modo debug, enquanto eu ainda não tenho uma conta que participa do Apple Developer Program.

                #if DEBUG
                
                let demoName = "André Silva"
                let demoEmail = "andre.silva.demo@harmonia.app"
                
                print("MODO DEBUG: Simulando login com dados mock \(demoEmail)")
                
                loginToServer(name: demoName, email: demoEmail)
                
                #else
                
                // Produção
                print("Login cancelado pelo usuário.")
                #endif
                
                return
            }
            
            // Outros erros
            showError(message: "A autenticação com a Apple falhou. Por favor, tente novamente! \(error.localizedDescription)")
        }
    }

    /// Envio pro back
    private func loginToServer(name: String, email: String) {
        self.isLoading = true
        NetworkService.shared.login(name: name, email: email) { result in
            self.isLoading = false
            switch result {
            case .success(let user):
                print("Login/cadastro com sucesso para o usuário: \(user.name) (ID: \(user.id))")
                self.userId = user.id
                self.isUserAuthenticated = true
            case .failure(let error):
                showError(message: "Tivemos um erro ao nos comunicarmos com o servidor. Por favor, tente novamente! \(error.localizedDescription)")
            }
        }
    }
    
    /// Mostra erro
    private func showError(message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}






