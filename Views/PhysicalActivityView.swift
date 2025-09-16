import SwiftUI
import Charts

struct PhysicalActivityView: View {
    @StateObject private var viewModel = PhysicalActivityViewModel()
    @State private var isShowingActivitySelector = false
    @State private var isShowingManualEntry = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Resumo semanal")) {
                    if viewModel.recentActivities.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Sem atividades")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)

                    } else {
                        Chart(viewModel.recentActivities) { activity in
                            BarMark(
                                x: .value("Data", activity.date, unit: .day),
                                y: .value("Duração (min)", activity.duration / 60)
                            )
                            .foregroundStyle(by: .value("Tipo", activity.activityType.displayName))
                        }
                        .frame(height: 200)
                    }
                }

                Section(header: Text("Histórico")) {
                    if viewModel.recentActivities.isEmpty {
                        Text("Nenhuma atividade registrada ainda. Toque em '+' para adicionar uma.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.recentActivities, id: \.id) { activity in
                            HStack(spacing: 15) {
                                Image(systemName: activity.activityType.icon)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 30)

                                VStack(alignment: .leading) {
                                    Text(activity.activityType.displayName)
                                        .fontWeight(.semibold)
                                    Text(activity.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(viewModel.formatTime(activity.duration))
                                        .font(.headline.monospacedDigit())
                                    
                                    if let distance = activity.distance, distance > 0 {
                                        Text(String(format: "%.2f km", distance))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Atividade física")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        isShowingManualEntry = true
                    }) {
                        Image(systemName: "plus")
                    }
                    
                    Button("Iniciar") {
                        isShowingActivitySelector = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                viewModel.fetchActivities()
            }
            .sheet(isPresented: $isShowingActivitySelector) {
                ActivityTypeSelectionView { selectedType in
                    viewModel.startActivity(type: selectedType)
                }
            }
            .sheet(isPresented: $isShowingManualEntry) {
                ManualEntryView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.isActivityRunning) {
                LiveActivityView(viewModel: viewModel)
            }
        }
    }
}

struct PhysicalActivityView_Previews: PreviewProvider {
    static var previews: some View {
        PhysicalActivityView()
    }
}
