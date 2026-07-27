//
//  CalendarMonthGridCell.swift
//  TidyUp
//
//  A single day cell in the proper month-grid calendar (this is what
//  makes Calendar feel like an actual calendar, not the Home week strip).
//

import SwiftUI

struct CalendarMonthGridCell: View {
    let date: Date?
    let isSelected: Bool
    let hasEvents: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 3) {
            if let date {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: date.isToday ? .bold : .regular))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(isSelected ? AppTheme.Colors.accent : (date.isToday ? AppTheme.Colors.accent.opacity(0.15) : .clear))
                    )
                    .foregroundStyle(isSelected ? .white : AppTheme.Colors.primaryText)

                Circle()
                    .fill(hasEvents ? AppTheme.Colors.accent : .clear)
                    .frame(width: 4, height: 4)
            } else {
                Color.clear.frame(width: 32, height: 32)
                Color.clear.frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 3)
        .contentShape(Rectangle())
        .onTapGesture { if date != nil { onTap() } }
    }
}
