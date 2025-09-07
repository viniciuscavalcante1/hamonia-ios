import SwiftUI

struct HabitDetailView: View {
    let habit: HabitStatus
    @StateObject private var viewModel = HabitDetailViewModel()
    
    @State private var displayedMonth: Date = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 16) {
                    Image(systemName: habit.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    
                    Text(habit.name)
                        .font(.largeTitle.bold())
                }
                
                VStack {
                    Text("🔥 Sequência atual")
                        .font(.headline)
                    Text("\(viewModel.currentStreak) dias")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                VStack(alignment: .leading) {
                    Text("Histórico de conclusão")
                        .font(.title2.bold())
                    
                    HabitCalendarView(
                        displayedMonth: $displayedMonth,
                        selectedDates: $viewModel.completedDates
                    )
                    .onChange(of: viewModel.completedDates) { oldValue, newValue in
                        viewModel.handleDateSelectionChange(oldSelection: oldValue, newSelection: newValue, habitId: habit.id)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detalhes do hábito")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchHistory(for: habit.id)
        }
    }
}


struct HabitCalendarView: View {
    @Binding var displayedMonth: Date
    @Binding var selectedDates: Set<DateComponents>
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SÁB"]
    
    var body: some View {
        VStack {
            HStack {
                Text(monthYearString(from: displayedMonth))
                    .font(.headline.bold())
                Spacer()
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(isNextMonthInFuture())
            }
            .padding(.bottom, 8)
            
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(generateDaysInMonth(), id: \.self) { date in
                    DayView(date: date, selectedDates: $selectedDates)
                }
            }
        }
    }
    
    
    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let emptySpaces = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: emptySpaces)
        
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)!.count
        for day in 1...numberOfDaysInMonth {
            let date = calendar.date(bySetting: .day, value: day, of: firstDayOfMonth)!
            days.append(date)
        }
        
        return days
    }
    
    private func changeMonth(by amount: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: amount, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
    
    private func isNextMonthInFuture() -> Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return true }
        return calendar.compare(nextMonth, to: Date(), toGranularity: .month) == .orderedDescending
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
}

struct DayView: View {
    let date: Date?
    @Binding var selectedDates: Set<DateComponents>
    
    private var dateComponents: DateComponents? {
        guard let date = date else { return nil }
        return Calendar.current.dateComponents([.year, .month, .day], from: date)
    }
    
    private var isSelected: Bool {
        guard let components = dateComponents else { return false }
        return selectedDates.contains(components)
    }
    
    private var isFutureDate: Bool {
        guard let date = date else { return true }
        return date > Date() && !Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        if let date = date {
            Button(action: toggleSelection) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(isSelected ? Color.accentColor : Color.clear)
                    .clipShape(Circle())
                    .foregroundColor(isSelected ? .white : (isFutureDate ? Color(.systemGray4) : .primary))
            }
            .disabled(isFutureDate)
        } else {
            Rectangle().fill(Color.clear)
        }
    }
    
    private func toggleSelection() {
        guard let components = dateComponents else { return }
        if isSelected {
            selectedDates.remove(components)
        } else {
            selectedDates.insert(components)
        }
    }
}
