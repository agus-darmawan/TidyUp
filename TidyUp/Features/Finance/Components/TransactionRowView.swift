//
//  TransactionRowView.swift
//  TidyUp
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    private var amountColor: Color {
        switch transaction.type {
        case .income, .debtBorrowed: AppTheme.Colors.income
        case .expense, .debtLent: AppTheme.Colors.expense
        case .reimbursement: AppTheme.Colors.reimburse
        case .transfer: AppTheme.Colors.secondaryText
        }
    }

    private var signedAmount: Decimal { transaction.type.balanceSign * transaction.amount }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: transaction.category?.icon ?? "circle.fill")
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 28, height: 28)
                .background(AppTheme.Colors.accent.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.note.isEmpty ? transaction.type.label : transaction.note)
                    .font(.system(size: 14))
                HStack(spacing: 6) {
                    Text(transaction.date.formatted(.dayMonth))
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                    if transaction.isReimbursable {
                        PATagChip(text: transaction.reimburseStatus.label, color: AppTheme.Colors.reimburse)
                    }
                    if transaction.isRecurring {
                        Image(systemName: "repeat").font(.system(size: 10)).foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
            }
            Spacer()
            PACurrencyText(amount: signedAmount, signed: true, color: amountColor)
        }
        .padding(.vertical, 4)
    }
}
