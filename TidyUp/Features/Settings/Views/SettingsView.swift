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
                    SettingsIconRow(icon: "tag.fill", tint: AppTheme.Colors.accent, title: "Manage Money Categories")
                }
                NavigationLink { TaskTagsView() } label: {
                    SettingsIconRow(icon: "checklist", tint: AppTheme.Colors.success, title: "Task Tags in Use")
                }
                NavigationLink { WardrobeCategoriesView() } label: {
                    SettingsIconRow(icon: "tshirt.fill", tint: AppTheme.Colors.warning, title: "Wardrobe Categories")
                }
                NavigationLink { BackupRestoreView() } label: {
                    SettingsIconRow(icon: "arrow.triangle.2.circlepath", tint: AppTheme.Colors.reimburse, title: "Backup & Restore")
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

/// Read-only reference: distinct tags currently used across your tasks,
/// with how many tasks use each one.
struct TaskTagsView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var tagCounts: [(tag: String, count: Int)] = []

    var body: some View {
        List {
            if tagCounts.isEmpty {
                Text("No tags in use yet — add tags when creating or editing a task.")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            } else {
                ForEach(tagCounts, id: \.tag) { entry in
                    SettingsIconRow(icon: "tag.fill", tint: AppTheme.Colors.success, title: entry.tag, value: "\(entry.count)")
                }
            }
        }
        .navigationTitle("Task Tags")
        .onAppear {
            let tasks = (try? container.taskRepository.fetchAll()) ?? []
            let allTags = tasks.flatMap(\.tags)
            let grouped = Dictionary(grouping: allTags) { $0 }
            tagCounts = grouped.map { (tag: $0.key, count: $0.value.count) }.sorted { $0.count > $1.count }
        }
    }
}

/// Read-only reference for Wardrobe's built-in categories — these are
/// fixed (not user-editable) since every category also drives wash-cycle
/// behavior (e.g. Outerwear/Linens use a duration cycle).
struct WardrobeCategoriesView: View {
    var body: some View {
        List {
            ForEach(ClothingCategory.allCases) { category in
                SettingsIconRow(icon: category.icon, tint: AppTheme.Colors.warning, title: category.label)
            }
        } 
        .navigationTitle("Wardrobe Categories")
        .safeAreaInset(edge: .bottom) {
            Text("These are built-in and drive wash-cycle behavior, so they aren't user-editable.")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .padding()
        }
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
