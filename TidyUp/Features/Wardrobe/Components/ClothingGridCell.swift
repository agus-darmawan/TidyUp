//
//  ClothingGridCell.swift
//  TidyUp
//
//  Compact card for the grid layout — same "tap to add to today's
//  outfit" behavior as the list row, just laid out for a 2-column grid.
//

import SwiftUI

struct ClothingGridCell: View {
    let item: ClothingItem
    let thumbnail: UIImage?
    let isSelected: Bool
    let onToggleSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(AppTheme.Colors.surfaceElevated)
                            .overlay {
                                Image(systemName: item.category.icon)
                                    .font(.system(size: 26))
                                    .foregroundStyle(AppTheme.Colors.secondaryText)
                            }
                    }
                }
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                .clipped()

                Button(action: onToggleSelect) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? AppTheme.Colors.accent : .white, isSelected ? .clear : .black.opacity(0.35))
                        .background(Circle().fill(isSelected ? Color.white : .clear))
                        .padding(6)
                }
                .buttonStyle(.plain)
            }

            Text(item.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineLimit(1)
            Text(item.itemCode)
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.Colors.secondaryText)

            statusBadge
        }
        .padding(AppTheme.Spacing.sm)
        .background(isSelected ? AppTheme.Colors.accent.opacity(0.08) : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .stroke(isSelected ? AppTheme.Colors.accent : .clear, lineWidth: 1.5)
        )
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
            .font(.system(size: 9, weight: .semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color)
            .foregroundStyle(AppTheme.Colors.contrastingText(on: color))
            .clipShape(Capsule())
    }
}
