//
//  ReimbursementReportView.swift
//  TidyUp
//

import SwiftUI

struct ReimbursementReportView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ReimbursementViewModel?
    @State private var showingShareSheet = false

    var body: some View {
        Group {
            if let viewModel {
                List {
                    Section {
                        LabeledContent("Total Pending", value: CurrencyFormatter.format(viewModel.totalPending))
                        LabeledContent("Ready to Export", value: "\(viewModel.reportReadyTransactions.count) items")
                        if viewModel.missingProofCount > 0 {
                            Label("\(viewModel.missingProofCount) item(s) missing required photos", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppTheme.Colors.danger)
                                .font(.system(size: 12))
                        }
                    }
                    Section("Included in Report") {
                        ForEach(viewModel.reportReadyTransactions) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                }

                PAPrimaryButton(title: "Export PDF Report", systemImage: "square.and.arrow.up") {
                    viewModel.exportPDF()
                    if viewModel.lastExportedURL != nil { showingShareSheet = true }
                }
                .padding()
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Export Report")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let url = viewModel?.lastExportedURL {
                ShareSheet(activityItems: [url])
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ReimbursementViewModel(
                    transactionRepository: container.transactionRepository,
                    pdfExportService: container.pdfExportService
                )
            }
            viewModel?.load()
        }
    }
}

/// Thin UIKit share sheet bridge for exporting the generated PDF.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
