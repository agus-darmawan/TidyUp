//
//  DashboardSummaryCard.swift
//  TidyUp
//

import SwiftUI

enum DashboardCardTint {
    case cream, mint, coral, neutral

    var background: Color {
        switch self {
        case .cream: AppTheme.Colors.brandYellow.opacity(0.35)
        case .mint: AppTheme.Colors.brandMint
        case .coral: AppTheme.Colors.brandCoral
        case .neutral: AppTheme.Colors.surface
        }
    }

    var foreground: Color {
        switch self {
        case .cream: AppTheme.Colors.brandNavy
        case .mint, .coral: AppTheme.Colors.contrastingText(on: background)
        case .neutral: AppTheme.Colors.primaryText
        }
    }
}

struct DashboardSummaryCard: View {
    let icon: String
    let title: String
    let value: String
    var tint: DashboardCardTint = .neutral

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint.foreground.opacity(0.75))

            Spacer(minLength: 0)

            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(tint.foreground.opacity(0.7))
                .lineLimit(1)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(tint.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .background(tint.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
    }
}
