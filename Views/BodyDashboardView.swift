// Views/BodyDashboardView.swift

import SwiftUI

struct BodyDashboardView: View {
    @StateObject private var viewModel = BodyDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    NavigationLink(destination: PhysicalActivityView()) {
                        MetricCardView(
                            icon: "figure.walk.circle.fill",
                            title: "Atividade",
                            value: viewModel.activitySummary,
                            color: .appGreen
                        )
                    }

                    NavigationLink(destination: Text("Tela de nutrição")) {
                        MetricCardView(
                            icon: "leaf.circle.fill",
                            title: "Nutrição",
                            value: viewModel.nutritionSummary,
                            color: .appOrange
                        )
                    }

                    NavigationLink(destination: Text("Tela de hidratação")) {
                        MetricCardView(
                            icon: "drop.circle.fill",
                            title: "Hidratação",
                            value: viewModel.hydrationSummary,
                            color: .appBlue
                        )
                    }

                    NavigationLink(destination: Text("Tela de sono")) {
                        MetricCardView(
                            icon: "moon.circle.fill",
                            title: "Sono",
                            value: viewModel.sleepSummary,
                            color: .appRed
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Corpo")
            .onAppear {
                viewModel.fetchSummaryData()
            }
        }
        .accentColor(.primary)
    }
}

struct BodyDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        BodyDashboardView()
    }
}
