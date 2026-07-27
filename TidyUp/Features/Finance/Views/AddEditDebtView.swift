//
//  AddEditDebtView.swift
//  TidyUp
//

import SwiftUI

struct AddEditDebtView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Debt) -> Void

    @State private var counterpartyName = ""
    @State private var direction: DebtDirection = .iOwe
    @State private var amountText = ""
    @State private var note = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date.now

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Direction", selection: $direction) {
                        ForEach(DebtDirection.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    TextField("Person's Name", text: $counterpartyName)
                    TextField("Amount", text: $amountText).keyboardType(.decimalPad)
                }

                Section("Details") {
                    TextField("Note", text: $note)
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Debt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(counterpartyName.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: amountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        let debt = Debt(
            counterpartyName: counterpartyName,
            direction: direction,
            originalAmount: amount,
            note: note,
            dueDate: hasDueDate ? dueDate : nil
        )
        onSave(debt)
        dismiss()
    }
}
