import SwiftUI

struct ManualEntryView: View {
    @ObservedObject var viewModel: PhysicalActivityViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalhes")) {
                    Picker("Tipo", selection: $viewModel.manualActivityType) {
                        ForEach(ActivityType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    DatePicker("Data", selection: $viewModel.manualDate, in: ...Date(), displayedComponents: .date)
                }
                
                Section(header: Text("Duração")) {
                    HStack {
                        Picker("Horas", selection: $viewModel.manualHours) {
                            ForEach(0..<24) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        
                        Text("h").font(.headline)

                        Picker("Minutos", selection: $viewModel.manualMinutes) {
                            ForEach(0..<60) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        
                        Text("m").font(.headline)
                        
                        Picker("Segundos", selection: $viewModel.manualSeconds) {
                            ForEach(0..<60) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        
                        Text("s").font(.headline)
                    }
                    .padding(.vertical, -10)
                }
                
                if viewModel.manualActivityType != .strengthTraining {
                    Section(header: Text("Distância")) {
                        HStack {
                            Picker("Quilômetros", selection: $viewModel.manualDistanceKm) {
                                ForEach(0..<1000) { Text("\($0)").tag($0) }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Text(",").font(.title).fontWeight(.heavy)
                            
                            Picker("Metros", selection: $viewModel.manualDistanceMeters) {
                                ForEach(stride(from: 0, to: 100, by: 5).map { $0 }, id: \.self) {
                                    Text(String(format: "%02d", $0)).tag($0)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Text("km").font(.headline)
                        }
                        .padding(.vertical, -10)
                    }
                }
            }
            .navigationTitle("Adicionar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.resetManualEntryFields()
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .confirmationAction) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Salvar") {
                            viewModel.saveManualActivity {
                                dismiss()
                            }
                        }
                        .disabled(viewModel.manualDurationAsTimeInterval == 0)
                    }
                }
            }
        }
    }
}
