//
//  TaskFilterBar.swift
//  TidyUp
//

import SwiftUI

struct TaskFilterBar: View {
    @Binding var selected: TaskFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(TaskFilter.allCases) { filter in
                    Button {
                        selected = filter
                    } label: {
                        Text(filter.label)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(selected == filter ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                            .foregroundStyle(selected == filter ? AppTheme.Colors.contrastingText(on: AppTheme.Colors.accent) : AppTheme.Colors.primaryText)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
