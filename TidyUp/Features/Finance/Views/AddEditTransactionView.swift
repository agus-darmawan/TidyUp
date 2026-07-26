//
//  AddEditTransactionView.swift
//  TidyUp
//
//  "Reimbursement" is its own Type option — no separate toggle needed.
//  Picking that type automatically requires a receipt photo AND an item
//  photo before the transaction can be saved.
//

import SwiftUI
import PhotosUI

struct AddEditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container

    let existingTransaction: Transaction?
    let accounts: [Account]
    @State private var categories: [TransactionCategory]
    let onSaved: () -> Void

    @State private var type: TransactionType
    @State private var amountText: String
    @State private var note: String
    @State private var date: Date
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    @State private var category: TransactionCategory?

    @State private var receiptImage: UIImage?
    @State private var itemImage: UIImage?
    @State private var receiptPickerItem: PhotosPickerItem?
    @State private var itemPickerItem: PhotosPickerItem?

    @State private var isRecurring: Bool
    @State private var recurrence: RecurrenceFrequency
    @State private var showingMissingPhotoAlert = false

    /// Reimbursement is a Type choice, not a separate flag.
    private var isReimbursement: Bool { type == .reimbursement }

    init(transaction: Transaction?, accounts: [Account], categories: [TransactionCategory], onSaved: @escaping () -> Void) {
        self.existingTransaction = transaction
        self.accounts = accounts
        self._categories = State(initialValue: categories)
        self.onSaved = onSaved
        _type = State(initialValue: transaction?.type ?? .expense)
        _amountText = State(initialValue: transaction.map { "\($0.amount)" } ?? "")
        _note = State(initialValue: transaction?.note ?? "")
        _date = State(initialValue: transaction?.date ?? .now)
        _fromAccount = State(initialValue: transaction?.fromAccount ?? accounts.first)
        _toAccount = State(initialValue: transaction?.toAccount)
        _category = State(initialValue: transaction?.category)
        _isRecurring = State(initialValue: transaction?.isRecurring ?? false)
        _recurrence = State(initialValue: transaction?.recurrenceFrequency ?? .monthly)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases) { Text($0.label).tag($0) }
                    }
                    TextField("Amount", text: $amountText).keyboardType(.decimalPad)
                    TextField("Note", text: $note)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Accounts") {
                    Picker("From Account", selection: $fromAccount) {
                        ForEach(accounts) { Text($0.name).tag(Account?.some($0)) }
                    }
                    if type == .transfer {
                        Picker("To Account", selection: $toAccount) {
                            Text("Select").tag(Account?.none)
                            ForEach(accounts) { Text($0.name).tag(Account?.some($0)) }
                        }
                    }
                }

                if type == .expense || isReimbursement {
                    CategoryPicker(categories: categories, selected: $category) { newName in
                        category = container.transactionRepository.addCategory(name: newName, icon: "tag.fill")
                        categories.append(category!)
                    }
                }

                if isReimbursement {
                    Section {
                        Text("Receipt and item photos are required for reimbursement.")
                            .font(.system(size: 12)).foregroundStyle(AppTheme.Colors.secondaryText)

                        PhotosPicker(selection: $receiptPickerItem, matching: .images) {
                            photoRow(title: "Receipt Photo", image: reimbursementReceiptPreview)
                        }
                        .onChange(of: receiptPickerItem) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    receiptImage = UIImage(data: data)
                                }
                            }
                        }

                        PhotosPicker(selection: $itemPickerItem, matching: .images) {
                            photoRow(title: "Item Photo", image: reimbursementItemPreview)
                        }
                        .onChange(of: itemPickerItem) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    itemImage = UIImage(data: data)
                                }
                            }
                        }
                    } header: {
                        Text("Reimbursement Proof")
                    }
                }

                Section("Recurring") {
                    Toggle("Recurring transaction", isOn: $isRecurring)
                    if isRecurring {
                        Picker("Frequency", selection: $recurrence) {
                            ForEach(RecurrenceFrequency.allCases.filter { $0 != .none }) { Text($0.label).tag($0) }
                        }
                    }
                }
            }
            .navigationTitle(existingTransaction == nil ? "New Transaction" : "Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { attemptSave() }.disabled(Decimal(string: amountText) == nil || fromAccount == nil)
                }
            }
            .alert("Missing Photos", isPresented: $showingMissingPhotoAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Reimbursement requires both a receipt photo and an item photo before saving.")
            }
        }
    }

    private var reimbursementReceiptPreview: UIImage? { receiptImage ?? existingReceiptImage }
    private var reimbursementItemPreview: UIImage? { itemImage ?? existingItemImage }
    private var existingReceiptImage: UIImage? {
        guard let filename = existingTransaction?.receiptImageFilename else { return nil }
        return container.imageStorageService.loadImage(filename: filename)
    }
    private var existingItemImage: UIImage? {
        guard let filename = existingTransaction?.itemImageFilename else { return nil }
        return container.imageStorageService.loadImage(filename: filename)
    }

    @ViewBuilder
    private func photoRow(title: String, image: UIImage?) -> some View {
        HStack {
            if let image {
                Image(uiImage: image).resizable().scaledToFill().frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
            } else {
                Image(systemName: "camera.fill").frame(width: 44, height: 44)
                    .background(AppTheme.Colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
            }
            Text(title)
        }
    }

    private func attemptSave() {
        guard let amount = Decimal(string: amountText), let fromAccount else { return }

        if isReimbursement {
            guard reimbursementReceiptPreview != nil, reimbursementItemPreview != nil else {
                showingMissingPhotoAlert = true
                return
            }
        }

        let transaction = existingTransaction ?? Transaction(amount: amount, type: type)
        let previousAmount = existingTransaction?.amount
        let previousType = existingTransaction?.type

        transaction.amount = amount
        transaction.type = type
        transaction.note = note
        transaction.date = date
        transaction.fromAccount = fromAccount
        transaction.toAccount = type == .transfer ? toAccount : nil
        transaction.category = category
        transaction.isReimbursable = isReimbursement
        transaction.isRecurring = isRecurring
        transaction.recurrenceFrequency = isRecurring ? recurrence : .none

        if isReimbursement {
            if let receiptImage { transaction.receiptImageFilename = try? container.imageStorageService.saveImage(receiptImage) }
            if let itemImage { transaction.itemImageFilename = try? container.imageStorageService.saveImage(itemImage) }
        }

        container.transactionRepository.save(transaction, previousAmount: previousAmount, previousType: previousType)
        onSaved()
        dismiss()
    }
}
