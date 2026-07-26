//
//  CalendarWeekStrip.swift
//  TidyUp
//
//  A navigable week strip (prev/next week) bound to the Calendar's
//  selected date — distinct from the read-only one on the Dashboard.
//

import SwiftUI

struct CalendarWeekStrip: View {
    @Binding var selected: Date
    let eventDates: Set<Date>

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selected)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: selected) else { return [selected] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                Button { shiftWeek(by: -7) } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(selected.formatted(.monthYear))
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Button { shiftWeek(by: 7) } label: { Image(systemName: "chevron.right") }
            }
            .foregroundStyle(AppTheme.Colors.primaryText)

            HStack(spacing: 6) {
                ForEach(weekDates, id: \.self) { date in
                    dayCell(for: date)
                }
            }
        }
    }

    private func shiftWeek(by days: Int) {
        selected = selected.adding(days: days)
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = date.isSameDay(as: selected)
        let hasEvents = eventDates.contains(where: { $0.isSameDay(as: date) })

        return VStack(spacing: 4) {
            Text(date.formatted(.weekdayNarrow))
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(AppTheme.Colors.secondaryText)
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : AppTheme.Colors.primaryText)
                .frame(width: 32, height: 32)
                .background(Circle().fill(isSelected ? AppTheme.Colors.accent : .clear))
            Circle()
                .fill(hasEvents ? AppTheme.Colors.accent : .clear)
                .frame(width: 4, height: 4)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { selected = date }
    }
}
