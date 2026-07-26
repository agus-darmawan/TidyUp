//
//  TaskRepository.swift
//  TidyUp
//

import Foundation
import SwiftData

@MainActor
protocol TaskRepositoryProtocol {
    func fetchAll() throws -> [TaskItem]
    func fetchDue(on date: Date) throws -> [TaskItem]
    func save(_ item: TaskItem)
    func delete(_ item: TaskItem)
    func toggleDone(_ item: TaskItem)
}

@MainActor
final class TaskRepository: TaskRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [TaskItem] {
        let descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func fetchDue(on date: Date) throws -> [TaskItem] {
        let start = date.startOfDay
        let end = date.endOfDay
        // #Predicate only allows a single expression — filter nil-safety
        // simply, then do the date-range check in memory.
        let predicate = #Predicate<TaskItem> { $0.dueDate != nil }
        let descriptor = FetchDescriptor<TaskItem>(predicate: predicate)
        let candidates = try context.fetch(descriptor)
        return candidates.filter { task in
            guard let due = task.dueDate else { return false }
            return due >= start && due <= end
        }
    }

    func save(_ item: TaskItem) {
        if item.modelContext == nil { context.insert(item) }
        try? context.save()
    }

    func delete(_ item: TaskItem) {
        context.delete(item)
        try? context.save()
    }

    func toggleDone(_ item: TaskItem) {
        item.isDone.toggle()

        if item.isDone, item.recurrence != .none, let dueDate = item.dueDate,
           let nextDate = item.recurrence.nextDate(after: dueDate) {
            let next = TaskItem(
                title: item.title, notes: item.notes, dueDate: nextDate,
                hasReminder: item.hasReminder, priority: item.priority,
                tags: item.tags, recurrence: item.recurrence,
                recurrenceParentID: item.recurrenceParentID ?? item.id
            )
            context.insert(next)
        }
        try? context.save()
    }
}
