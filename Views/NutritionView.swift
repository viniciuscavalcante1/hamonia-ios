//
//  NutritionView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 14/09/2025.
//

import SwiftUI

struct NutritionView: View {
    @StateObject private var viewModel = NutritionViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Calorias consumidas Hoje")
                .font(.headline)
            
            Text("\(viewModel.caloriesToday) kcal")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button(action: {
            }) {
                Text("Adicionar refeição")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Nutrição")
    }
}

struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
