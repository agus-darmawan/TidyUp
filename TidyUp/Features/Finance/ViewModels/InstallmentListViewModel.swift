//
//  InstallmentListViewModel.swift
//  TidyUp
//

import Foundation
import Observation

@Observable
final class InstallmentListViewModel {
    private let repository: InstallmentRepositoryProtocol

    var installments: [Installment] = []

    init(repository: InstallmentRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        installments = (try? repository.fetchAll()) ?? []
    }

    var active: [Installment] { installments.filter { !$0.isComplete } }
    var completed: [Installment] { installments.filter(\.isComplete) }

    var totalMonthlyDue: Decimal {
        active.reduce(Decimal(0)) { $0 + $1.monthlyAmount }
    }

    func save(_ installment: Installment) {
        repository.save(installment)
        load()
    }

    func delete(_ installment: Installment) {
        repository.delete(installment)
        load()
    }

    func recordPayment(_ installment: Installment) {
        repository.recordPayment(installment)
        load()
    }
}
