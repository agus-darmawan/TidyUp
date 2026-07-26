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

    func delete(_ item: ClothingItem) {
        for filename in item.photoFilenames {
            imageStorageService.deleteImage(filename: filename)
        }
        notificationService.cancelReminder(id: item.id)
        repository.delete(item)
        load()
    }

    func addPhoto(_ item: ClothingItem, image: UIImage) {
        guard let filename = try? imageStorageService.saveImage(image) else { return }
        item.photoFilenames.append(filename)
        repository.save(item)
        load()
    }

    func loadImage(filename: String) -> UIImage? {
        imageStorageService.loadImage(filename: filename)
    }
}
