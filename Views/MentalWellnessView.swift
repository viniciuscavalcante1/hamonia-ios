import SwiftUI

struct MentalWellnessView: View {
    @StateObject private var viewModel = MentalWellnessViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    MoodSelectionView(selectedMood: $viewModel.selectedMood)
                    
                    BreathingExerciseView()
                    
                    JournalInputView(viewModel: viewModel)
                    
                    if !viewModel.journalText.isEmpty {
                        SaveButtonView(viewModel: viewModel)
                    }
                    
                    NavigationLink(destination: JournalHistoryView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "book.closed.fill")
                            Text("Ver histórico do diário")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Mente")
        }
    }
}


struct MoodSelectionView: View {
    @Binding var selectedMood: Mood?

    var body: some View {
        VStack(spacing: 12) {
            Text("Como você se sente hoje?")
                .font(.title2.bold())
            
            HStack(spacing: 15) {
                ForEach(Mood.allCases) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        Text(mood.emoji)
                            .font(.system(size: 40))
                            .padding(10)
                            .background(
                                (selectedMood == mood ? Color.accentColor.opacity(0.3) : Color.clear)
                                    .clipShape(Circle())
                            )
                            .scaleEffect(selectedMood == mood ? 1.1 : 1.0)
                    }
                }
            }
            .animation(.spring(), value: selectedMood)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}


struct BreathingExerciseView: View {
    enum BreathingPhase {
        case initial, inhale, hold, exhale, pause
    }

    @State private var phase: BreathingPhase = .initial
    @State private var isAnimating = false

    var body: some View {
        VStack {
            Text("Respire fundo")
                .font(.title2.bold())
                .padding(.bottom, 10)

            ZStack {
                Circle().fill(Color.accentColor.opacity(0.1))
                Circle().stroke(Color.accentColor.opacity(0.3), lineWidth: 5)

                Circle()
                    .fill(Color.accentColor.opacity(0.8))
                    .scaleEffect(phase == .inhale || phase == .hold ? 1.0 : 0.55)

                Text(textForPhase(phase))
                    .font(.headline)
                    .foregroundColor(.white)
                    .animation(nil, value: phase)
            }
            .frame(width: 180, height: 180)

            Button(isAnimating ? "Parar exercício" : "Começar exercício") {
                isAnimating.toggle()
                if isAnimating {
                    startBreathingCycle()
                } else {
                    resetAnimation()
                }
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func textForPhase(_ currentPhase: BreathingPhase) -> String {
        switch currentPhase {
        case .initial: return "Começar"
        case .inhale: return "Inspire..."
        case .hold: return "Segure"
        case .exhale: return "Expire..."
        case .pause: return "Pausa"
        }
    }
    
    private func startBreathingCycle() {
        guard isAnimating else { return }
        
        withAnimation(.easeInOut(duration: 4.0)) { phase = .inhale }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            guard isAnimating else { return }
            phase = .hold
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                guard isAnimating else { return }
                withAnimation(.easeInOut(duration: 4.0)) { phase = .exhale }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    guard isAnimating else { return }
                    phase = .pause
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        startBreathingCycle()
                    }
                }
            }
        }
    }
    
    private func resetAnimation() {
        isAnimating = false
        withAnimation(.easeInOut(duration: 0.5)) {
            phase = .initial
        }
    }
}


struct JournalInputView: View {
    @ObservedObject var viewModel: MentalWellnessViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Diário do dia")
                .font(.title2.bold())
            
            TextEditor(text: $viewModel.journalText)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(minHeight: 150, maxHeight: 300)
                .overlay(
                    viewModel.journalText.isEmpty ? Text("Escreva um pouco sobre como foi o seu dia...")
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.all, 12)
                        .allowsHitTesting(false) : nil,
                    alignment: .topLeading
                )
        }
    }
}


struct SaveButtonView: View {
    @ObservedObject var viewModel: MentalWellnessViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.saveJournalEntry(isMoodTriggered: false)
            }) {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Salvar diário")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.isLoading)
            
            if let message = viewModel.successMessage ?? viewModel.errorMessage {
                Text(message)
                    .foregroundColor(viewModel.successMessage != nil ? .green : .red)
                    .font(.caption)
                    .padding(.top, 5)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.successMessage)
        .animation(.default, value: viewModel.errorMessage)
    }
}
