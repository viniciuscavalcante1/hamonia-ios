import SwiftUI

struct JournalHistoryView: View {
    @ObservedObject var viewModel: MentalWellnessViewModel
    
    var body: some View {
        VStack {
            if viewModel.isHistoryLoading {
                ProgressView("Carregando histórico...")
            } else if let errorMessage = viewModel.historyErrorMessage {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Erro ao carregar")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else if viewModel.journalHistory.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "moon.stars.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Nenhuma entrada no diário ainda.")
                        .foregroundColor(.secondary)
                    Text("Seus registros aparecerão aqui.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                List(viewModel.journalHistory) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(Mood(rawValue: entry.mood)?.emoji ?? "🤔")
                                .font(.title)
                            Text(entry.formattedDate)
                                .font(.headline)
                            Spacer()
                        }
                        
                        if !entry.text.isEmpty {
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(4)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Histórico do diário")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchJournalHistory()
        }
    }
}

extension JournalEntry {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}
