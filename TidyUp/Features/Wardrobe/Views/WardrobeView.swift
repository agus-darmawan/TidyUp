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

private enum WardrobeGrouping: String, CaseIterable, Identifiable {
    case none, category, status
    var id: String { rawValue }
    var label: String {
        switch self {
        case .none: "None"
        case .category: "Category"
        case .status: "Status"
        }
    }
}

struct WardrobeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: WardrobeViewModel?
    @State private var cart = OutfitCartViewModel()
    @State private var showingAdd = false
    @State private var layout: WardrobeLayout = .grid
    @State private var grouping: WardrobeGrouping = .none

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
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Group By", selection: $grouping) {
                            ForEach(WardrobeGrouping.allCases) { option in
                                Text(option.label).tag(option)
                            }
                        }
                    } label: {
                        Label("Group", systemImage: "rectangle.grid.1x2")
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
            statStrip(viewModel)
                .padding(.horizontal)

            HStack(spacing: AppTheme.Spacing.sm) {
                if grouping != .category {
                    CategoryFilterBar(selected: $viewModel.selectedCategory)
                }
                Spacer(minLength: 0)
                Button {
                    withAnimation(AppTheme.Motion.snappy) { layout = layout == .grid ? .list : .grid }
                } label: {
                    Image(systemName: layout == .grid ? "list.bullet" : "square.grid.2x2")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.Colors.surface)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            if !viewModel.itemsInLaundry.isEmpty {
                laundrySection(viewModel)
                    .padding(.horizontal)
            }

            if !viewModel.itemsNeedingWash.isEmpty {
                washSoonBanner(viewModel.itemsNeedingWash.count)
                    .padding(.horizontal)
            }

            if (grouping == .none ? viewModel.filteredItems : viewModel.items).isEmpty {
                PAEmptyState(systemImage: "tshirt", title: "No clothing items", message: "Add items to start tracking your wardrobe.")
            } else {
                ScrollView {
                    switch grouping {
                    case .none:
                        itemsView(viewModel.filteredItems, viewModel)
                            .padding(.horizontal)
                    case .category:
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                            ForEach(viewModel.groupedByCategory, id: \.category) { group in
                                groupSection(title: group.category.label, items: group.items, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    case .status:
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                            ForEach(viewModel.groupedByStatus, id: \.status) { group in
                                groupSection(title: group.status.label, items: group.items, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, cart.isEmpty ? AppTheme.Spacing.xxl : 80)
            }
        }
        .padding(.top, AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
            if !cart.isEmpty {
                confirmBar(viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func groupSection(title: String, items: [ClothingItem], viewModel: WardrobeViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("\(title.uppercased()) (\(items.count))")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            itemsView(items, viewModel)
        }
        .padding(.bottom, AppTheme.Spacing.sm)
    }

    @ViewBuilder
    private func itemsView(_ items: [ClothingItem], _ viewModel: WardrobeViewModel) -> some View {
        switch layout {
        case .grid:
            LazyVGrid(columns: gridColumns, spacing: AppTheme.Spacing.md) {
                ForEach(items) { item in
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
                    .buttonStyle(PressableButtonStyle())
                }
            }
        case .list:
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(items) { item in
                    NavigationLink {
                        ClothingDetailView(item: item)
                    } label: {
                        ClothingRowView(
                            item: item,
                            thumbnail: item.photoFilename.flatMap { viewModel.loadImage(filename: $0) },
                            isSelected: cart.isSelected(item),
                            onToggleSelect: { cart.toggle(item) },
                            onStartWash: { viewModel.startWash(item) },
                            onWashed: { viewModel.markWashed(item) },
                            onDelete: { viewModel.delete(item) }
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
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

    private func statStrip(_ viewModel: WardrobeViewModel) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            wardrobeStat(title: "Total", value: "\(viewModel.items.count)", color: AppTheme.Colors.primaryText)
            wardrobeStat(title: "Clean", value: "\(viewModel.items.filter { $0.laundryStatus == .clean }.count)", color: AppTheme.Colors.success)
            wardrobeStat(title: "Washing", value: "\(viewModel.washingItemsCount)", color: AppTheme.Colors.accent)
            wardrobeStat(title: "Dirty", value: "\(viewModel.items.filter { $0.laundryStatus == .dirty }.count)", color: AppTheme.Colors.danger)
        }
    }

    private func wardrobeStat(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }

    private func laundrySection(_ viewModel: WardrobeViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("IN LAUNDRY")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            VStack(spacing: AppTheme.Spacing.xs) {
                ForEach(viewModel.itemsInLaundry) { item in
                    HStack {
                        Image(systemName: "washer.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.Colors.accent)
                        Text(item.name)
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                        Text(item.washTimeRemainingLabel)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.accent)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                }
            }
        }
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
