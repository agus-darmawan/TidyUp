//
//  WardrobeView.swift
//  TidyUp
//
//  Grid view by default (toggle to list anytime). Main feature is
//  logging wear time via the outfit cart — tap items in, confirm once.
//

import SwiftUI

private enum WardrobeLayout {
    case grid, list
}

struct WardrobeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: WardrobeViewModel?
    @State private var cart = OutfitCartViewModel()
    @State private var showingAdd = false
    @State private var layout: WardrobeLayout = .grid

    private let gridColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        layout = layout == .grid ? .list : .grid
                    } label: {
                        Image(systemName: layout == .grid ? "list.bullet" : "square.grid.2x2")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                if let viewModel {
                    AddClothingItemView(suggestedCode: viewModel.nextItemCode()) { newItem in
                        viewModel.addItem(newItem)
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = WardrobeViewModel(
                        repository: container.wardrobeRepository,
                        imageStorageService: container.imageStorageService,
                        notificationService: container.notificationService
                    )
                }
                viewModel?.load()
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
        }
    }

    @ViewBuilder
    private func content(_ viewModel: WardrobeViewModel) -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: AppTheme.Spacing.sm) {
            CategoryFilterBar(selected: $viewModel.selectedCategory)
                .padding(.horizontal)

            if !viewModel.itemsNeedingWash.isEmpty {
                washSoonBanner(viewModel.itemsNeedingWash.count)
                    .padding(.horizontal)
            }

            if viewModel.filteredItems.isEmpty {
                PAEmptyState(systemImage: "tshirt", title: "No clothing items", message: "Add items to start tracking your wardrobe.")
            } else {
                ScrollView {
                    Group {
                        switch layout {
                        case .grid:
                            LazyVGrid(columns: gridColumns, spacing: AppTheme.Spacing.md) {
                                ForEach(viewModel.filteredItems) { item in
                                    NavigationLink {
                                        ClothingDetailView(item: item)
                                    } label: {
                                        ClothingGridCell(
                                            item: item,
                                            thumbnail: item.photoFilename.flatMap { viewModel.loadImage(filename: $0) },
                                            isSelected: cart.isSelected(item),
                                            onToggleSelect: { cart.toggle(item) }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        case .list:
                            LazyVStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(viewModel.filteredItems) { item in
                                    NavigationLink {
                                        ClothingDetailView(item: item)
                                    } label: {
                                        ClothingRowView(
                                            item: item,
                                            thumbnail: item.photoFilename.flatMap { viewModel.loadImage(filename: $0) },
                                            isSelected: cart.isSelected(item),
                                            onToggleSelect: { cart.toggle(item) },
                                            onWashed: { viewModel.markWashed(item) },
                                            onDelete: { viewModel.delete(item) }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, cart.isEmpty ? AppTheme.Spacing.xxl : 80)
                }
            }
        }
        .padding(.top, AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
            if !cart.isEmpty {
                confirmBar(viewModel)
            }
        }
    }

    private func confirmBar(_ viewModel: WardrobeViewModel) -> some View {
        Button {
            viewModel.confirmOutfit(cart.selectedItemIDs)
            cart.clear()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Confirm Wear (\(cart.count))")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.Colors.accent)
        .padding(.horizontal)
        .padding(.bottom, AppTheme.Spacing.sm)
    }

    private func washSoonBanner(_ count: Int) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("\(count) item(s) need washing soon").font(.system(size: 13, weight: .medium))
            Spacer()
        }
        .foregroundStyle(AppTheme.Colors.contrastingText(on: AppTheme.Colors.warning))
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.warning)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}

#Preview {
    WardrobeView().environment(DependencyContainer.preview)
}
