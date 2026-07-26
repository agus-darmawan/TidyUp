//
//  TransactionTests.swift
//  TidyUpTests
//

import XCTest
@testable import TidyUp

final class TransactionTests: XCTestCase {

    func testExpenseHasNegativeBalanceSign() {
        XCTAssertEqual(TransactionType.expense.balanceSign, -1)
    }

    func testIncomeHasPositiveBalanceSign() {
        XCTAssertEqual(TransactionType.income.balanceSign, 1)
    }

    func testDebtBorrowedIncreasesBalance() {
        XCTAssertEqual(TransactionType.debtBorrowed.balanceSign, 1)
    }

    func testReimbursementProofRequiredOnlyWhenReimbursable() {
        let expense = Transaction(amount: 10_000, type: .expense, isReimbursable: false)
        XCTAssertTrue(expense.hasRequiredReimbursementProof, "Non-reimbursable transactions don't need proof")
    }

    func testReimbursementMissingProofFailsCheck() {
        let reimbursement = Transaction(amount: 50_000, type: .reimbursement, isReimbursable: true)
        XCTAssertFalse(reimbursement.hasRequiredReimbursementProof)
    }

    func testReimbursementWithBothPhotosPassesCheck() {
        let reimbursement = Transaction(
            amount: 50_000, type: .reimbursement, isReimbursable: true,
            receiptImageFilename: "receipt.jpg", itemImageFilename: "item.jpg"
        )
        XCTAssertTrue(reimbursement.hasRequiredReimbursementProof)
    }

    func testRejectedReimbursementLabel() {
        XCTAssertEqual(ReimburseStatus.rejected.label, "Rejected")
    }
}
