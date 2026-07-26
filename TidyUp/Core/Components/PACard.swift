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
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

/// Soft-tinted, bordered chip — used for tags, categories, and status
/// labels. Deliberately subtle (not a loud solid-fill pill) for a more
/// refined, modern look.
struct PATagChip: View {
    let text: String
    var color: Color = AppTheme.Colors.accent

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .overlay(
                Capsule().stroke(color.opacity(0.25), lineWidth: 1)
            )
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

/// Friendlier empty state: icon sits inside a soft tinted circle instead
/// of floating bare, and gently scales/fades in on appear.
struct PAEmptyState: View {
    let systemImage: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var appeared = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 84, height: 84)
                .background(AppTheme.Colors.accent.opacity(0.12))
                .clipShape(Circle())

            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.primaryText)
            if let message {
                Text(message)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
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
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(AppTheme.Motion.bouncy) { appeared = true }
        }
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
        .buttonStyle(PressableButtonStyle())
        .tint(AppTheme.Colors.accent)
        .background(AppTheme.Colors.accent)
        .foregroundStyle(AppTheme.Colors.contrastingText(on: AppTheme.Colors.accent))
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
            .contentTransition(.numericText())
    }
}

/// Subtle scale-down-on-press feedback for tappable cards and buttons —
/// the "modern app" tactile touch, used across Tasks/Wardrobe/Finance rows.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(AppTheme.Motion.quick, value: configuration.isPressed)
    }
}
