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
        VStack(spacing: 30) {
            Text("Hidratação diária")
                .font(.title2).bold()

            ProgressView(value: viewModel.waterConsumed, total: viewModel.dailyGoal) {
                Text("Meta: \(Int(viewModel.dailyGoal)) ml")
            }
            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            .padding(.horizontal)
            
            Text("\(Int(viewModel.waterConsumed)) ml")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                Button("Copo (250ml)") { viewModel.addWater(amount: 250) }
                Button("Garrafa (500ml)") { viewModel.addWater(amount: 500) }
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle("Hidratação")
        .padding()
    }
}

struct WaterIntakeView_Previews: PreviewProvider {
    static var previews: some View {
        WaterIntakeView()
    }
}
