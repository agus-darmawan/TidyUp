//
//  TaskListViewModel.swift
//  TidyUp
//

import Foundation
import Observation

enum TaskFilter: String, CaseIterable, Identifiable {
    case all, today, overdue, highPriority, done
    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: "All"
        case .today: "Today"
        case .overdue: "Overdue"
        case .highPriority: "High Priority"
        case .done: "Done"
        }
    }
}

@Observable
final class TaskListViewModel {
    private let repository: TaskRepositoryProtocol
    private let notificationService: NotificationService

    var tasks: [TaskItem] = []
    var filter: TaskFilter = .all
    var searchText: String = ""

    init(repository: TaskRepositoryProtocol, notificationService: NotificationService) {
        self.repository = repository
        self.notificationService = notificationService
    }

    func load() {
        tasks = (try? repository.fetchAll()) ?? []
    }

    var filteredTasks: [TaskItem] {
        var result = tasks
        switch filter {
        case .all: break
        case .today: result = result.filter { $0.dueDate?.isToday == true }
        case .overdue: result = result.filter(\.isOverdue)
        case .highPriority: result = result.filter { $0.priority == .high }
        case .done: result = result.filter(\.isDone)
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result.sorted { lhs, rhs in
            if lhs.isDone != rhs.isDone { return !lhs.isDone && rhs.isDone }
            return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
        }
    }

    func toggleDone(_ item: TaskItem) {
        repository.toggleDone(item)
        if item.isDone { notificationService.cancelReminder(id: item.id) }
        load()
    }

    func delete(_ item: TaskItem) {
        notificationService.cancelReminder(id: item.id)
        repository.delete(item)
        load()
    }

    func save(_ item: TaskItem) {
        repository.save(item)
        if item.hasReminder, let due = item.dueDate, !item.isDone {
            notificationService.scheduleReminder(
                id: item.id, title: item.title,
                body: item.notes.isEmpty ? "Reminder" : item.notes,
                date: due, repeats: item.recurrence != .none
            )
        }
        load()
    }
}
