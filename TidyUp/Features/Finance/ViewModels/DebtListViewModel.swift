//
//  DebtListViewModel.swift
//  TidyUp
//

import Foundation
import Observation

@Observable
final class DebtListViewModel {
    private let repository: DebtRepositoryProtocol

    var debts: [Debt] = []

    init(repository: DebtRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        debts = (try? repository.fetchAll()) ?? []
    }

    var activeDebts: [Debt] { debts.filter { !$0.isSettled } }
    var settledDebts: [Debt] { debts.filter(\.isSettled) }

    var totalIOwe: Decimal {
        activeDebts.filter { $0.direction == .iOwe }.reduce(Decimal(0)) { $0 + $1.remainingAmount }
    }

    var totalOwedToMe: Decimal {
        activeDebts.filter { $0.direction == .owedToMe }.reduce(Decimal(0)) { $0 + $1.remainingAmount }
    }

    func save(_ debt: Debt) {
        repository.save(debt)
        load()
    }

    func delete(_ debt: Debt) {
        repository.delete(debt)
        load()
    }

    func applyPayment(_ debt: Debt, amount: Decimal) {
        repository.applyPayment(debt, amount: amount)
        load()
    }
}
