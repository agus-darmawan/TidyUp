//
//  CategoryFilterBar.swift
//  TidyUp
//

import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selected: ClothingCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                chip(title: "All", isSelected: selected == nil) { selected = nil }
                ForEach(ClothingCategory.allCases) { category in
                    chip(title: category.label, isSelected: selected == category) { selected = category }
                }
            }
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surface)
                .foregroundStyle(isSelected ? AppTheme.Colors.contrastingText(on: AppTheme.Colors.accent) : AppTheme.Colors.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
