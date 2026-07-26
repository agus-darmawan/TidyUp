//
//  WeekStripView.swift
//  TidyUp
//
//  A small horizontal "this week" strip for the Home header — just a
//  visual touch, not a real calendar picker. Today is highlighted;
//  tapping a day is a no-op for now (full Calendar lives under More).
//

import SwiftUI

struct WeekStripView: View {
    @State private var selected: Date = .now

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date.now
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7   // Monday-first week
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [today] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDates, id: \.self) { date in
                dayCell(for: date)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isToday = date.isSameDay(as: .now)
        let isSelected = date.isSameDay(as: selected)
        let dayNumber = Calendar.current.component(.day, from: date)
        let weekdaySymbol = date.formatted(.weekdayNarrow)

        return VStack(spacing: 4) {
            Text(weekdaySymbol)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))
            Text("\(dayNumber)")
                .font(.system(size: 13, weight: isToday ? .bold : .medium))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(isSelected ? Color.white.opacity(0.9) : (isToday ? .white.opacity(0.25) : .clear))
                )
                .foregroundStyle(isSelected ? AppTheme.Colors.brandNavy : .white)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { selected = date }
    }
}
