//
//  AccountDetailView.swift
//  TidyUp
//

import SwiftUI

struct AccountDetailView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var transactions: [Transaction] = []

    let account: Account

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.type.isCredit ? "Outstanding" : "Balance")
                        .font(.system(size: 12)).foregroundStyle(AppTheme.Colors.secondaryText)
                    PACurrencyText(amount: account.type.isCredit ? -account.balance : account.balance)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                }
            }
            Section("Transactions") {
                if transactions.isEmpty {
                    Text("No transactions yet").foregroundStyle(AppTheme.Colors.secondaryText)
                } else {
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            container.transactionRepository.delete(transactions[index])
                        }
                        load()
                    }
                }
            }
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { load() }
    }

    private func load() {
        let all = (try? container.transactionRepository.fetchAll()) ?? []
        transactions = all.filter { $0.fromAccount?.id == account.id || $0.toAccount?.id == account.id }
    }
}
