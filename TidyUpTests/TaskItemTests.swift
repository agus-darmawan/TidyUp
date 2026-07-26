//
//  TaskItemTests.swift
//  TidyUpTests
//

import XCTest
@testable import TidyUp

final class TaskItemTests: XCTestCase {

    func testSubtaskProgressNilWhenNoSubtasks() {
        let task = TaskItem(title: "Solo task")
        XCTAssertNil(task.subtaskProgress)
    }

    func testSubtaskProgressReflectsCompletionRatio() {
        let task = TaskItem(title: "With subtasks")
        task.subtasks = [
            SubTask(title: "One", isDone: true),
            SubTask(title: "Two", isDone: true),
            SubTask(title: "Three", isDone: false),
            SubTask(title: "Four", isDone: false)
        ]
        XCTAssertEqual(task.subtaskProgress, 0.5)
    }

    func testIsOverdueTrueForPastDueDateNotDone() {
        let pastDate = Date.now.adding(days: -2)
        let task = TaskItem(title: "Late", isDone: false, dueDate: pastDate)
        XCTAssertTrue(task.isOverdue)
    }

    func testIsOverdueFalseWhenDone() {
        let pastDate = Date.now.adding(days: -2)
        let task = TaskItem(title: "Late but done", isDone: true, dueDate: pastDate)
        XCTAssertFalse(task.isOverdue)
    }

    func testIsOverdueFalseWithNoDueDate() {
        let task = TaskItem(title: "No due date")
        XCTAssertFalse(task.isOverdue)
    }

    func testRecurrenceNextDateWeekly() {
        let today = Date.now.startOfDay
        let next = RecurrenceFrequency.weekly.nextDate(after: today)
        XCTAssertEqual(next, today.adding(days: 7))
    }

    func testRecurrenceNoneReturnsNil() {
        XCTAssertNil(RecurrenceFrequency.none.nextDate(after: .now))
    }
}
