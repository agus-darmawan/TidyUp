//
//  InstallmentRowView.swift
//  TidyUp
//

import SwiftUI

struct InstallmentRowView: View {
    let installment: Installment

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(installment.itemName).font(.system(size: 14, weight: .medium))
                    if let account = installment.account {
                        Text(account.name).font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyFormatter.format(installment.monthlyAmount))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("/ month").font(.system(size: 10)).foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }

            ProgressView(value: Double(installment.paidTerms), total: Double(installment.totalTerms))
                .tint(AppTheme.Colors.accent)

            HStack {
                Text("\(installment.paidTerms) of \(installment.totalTerms) paid")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                Spacer()
                if let next = installment.nextDueDate {
                    Text("Next: \(next.formatted(.dayMonth))")
                        .font(.system(size: 11))
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
