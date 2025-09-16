//
//  WaterIntakeViewModel.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 14/09/2025.
//

import Foundation

class WaterIntakeViewModel: ObservableObject {
    @Published var waterConsumed: Double = 0
    let dailyGoal: Double = 2000

    func addWater(amount: Double) {
        waterConsumed += amount
    }
}
