//
//  CalendarViewModel.swift
//  TidyUp
//

import Foundation
import Observation

@Observable
final class CalendarViewModel {
    private let taskRepository: TaskRepositoryProtocol
    private let journalRepository: JournalRepositoryProtocol
    private let scheduleEventRepository: ScheduleEventRepositoryProtocol

    var selectedDate: Date = .now
    var monthAnchor: Date = .now
    private var allEvents: [CalendarEvent] = []

    init(
        taskRepository: TaskRepositoryProtocol,
        journalRepository: JournalRepositoryProtocol,
        scheduleEventRepository: ScheduleEventRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.journalRepository = journalRepository
        self.scheduleEventRepository = scheduleEventRepository
    }

    func load() {
        var events: [CalendarEvent] = []
        if let tasks = try? taskRepository.fetchAll() {
            events += tasks.compactMap { $0.dueDate != nil ? CalendarEvent(task: $0) : nil }
        }
        if let entries = try? journalRepository.fetchAll() {
            events += entries.map(CalendarEvent.init(journal:))
        }
        if let scheduled = try? scheduleEventRepository.fetchAll() {
            events += scheduled.map(CalendarEvent.init(schedule:))
        }
        allEvents = events
    }

    func events(on date: Date) -> [CalendarEvent] {
        allEvents.filter { $0.date.isSameDay(as: date) }.sorted { $0.date < $1.date }
    }

    var daysGrid: [Date?] {
        Date.daysGrid(for: monthAnchor)
    }

    func hasEvents(on date: Date) -> Bool {
        !events(on: date).isEmpty
    }

    func goToPreviousMonth() {
        monthAnchor = monthAnchor.adding(months: -1)
    }

    func goToNextMonth() {
        monthAnchor = monthAnchor.adding(months: 1)
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    var selectedDayEvents: [CalendarEvent] {
        events(on: selectedDate)
    }

    /// Everything from today onward, across all days — the "next up" agenda view.
    var upcomingEvents: [CalendarEvent] {
        allEvents.filter { $0.date >= Date.now.startOfDay }.sorted { $0.date < $1.date }
    }

    func addScheduleEvent(_ event: ScheduleEvent) {
        scheduleEventRepository.save(event)
        load()
    }

    func deleteScheduleEvent(_ event: ScheduleEvent) {
        scheduleEventRepository.delete(event)
        load()
    }
}
