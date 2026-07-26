//
//  WardrobeViewModel.swift
//  TidyUp
//

import Foundation
import UIKit
import Observation

@Observable
final class WardrobeViewModel {
    private let repository: WardrobeRepositoryProtocol
    private let imageStorageService: ImageStorageService
    private let notificationService: NotificationService

    var items: [ClothingItem] = []
    var selectedCategory: ClothingCategory?

    init(repository: WardrobeRepositoryProtocol, imageStorageService: ImageStorageService, notificationService: NotificationService) {
        self.repository = repository
        self.imageStorageService = imageStorageService
        self.notificationService = notificationService
    }

    func load() {
        items = (try? repository.fetchAll()) ?? []
    }

    var filteredItems: [ClothingItem] {
        guard let selectedCategory else { return items }
        return items.filter { $0.category == selectedCategory }
    }

    /// Only categories that actually contain at least one item — no
    /// point showing a clickable "Prayer" chip if you own zero prayer clothes.
    var categoriesInUse: [ClothingCategory] {
        ClothingCategory.allCases.filter { category in
            items.contains { $0.category == category }
        }
    }

    /// Items grouped by category — each group only appears if it has items.
    var groupedByCategory: [(category: ClothingCategory, items: [ClothingItem])] {
        ClothingCategory.allCases.compactMap { category in
            let matching = items.filter { $0.category == category }
            return matching.isEmpty ? nil : (category, matching)
        }
    }

    /// Items grouped by laundry status (In Laundry first, then Dirty, then Clean).
    var groupedByStatus: [(status: LaundryStatus, items: [ClothingItem])] {
        [LaundryStatus.washing, .dirty, .clean].compactMap { status in
            let matching = items.filter { $0.laundryStatus == status }
            return matching.isEmpty ? nil : (status, matching)
        }
    }

    /// Jackets/linens that are approaching or past the end of their wear cycle.
    var itemsNeedingWash: [ClothingItem] {
        items.filter { item in
            guard let remaining = item.daysRemainingInCycle else { return false }
            return remaining <= 1
        }
    }

    func nextItemCode() -> String {
        repository.nextItemCode()
    }

    func addItem(_ item: ClothingItem) {
        repository.save(item)
        load()
    }

    /// One-tap "wear this" straight from the list row.
    func wear(_ item: ClothingItem) {
        item.markWorn()
        repository.save(item)
        load()
    }

    /// Confirms an entire "outfit cart" selection at once — logs a wear
    /// for every selected item in a single action.
    func confirmOutfit(_ itemIDs: Set<UUID>) {
        for item in items where itemIDs.contains(item.id) {
            item.markWorn()
            repository.save(item)
        }
        load()
    }

    func markWashed(_ item: ClothingItem) {
        item.markWashed()
        repository.save(item)
        load()
    }

    /// Dirty -> In Laundry, with an estimated completion time.
    func startWash(_ item: ClothingItem) {
        item.startWash()
        repository.save(item)
        load()
    }

    var washingItemsCount: Int {
        items.filter { $0.laundryStatus == .washing }.count
    }

    /// Items currently in the laundry, soonest-ready first — used for the
    /// "In Laundry" list.
    var itemsInLaundry: [ClothingItem] {
        items.filter { $0.laundryStatus == .washing }
            .sorted { ($0.estimatedWashDoneDate ?? .distantFuture) < ($1.estimatedWashDoneDate ?? .distantFuture) }
    }

    func delete(_ item: ClothingItem) {
        if let filename = item.photoFilename {
            imageStorageService.deleteImage(filename: filename)
        }
        notificationService.cancelReminder(id: item.id)
        repository.delete(item)
        load()
    }

    /// Sets (or replaces) the single photo for this item — deletes the
    /// previous one first so old files don't pile up unused.
    func setPhoto(_ item: ClothingItem, image: UIImage) {
        if let oldFilename = item.photoFilename {
            imageStorageService.deleteImage(filename: oldFilename)
        }
        guard let filename = try? imageStorageService.saveImage(image) else { return }
        item.photoFilename = filename
        repository.save(item)
        load()
    }

    func loadImage(filename: String) -> UIImage? {
        imageStorageService.loadImage(filename: filename)
    }
}
