//
//  Account.swift
//  TidyUp
//

import Foundation
import SwiftData

enum AccountType: String, Codable, CaseIterable, Identifiable {
    case bank, eWallet, cash, creditCard, payLater
    var id: String { rawValue }

    var label: String {
        switch self {
        case .bank: "Bank"
        case .eWallet: "E-Wallet"
        case .cash: "Cash"
        case .creditCard: "Credit Card"
        case .payLater: "Pay Later"
        }
    }

    var icon: String {
        switch self {
        case .bank: "building.columns.fill"
        case .eWallet: "wallet.pass.fill"
        case .cash: "banknote.fill"
        case .creditCard: "creditcard.fill"
        case .payLater: "clock.arrow.circlepath"
        }
    }

    var isCredit: Bool { self == .creditCard || self == .payLater }

    /// E-wallets (and credit/pay-later, which are already debt-style) can
    /// go negative — think GoPay PayLater. Bank and cash can't realistically
    /// go below zero, so those get a confirmation warning instead.
    var allowsNegativeBalance: Bool {
        self == .eWallet || isCredit
    }
}

@Model
final class Account {
    var id: UUID
    var name: String
    var typeRaw: String
    var balance: Decimal
    var creditLimit: Decimal?
    var isArchived: Bool
    var createdAt: Date

    init(id: UUID = UUID(), name: String, type: AccountType, balance: Decimal = 0, creditLimit: Decimal? = nil) {
        self.id = id
        self.name = name
        self.typeRaw = type.rawValue
        self.balance = balance
        self.creditLimit = creditLimit
        self.isArchived = false
        self.createdAt = .now
    }

    var type: AccountType {
        get { AccountType(rawValue: typeRaw) ?? .cash }
        set { typeRaw = newValue.rawValue }
    }

    var availableCredit: Decimal? {
        guard let creditLimit else { return nil }
        return creditLimit - balance
    }
}
