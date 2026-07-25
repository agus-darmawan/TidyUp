//
//  Debt.swift
//  TidyUp
//

import Foundation
import SwiftData

enum DebtDirection: String, Codable, CaseIterable, Identifiable {
    case iOwe, owedToMe
    var id: String { rawValue }
    var label: String { self == .iOwe ? "I Owe" : "Owed To Me" }
}

@Model
final class Debt {
    var id: UUID
    var counterpartyName: String
    var directionRaw: String
    var originalAmount: Decimal
    var remainingAmount: Decimal
    var note: String
    var dueDate: Date?
    var isSettled: Bool
    var createdAt: Date

    init(id: UUID = UUID(), counterpartyName: String, direction: DebtDirection, originalAmount: Decimal, note: String = "", dueDate: Date? = nil) {
        self.id = id
        self.counterpartyName = counterpartyName
        self.directionRaw = direction.rawValue
        self.originalAmount = originalAmount
        self.remainingAmount = originalAmount
        self.note = note
        self.dueDate = dueDate
        self.isSettled = false
        self.createdAt = .now
    }

    var direction: DebtDirection {
        get { DebtDirection(rawValue: directionRaw) ?? .iOwe }
        set { directionRaw = newValue.rawValue }
    }

    func applyPayment(_ amount: Decimal) {
        remainingAmount = max(0, remainingAmount - amount)
        if remainingAmount == 0 { isSettled = true }
    }
}
