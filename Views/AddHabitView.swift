//
//  AddHabitView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 01/09/2025.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: DashboardViewModel
    
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "star.fill"
    
    let iconOptions = [
        "star.fill", "heart.fill", "book.fill", "figure.walk", "drop.fill",
        "flame.fill", "leaf.fill", "bed.double.fill", "fork.knife", "dumbbell.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nome do hábito")) {
                    TextField("Ex: Correr 5km", text: $habitName)
                }
                
                Section(header: Text("Escolha um ícone")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? Color.accentColor.opacity(0.3) : Color(.systemGray6))
                                .clipShape(Circle())
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Novo hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        viewModel.addHabit(name: habitName, icon: selectedIcon)
                        dismiss()
                    }
                    .disabled(habitName.isEmpty)
                }
            }
        }
    }
}
