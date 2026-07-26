//
//  WardrobeRepository.swift
//  TidyUp
//

import Foundation
import SwiftData

@MainActor
protocol WardrobeRepositoryProtocol {
    func fetchAll() throws -> [ClothingItem]
    func save(_ item: ClothingItem)
    func delete(_ item: ClothingItem)
    func nextItemCode() -> String
}

@MainActor
final class WardrobeRepository: WardrobeRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [ClothingItem] {
        let descriptor = FetchDescriptor<ClothingItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func save(_ item: ClothingItem) {
        if item.modelContext == nil { context.insert(item) }
        try? context.save()
    }

    func delete(_ item: ClothingItem) {
        context.delete(item)
        try? context.save()
    }

    /// Sequential unique code — every item is one-of-a-kind, no stock counting.
    func nextItemCode() -> String {
        let count = (try? context.fetchCount(FetchDescriptor<ClothingItem>())) ?? 0
        return String(format: "TU-%04d", count + 1)
    }
}
