//
//  ReimbursementViewModel.swift
//  TidyUp
//
//  Drives the full reimbursement flow: list + filter by status, mark
//  paid (credits an account), and export a submittable PDF report of
//  everything that has both required photos attached.
//

import Foundation
import Observation

@Observable
final class ReimbursementViewModel {
    private let transactionRepository: TransactionRepositoryProtocol
    private let pdfExportService: PDFExportService

    var reimbursements: [Transaction] = []
    var filterStatus: ReimburseStatus?
    var lastExportedURL: URL?
    var errorMessage: String?

    init(transactionRepository: TransactionRepositoryProtocol, pdfExportService: PDFExportService) {
        self.transactionRepository = transactionRepository
        self.pdfExportService = pdfExportService
    }

    func load() {
        reimbursements = (try? transactionRepository.fetchReimbursable(status: filterStatus)) ?? []
    }

    var totalPending: Decimal {
        reimbursements.filter { $0.reimburseStatus != .paid }.reduce(Decimal(0)) { $0 + $1.amount }
    }

    /// Only transactions with both mandatory photos can go into a submittable report.
    var reportReadyTransactions: [Transaction] {
        reimbursements.filter(\.hasRequiredReimbursementProof)
    }

    var missingProofCount: Int {
        reimbursements.count - reportReadyTransactions.count
    }

    func markPaid(_ transaction: Transaction, creditTo account: Account) {
        transactionRepository.markReimbursementPaid(transaction, creditTo: account)
        load()
    }

    func exportPDF() {
        do {
            lastExportedURL = try pdfExportService.generateReimbursementReport(
                title: "Reimbursement Report",
                transactions: reportReadyTransactions
            )
        } catch {
            errorMessage = "Failed to generate PDF: \(error.localizedDescription)"
        }
    }
}
