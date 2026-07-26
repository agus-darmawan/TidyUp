//
//  AddClothingItemView.swift
//  TidyUp
//

import SwiftUI
import PhotosUI

struct AddClothingItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container

    let suggestedCode: String
    let onSave: (ClothingItem) -> Void

    @State private var name = ""
    @State private var category: ClothingCategory = .casual
    @State private var brand = ""
    @State private var color = ""
    @State private var notes = ""
    @State private var hasPurchaseDate = false
    @State private var purchaseDate = Date.now
    @State private var usageDurationText = "7"
    @State private var photo: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        HStack {
                            if let photo {
                                Image(uiImage: photo)
                                    .resizable().scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .frame(width: 44, height: 44)
                                    .background(AppTheme.Colors.surfaceElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                            }
                            Text(photo == nil ? "Add Photo" : "Change Photo")
                        }
                    }
                    .onChange(of: photoPickerItem) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photo = UIImage(data: data)
                            }
                        }
                    }

                    LabeledContent("Item Code", value: suggestedCode)
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(ClothingCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .onChange(of: category) { _, newValue in
                        if newValue.usesDurationCycle {
                            usageDurationText = "\(newValue.defaultUsageDurationDays)"
                        }
                    }
                }

                Section("Attributes") {
                    TextField("Brand", text: $brand)
                    TextField("Color", text: $color)
                }

                if category.usesDurationCycle {
                    Section {
                        TextField("Wash every (days)", text: $usageDurationText)
                            .keyboardType(.numberPad)
                    } header: {
                        Text("Wear Cycle")
                    } footer: {
                        Text("This item won't be marked dirty after a single wear — it stays in use for this many days before needing a wash.")
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
            usageDurationDays: category.usesDurationCycle ? Int(usageDurationText) : nil
        )
        if let photo {
            item.photoFilename = try? container.imageStorageService.saveImage(photo)
        }
        onSave(item)
        dismiss()
    }
}
