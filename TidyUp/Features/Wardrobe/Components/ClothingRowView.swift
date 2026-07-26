//
//  ClothingRowView.swift
//  TidyUp
//
//  Tap the circle to add this item to "today's outfit" cart — confirm
//  once from the bottom bar to log the wear across the whole selection.
//  Status badge matches Task's soft-tint tag chip style for consistency.
//

import SwiftUI

struct ClothingRowView: View {
    let item: ClothingItem
    let thumbnail: UIImage?
    let isSelected: Bool
    let onToggleSelect: () -> Void
    let onStartWash: () -> Void
    let onWashed: () -> Void
    let onDelete: () -> Void

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
                PATagChip(text: statusText, color: statusColor)
            }

            Spacer()

            Button {
                withAnimation(AppTheme.Motion.bouncy) { onToggleSelect() }
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22))
                    .symbolEffect(.bounce, value: isSelected)
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
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            if item.laundryStatus == .dirty {
                Button("Start Wash") { onStartWash() }.tint(AppTheme.Colors.accent)
            }
            if item.laundryStatus == .washing {
                Button("Done") { onWashed() }.tint(AppTheme.Colors.success)
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
