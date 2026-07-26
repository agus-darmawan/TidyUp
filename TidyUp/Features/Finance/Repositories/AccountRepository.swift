//
//  AccountRepository.swift
//  TidyUp
//

import Foundation
import SwiftData

@MainActor
protocol AccountRepositoryProtocol {
    func fetchAll() throws -> [Account]
    func save(_ account: Account)
    func delete(_ account: Account)
    var totalNetWorth: Decimal { get }
}

@MainActor
final class AccountRepository: AccountRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Account] {
        let predicate = #Predicate<Account> { !$0.isArchived }
        let descriptor = FetchDescriptor<Account>(predicate: predicate, sortBy: [SortDescriptor(\.createdAt)])
        return try context.fetch(descriptor)
    }

    func save(_ account: Account) {
        if account.modelContext == nil { context.insert(account) }
        try? context.save()
    }

    func delete(_ account: Account) {
        context.delete(account)
        try? context.save()
    }

    var totalNetWorth: Decimal {
        let accounts = (try? fetchAll()) ?? []
        return accounts.reduce(Decimal(0)) { partial, account in
            partial + (account.type.isCredit ? -account.balance : account.balance)
        }
    }
}
