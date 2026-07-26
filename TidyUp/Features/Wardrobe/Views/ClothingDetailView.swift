//
//  ClothingDetailView.swift
//  TidyUp
//
//  One photo per item, tap to replace it. Includes a Delete Item action.
//

import SwiftUI
import PhotosUI

struct ClothingDetailView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WardrobeViewModel?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingDeleteConfirm = false

    let item: ClothingItem

    var body: some View {
        List {
            Section {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        if let filename = item.photoFilename, let image = viewModel?.loadImage(filename: filename) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .fill(AppTheme.Colors.surfaceElevated)
                                .frame(height: 160)
                                .overlay {
                                    VStack(spacing: 6) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 28))
                                        Text("Add Photo").font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundStyle(AppTheme.Colors.secondaryText)
                                }
                        }
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white, AppTheme.Colors.accent)
                            .padding(8)
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel?.setPhoto(item, image: image)
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

                if item.laundryStatus == .washing {
                    LabeledContent("Estimated Done", value: item.washTimeRemainingLabel)
                }

                if item.laundryStatus == .dirty {
                    Button("Start Wash") { viewModel?.startWash(item) }
                }
                if item.laundryStatus == .washing {
                    Button("Mark as Done") { viewModel?.markWashed(item) }
                }
            }

            if item.usageDurationDays != nil {
                Section("Wear Cycle") {
                    LabeledContent("Wash Every", value: "\(item.usageDurationDays ?? 0) days")
                    if let remaining = item.daysRemainingInCycle {
                        LabeledContent("Days Left", value: remaining > 0 ? "\(remaining) days" : "Wash now")
                    }
                }
            }

            if !item.notes.isEmpty {
                Section("Notes") { Text(item.notes) }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("Delete Item", systemImage: "trash")
                }
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete \(item.name)?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                viewModel?.delete(item)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
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
