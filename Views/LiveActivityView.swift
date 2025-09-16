//
//  LiveActivityView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 15/09/2025.
//

import SwiftUI

struct LiveActivityView: View {
    @ObservedObject var viewModel: PhysicalActivityViewModel

    var body: some View {
        VStack(spacing: 40) {
            if let type = viewModel.selectedActivityType {
                Text(type.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Text(viewModel.formatTime(viewModel.elapsedTime))
                .font(.system(size: 70, weight: .regular, design: .monospaced))
                
            Button(action: {
                viewModel.stopActivity()
            }) {
                Text("Parar e salvar")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
