//
//  CalendarEvent.swift
//  TidyUp
//
//  Read-only aggregator — pulls from Tasks/Journal/Finance, doesn't own
//  its own SwiftData store. Calendar is a secondary feature here
//  (Tasks and Money are the main two), so this stays lightweight.
//

import Foundation
import SwiftUI

enum CalendarEventKind {
    case task(TaskItem)
    case bill(Transaction)
    case journal(JournalEntry)

    var icon: String {
        switch self {
        case .task: "checklist"
        case .bill: "creditcard.fill"
        case .journal: "book.closed.fill"
        }
    }

    var color: Color {
        switch self {
        case .task(let task): AppTheme.Colors.forPriority(task.priority)
        case .bill: AppTheme.Colors.warning
        case .journal(let entry): AppTheme.Colors.forMood(entry.mood)
        }
    }
}

struct CalendarEvent: Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let kind: CalendarEventKind

    init(task: TaskItem) {
        id = task.id
        date = task.dueDate ?? task.createdAt
        title = task.title
        kind = .task(task)
    }

    init(bill transaction: Transaction) {
        id = transaction.id
        date = transaction.date
        title = transaction.note
        kind = .bill(transaction)
    }

    init(journal entry: JournalEntry) {
        id = entry.id
        date = entry.date
        title = entry.reflection.isEmpty ? "Journal entry" : entry.reflection
        kind = .journal(entry)
    }
}
