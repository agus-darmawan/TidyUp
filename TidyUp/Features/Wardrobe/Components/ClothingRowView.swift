//
//  ClothingRowView.swift
//  TidyUp
//
//  Tap the circle to add this item to "today's outfit" cart — confirm
//  once from the bottom bar to log the wear across the whole selection.
//

import SwiftUI

struct ClothingRowView: View {
    let item: ClothingItem
    let thumbnail: UIImage?
    let isSelected: Bool
    let onToggleSelect: () -> Void
    let onWashed: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            thumbnailView

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text(item.itemCode)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                statusBadge
            }

            Spacer()

            Button(action: onToggleSelect) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.brandGray)
            }
            .buttonStyle(.plain)
        }
        .padding(AppTheme.Spacing.sm)
        .background(isSelected ? AppTheme.Colors.accent.opacity(0.08) : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(isSelected ? AppTheme.Colors.accent : .clear, lineWidth: 1.5)
        )
        .swipeActions(edge: .trailing) {
            if item.laundryStatus == .dirty {
                Button("Washed") { onWashed() }.tint(AppTheme.Colors.success)
            }
        }
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
        } else {
            Image(systemName: item.category.icon)
                .font(.system(size: 18))
                .frame(width: 44, height: 44)
                .background(AppTheme.Colors.surfaceElevated)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
        }
    }

    private var statusBadge: some View {
        let color: Color
        let text: String
        if let remaining = item.daysRemainingInCycle {
            color = remaining <= 1 ? AppTheme.Colors.warning : AppTheme.Colors.success
            text = remaining <= 0 ? "Wash now" : "\(remaining)d left"
        } else {
            color = item.laundryStatus == .dirty ? AppTheme.Colors.danger : AppTheme.Colors.success
            text = item.laundryStatus.label
        }

        return Text(text)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color)
            .foregroundStyle(AppTheme.Colors.contrastingText(on: color))
            .clipShape(Capsule())
    }
}
