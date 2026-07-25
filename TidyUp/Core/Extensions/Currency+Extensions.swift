//
//  Currency+Extensions.swift
//  TidyUp
//

import Foundation

enum CurrencyFormatter {
    static var currencyCode: String = "IDR"

    static func format(_ amount: Decimal, signed: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "id_ID")

        let value = NSDecimalNumber(decimal: amount)
        var result = formatter.string(from: value) ?? "\(amount)"
        if signed && amount > 0 { result = "+" + result }
        return result
    }
}
