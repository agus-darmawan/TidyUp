//
//  ScheduleEventRepository.swift
//  TidyUp
//

import Foundation
import SwiftData

@MainActor
protocol ScheduleEventRepositoryProtocol {
    func fetchAll() throws -> [ScheduleEvent]
    func save(_ event: ScheduleEvent)
    func delete(_ event: ScheduleEvent)
}

@MainActor
final class ScheduleEventRepository: ScheduleEventRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [ScheduleEvent] {
        try context.fetch(FetchDescriptor<ScheduleEvent>(sortBy: [SortDescriptor(\.startDate)]))
    }

    func save(_ event: ScheduleEvent) {
        if event.modelContext == nil { context.insert(event) }
        try? context.save()
    }

    func delete(_ event: ScheduleEvent) {
        context.delete(event)
        try? context.save()
    }
}
