//
//  SettingsView.swift
//  TidyUp
//
//  Restyled with iOS-Settings-style colored-square icon rows instead of
//  plain system Labels.
//

import SwiftUI

/// A single Settings row: icon in a colored rounded square, title, and
/// an optional trailing value/chevron — mirrors the iOS Settings app.
struct SettingsIconRow: View {
    let icon: String
    let tint: Color
    let title: String
    var value: String? = nil

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(tint)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(title)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.primaryText)
            Spacer()
            if let value {
                Text(value)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section("Data") {
                NavigationLink { CategoryManagementView() } label: {
                    SettingsIconRow(icon: "tag.fill", tint: AppTheme.Colors.accent, title: "Manage Categories")
                }
            }

            Section("About") {
                SettingsIconRow(icon: "number", tint: AppTheme.Colors.brandGray, title: "Version", value: "1.0.0")
                Text("TidyUp is fully offline — your data never leaves your device.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .navigationTitle("Settings")
    }
}

struct CategoryManagementView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var categories: [TransactionCategory] = []
    @State private var newCategoryName = ""

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("New category", text: $newCategoryName)
                    Button("Add") {
                        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        withAnimation(AppTheme.Motion.snappy) {
                            container.transactionRepository.addCategory(name: newCategoryName)
                            newCategoryName = ""
                            load()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            Section {
                ForEach(categories) { category in
                    SettingsIconRow(icon: category.icon, tint: AppTheme.Colors.accent, title: category.name)
                }
            }
        }
        .navigationTitle("Categories")
        .onAppear { load() }
    }

    private func load() {
        categories = (try? container.transactionRepository.fetchCategories()) ?? []
    }
}
