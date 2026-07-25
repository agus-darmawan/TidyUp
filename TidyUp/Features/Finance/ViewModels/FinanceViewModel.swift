//
//  FinanceViewModel.swift
//  TidyUp
//

import Foundation
import Observation

@Observable
final class FinanceViewModel {
    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol

    var accounts: [Account] = []
    var recentTransactions: [Transaction] = []
    var categories: [TransactionCategory] = []
    private var allTransactions: [Transaction] = []

    init(accountRepository: AccountRepositoryProtocol, transactionRepository: TransactionRepositoryProtocol) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
    }

    func load() {
        accounts = (try? accountRepository.fetchAll()) ?? []
        allTransactions = (try? transactionRepository.fetchAll()) ?? []
        recentTransactions = Array(allTransactions.prefix(20))
        categories = (try? transactionRepository.fetchCategories()) ?? []
    }

    var netWorth: Decimal { accountRepository.totalNetWorth }
    var pendingReimburseTotal: Decimal { transactionRepository.pendingReimburseTotal }

    var monthlySpending: Decimal {
        let interval = Date.now.monthInterval
        return allTransactions
            .filter { $0.type == .expense || $0.type == .reimbursement }
            .filter { interval.contains($0.date) }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }

    var monthlyIncome: Decimal {
        let interval = Date.now.monthInterval
        return allTransactions
            .filter { $0.type == .income }
            .filter { interval.contains($0.date) }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }

    func deleteTransaction(_ transaction: Transaction) {
        transactionRepository.delete(transaction)
        load()
    }

    func addCategory(name: String) -> TransactionCategory {
        let category = transactionRepository.addCategory(name: name, icon: "tag.fill")
        categories.append(category)
        return category
    }
}
