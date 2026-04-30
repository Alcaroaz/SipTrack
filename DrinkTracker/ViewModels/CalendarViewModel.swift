import Foundation
import SwiftUI
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var recordsForSelectedDate: [DrinkRecord] = []
    @Published var monthRecords: [Date: Set<DrinkCategory>] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = FirestoreService.shared
    private let calendar = Calendar.current

    var currentMonthDates: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    @Published var displayedMonth: Date = Date()

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        return formatter.string(from: Date()).capitalized
    }

    var firstWeekdayOfMonth: Int {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let weekday = calendar.component(.weekday, from: startOfMonth)
        // Adjust for Monday start (1=Mon, 7=Sun)
        return (weekday + 5) % 7
    }

    var weekdayHeaders: [String] {
        ["L", "M", "X", "J", "V", "S", "D"]
    }

    func loadMonthData() async {
        isLoading = true
        errorMessage = nil

        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        do {
            let records = try await service.fetchRecords(from: startOfMonth, to: endOfMonth)
            var grouped: [Date: Set<DrinkCategory>] = [:]

            for record in records {
                let day = calendar.startOfDay(for: record.timestamp)
                if grouped[day] == nil {
                    grouped[day] = Set<DrinkCategory>()
                }
                grouped[day]?.insert(record.category)
            }

            monthRecords = grouped
        } catch {
            errorMessage = "Error al cargar datos del mes: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadRecords(for date: Date) async {
        selectedDate = date
        do {
            recordsForSelectedDate = try await service.fetchRecords(for: date)
        } catch {
            errorMessage = "Error al cargar registros: \(error.localizedDescription)"
        }
    }

    func deleteRecord(_ record: DrinkRecord) async {
        do {
            try await service.deleteRecord(record)
            await loadRecords(for: selectedDate)
            await loadMonthData()
        } catch {
            errorMessage = "Error al eliminar registro: \(error.localizedDescription)"
        }
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func categoriesFor(date: Date) -> Set<DrinkCategory> {
        let day = calendar.startOfDay(for: date)
        return monthRecords[day] ?? []
    }

    func previousMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        Task { await loadMonthData() }
    }

    func nextMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        Task { await loadMonthData() }
    }
}
