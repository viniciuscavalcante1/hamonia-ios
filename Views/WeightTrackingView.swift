//
//  WeightTrackingView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 15/09/2025.
//

import SwiftUI

struct WeightTrackingView: View {
    @StateObject private var viewModel = WeightTrackingViewModel()

    var body: some View {
        VStack(spacing: 30) {
            Text("Último peso registrado")
                .font(.headline)
            
            Text(String(format: "%.1f kg", viewModel.currentWeight))
                .font(.system(size: 50, weight: .bold))

            VStack {
                TextField("Digite o novo peso (ex: 75,2)", text: $viewModel.weightInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                
                Button("Salvar") {
                    viewModel.saveNewWeight()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.weightInput.isEmpty)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Peso e medidas")
    }
}

struct WeightTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        WeightTrackingView()
    }
}
