//
//  BackupModels.swift
//  TidyUp
//
//  Codable snapshots of every persisted model, used by BackupService to
//  produce a single self-contained JSON file — including embedded photo
//  bytes — so restoring doesn't depend on anything else surviving.
//

import Foundation

struct BackupPayload: Codable {
    var version: Int = 1
    var exportedAt: Date = .now

    var accounts: [AccountBackup] = []
    var categories: [CategoryBackup] = []
    var debts: [DebtBackup] = []
    var installments: [InstallmentBackup] = []
    var tasks: [TaskBackup] = []
    var clothingItems: [ClothingItemBackup] = []
    var journalEntries: [JournalEntryBackup] = []
    var scheduleEvents: [ScheduleEventBackup] = []
    var transactions: [TransactionBackup] = []

    /// filename -> raw JPEG bytes for every photo referenced anywhere above.
    var images: [String: Data] = [:]
}

struct AccountBackup: Codable {
    var id: UUID
    var name: String
    var type: String
    var balance: Decimal
    var creditLimit: Decimal?
    var isArchived: Bool
    var createdAt: Date
}

struct CategoryBackup: Codable {
    var id: UUID
    var name: String
    var icon: String
    var isDefault: Bool
}

struct DebtBackup: Codable {
    var id: UUID
    var counterpartyName: String
    var direction: String
    var originalAmount: Decimal
    var remainingAmount: Decimal
    var note: String
    var dueDate: Date?
    var isSettled: Bool
    var createdAt: Date
}

struct InstallmentBackup: Codable {
    var id: UUID
    var itemName: String
    var totalAmount: Decimal
    var totalTerms: Int
    var paidTerms: Int
    var startDate: Date
    var accountID: UUID?
    var createdAt: Date
}

struct SubTaskBackup: Codable {
    var id: UUID
    var title: String
    var isDone: Bool
    var order: Int
}

struct TaskBackup: Codable {
    var id: UUID
    var title: String
    var notes: String
    var isDone: Bool
    var createdAt: Date
    var dueDate: Date?
    var hasReminder: Bool
    var priority: String
    var tags: [String]
    var recurrence: String
    var recurrenceParentID: UUID?
    var subtasks: [SubTaskBackup]
}

struct ClothingItemBackup: Codable {
    var itemCode: String
    var id: UUID
    var name: String
    var category: String
    var brand: String
    var color: String
    var notes: String
    var photoFilename: String?
    var purchaseDate: Date?
    var createdAt: Date
    var laundryStatus: String
    var lastWornDate: Date?
    var lastWashedDate: Date?
    var washStartedDate: Date?
    var wearCountSinceWash: Int
    var usageDurationDays: Int?
    var wearCycleStartDate: Date?
}

struct JournalEntryBackup: Codable {
    var id: UUID
    var date: Date
    var mood: String
    var reflection: String
    var tags: [String]
    var photoFilenames: [String]
    var createdAt: Date
}

struct ScheduleEventBackup: Codable {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var note: String
    var colorTag: String
    var createdAt: Date
}

struct TransactionBackup: Codable {
    var id: UUID
    var date: Date
    var amount: Decimal
    var type: String
    var note: String
    var fromAccountID: UUID?
    var toAccountID: UUID?
    var categoryID: UUID?
    var isReimbursable: Bool
    var reimburseStatus: String
    var receiptImageFilename: String?
    var itemImageFilename: String?
    var isRecurring: Bool
    var recurrenceFrequency: String
    var nextOccurrenceDate: Date?
    var linkedDebtID: UUID?
    var createdAt: Date
}
