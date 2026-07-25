//
//  TaskItem.swift
//  TidyUp
//

import Foundation
import SwiftData

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low, medium, high
    var id: String { rawValue }
    var label: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
}

enum RecurrenceFrequency: String, Codable, CaseIterable, Identifiable {
    case none, daily, weekly, monthly, yearly
    var id: String { rawValue }
    var label: String {
        switch self {
        case .none: "Does not repeat"
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }
    func nextDate(after date: Date) -> Date? {
        switch self {
        case .none: return nil
        case .daily: return date.adding(days: 1)
        case .weekly: return date.adding(days: 7)
        case .monthly: return date.adding(months: 1)
        case .yearly: return date.adding(years: 1)
        }
    }
}

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var notes: String
    var isDone: Bool
    var createdAt: Date
    var dueDate: Date?
    var hasReminder: Bool
    var priorityRaw: String
    var tags: [String]
    var recurrenceRaw: String
    var recurrenceParentID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \SubTask.parentTask)
    var subtasks: [SubTask]

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        isDone: Bool = false,
        dueDate: Date? = nil,
        hasReminder: Bool = false,
        priority: TaskPriority = .medium,
        tags: [String] = [],
        recurrence: RecurrenceFrequency = .none,
        recurrenceParentID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isDone = isDone
        self.createdAt = .now
        self.dueDate = dueDate
        self.hasReminder = hasReminder
        self.priorityRaw = priority.rawValue
        self.tags = tags
        self.recurrenceRaw = recurrence.rawValue
        self.recurrenceParentID = recurrenceParentID
        self.subtasks = []
    }

    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var recurrence: RecurrenceFrequency {
        get { RecurrenceFrequency(rawValue: recurrenceRaw) ?? .none }
        set { recurrenceRaw = newValue.rawValue }
    }

    var subtaskProgress: Double? {
        guard !subtasks.isEmpty else { return nil }
        return Double(subtasks.filter(\.isDone).count) / Double(subtasks.count)
    }

    var isOverdue: Bool {
        guard let dueDate, !isDone else { return false }
        return dueDate < Date.now.startOfDay
    }
}

@Model
final class SubTask {
    var id: UUID
    var title: String
    var isDone: Bool
    var order: Int
    var parentTask: TaskItem?

    init(id: UUID = UUID(), title: String, isDone: Bool = false, order: Int = 0) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.order = order
    }
}
