//
//  SettingsView.swift
//  TidyUp
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Data") {
                NavigationLink { CategoryManagementView() } label: {
                    Label("Manage Categories", systemImage: "tag.fill")
                }
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                Text("TidyUp is fully offline — your data never leaves your device.")
                    .font(.system(size: 12))
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
                        container.transactionRepository.addCategory(name: newCategoryName)
                        newCategoryName = ""
                        load()
                    }
                }
            }
            Section {
                ForEach(categories) { category in
                    Label(category.name, systemImage: category.icon)
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
