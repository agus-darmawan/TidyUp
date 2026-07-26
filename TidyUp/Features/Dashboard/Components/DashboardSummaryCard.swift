//
//  DashboardSummaryCard.swift
//  TidyUp
//
//  All four overview cards now share the same neutral surface background
//  — only the icon badge and value are tinted per category — so they
//  read as one consistent set instead of a mismatched mix of solid,
//  pastel, and dark cards.
//

import SwiftUI

enum DashboardCardTint {
    case cream, mint, coral, neutral

    /// The accent color used for this card's icon badge and value text.
    var accent: Color {
        switch self {
        case .cream: AppTheme.Colors.brandYellow
        case .mint: AppTheme.Colors.success
        case .coral: AppTheme.Colors.danger
        case .neutral: AppTheme.Colors.accent
        }
    }
}

struct DashboardSummaryCard: View {
    let icon: String
    let title: String
    let value: String
    var tint: DashboardCardTint = .neutral

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint.accent)
                .frame(width: 28, height: 28)
                .background(tint.accent.opacity(0.12))
                .clipShape(Circle())

            Spacer(minLength: 0)

            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
    }
}
