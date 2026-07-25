//
//  ClothingRowView.swift
//  TidyUp
//
//  One-tap "wear this" straight from the list — no need to search and
//  open a detail screen first, per the user's request.
//

import SwiftUI

struct ClothingRowView: View {
    let item: ClothingItem
    let thumbnail: UIImage?
    let onWear: () -> Void
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

            // One tap = "I'm wearing this today".
            Button(action: onWear) {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.brandMint)
                    .foregroundStyle(AppTheme.Colors.contrastingText(on: AppTheme.Colors.brandMint))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .swipeActions(edge: .trailing) {
            if item.laundryStatus == .dirty {
                Button("Washed") { onWashed() }.tint(AppTheme.Colors.brandMint)
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
        let color: Color = item.needsReplacement ? AppTheme.Colors.warning
            : (item.laundryStatus == .dirty ? AppTheme.Colors.danger : AppTheme.Colors.success)
        let text = item.needsReplacement ? "Replace soon" : item.laundryStatus.label

        return Text(text)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color)
            .foregroundStyle(AppTheme.Colors.contrastingText(on: color))
            .clipShape(Capsule())
    }
}
