//
//  ActivityTypeSelectionView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 15/09/2025.
//

import SwiftUI

struct ActivityTypeSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var onSelectActivity: (ActivityType) -> Void

    var body: some View {
        NavigationStack {
            List(ActivityType.allCases) { activityType in
                Button(action: {
                    onSelectActivity(activityType)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: activityType.icon)
                            .font(.title)
                            .frame(width: 50)
                        Text(activityType.displayName)
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Escolha a atividade")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
