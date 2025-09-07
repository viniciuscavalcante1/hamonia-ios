//
//  DashboardView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 01/09/2025.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.largeTitle).foregroundStyle(.secondary)
                        Text("Ocorreu um Erro").font(.headline)
                        Text(errorMessage).font(.caption).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center).padding(.horizontal)
                        Button("Tentar Novamente") {
                            viewModel.fetchDashboardData()
                        }
                        .padding(.top)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(viewModel.greeting)
                                .font(.largeTitle.bold())
                                .padding(.bottom, 10)
                            
                            HStack(spacing: 16) {
                                MetricCard(title: "Atividade", value: viewModel.activitySteps, unit: "passos", icon: "figure.walk", color: Color("AppBlue"))
                                MetricCard(title: "Sono", value: viewModel.sleepDuration, unit: "total", icon: "bed.double.fill", color: Color("AppGreen"))
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("✨ Insight do dia").font(.headline).foregroundStyle(.secondary)
                                Text(viewModel.dailyInsight)
                            }
                            .padding().background(Color(.secondarySystemBackground)).cornerRadius(16)
                            
                            Text("Seus hábitos de hoje").font(.title2.bold())
        
                            if viewModel.isLoading && viewModel.habits.isEmpty {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                            } else if viewModel.habits.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "sparkles")
                                        .font(.largeTitle).foregroundStyle(.secondary)
                                    Text("Nenhum hábito cadastrado.").font(.headline)
                                    Text("Toque no botão '+' para adicionar seu primeiro hábito!").font(.caption).foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(viewModel.habits) { habit in
                                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                                        HabitRow(habit: habit, viewModel: viewModel)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                    }
                    .refreshable {
                        await viewModel.fetchDashboardDataAsync()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isAddingHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddingHabit) {
                AddHabitView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchDashboardData()
            }
        }
    }
}

struct HabitRow: View {
    let habit: HabitStatus
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        HStack {
            Image(systemName: habit.icon)
                .font(.title2).frame(width: 40)
                .foregroundColor(habit.isCompleted ? .white : .accentColor)
            Text(habit.name).font(.headline)
            Spacer()
            
            Button(action: {
                viewModel.toggleCompletion(for: habit)
            }) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(habit.isCompleted ? Color("AppGreen") : Color(.systemGray4))
            }
            
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .background(habit.isCompleted ? Color.accentColor.opacity(0.8) : Color(.secondarySystemBackground))
        .foregroundColor(habit.isCompleted ? .white : .primary)
        .cornerRadius(16)
        .animation(.snappy, value: habit.isCompleted)
    }
}

struct MetricCard: View {
    let title: String, value: String, unit: String, icon: String, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.headline).foregroundColor(color)
            Spacer()
            Text(value).font(.title.bold())
            Text(unit).font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading).frame(height: 120)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

