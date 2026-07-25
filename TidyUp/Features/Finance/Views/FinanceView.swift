//
//  FinanceView.swift
//  TidyUp
//
//  This is the "Money" tab — one of the two main features (alongside
//  Tasks), not Calendar.
//

import SwiftUI

struct FinanceView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: FinanceViewModel?
    @State private var showingAddTransaction = false
    @State private var showingAddAccount = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Money")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showingAddTransaction = true } label: { Label("New Transaction", systemImage: "plus") }
                        Button { showingAddAccount = true } label: { Label("New Account", systemImage: "creditcard.and.123") }
                        NavigationLink { ReimbursementView() } label: { Label("Reimbursements", systemImage: "arrow.triangle.2.circlepath") }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                if let viewModel {
                    AddEditTransactionView(transaction: nil, accounts: viewModel.accounts, categories: viewModel.categories) {
                        viewModel.load()
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddEditAccountView(account: nil) { account in
                    container.accountRepository.save(account)
                    viewModel?.load()
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = FinanceViewModel(accountRepository: container.accountRepository, transactionRepository: container.transactionRepository)
                }
                viewModel?.load()
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
        }
    }

    @ViewBuilder
    private func content(_ viewModel: FinanceViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                PACard {
                    Text("Net Worth").font(.system(size: 12)).foregroundStyle(AppTheme.Colors.secondaryText)
                    PACurrencyText(amount: viewModel.netWorth).font(.system(size: 26, weight: .bold, design: .rounded))

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Income").font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                            PACurrencyText(amount: viewModel.monthlyIncome, color: AppTheme.Colors.income)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Spend").font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                            PACurrencyText(amount: viewModel.monthlySpending, color: AppTheme.Colors.expense)
                        }
                    }

                    if viewModel.pendingReimburseTotal > 0 {
                        Divider()
                        HStack {
                            Label("Pending Reimburse", systemImage: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12)).foregroundStyle(AppTheme.Colors.reimburse)
                            Spacer()
                            PACurrencyText(amount: viewModel.pendingReimburseTotal, color: AppTheme.Colors.reimburse)
                        }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    PASectionHeader(title: "Accounts").padding(.horizontal)
                    ForEach(viewModel.accounts) { account in
                        NavigationLink { AccountDetailView(account: account) } label: {
                            AccountCard(account: account)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    PASectionHeader(title: "Recent Transactions").padding(.horizontal)
                    ForEach(viewModel.recentTransactions.prefix(10)) { transaction in
                        TransactionRowView(transaction: transaction)
                            .padding(.horizontal)
                            .contextMenu {
                                Button(role: .destructive) { viewModel.deleteTransaction(transaction) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    FinanceView().environment(DependencyContainer.preview)
}
