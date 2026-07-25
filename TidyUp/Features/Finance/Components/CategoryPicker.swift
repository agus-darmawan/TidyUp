//
//  CategoryPicker.swift
//  TidyUp
//

import SwiftUI

struct CategoryPicker: View {
    let categories: [TransactionCategory]
    @Binding var selected: TransactionCategory?
    var onAddNew: (String) -> Void

    @State private var showingAddNew = false
    @State private var newCategoryName = ""

    var body: some View {
        Section("Category") {
            Picker("Category", selection: $selected) {
                Text("None").tag(TransactionCategory?.none)
                ForEach(categories) { category in
                    Label(category.name, systemImage: category.icon).tag(TransactionCategory?.some(category))
                }
            }

            Button {
                showingAddNew = true
            } label: {
                Label("Add New Category", systemImage: "plus.circle")
            }
            .alert("New Category", isPresented: $showingAddNew) {
                TextField("Category name", text: $newCategoryName)
                Button("Add") { onAddNew(newCategoryName); newCategoryName = "" }
                Button("Cancel", role: .cancel) { newCategoryName = "" }
            }
        }
    }
}
