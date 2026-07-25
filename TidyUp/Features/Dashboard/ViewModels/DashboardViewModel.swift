//
//  DashboardViewModel.swift
//  TidyUp
//
//  Real data now (not mock) — aggregates Tasks and Money first (the two
//  main features), plus a quick Wardrobe laundry stat and recent journal.
//  Calendar intentionally isn't a headline stat here.
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    private let taskRepository: TaskRepositoryProtocol
    private let journalRepository: JournalRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let wardrobeRepository: WardrobeRepositoryProtocol

    var todayTasks: [TaskItem] = []
    var recentJournalEntries: [JournalEntry] = []
    var dirtyClothingCount: Int = 0
    var todaySpending: Decimal = 0

    init(
        taskRepository: TaskRepositoryProtocol,
        journalRepository: JournalRepositoryProtocol,
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        wardrobeRepository: WardrobeRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.journalRepository = journalRepository
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.wardrobeRepository = wardrobeRepository
    }

    func load() {
        todayTasks = (try? taskRepository.fetchDue(on: .now)) ?? []
        recentJournalEntries = (try? journalRepository.fetchRecent(limit: 3)) ?? []
        dirtyClothingCount = ((try? wardrobeRepository.fetchAll()) ?? []).filter { $0.laundryStatus == .dirty }.count

        let todayTransactions = (try? transactionRepository.fetchToday()) ?? []
        todaySpending = todayTransactions
            .filter { $0.type == .expense || $0.type == .reimbursement }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }

    var netWorth: Decimal { accountRepository.totalNetWorth }
    var completedTodayCount: Int { todayTasks.filter(\.isDone).count }
}
