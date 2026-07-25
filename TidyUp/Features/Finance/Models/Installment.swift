//
//  Installment.swift
//  TidyUp
//

import Foundation
import SwiftData

@Model
final class Installment {
    var id: UUID
    var itemName: String
    var totalAmount: Decimal
    var totalTerms: Int
    var paidTerms: Int
    var monthlyAmount: Decimal
    var startDate: Date
    var account: Account?
    var createdAt: Date

    init(id: UUID = UUID(), itemName: String, totalAmount: Decimal, totalTerms: Int, paidTerms: Int = 0, startDate: Date = .now) {
        self.id = id
        self.itemName = itemName
        self.totalAmount = totalAmount
        self.totalTerms = max(totalTerms, 1)
        self.paidTerms = paidTerms
        self.monthlyAmount = totalAmount / Decimal(max(totalTerms, 1))
        self.startDate = startDate
        self.createdAt = .now
    }

    var remainingTerms: Int { max(0, totalTerms - paidTerms) }
    var isComplete: Bool { paidTerms >= totalTerms }
    var nextDueDate: Date? { isComplete ? nil : startDate.adding(months: paidTerms + 1) }

    func recordPayment() {
        guard !isComplete else { return }
        paidTerms += 1
    }
}
