//
//  CalendarEvent.swift
//  TidyUp
//
//  Unified event wrapper: Tasks with due dates, manually-added
//  ScheduleEvents (with real duration), and journal entries all show up
//  side by side. Tasks still show up here even though they can also be
//  added from the Tasks tab — either place works.
//

import Foundation
import SwiftUI

enum CalendarEventKind {
    case task(TaskItem)
    case schedule(ScheduleEvent)
    case journal(JournalEntry)

    var icon: String {
        switch self {
        case .task: "checklist"
        case .schedule: "calendar"
        case .journal: "book.closed.fill"
        }
    }

    var color: Color {
        switch self {
        case .task(let task): AppTheme.Colors.forPriority(task.priority)
        case .schedule(let event): Color(hex: event.colorTag)
        case .journal(let entry): AppTheme.Colors.forMood(entry.mood)
        }
    }
}

struct CalendarEvent: Identifiable {
    let id: UUID
    let date: Date
    let endDate: Date?
    let title: String
    let kind: CalendarEventKind

    init(task: TaskItem) {
        id = task.id
        date = task.dueDate ?? task.createdAt
        endDate = nil
        title = task.title
        kind = .task(task)
    }

    init(schedule event: ScheduleEvent) {
        id = event.id
        date = event.startDate
        endDate = event.endDate
        title = event.title
        kind = .schedule(event)
    }

    init(journal entry: JournalEntry) {
        id = entry.id
        date = entry.date
        endDate = nil
        title = entry.reflection.isEmpty ? "Journal entry" : entry.reflection
        kind = .journal(entry)
    }

    /// e.g. "10:00 – 11:00" for scheduled events, just "10:00" for tasks.
    var timeLabel: String {
        guard let endDate else { return date.formatted(.time) }
        return "\(date.formatted(.time)) – \(endDate.formatted(.time))"
    }
}
