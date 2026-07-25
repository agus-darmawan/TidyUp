//
//  JournalViewModel.swift
//  TidyUp
//

import Foundation
import Observation

@Observable
final class JournalViewModel {
    private let repository: JournalRepositoryProtocol

    var entries: [JournalEntry] = []

    init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        entries = (try? repository.fetchAll()) ?? []
    }

    func save(_ entry: JournalEntry) {
        repository.save(entry)
        load()
    }

    func delete(_ entry: JournalEntry) {
        repository.delete(entry)
        load()
    }
}
