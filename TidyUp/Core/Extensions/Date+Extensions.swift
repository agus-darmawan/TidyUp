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
