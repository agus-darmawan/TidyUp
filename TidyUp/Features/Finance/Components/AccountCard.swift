//
//  AccountCard.swift
//  TidyUp
//

import SwiftUI

struct AccountCard: View {
    let account: Account

    var body: some View {
        PACard {
            HStack {
                Image(systemName: account.type.icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.Colors.accent)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.Colors.accent.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name).font(.system(size: 14, weight: .medium))
                    Text(account.type.label).font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    PACurrencyText(amount: account.type.isCredit ? -account.balance : account.balance)
                    if let limit = account.creditLimit {
                        Text("Limit \(CurrencyFormatter.format(limit))")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
            }
        }
    }
}
