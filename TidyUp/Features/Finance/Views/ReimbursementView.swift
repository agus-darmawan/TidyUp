//
//  ReimbursementView.swift
//  TidyUp
//
//  Full reimbursement flow: filter by status, see which items are
//  missing required proof, mark paid (credits an account), and jump
//  into the PDF export report.
//

import SwiftUI

struct ReimbursementView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ReimbursementViewModel?
    @State private var accounts: [Account] = []
    @State private var showingMarkPaidFor: Transaction?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Reimbursements")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Report") { ReimbursementReportView() }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ReimbursementViewModel(
                    transactionRepository: container.transactionRepository,
                    pdfExportService: container.pdfExportService
                )
            }
            accounts = (try? container.accountRepository.fetchAll()) ?? []
            viewModel?.load()
        }
    }

    @ViewBuilder
    private func content(_ viewModel: ReimbursementViewModel) -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            Picker("Status", selection: Binding(
                get: { viewModel.filterStatus },
                set: { viewModel.filterStatus = $0; viewModel.load() }
            )) {
                Text("All").tag(ReimburseStatus?.none)
                ForEach(ReimburseStatus.allCases) { Text($0.label).tag(ReimburseStatus?.some($0)) }
            }
            .pickerStyle(.segmented)
            .padding()

            if viewModel.reimbursements.isEmpty {
                PAEmptyState(
                    systemImage: "arrow.triangle.2.circlepath",
                    title: "No reimbursements",
                    message: "Mark an expense as reimbursable in Money to track it here."
                )
            } else {
                List {
                    ForEach(viewModel.reimbursements) { transaction in
                        VStack(alignment: .leading) {
                            TransactionRowView(transaction: transaction)
                            if !transaction.hasRequiredReimbursementProof {
                                Label("Missing receipt/item photo", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11)).foregroundStyle(AppTheme.Colors.danger)
                            }
                        }
                        .swipeActions {
                            if transaction.reimburseStatus != .paid && transaction.reimburseStatus != .rejected {
                                Button("Mark Paid") { showingMarkPaidFor = transaction }.tint(AppTheme.Colors.success)
                                Button("Reject", role: .destructive) { viewModel.markRejected(transaction) }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .confirmationDialog("Credit to which account?", isPresented: Binding(
            get: { showingMarkPaidFor != nil },
            set: { if !$0 { showingMarkPaidFor = nil } }
        )) {
            ForEach(accounts) { account in
                Button(account.name) {
                    if let transaction = showingMarkPaidFor { viewModel.markPaid(transaction, creditTo: account) }
                    showingMarkPaidFor = nil
                }
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}
