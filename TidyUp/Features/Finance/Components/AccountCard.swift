//
//  AccountCard.swift
//  TidyUp
//
//  Redesigned as a wallet-style card (à la Apple Card / banking apps) —
//  full-bleed gradient, large balance type, subtle sheen. Used in a
//  horizontal paging carousel on the Money tab.
//

import SwiftUI

struct AccountCard: View {
    let account: Account
    var gradientIndex: Int = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            HStack {
                Image(systemName: account.type.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text(account.type.label.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.type.isCredit ? "Outstanding" : "Balance")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.7))
                Text(CurrencyFormatter.format(account.type.isCredit ? -account.balance : account.balance))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            HStack {
                Text(account.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                if let limit = account.creditLimit {
                    Text("Limit \(CurrencyFormatter.format(limit))")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(width: 260, height: 160, alignment: .leading)
        .background(AppTheme.Colors.walletGradient(for: gradientIndex))
        .overlay(colorScheme == .dark ? Color.black.opacity(0.18) : Color.clear)
        .overlay(
            // Faint diagonal sheen for a bit of card-material realism.
            LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .topLeading, endPoint: .center)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}
