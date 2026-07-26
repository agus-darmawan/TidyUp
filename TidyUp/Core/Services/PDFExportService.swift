//
//  PDFExportService.swift
//  TidyUp
//
//  Generates a printable reimbursement report using PDFKit-style rendering
//  (UIGraphicsPDFRenderer). Every reimbursable transaction embeds its
//  receipt + item photo since that's what gets submitted to the office.
//

import Foundation
import UIKit

final class PDFExportService {
    private let imageStorageService: ImageStorageService
    private let pageSize = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 @ 72dpi

    init(imageStorageService: ImageStorageService) {
        self.imageStorageService = imageStorageService
    }

    /// General ledger export for a date range — compact one-line rows
    /// (no mandatory photos, unlike the reimbursement report), ending
    /// with income/expense totals for the period.
    func generateTransactionReport(title: String, rangeLabel: String, transactions: [Transaction]) throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        let filename = "\(title.replacingOccurrences(of: " ", with: "_"))-\(Int(Date.now.timeIntervalSince1970)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let data = renderer.pdfData { context in
            var y: CGFloat = 0
            context.beginPage()
            y = drawHeader(title: title, y: y)
            (rangeLabel as NSString).draw(
                at: CGPoint(x: 32, y: y),
                withAttributes: [.font: UIFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: UIColor.darkGray]
            )
            y += 20

            for transaction in transactions {
                if y > pageSize.height - 60 {
                    context.beginPage()
                    y = 40
                }
                let sign = transaction.type.balanceSign > 0 ? "+" : "-"
                let line = "\(transaction.date.formatted(.medium))  ·  \(transaction.note.isEmpty ? transaction.type.label : transaction.note)  ·  \(sign)\(CurrencyFormatter.format(transaction.amount))"
                (line as NSString).draw(
                    at: CGPoint(x: 32, y: y),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 11)]
                )
                y += 20
            }

            y += 12
            let income = transactions.filter { $0.type == .income }.reduce(Decimal(0)) { $0 + $1.amount }
            let expense = transactions.filter { $0.type == .expense || $0.type == .reimbursement }.reduce(Decimal(0)) { $0 + $1.amount }
            let summary = "Total Income: \(CurrencyFormatter.format(income))   ·   Total Expense: \(CurrencyFormatter.format(expense))"
            (summary as NSString).draw(
                at: CGPoint(x: 32, y: y),
                withAttributes: [.font: UIFont.boldSystemFont(ofSize: 12)]
            )
        }

        try data.write(to: url)
        return url
    }

    func generateReimbursementReport(title: String, transactions: [Transaction]) throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        let filename = "\(title.replacingOccurrences(of: " ", with: "_"))-\(Int(Date.now.timeIntervalSince1970)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let data = renderer.pdfData { context in
            var y: CGFloat = 0
            context.beginPage()
            y = drawHeader(title: title, y: y)

            for transaction in transactions {
                if y > pageSize.height - 220 {
                    context.beginPage()
                    y = 40
                }
                y = drawRow(transaction, y: y)
            }
            drawTotal(transactions, y: y)
        }

        try data.write(to: url)
        return url
    }

    private func drawHeader(title: String, y: CGFloat) -> CGFloat {
        var cursor = y + 32
        (title as NSString).draw(
            at: CGPoint(x: 32, y: cursor),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 20)]
        )
        cursor += 26
        let subtitle = "Generated \(Date.now.formatted(.medium)) · TidyUp"
        (subtitle as NSString).draw(
            at: CGPoint(x: 32, y: cursor),
            withAttributes: [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.gray]
        )
        return cursor + 24
    }

    private func drawRow(_ transaction: Transaction, y: CGFloat) -> CGFloat {
        var cursor = y + 12
        let line = "\(transaction.date.formatted(.medium))  ·  \(transaction.note)  ·  \(CurrencyFormatter.format(transaction.amount))"
        (line as NSString).draw(
            at: CGPoint(x: 32, y: cursor),
            withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]
        )
        cursor += 18

        var x: CGFloat = 32
        let size: CGFloat = 90
        if let filename = transaction.receiptImageFilename, let image = imageStorageService.loadImage(filename: filename) {
            image.draw(in: CGRect(x: x, y: cursor, width: size, height: size))
            x += size + 12
        }
        if let filename = transaction.itemImageFilename, let image = imageStorageService.loadImage(filename: filename) {
            image.draw(in: CGRect(x: x, y: cursor, width: size, height: size))
        }
        cursor += size + 16

        let divider = UIBezierPath()
        divider.move(to: CGPoint(x: 32, y: cursor))
        divider.addLine(to: CGPoint(x: pageSize.width - 32, y: cursor))
        UIColor.lightGray.setStroke()
        divider.stroke()
        return cursor + 10
    }

    private func drawTotal(_ transactions: [Transaction], y: CGFloat) {
        let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        let text = "Total: \(CurrencyFormatter.format(total))"
        (text as NSString).draw(
            at: CGPoint(x: 32, y: y + 16),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
    }
}
