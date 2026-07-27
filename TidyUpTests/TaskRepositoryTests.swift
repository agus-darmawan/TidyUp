//
//  TaskRepositoryTests.swift
//  TidyUpTests
//
//  Integration-style test against a real in-memory SwiftData container —
//  this is exactly the pattern DependencyContainer.preview exists for.
//
//  NOTE: @MainActor is applied per-method, not at the class level.
//  Marking the whole XCTestCase class @MainActor was found to crash the
//  Xcode 27 beta test runner ("Lost connection to testmanagerd") — the
//  per-method annotation avoids that while still satisfying the
//  repositories' MainActor isolation requirement.
//

import XCTest
import SwiftData
@testable import TidyUp

final class TaskRepositoryTests: XCTestCase {

    private var context: ModelContext!
    private var repository: TaskRepository!

    @MainActor
    override func setUpWithError() throws {
        let schema = Schema([TaskItem.self, SubTask.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
        repository = TaskRepository(context: context)
    }

    override func tearDownWithError() throws {
        context = nil
        repository = nil
    }

    @MainActor
    func testSaveInsertsNewTask() throws {
        let task = TaskItem(title: "Buy groceries")
        repository.save(task)
        let all = try repository.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.title, "Buy groceries")
    }

    @MainActor
    func testToggleDoneMarksTaskComplete() throws {
        let task = TaskItem(title: "Finish report")
        repository.save(task)
        repository.toggleDone(task)
        XCTAssertTrue(task.isDone)
    }

    @MainActor
    func testCompletingRecurringTaskSpawnsNextOccurrence() throws {
        let today = Date.now.startOfDay
        let task = TaskItem(title: "Water the plants", dueDate: today, recurrence: .daily)
        repository.save(task)

        repository.toggleDone(task)

        let all = try repository.fetchAll()
        XCTAssertEqual(all.count, 2, "Completing a recurring task should spawn the next occurrence")
        let next = all.first { $0.id != task.id }
        XCTAssertEqual(next?.dueDate, today.adding(days: 1))
        XCTAssertFalse(next?.isDone ?? true)
    }

    @MainActor
    func testDeleteRemovesTask() throws {
        let task = TaskItem(title: "Temporary")
        repository.save(task)
        repository.delete(task)
        let all = try repository.fetchAll()
        XCTAssertTrue(all.isEmpty)
    }
}
