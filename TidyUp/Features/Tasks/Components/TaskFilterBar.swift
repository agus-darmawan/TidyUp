//
//  TaskFilterBar.swift
//  TidyUp
//
//  Fills the full width in one row instead of horizontal-scrolling
//  chips — reads as a single segmented control at a glance.
//

import SwiftUI

struct TaskFilterBar: View {
    @Binding var selected: TaskFilter

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TaskFilter.allCases) { filter in
                Button {
                    withAnimation(AppTheme.Motion.quick) { selected = filter }
                } label: {
                    Text(filter.label)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selected == filter ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                        .foregroundStyle(selected == filter ? AppTheme.Colors.contrastingText(on: AppTheme.Colors.accent) : AppTheme.Colors.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
