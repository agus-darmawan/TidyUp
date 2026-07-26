//
//  TaskRowView.swift
//  TidyUp
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Button {
                withAnimation(AppTheme.Motion.bouncy) { onToggle() }
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(task.isDone ? AppTheme.Colors.brandMint : AppTheme.Colors.brandGray)
                    .symbolEffect(.bounce, value: task.isDone)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(task.isDone ? AppTheme.Colors.secondaryText : AppTheme.Colors.primaryText)
                    .strikethrough(task.isDone)

                if let progress = task.subtaskProgress {
                    ProgressView(value: progress)
                        .tint(AppTheme.Colors.brandMint)
                        .frame(maxWidth: 120)
                }

                HStack(spacing: AppTheme.Spacing.xs) {
                    if let due = task.dueDate {
                        Label(due.formatted(.dayMonth), systemImage: task.hasReminder ? "bell.fill" : "calendar")
                            .font(.system(size: 11))
                            .foregroundStyle(task.isOverdue ? AppTheme.Colors.danger : AppTheme.Colors.secondaryText)
                    }
                    if task.recurrence != .none {
                        Image(systemName: "repeat")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                    ForEach(task.tags.prefix(2), id: \.self) { tag in
                        PATagChip(text: tag)
                    }
                }
            }

            Spacer()

            if !task.isDone {
                Text(task.priority.label)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.Colors.forPriority(task.priority))
                    .foregroundStyle(AppTheme.Colors.contrastingText(on: AppTheme.Colors.forPriority(task.priority)))
                    .clipShape(Capsule())
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        .animation(AppTheme.Motion.quick, value: task.isDone)
    }
}
