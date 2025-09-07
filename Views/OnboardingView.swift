//
//  OnboardingView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 07/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            NavigationView {
                if viewModel.suggestedHabits.isEmpty {
                    ObjectiveInputView(viewModel: viewModel)
                        .navigationTitle("Personalização")
                } else {
                    HabitSuggestionView(viewModel: viewModel)
                        .navigationTitle("Sugestões para você")
                }
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Analisando seu objetivo...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .scaleEffect(1.5)
            }
        }
    }
}

struct ObjectiveInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var objective: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Qual seu principal objetivo de saúde?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            TextField("Ex: dormir melhor, reduzir o estresse...", text: $objective)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Obter sugestões com IA") {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                viewModel.fetchSuggestions(for: objective)
            }
            .buttonStyle(.borderedProminent)
            .disabled(objective.isEmpty)
        }
        .padding()
    }
}

struct HabitSuggestionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Com base no seu objetivo, sugerimos começar com estes 3 hábitos:")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ForEach(viewModel.suggestedHabits) { habit in
                SuggestionRow(habit: habit)
            }
            
            Spacer()
            
            Button("Adicionar à minha rotina") {
                viewModel.addSuggestedHabits()
                hasCompletedOnboarding = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
    }
}

struct SuggestionRow: View {
    let habit: HabitSuggestion

    var body: some View {
        HStack {
            Image(systemName: habit.icon)
                .font(.title2).frame(width: 40)
                .foregroundColor(.accentColor)
            Text(habit.name).font(.headline)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
