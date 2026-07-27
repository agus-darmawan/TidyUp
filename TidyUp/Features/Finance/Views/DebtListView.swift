//
//  DebtListView.swift
//  TidyUp
//
//  Debts and loans, tracked separately from the regular transaction
//  ledger so "who owes what" doesn't get lost among everyday spending.
//

import SwiftUI

struct DebtListView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: DebtListViewModel?
    @State private var showingAdd = false
    @State private var payingDebt: Debt?
    @State private var paymentAmountText = ""

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Debts & Loans")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditDebtView { debt in viewModel?.save(debt) }
        }
        .alert("Record Payment", isPresented: Binding(
            get: { payingDebt != nil },
            set: { if !$0 { payingDebt = nil; paymentAmountText = "" } }
        )) {
            TextField("Amount", text: $paymentAmountText).keyboardType(.decimalPad)
            Button("Save") {
                if let debt = payingDebt, let amount = Decimal(string: paymentAmountText) {
                    viewModel?.applyPayment(debt, amount: amount)
                }
                paymentAmountText = ""
            }
            Button("Cancel", role: .cancel) { paymentAmountText = "" }
        }
        .onAppear {
            if viewModel == nil { viewModel = DebtListViewModel(repository: container.debtRepository) }
            viewModel?.load()
        }
    }

    @ViewBuilder
    private func content(_ viewModel: DebtListViewModel) -> some View {
        if viewModel.debts.isEmpty {
            PAEmptyState(systemImage: "person.2.fill", title: "No debts tracked", message: "Track money you owe or that's owed to you.", actionTitle: "Add Debt") {
                showingAdd = true
            }
        } else {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("I Owe").font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                            Text(CurrencyFormatter.format(viewModel.totalIOwe)).font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.Colors.danger)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Owed To Me").font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                            Text(CurrencyFormatter.format(viewModel.totalOwedToMe)).font(.system(size: 16, weight: .bold)).foregroundStyle(AppTheme.Colors.success)
                        }
                    }
                }

                if !viewModel.activeDebts.isEmpty {
                    Section("Active") {
                        ForEach(viewModel.activeDebts) { debt in
                            DebtRowView(debt: debt)
                                .swipeActions {
                                    Button("Pay") { payingDebt = debt }.tint(AppTheme.Colors.success)
                                    Button(role: .destructive) { viewModel.delete(debt) } label: { Label("Delete", systemImage: "trash") }
                                }
                        }
                    }
                }

                if !viewModel.settledDebts.isEmpty {
                    Section("Settled") {
                        ForEach(viewModel.settledDebts) { debt in
                            DebtRowView(debt: debt).opacity(0.5)
                                .swipeActions {
                                    Button(role: .destructive) { viewModel.delete(debt) } label: { Label("Delete", systemImage: "trash") }
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack { DebtListView() }.environment(DependencyContainer.preview)
}
