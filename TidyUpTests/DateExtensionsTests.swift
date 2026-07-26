//
//  DateExtensionsTests.swift
//  TidyUpTests
//

import XCTest
@testable import TidyUp

final class DateExtensionsTests: XCTestCase {

    func testIsSameDayTrueForSameCalendarDay() {
        let date1 = Date.now.startOfDay
        let date2 = date1.addingTimeInterval(3600 * 5) // same day, 5 hours later
        XCTAssertTrue(date1.isSameDay(as: date2))
    }

    func testIsSameDayFalseAcrossDays() {
        let date1 = Date.now.startOfDay
        let date2 = date1.adding(days: 1)
        XCTAssertFalse(date1.isSameDay(as: date2))
    }

    func testAddingDaysMovesForwardCorrectly() {
        let base = Date.now.startOfDay
        let future = base.adding(days: 7)
        XCTAssertEqual(base.daysSince(future.adding(days: -7)), 0)
        XCTAssertEqual(future.daysSince(base), 7)
    }

    func testDaysGridPadsToMultipleOfSeven() {
        let grid = Date.daysGrid(for: .now)
        XCTAssertEqual(grid.count % 7, 0, "Calendar month grid should always be a multiple of 7")
    }

    func testEndOfDayIsAfterStartOfDay() {
        let date = Date.now
        XCTAssertTrue(date.endOfDay > date.startOfDay)
    }
}
