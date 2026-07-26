//
//  Date+Extensions.swift
//  TidyUp
//

import Foundation

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var endOfDay: Date { Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) ?? self }
    var isToday: Bool { Calendar.current.isDateInToday(self) }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func adding(days: Int) -> Date { Calendar.current.date(byAdding: .day, value: days, to: self) ?? self }
    func adding(months: Int) -> Date { Calendar.current.date(byAdding: .month, value: months, to: self) ?? self }
    func adding(years: Int) -> Date { Calendar.current.date(byAdding: .year, value: years, to: self) ?? self }

    func daysSince(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: other, to: self).day ?? 0
    }

    var monthInterval: DateInterval {
        Calendar.current.dateInterval(of: .month, for: self) ?? DateInterval(start: self, end: self)
    }

    /// Builds a Monday-first 7-column grid of dates for the given month,
    /// padded with `nil` for the leading/trailing blank cells.
    static func daysGrid(for monthAnchor: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: monthAnchor) else { return [] }
        let firstOfMonth = interval.start
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (weekday + 5) % 7   // Monday-first week
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthAnchor)?.count ?? 30

        var grid: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) {
                grid.append(date)
            }
        }
        while grid.count % 7 != 0 { grid.append(nil) }
        return grid
    }

    func formatted(_ style: DateFormatStyle) -> String {
        let formatter = DateFormatter()
        switch style {
        case .short: formatter.dateStyle = .short
        case .medium: formatter.dateStyle = .medium
        case .monthYear: formatter.dateFormat = "MMMM yyyy"
        case .dayMonth: formatter.dateFormat = "d MMM"
        case .time: formatter.timeStyle = .short
        case .weekdayNarrow: formatter.dateFormat = "EEEEE"
        }
        return formatter.string(from: self)
    }

    enum DateFormatStyle { case short, medium, monthYear, dayMonth, time, weekdayNarrow }
}
