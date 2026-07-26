//
//  ExportTransactionsView.swift
//  TidyUp
//
//  Export a PDF ledger of all transactions within a chosen date range.
//

import SwiftUI

struct ExportTransactionsView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    @State private var startDate: Date = Date.now.adding(days: -30)
    @State private var endDate: Date = .now
    @State private var lastExportedURL: URL?
    @State private var showingShareSheet = false
    @State private var errorMessage: String?

    private var transactionsInRange: [Transaction] {
        let all = (try? container.transactionRepository.fetchAll()) ?? []
        let start = startDate.startOfDay
        let end = endDate.endOfDay
        return all.filter { $0.date >= start && $0.date <= end }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date Range") {
                    DatePicker("From", selection: $startDate, in: ...endDate, displayedComponents: .date)
                    DatePicker("To", selection: $endDate, in: startDate...Date.now, displayedComponents: .date)
                }

                Section {
                    LabeledContent("Transactions Found", value: "\(transactionsInRange.count)")
                } footer: {
                    Text("Exports a PDF ledger listing every transaction in this range, with income/expense totals.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(AppTheme.Colors.danger)
                    }
                }
            }
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .safeAreaInset(edge: .bottom) {
                PAPrimaryButton(title: "Export PDF", systemImage: "square.and.arrow.up") {
                    exportPDF()
                }
                .padding()
                .disabled(transactionsInRange.isEmpty)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let lastExportedURL {
                    ShareSheet(activityItems: [lastExportedURL])
                }
            }
        }
    }

    private func exportPDF() {
        let rangeLabel = "\(startDate.formatted(.medium)) – \(endDate.formatted(.medium))"
        do {
            lastExportedURL = try container.pdfExportService.generateTransactionReport(
                title: "Transaction Report",
                rangeLabel: rangeLabel,
                transactions: transactionsInRange
            )
            showingShareSheet = true
        } catch {
            errorMessage = "Failed to generate PDF: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ExportTransactionsView().environment(DependencyContainer.preview)
}
