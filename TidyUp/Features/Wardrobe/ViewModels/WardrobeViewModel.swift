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
    var searchText: String = ""

    init(repository: WardrobeRepositoryProtocol, imageStorageService: ImageStorageService, notificationService: NotificationService) {
        self.repository = repository
        self.imageStorageService = imageStorageService
        self.notificationService = notificationService
    }

    func load() {
        items = (try? repository.fetchAll()) ?? []
    }

    var filteredItems: [ClothingItem] {
        var result = items
        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.itemCode.localizedCaseInsensitiveContains(searchText) ||
                $0.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var itemsNeedingReplacement: [ClothingItem] {
        items.filter(\.needsReplacement)
    }

    func nextItemCode() -> String {
        repository.nextItemCode()
    }

    func addItem(_ item: ClothingItem) {
        repository.save(item)
        if item.category.isLinen, let interval = item.replacementIntervalDays, let start = item.lastReplacedDate {
            notificationService.scheduleReplacementReminder(
                id: item.id, itemName: item.name,
                dueDate: start.adding(days: interval)
            )
        }
        load()
    }

    /// One-tap "wear this" straight from the list row — no need to open detail first.
    func wear(_ item: ClothingItem) {
        item.markWorn()
        repository.save(item)
        load()
    }

    func markWashed(_ item: ClothingItem) {
        item.markWashed()
        repository.save(item)
        load()
    }

    func markReplaced(_ item: ClothingItem) {
        item.markReplaced()
        repository.save(item)
        if let interval = item.replacementIntervalDays {
            notificationService.scheduleReplacementReminder(
                id: item.id, itemName: item.name,
                dueDate: Date.now.adding(days: interval)
            )
        }
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
