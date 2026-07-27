//
//  FinanceView.swift
//  TidyUp
//
//  This is the "Money" tab — one of the two main features (alongside
//  Tasks), not Calendar. Accounts are shown as a horizontal, paged
//  "wallet" carousel instead of a plain vertical list.
//

import SwiftUI

struct FinanceView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: FinanceViewModel?
    @State private var showingAddTransaction = false
    @State private var showingAddAccount = false
    @State private var showingExport = false

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
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showingAddTransaction = true } label: { Label("New Transaction", systemImage: "plus") }
                        Button { showingAddAccount = true } label: { Label("New Account", systemImage: "creditcard.and.123") }
                        NavigationLink { ReimbursementView() } label: { Label("Reimbursements", systemImage: "arrow.triangle.2.circlepath") }
                        NavigationLink { DebtListView() } label: { Label("Debts & Loans", systemImage: "person.2.fill") }
                        NavigationLink { InstallmentListView() } label: { Label("Installments", systemImage: "calendar.badge.clock") }
                        Button { showingExport = true } label: { Label("Export Report", systemImage: "square.and.arrow.up") }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
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
            .sheet(isPresented: $showingExport) {
                ExportTransactionsView()
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
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                walletCarousel(viewModel)
                statsStrip(viewModel)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    PASectionHeader(title: "Recent Transactions").padding(.horizontal)
                    if viewModel.recentTransactions.isEmpty {
                        Text("No transactions yet")
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: AppTheme.Spacing.xs) {
                            ForEach(viewModel.recentTransactions.prefix(10)) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .padding(.horizontal, AppTheme.Spacing.md)
                                    .padding(.vertical, AppTheme.Spacing.xs)
                                    .background(AppTheme.Colors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                                    .padding(.horizontal)
                                    .contextMenu {
                                        Button(role: .destructive) { viewModel.deleteTransaction(transaction) } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private func walletCarousel(_ viewModel: FinanceViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(Array(viewModel.accounts.enumerated()), id: \.element.id) { index, account in
                    NavigationLink { AccountDetailView(account: account) } label: {
                        AccountCard(account: account, gradientIndex: index)
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                Button { showingAddAccount = true } label: {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                        Text("Add Account")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.Colors.accent)
                    .frame(width: 260, height: 160)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                            .strokeBorder(AppTheme.Colors.accent.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                    )
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
    }

    private func statsStrip(_ viewModel: FinanceViewModel) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            statPill(title: "Net Worth", amount: viewModel.netWorth, color: AppTheme.Colors.accent, icon: "chart.pie.fill")
            statPill(title: "Income", amount: viewModel.monthlyIncome, color: AppTheme.Colors.income, icon: "arrow.down.circle.fill")
            statPill(title: "Spend", amount: viewModel.monthlySpending, color: AppTheme.Colors.expense, icon: "arrow.up.circle.fill")
        }
        .padding(.horizontal)
        .overlay(alignment: .bottom) {
            if viewModel.pendingReimburseTotal > 0 {
                HStack {
                    Label("Pending Reimburse", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .medium)).foregroundStyle(AppTheme.Colors.reimburse)
                    Spacer()
                    Text(CurrencyFormatter.format(viewModel.pendingReimburseTotal))
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(AppTheme.Colors.reimburse)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.reimburse.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                .padding(.horizontal)
                .offset(y: 44)
            }
        }
        .padding(.bottom, viewModel.pendingReimburseTotal > 0 ? 44 : 0)
    }

    private func statPill(title: String, amount: Decimal, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.3)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            Text(CurrencyFormatter.format(amount))
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}

#Preview {
    FinanceView().environment(DependencyContainer.preview)
}
