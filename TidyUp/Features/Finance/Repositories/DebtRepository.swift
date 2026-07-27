//
//  DebtRepository.swift
//  TidyUp
//

import Foundation
import SwiftData

@MainActor
protocol DebtRepositoryProtocol {
    func fetchAll() throws -> [Debt]
    func save(_ debt: Debt)
    func delete(_ debt: Debt)
    func applyPayment(_ debt: Debt, amount: Decimal)
}

@MainActor
final class DebtRepository: DebtRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Debt] {
        try context.fetch(FetchDescriptor<Debt>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
    }

    func save(_ debt: Debt) {
        if debt.modelContext == nil { context.insert(debt) }
        try? context.save()
    }

    func delete(_ debt: Debt) {
        context.delete(debt)
        try? context.save()
    }

    func applyPayment(_ debt: Debt, amount: Decimal) {
        debt.applyPayment(amount)
        try? context.save()
    }
}
