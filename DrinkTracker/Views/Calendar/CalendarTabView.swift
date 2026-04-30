import SwiftUI

struct CalendarTabView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showDayDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's date
                    Text(viewModel.todayFormatted)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    // Legend
                    legendView

                    // Calendar
                    calendarView

                    // Day detail
                    dayDetailSection
                }
                .padding(.vertical)
            }
            .navigationTitle("SipTrak")
            .task {
                await viewModel.loadMonthData()
                await viewModel.loadRecords(for: viewModel.selectedDate)
            }
        }
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: 24) {
            ForEach(DrinkCategory.allCases) { category in
                HStack(spacing: 6) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 10, height: 10)
                    Text(category.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Calendar

    private var calendarView: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Button(action: { viewModel.previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                Text(viewModel.monthTitle)
                    .font(.headline)

                Spacer()

                Button(action: { viewModel.nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(viewModel.weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

            LazyVGrid(columns: columns, spacing: 8) {
                // Empty cells for offset
                ForEach(0..<viewModel.firstWeekdayOfMonth, id: \.self) { _ in
                    Color.clear
                        .frame(height: 50)
                }

                // Day cells
                ForEach(viewModel.currentMonthDates, id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        isToday: viewModel.isToday(date),
                        isSelected: viewModel.isSelected(date),
                        categories: viewModel.categoriesFor(date: date)
                    )
                    .onTapGesture {
                        Task {
                            await viewModel.loadRecords(for: date)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        )
        .padding(.horizontal)
    }

    // MARK: - Day Detail

    private var dayDetailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let formatter: DateFormatter = {
                let f = DateFormatter()
                f.locale = Locale(identifier: "es_ES")
                f.dateFormat = "EEEE, d 'de' MMMM"
                return f
            }()

            Text(formatter.string(from: viewModel.selectedDate).capitalized)
                .font(.headline)
                .padding(.horizontal)

            if viewModel.recordsForSelectedDate.isEmpty {
                Text("No hay consumiciones este día")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ForEach(viewModel.recordsForSelectedDate) { record in
                    RecordRow(record: record, onDelete: {
                        Task { await viewModel.deleteRecord(record) }
                    })
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let categories: Set<DrinkCategory>

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                )

            // Category dots
            HStack(spacing: 3) {
                let sortedCategories = DrinkCategory.allCases.filter { categories.contains($0) }
                ForEach(sortedCategories) { category in
                    Circle()
                        .fill(category.color)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
        .frame(height: 50)
    }
}

// MARK: - Record Row

struct RecordRow: View {
    let record: DrinkRecord
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(record.category.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.drinkName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(record.size.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(record.formattedTime)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    CalendarTabView()
}
