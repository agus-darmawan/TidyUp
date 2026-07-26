//
//  TaskProgressHeader.swift
//  TidyUp
//
//  Circular progress ring summarizing today's completion, matching the
//  hero-stat treatment used on Home and Money.
//

import SwiftUI

struct TaskProgressHeader: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.accent.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppTheme.Colors.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(AppTheme.Motion.snappy, value: progress)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .contentTransition(.numericText())
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Progress")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                Text(total == 0 ? "Nothing due today" : "\(completed) of \(total) tasks done")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .contentTransition(.numericText())
            }
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}
