//
//  AddEditInstallmentView.swift
//  TidyUp
//

import SwiftUI

struct AddEditInstallmentView: View {
    @Environment(\.dismiss) private var dismiss
    let accounts: [Account]
    let onSave: (Installment) -> Void

    @State private var itemName = ""
    @State private var totalAmountText = ""
    @State private var totalTermsText = "12"
    @State private var startDate = Date.now
    @State private var selectedAccount: Account?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item Name (e.g. iPhone 17)", text: $itemName)
                    TextField("Total Amount", text: $totalAmountText).keyboardType(.decimalPad)
                    TextField("Number of Terms (months)", text: $totalTermsText).keyboardType(.numberPad)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }

                Section("Account") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("None").tag(Account?.none)
                        ForEach(accounts) { Text($0.name).tag(Account?.some($0)) }
                    }
                } footer: {
                    Text("Recording a payment will reduce this account's outstanding balance.")
                }

                if let amount = Decimal(string: totalAmountText), let terms = Int(totalTermsText), terms > 0 {
                    Section {
                        LabeledContent("Monthly Payment", value: CurrencyFormatter.format(amount / Decimal(terms)))
                    }
                }
            }
            .navigationTitle("New Installment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(itemName.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: totalAmountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: totalAmountText), let terms = Int(totalTermsText) else { return }
        let installment = Installment(itemName: itemName, totalAmount: amount, totalTerms: terms, startDate: startDate)
        installment.account = selectedAccount
        onSave(installment)
        dismiss()
    }
}
