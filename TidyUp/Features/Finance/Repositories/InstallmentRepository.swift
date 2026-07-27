//
//  InstallmentRepository.swift
//  TidyUp
//

import Foundation
import SwiftData

@MainActor
protocol InstallmentRepositoryProtocol {
    func fetchAll() throws -> [Installment]
    func save(_ installment: Installment)
    func delete(_ installment: Installment)
    func recordPayment(_ installment: Installment)
}

@MainActor
final class InstallmentRepository: InstallmentRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Installment] {
        try context.fetch(FetchDescriptor<Installment>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
    }

    func save(_ installment: Installment) {
        if installment.modelContext == nil { context.insert(installment) }
        try? context.save()
    }

    func delete(_ installment: Installment) {
        context.delete(installment)
        try? context.save()
    }

    /// Recording a payment also reduces the linked account's outstanding
    /// balance (if one is set), keeping the credit-card/pay-later balance
    /// in sync with the installment plan.
    func recordPayment(_ installment: Installment) {
        installment.recordPayment()
        if let account = installment.account {
            account.balance = max(0, account.balance - installment.monthlyAmount)
        }
        try? context.save()
    }
}
