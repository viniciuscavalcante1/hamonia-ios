import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.suggestedHabits.isEmpty {
                    ObjectiveInputView(viewModel: viewModel)
                } else {
                    HabitSuggestionView(viewModel: viewModel)
                }
            }
            .navigationTitle("Personalização")
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
            
            TextField("Ex: Dormir melhor, reduzir o estresse...", text: $objective)
                .textFieldStyle(.roundedBorder)
            
            Button("Obter Sugestões") {
                viewModel.fetchSuggestions(for: objective)
            }
            .buttonStyle(.borderedProminent)
            .disabled(objective.isEmpty || viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}

struct HabitSuggestionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Aqui estão 3 hábitos para começar:")
                .font(.title2.bold())
            
            ForEach(viewModel.suggestedHabits, id: \.name) { habit in
                HabitRow(habit: Habit(id: 0, userId: 0, name: habit.name, icon: habit.icon, isCompleted: false, date: ""))
            }
            
            Button("Adicionar à minha rotina") {
                viewModel.addSuggestedHabits()
                hasCompletedOnboarding = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
