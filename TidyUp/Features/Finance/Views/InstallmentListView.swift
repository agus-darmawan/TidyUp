//
//  InstallmentListView.swift
//  TidyUp
//
//  Fixed-term installment plans (credit card / pay-later purchases),
//  with progress tracking and a linked account whose balance goes down
//  as payments are recorded.
//

import SwiftUI

struct InstallmentListView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: InstallmentListViewModel?
    @State private var showingAdd = false

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Installments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditInstallmentView(accounts: (try? container.accountRepository.fetchAll()) ?? []) { installment in
                viewModel?.save(installment)
            }
        }
        .onAppear {
            if viewModel == nil { viewModel = InstallmentListViewModel(repository: container.installmentRepository) }
            viewModel?.load()
        }
    }

    @ViewBuilder
    private func content(_ viewModel: InstallmentListViewModel) -> some View {
        if viewModel.installments.isEmpty {
            PAEmptyState(systemImage: "creditcard.and.123", title: "No installments", message: "Track fixed-term credit card or pay-later purchases.", actionTitle: "Add Installment") {
                showingAdd = true
            }
        } else {
            List {
                Section {
                    LabeledContent("Total Due Monthly", value: CurrencyFormatter.format(viewModel.totalMonthlyDue))
                }

                if !viewModel.active.isEmpty {
                    Section("Active") {
                        ForEach(viewModel.active) { installment in
                            InstallmentRowView(installment: installment)
                                .swipeActions {
                                    Button("Pay") { viewModel.recordPayment(installment) }.tint(AppTheme.Colors.success)
                                    Button(role: .destructive) { viewModel.delete(installment) } label: { Label("Delete", systemImage: "trash") }
                                }
                        }
                    }
                }

                if !viewModel.completed.isEmpty {
                    Section("Paid Off") {
                        ForEach(viewModel.completed) { installment in
                            InstallmentRowView(installment: installment).opacity(0.5)
                                .swipeActions {
                                    Button(role: .destructive) { viewModel.delete(installment) } label: { Label("Delete", systemImage: "trash") }
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
    NavigationStack { InstallmentListView() }.environment(DependencyContainer.preview)
}
