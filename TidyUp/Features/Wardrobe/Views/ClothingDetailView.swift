//
//  ClothingDetailView.swift
//  TidyUp
//

import SwiftUI
import PhotosUI

struct ClothingDetailView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: WardrobeViewModel?
    @State private var selectedPhoto: PhotosPickerItem?

    let item: ClothingItem

    var body: some View {
        List {
            Section {
                if !item.photoFilenames.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(item.photoFilenames, id: \.self) { filename in
                                if let image = viewModel?.loadImage(filename: filename) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                }
                            }
                        }
                    }
                }
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Add Photo", systemImage: "photo.badge.plus")
                }
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel?.addPhoto(item, image: image)
                        }
                    }
                }
            }

            Section("Details") {
                LabeledContent("Code", value: item.itemCode)
                LabeledContent("Category", value: item.category.label)
                if !item.brand.isEmpty { LabeledContent("Brand", value: item.brand) }
                if !item.color.isEmpty { LabeledContent("Color", value: item.color) }
                if let date = item.purchaseDate { LabeledContent("Purchased", value: date.formatted(.medium)) }
            }

            Section("Laundry") {
                LabeledContent("Status", value: item.laundryStatus.label)
                if let lastWorn = item.lastWornDate { LabeledContent("Last Worn", value: lastWorn.formatted(.medium)) }
                if let lastWashed = item.lastWashedDate { LabeledContent("Last Washed", value: lastWashed.formatted(.medium)) }
                LabeledContent("Worn Since Wash", value: "\(item.wearCountSinceWash)x")

                if item.laundryStatus == .dirty {
                    Button("Mark as Washed") { viewModel?.markWashed(item) }
                }
            }

            if item.category.isLinen {
                Section("Replacement") {
                    if let days = item.daysUntilReplacement {
                        LabeledContent("Days Until Replace", value: days > 0 ? "\(days) days" : "Overdue")
                    }
                    if item.needsReplacement {
                        Button("Mark as Replaced") { viewModel?.markReplaced(item) }
                            .foregroundStyle(AppTheme.Colors.danger)
                    }
                }
            }

            if !item.notes.isEmpty {
                Section("Notes") { Text(item.notes) }
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = WardrobeViewModel(
                    repository: container.wardrobeRepository,
                    imageStorageService: container.imageStorageService,
                    notificationService: container.notificationService
                )
            }
        }
    }
}
