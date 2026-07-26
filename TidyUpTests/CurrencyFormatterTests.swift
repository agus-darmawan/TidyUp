//
//  CurrencyFormatterTests.swift
//  TidyUpTests
//

import XCTest
@testable import TidyUp

final class CurrencyFormatterTests: XCTestCase {

    func testFormatWholeNumberHasNoDecimals() {
        let result = CurrencyFormatter.format(1_250_000)
        XCTAssertFalse(result.contains(","), "IDR formatting should not show decimal separators for whole amounts")
    }

    func testSignedPositiveAddsPlusPrefix() {
        let result = CurrencyFormatter.format(50_000, signed: true)
        XCTAssertTrue(result.hasPrefix("+"), "Signed positive amounts should be prefixed with +")
    }

    func testSignedNegativeDoesNotDoublePrefix() {
        let result = CurrencyFormatter.format(-50_000, signed: true)
        XCTAssertFalse(result.hasPrefix("+"), "Negative amounts should not get a + prefix")
    }

    func testUnsignedPositiveHasNoPlusPrefix() {
        let result = CurrencyFormatter.format(50_000, signed: false)
        XCTAssertFalse(result.hasPrefix("+"))
    }
}
