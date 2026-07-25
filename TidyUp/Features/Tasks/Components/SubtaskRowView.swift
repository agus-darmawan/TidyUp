//
//  SubtaskRowView.swift
//  TidyUp
//

import SwiftUI

struct SubtaskRowView: View {
    let subtask: SubTask
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: subtask.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(subtask.isDone ? AppTheme.Colors.brandMint : AppTheme.Colors.brandGray)
            }
            .buttonStyle(.plain)

            Text(subtask.title)
                .strikethrough(subtask.isDone)
                .foregroundStyle(subtask.isDone ? AppTheme.Colors.secondaryText : AppTheme.Colors.primaryText)

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(AppTheme.Colors.danger)
            }
            .buttonStyle(.plain)
        }
    }
}
