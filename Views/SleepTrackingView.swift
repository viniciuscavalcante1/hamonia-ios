//
//  SleepTrackingView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 14/09/2025.
//

import SwiftUI

struct SleepTrackingView: View {
    @StateObject private var viewModel = SleepTrackingViewModel()
    
    var body: some View {
        List {
            Section(header: Text("Registrar sono")) {
                DatePicker("Fui dormir às", selection: $viewModel.startTime)
                DatePicker("Acordei às", selection: $viewModel.endTime)
                
                VStack(alignment: .leading) {
                    Text("Qualidade")
                    Picker("Qualidade", selection: $viewModel.selectedQuality) {
                        Text("N/A").tag(SleepQuality?(nil))
                        ForEach(SleepQuality.allCases) { quality in
                            Text(quality.rawValue).tag(SleepQuality?(quality))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button(action: {
                    viewModel.saveSleepLog()
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Label("Salvar", systemImage: "bed.double.fill")
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                .listRowInsets(EdgeInsets())
                .padding(.vertical)
            }

            Section(header: Text("Histórico")) {
                if viewModel.recentLogs.isEmpty {
                    ContentUnavailableView("Nenhum registro de sono", systemImage: "moon.zzz.fill")
                } else {
                    ForEach(viewModel.recentLogs) { log in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(log.startTime, style: .date)
                                    .font(.headline)
                                Text("\(log.startTime, style: .time) - \(log.endTime, style: .time)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(viewModel.formatDuration(minutes: log.durationMinutes))
                                    .font(.title3.weight(.semibold))
                                if let quality = log.quality {
                                    Text(quality.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(qualityColor(quality))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(qualityColor(quality).opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("Sono")
        .onAppear {
            viewModel.fetchRecentSleepLogs()
        }
    }
    
    private func qualityColor(_ quality: SleepQuality) -> Color {
        switch quality {
        case .ruim:
            return .red
        case .ok:
            return .orange
        case .bom:
            return .green
        }
    }
}

struct SleepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SleepTrackingView()
        }
    }
}
