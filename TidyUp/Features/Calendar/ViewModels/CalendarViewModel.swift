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
    private let transactionRepository: TransactionRepositoryProtocol

    var selectedDate: Date = .now
    private var allEvents: [CalendarEvent] = []

    init(taskRepository: TaskRepositoryProtocol, journalRepository: JournalRepositoryProtocol, transactionRepository: TransactionRepositoryProtocol) {
        self.taskRepository = taskRepository
        self.journalRepository = journalRepository
        self.transactionRepository = transactionRepository
    }

    func load() {
        var events: [CalendarEvent] = []
        if let tasks = try? taskRepository.fetchAll() {
            events += tasks.compactMap { $0.dueDate != nil ? CalendarEvent(task: $0) : nil }
        }
        if let entries = try? journalRepository.fetchAll() {
            events += entries.map(CalendarEvent.init(journal:))
        }
        if let bills = try? transactionRepository.fetchUpcomingBills() {
            events += bills.map(CalendarEvent.init(bill:))
        }
        allEvents = events
    }

    func events(on date: Date) -> [CalendarEvent] {
        allEvents.filter { $0.date.isSameDay(as: date) }
    }

    var selectedDayEvents: [CalendarEvent] {
        events(on: selectedDate).sorted { $0.date < $1.date }
    }

    var upcomingEvents: [CalendarEvent] {
        allEvents.filter { $0.date >= Date.now.startOfDay }.sorted { $0.date < $1.date }
    }
}
