//
//  WeightTrackingViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 15/09/2025.
//

import Foundation

class WeightTrackingViewModel: ObservableObject {
    @Published var currentWeight: Double = 75.5
    @Published var weightInput: String = ""
    
    func saveNewWeight() {
        guard let newWeight = Double(weightInput.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        currentWeight = newWeight
        weightInput = ""
    }
}
