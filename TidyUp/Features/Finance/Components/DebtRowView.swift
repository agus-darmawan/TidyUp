//
//  DebtRowView.swift
//  TidyUp
//

import SwiftUI

struct DebtRowView: View {
    let debt: Debt

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: debt.direction == .iOwe ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(debt.direction == .iOwe ? AppTheme.Colors.danger : AppTheme.Colors.success)

            VStack(alignment: .leading, spacing: 2) {
                Text(debt.counterpartyName)
                    .font(.system(size: 14, weight: .medium))
                if !debt.note.isEmpty {
                    Text(debt.note)
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .lineLimit(1)
                }
                if let due = debt.dueDate {
                    Text("Due \(due.formatted(.dayMonth))")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(debt.remainingAmount))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(debt.direction == .iOwe ? AppTheme.Colors.danger : AppTheme.Colors.success)
                if debt.remainingAmount != debt.originalAmount {
                    Text("of \(CurrencyFormatter.format(debt.originalAmount))")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
