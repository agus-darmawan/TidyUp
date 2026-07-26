//
//  WardrobeView.swift
//  TidyUp
//
//  Grid view by default (toggle to list anytime). Main feature is
//  logging wear time via the outfit cart — tap items in, confirm once.
//  Gradient hero header matches Home/Money's visual language.
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
            .toolbar(.hidden, for: .navigationBar)
            .ignoresSafeArea(edges: .top)
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
            heroHeader(viewModel)

            statStrip(viewModel)
                .padding(.horizontal)

            HStack(spacing: AppTheme.Spacing.sm) {
                CategoryFilterBar(selected: $viewModel.selectedCategory)
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
                                    .buttonStyle(PressableButtonStyle())
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
                    .padding(.horizontal)
                    .padding(.bottom, cart.isEmpty ? AppTheme.Spacing.xxl : 80)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
            if !cart.isEmpty {
                confirmBar(viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func heroHeader(_ viewModel: WardrobeViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Wardrobe")
                    .font(AppTheme.Typography.title1)
                    .foregroundStyle(.white)
                Text("\(viewModel.items.count) items in your closet")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }
            Spacer()
            Button { showingAdd = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.18))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, 56)
        .padding(.bottom, AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.walletGradient(for: 2))
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: AppTheme.Radius.xl, bottomTrailingRadius: AppTheme.Radius.xl))
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
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.sm)
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
