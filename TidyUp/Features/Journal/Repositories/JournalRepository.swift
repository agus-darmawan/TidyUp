//
//  JournalRepository.swift
//  TidyUp
//

import Foundation
import SwiftData

protocol JournalRepositoryProtocol {
    func fetchAll() throws -> [JournalEntry]
    func fetchRecent(limit: Int) throws -> [JournalEntry]
    func save(_ entry: JournalEntry)
    func delete(_ entry: JournalEntry)
}

final class JournalRepository: JournalRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [JournalEntry] {
        try context.fetch(FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
    }

    func fetchRecent(limit: Int) throws -> [JournalEntry] {
        var descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func save(_ entry: JournalEntry) {
        if entry.modelContext == nil { context.insert(entry) }
        try? context.save()
    }

    func delete(_ entry: JournalEntry) {
        context.delete(entry)
        try? context.save()
    }
}
