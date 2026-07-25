//
//  AddClothingItemView.swift
//  TidyUp
//

import SwiftUI

struct AddClothingItemView: View {
    @Environment(\.dismiss) private var dismiss

    let suggestedCode: String
    let onSave: (ClothingItem) -> Void

    @State private var name = ""
    @State private var category: ClothingCategory = .tops
    @State private var brand = ""
    @State private var color = ""
    @State private var notes = ""
    @State private var hasPurchaseDate = false
    @State private var purchaseDate = Date.now
    @State private var replacementIntervalText = "180"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Item Code", value: suggestedCode)
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(ClothingCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Attributes") {
                    TextField("Brand", text: $brand)
                    TextField("Color", text: $color)
                }

                if category.isLinen {
                    Section {
                        TextField("Replace every (days)", text: $replacementIntervalText)
                            .keyboardType(.numberPad)
                    } header: {
                        Text("Replacement Cycle")
                    } footer: {
                        Text("You'll get a reminder once this item passes its replacement cycle — e.g. 180 days for a towel.")
                    }
                }

                Section("Purchase Info") {
                    Toggle("Has purchase date", isOn: $hasPurchaseDate)
                    if hasPurchaseDate {
                        DatePicker("Purchased On", selection: $purchaseDate, displayedComponents: .date)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let item = ClothingItem(
            itemCode: suggestedCode,
            name: name,
            category: category,
            brand: brand,
            color: color,
            notes: notes,
            purchaseDate: hasPurchaseDate ? purchaseDate : nil,
            replacementIntervalDays: category.isLinen ? Int(replacementIntervalText) : nil
        )
        onSave(item)
        dismiss()
    }
}
