//
//  TransactionRepository.swift
//  TidyUp
//
//  Owns all balance-mutation logic — every save/delete keeps account
//  balances consistent with the transaction ledger automatically.
//

import Foundation
import SwiftData

@MainActor
protocol TransactionRepositoryProtocol {
    func fetchAll() throws -> [Transaction]
    func fetchToday() throws -> [Transaction]
    func fetchUpcomingBills() throws -> [Transaction]
    func fetchReimbursable(status: ReimburseStatus?) throws -> [Transaction]
    func fetchCategories() throws -> [TransactionCategory]
    @discardableResult func addCategory(name: String, icon: String) -> TransactionCategory
    func save(_ transaction: Transaction, previousAmount: Decimal?, previousType: TransactionType?)
    func delete(_ transaction: Transaction)
    func markReimbursementPaid(_ transaction: Transaction, creditTo account: Account)
    func markReimbursementSubmitted(_ transaction: Transaction)
    func markReimbursementRejected(_ transaction: Transaction)
    func seedDefaultCategoriesIfNeeded()
    var pendingReimburseTotal: Decimal { get }
}

@MainActor
final class TransactionRepository: TransactionRepositoryProtocol {
    private let context: ModelContext
    private let accountRepository: AccountRepositoryProtocol

    init(context: ModelContext, accountRepository: AccountRepositoryProtocol) {
        self.context = context
        self.accountRepository = accountRepository
    }

    func fetchAll() throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func fetchToday() throws -> [Transaction] {
        let start = Date.now.startOfDay
        let end = Date.now.endOfDay
        let predicate = #Predicate<Transaction> { $0.date >= start && $0.date <= end }
        return try context.fetch(FetchDescriptor<Transaction>(predicate: predicate))
    }

    func fetchUpcomingBills() throws -> [Transaction] {
        let now = Date.now
        let predicate = #Predicate<Transaction> { $0.isRecurring && $0.nextOccurrenceDate != nil }
        let descriptor = FetchDescriptor<Transaction>(predicate: predicate, sortBy: [SortDescriptor(\.nextOccurrenceDate)])
        return try context.fetch(descriptor).filter { ($0.nextOccurrenceDate ?? .distantPast) >= now.startOfDay }
    }

    func fetchReimbursable(status: ReimburseStatus? = nil) throws -> [Transaction] {
        let all = try fetchAll().filter(\.isReimbursable)
        guard let status else { return all }
        return all.filter { $0.reimburseStatus == status }
    }

    var pendingReimburseTotal: Decimal {
        let items = (try? fetchReimbursable()) ?? []
        return items.filter { $0.reimburseStatus != .paid && $0.reimburseStatus != .rejected }.reduce(Decimal(0)) { $0 + $1.amount }
    }

    func fetchCategories() throws -> [TransactionCategory] {
        try context.fetch(FetchDescriptor<TransactionCategory>(sortBy: [SortDescriptor(\.name)]))
    }

    @discardableResult
    func addCategory(name: String, icon: String = "tag.fill") -> TransactionCategory {
        let category = TransactionCategory(name: name, icon: icon, isDefault: false)
        context.insert(category)
        try? context.save()
        return category
    }

    func save(_ transaction: Transaction, previousAmount: Decimal? = nil, previousType: TransactionType? = nil) {
        if transaction.modelContext == nil {
            context.insert(transaction)
        } else if let previousAmount, let previousType {
            reverseBalanceEffect(amount: previousAmount, type: previousType, transaction: transaction)
        }
        applyBalanceEffect(transaction)

        if transaction.isRecurring, transaction.nextOccurrenceDate == nil {
            transaction.nextOccurrenceDate = transaction.recurrenceFrequency.nextDate(after: transaction.date)
        }
        try? context.save()
    }

    func delete(_ transaction: Transaction) {
        reverseBalanceEffect(amount: transaction.amount, type: transaction.type, transaction: transaction)
        context.delete(transaction)
        try? context.save()
    }

    /// Reimbursement paid out by the office: credits the chosen account
    /// without re-affecting the original expense's account balance.
    func markReimbursementPaid(_ transaction: Transaction, creditTo account: Account) {
        transaction.reimburseStatus = .paid
        account.balance += transaction.amount
        try? context.save()
    }

    /// Pending → Submitted: you've sent the receipt/claim to the office,
    /// now waiting on Paid or Rejected.
    func markReimbursementSubmitted(_ transaction: Transaction) {
        transaction.reimburseStatus = .submitted
        try? context.save()
    }

    /// Rejected by the office — the money already left the account when
    /// the expense was logged, so no balance change is needed. It simply
    /// stops counting as pending reimbursement and becomes, in effect,
    /// an ordinary personal expense.
    func markReimbursementRejected(_ transaction: Transaction) {
        transaction.reimburseStatus = .rejected
        try? context.save()
    }

    private func applyBalanceEffect(_ transaction: Transaction) {
        switch transaction.type {
        case .income, .expense, .reimbursement, .debtBorrowed, .debtLent:
            transaction.fromAccount?.balance += transaction.type.balanceSign * transaction.amount
        case .transfer:
            transaction.fromAccount?.balance -= transaction.amount
            transaction.toAccount?.balance += transaction.amount
        }
    }

    private func reverseBalanceEffect(amount: Decimal, type: TransactionType, transaction: Transaction) {
        switch type {
        case .income, .expense, .reimbursement, .debtBorrowed, .debtLent:
            transaction.fromAccount?.balance -= type.balanceSign * amount
        case .transfer:
            transaction.fromAccount?.balance += amount
            transaction.toAccount?.balance -= amount
        }
    }

    func seedDefaultCategoriesIfNeeded() {
        let count = (try? context.fetchCount(FetchDescriptor<TransactionCategory>())) ?? 0
        guard count == 0 else { return }
        let defaults: [(String, String)] = [
            ("Food & Drink", "fork.knife"), ("Coffee", "cup.and.saucer.fill"),
            ("Transport", "car.fill"), ("Shopping", "bag.fill"),
            ("Bills & Subscriptions", "doc.text.fill"), ("Salary", "banknote.fill"),
            ("Health", "cross.case.fill"), ("Entertainment", "gamecontroller.fill"),
            ("Other", "ellipsis.circle.fill")
        ]
        for (name, icon) in defaults {
            context.insert(TransactionCategory(name: name, icon: icon, isDefault: true))
        }
        try? context.save()
    }
}
