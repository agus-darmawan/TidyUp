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

                Button {
                    withAnimation(AppTheme.Motion.bouncy) { onToggleSelect() }
                } label: {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 20))
                        .symbolEffect(.bounce, value: isSelected)
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

            PATagChip(text: statusText, color: statusColor)
        }
        .padding(AppTheme.Spacing.sm)
        .background(isSelected ? AppTheme.Colors.accent.opacity(0.08) : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .stroke(isSelected ? AppTheme.Colors.accent : .clear, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var statusColor: Color {
        if let remaining = item.daysRemainingInCycle {
            return remaining <= 1 ? AppTheme.Colors.warning : AppTheme.Colors.success
        }
        switch item.laundryStatus {
        case .clean: return AppTheme.Colors.success
        case .dirty: return AppTheme.Colors.danger
        case .washing: return AppTheme.Colors.accent
        }
    }

    private var statusText: String {
        if let remaining = item.daysRemainingInCycle {
            return remaining <= 0 ? "Wash now" : "\(remaining)d left"
        }
        if item.laundryStatus == .washing {
            return item.washTimeRemainingLabel
        }
        return item.laundryStatus.label
    }
}
