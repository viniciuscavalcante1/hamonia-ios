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
        VStack(spacing: 20) {
            Text("Duração do sono (última noite)")
                .font(.headline)
            
            Text(viewModel.sleepData)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .navigationTitle("Sono")
    }
}

struct SleepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        SleepTrackingView()
    }
}
