//
//  PACard.swift
//  TidyUp
//

import SwiftUI

struct PACard<Content: View>: View {
    var padding: CGFloat = AppTheme.Spacing.lg
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
    }
}

/// Solid-background badge with auto-contrasting text — used for tags,
/// priority labels, and status pills so they never wash out.
struct PATagChip: View {
    let text: String
    var color: Color = AppTheme.Colors.accent

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 4)
            .background(color)
            .foregroundStyle(AppTheme.Colors.contrastingText(on: color))
            .clipShape(Capsule())
    }
}

struct PASectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.accent)
            }
        }
    }
}

struct PAEmptyState: View {
    let systemImage: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(AppTheme.Colors.tertiaryText)
            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            if let message {
                Text(message)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.Colors.accent)
                    .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(AppTheme.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PAPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.Colors.accent)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}

struct PACurrencyText: View {
    let amount: Decimal
    var signed: Bool = false
    var color: Color? = nil

    var body: some View {
        Text(CurrencyFormatter.format(amount, signed: signed))
            .font(AppTheme.Typography.monospacedAmount)
            .foregroundStyle(color ?? (amount < 0 ? AppTheme.Colors.expense : AppTheme.Colors.primaryText))
    }
}
