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
        reimbursements.filter { $0.reimburseStatus != .paid && $0.reimburseStatus != .rejected }.reduce(Decimal(0)) { $0 + $1.amount }
    }

    /// Only transactions with both mandatory photos, and that haven't been
    /// rejected, can go into a submittable report.
    var reportReadyTransactions: [Transaction] {
        reimbursements.filter { $0.hasRequiredReimbursementProof && $0.reimburseStatus != .rejected }
    }

    var missingProofCount: Int {
        reimbursements.filter { $0.reimburseStatus != .rejected }.count - reportReadyTransactions.count
    }

    func markPaid(_ transaction: Transaction, creditTo account: Account) {
        transactionRepository.markReimbursementPaid(transaction, creditTo: account)
        load()
    }

    /// Pending → Submitted (claim sent to the office, awaiting outcome).
    func markSubmitted(_ transaction: Transaction) {
        transactionRepository.markReimbursementSubmitted(transaction)
        load()
    }

    /// Rejected by the office — it's excluded from the pending total and
    /// the PDF report from now on, and effectively becomes a personal
    /// expense (the balance already reflects this; nothing else changes).
    func markRejected(_ transaction: Transaction) {
        transactionRepository.markReimbursementRejected(transaction)
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
