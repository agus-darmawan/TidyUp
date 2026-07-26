//
//  ClothingItemTests.swift
//  TidyUpTests
//
//  Covers the wash-cycle logic: regular items go dirty immediately on
//  wear, while Outerwear/Linens use a duration-based cycle instead.
//

import XCTest
@testable import TidyUp

final class ClothingItemTests: XCTestCase {

    func testMarkWornSetsRegularItemDirtyImmediately() {
        let shirt = ClothingItem(itemCode: "TU-0001", name: "Shirt", category: .casual)
        XCTAssertEqual(shirt.laundryStatus, .clean)
        shirt.markWorn()
        XCTAssertEqual(shirt.laundryStatus, .dirty)
        XCTAssertEqual(shirt.wearCountSinceWash, 1)
    }

    func testMarkWornOnJacketStaysCleanWithinCycle() {
        let jacket = ClothingItem(itemCode: "TU-0002", name: "Jacket", category: .outerwear, usageDurationDays: 7)
        jacket.markWorn()
        // Wearing it once, on day 0 of a 7-day cycle, should not be dirty yet.
        XCTAssertEqual(jacket.laundryStatus, .clean)
        XCTAssertNotNil(jacket.daysRemainingInCycle)
    }

    func testStartWashTransitionsToWashingWithEstimate() {
        let shirt = ClothingItem(itemCode: "TU-0003", name: "Shirt", category: .casual)
        shirt.markWorn()
        shirt.startWash()
        XCTAssertEqual(shirt.laundryStatus, .washing)
        XCTAssertNotNil(shirt.estimatedWashDoneDate)
        XCTAssertFalse(shirt.washTimeRemainingLabel.isEmpty)
    }

    func testMarkWashedReturnsToCleanAndResetsCounters() {
        let shirt = ClothingItem(itemCode: "TU-0004", name: "Shirt", category: .casual)
        shirt.markWorn()
        shirt.startWash()
        shirt.markWashed()
        XCTAssertEqual(shirt.laundryStatus, .clean)
        XCTAssertEqual(shirt.wearCountSinceWash, 0)
        XCTAssertNotNil(shirt.lastWashedDate)
    }

    func testNonDurationCategoryHasNilUsageDuration() {
        let shirt = ClothingItem(itemCode: "TU-0005", name: "Shirt", category: .casual)
        XCTAssertNil(shirt.usageDurationDays)
        XCTAssertNil(shirt.daysRemainingInCycle)
    }

    func testDurationCategoryDefaultsUsageDuration() {
        let jacket = ClothingItem(itemCode: "TU-0006", name: "Jacket", category: .outerwear)
        XCTAssertEqual(jacket.usageDurationDays, ClothingCategory.outerwear.defaultUsageDurationDays)
    }
}
