//
//  Transaction.swift
//  TidyUp
//
//  Reimbursement concept: marking a transaction reimbursable still debits
//  the real account immediately (the money left your pocket), but also
//  tracks a separate "pending reimburse" total until the office pays it
//  back. Reimbursable transactions require both a receipt photo and an
//  item photo before they're considered report-ready.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income, expense, transfer, reimbursement, debtBorrowed, debtLent
    var id: String { rawValue }

    var label: String {
        switch self {
        case .income: "Income"
        case .expense: "Expense"
        case .transfer: "Transfer"
        case .reimbursement: "Reimbursement"
        case .debtBorrowed: "Debt (Borrowed)"
        case .debtLent: "Debt (Lent)"
        }
    }

    var balanceSign: Decimal {
        switch self {
        case .income, .debtBorrowed: 1
        case .expense, .transfer, .reimbursement, .debtLent: -1
        }
    }
}

enum ReimburseStatus: String, Codable, CaseIterable, Identifiable {
    case pending, submitted, paid
    var id: String { rawValue }
    var label: String {
        switch self {
        case .pending: "Pending"
        case .submitted: "Submitted"
        case .paid: "Paid"
        }
    }
}

@Model
final class Transaction {
    var id: UUID
    var date: Date
    var amount: Decimal
    var typeRaw: String
    var note: String

    var fromAccount: Account?
    var toAccount: Account?
    var category: TransactionCategory?

    var isReimbursable: Bool
    var reimburseStatusRaw: String
    var receiptImageFilename: String?
    var itemImageFilename: String?

    var isRecurring: Bool
    var recurrenceFrequencyRaw: String
    var nextOccurrenceDate: Date?

    var linkedDebtID: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = .now,
        amount: Decimal,
        type: TransactionType,
        note: String = "",
        fromAccount: Account? = nil,
        toAccount: Account? = nil,
        category: TransactionCategory? = nil,
        isReimbursable: Bool = false,
        reimburseStatus: ReimburseStatus = .pending,
        receiptImageFilename: String? = nil,
        itemImageFilename: String? = nil,
        isRecurring: Bool = false,
        recurrenceFrequency: RecurrenceFrequency = .none,
        nextOccurrenceDate: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.typeRaw = type.rawValue
        self.note = note
        self.fromAccount = fromAccount
        self.toAccount = toAccount
        self.category = category
        self.isReimbursable = isReimbursable
        self.reimburseStatusRaw = reimburseStatus.rawValue
        self.receiptImageFilename = receiptImageFilename
        self.itemImageFilename = itemImageFilename
        self.isRecurring = isRecurring
        self.recurrenceFrequencyRaw = recurrenceFrequency.rawValue
        self.nextOccurrenceDate = nextOccurrenceDate
        self.createdAt = .now
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    var reimburseStatus: ReimburseStatus {
        get { ReimburseStatus(rawValue: reimburseStatusRaw) ?? .pending }
        set { reimburseStatusRaw = newValue.rawValue }
    }

    var recurrenceFrequency: RecurrenceFrequency {
        get { RecurrenceFrequency(rawValue: recurrenceFrequencyRaw) ?? .none }
        set { recurrenceFrequencyRaw = newValue.rawValue }
    }

    /// A reimbursement is only "report-ready" once both mandatory photos exist.
    var hasRequiredReimbursementProof: Bool {
        guard isReimbursable else { return true }
        return receiptImageFilename != nil && itemImageFilename != nil
    }
}
