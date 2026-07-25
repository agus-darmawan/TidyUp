//
//  AddEditAccountView.swift
//  TidyUp
//

import SwiftUI

struct AddEditAccountView: View {
    @Environment(\.dismiss) private var dismiss

    let existingAccount: Account?
    let onSave: (Account) -> Void

    @State private var name: String
    @State private var type: AccountType
    @State private var balanceText: String
    @State private var hasCreditLimit: Bool
    @State private var creditLimitText: String

    init(account: Account?, onSave: @escaping (Account) -> Void) {
        self.existingAccount = account
        self.onSave = onSave
        _name = State(initialValue: account?.name ?? "")
        _type = State(initialValue: account?.type ?? .bank)
        _balanceText = State(initialValue: account.map { "\($0.balance)" } ?? "0")
        _hasCreditLimit = State(initialValue: account?.creditLimit != nil)
        _creditLimitText = State(initialValue: account?.creditLimit.map { "\($0)" } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Account Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(AccountType.allCases) { Label($0.label, systemImage: $0.icon).tag($0) }
                    }
                }
                Section(type.isCredit ? "Current Owed" : "Starting Balance") {
                    TextField("Balance", text: $balanceText).keyboardType(.decimalPad)
                }
                if type.isCredit {
                    Section("Credit Limit") {
                        Toggle("Set credit limit", isOn: $hasCreditLimit)
                        if hasCreditLimit {
                            TextField("Limit", text: $creditLimitText).keyboardType(.decimalPad)
                        }
                    }
                }
            }
            .navigationTitle(existingAccount == nil ? "New Account" : "Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let account = existingAccount ?? Account(name: name, type: type)
        account.name = name
        account.type = type
        account.balance = Decimal(string: balanceText) ?? 0
        account.creditLimit = (type.isCredit && hasCreditLimit) ? Decimal(string: creditLimitText) : nil
        onSave(account)
        dismiss()
    }
}
