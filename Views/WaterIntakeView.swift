//
//  WaterIntakeView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 14/09/2025.
//

import SwiftUI

struct WaterIntakeView: View {
    @StateObject private var viewModel = WaterIntakeViewModel()
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    ProgressView(value: Double(viewModel.totalIntakeToday), total: Double(viewModel.dailyGoal)) {
                        Text("Progresso diário")
                            .font(.headline)
                    } currentValueLabel: {
                        Text("\(viewModel.totalIntakeToday) / \(viewModel.dailyGoal) ml")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .tint(.appBlue)
                    .controlSize(.large)
                    
                    Text("Meta: Beber \(viewModel.dailyGoal / 1000) litros por dia!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)
            }
            
            // Seção de Ações Rápidas
            Section(header: Text("Adicionar Consumo")) {
                HStack {
                    Spacer()
                    QuickAddButton(amount: 250, viewModel: viewModel)
                    Spacer()
                    QuickAddButton(amount: 500, viewModel: viewModel)
                    Spacer()
                    QuickAddButton(amount: 750, viewModel: viewModel)
                    Spacer()
                }
                .buttonStyle(.bordered)
            }
            
            Section(header: Text("Registros de hoje")) {
                if viewModel.isLoading && viewModel.waterLogs.isEmpty {
                    ProgressView()
                } else if viewModel.waterLogs.isEmpty {
                    ContentUnavailableView("Nenhum registro ainda", systemImage: "drop.fill")
                } else {
                    ForEach(viewModel.waterLogs) { log in
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(.appBlue)
                            Text("\(log.amountMl) ml")
                            Spacer()
                            Text(log.logDate, style: .time)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: viewModel.deleteLog)
                }
            }
        }
        .navigationTitle("Hidratação")
        .refreshable {
            viewModel.fetchLogsForToday()
        }
        .onAppear {
            if viewModel.waterLogs.isEmpty {
                viewModel.fetchLogsForToday()
            }
        }
    }
}

struct QuickAddButton: View {
    let amount: Int
    @ObservedObject var viewModel: WaterIntakeViewModel
    
    private func iconName(for amount: Int) -> String {
        switch amount {
        case 250:
            return "cup.and.saucer.fill"
        case 500:
            return "mug.fill"
        default:
            return "takeoutbag.and.cup.and.straw.fill"
        }
    }
    
    var body: some View {
        Button(action: {
            viewModel.addWater(amount: amount)
        }) {
            VStack {
                Image(systemName: iconName(for: amount))
                    .font(.title2)
                Text("\(amount) ml")
                    .font(.caption)
            }
        }
        .tint(.appBlue)
    }
}


struct WaterIntakeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WaterIntakeView()
        }
    }
}
