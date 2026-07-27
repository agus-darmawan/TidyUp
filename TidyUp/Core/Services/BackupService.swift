//
//  BackupService.swift
//  TidyUp
//
//  Exports everything (Tasks, Wardrobe, Journal, Money, Calendar — plus
//  every referenced photo) into a single self-contained JSON file, and
//  can restore from one. This is the "if something gets deleted, I have
//  a backup" safety net — fully local, no cloud involved.
//

import Foundation
import SwiftData

@MainActor
final class BackupService {
    private let context: ModelContext
    private let imageStorageService: ImageStorageService

    init(context: ModelContext, imageStorageService: ImageStorageService) {
        self.context = context
        self.imageStorageService = imageStorageService
    }

    // MARK: - Export

    func exportBackup() throws -> URL {
        let accounts = try context.fetch(FetchDescriptor<Account>())
        let categories = try context.fetch(FetchDescriptor<TransactionCategory>())
        let debts = try context.fetch(FetchDescriptor<Debt>())
        let installments = try context.fetch(FetchDescriptor<Installment>())
        let tasks = try context.fetch(FetchDescriptor<TaskItem>())
        let clothingItems = try context.fetch(FetchDescriptor<ClothingItem>())
        let journalEntries = try context.fetch(FetchDescriptor<JournalEntry>())
        let scheduleEvents = try context.fetch(FetchDescriptor<ScheduleEvent>())
        let transactions = try context.fetch(FetchDescriptor<Transaction>())

        var images: [String: Data] = [:]
        func collect(_ filename: String?) {
            guard let filename, images[filename] == nil else { return }
            if let data = imageStorageService.loadRawData(filename: filename) {
                images[filename] = data
            }
        }
        clothingItems.forEach { collect($0.photoFilename) }
        journalEntries.forEach { entry in entry.photoFilenames.forEach { collect($0) } }
        transactions.forEach { collect($0.receiptImageFilename); collect($0.itemImageFilename) }

        let payload = BackupPayload(
            accounts: accounts.map {
                AccountBackup(id: $0.id, name: $0.name, type: $0.typeRaw, balance: $0.balance, creditLimit: $0.creditLimit, isArchived: $0.isArchived, createdAt: $0.createdAt)
            },
            categories: categories.map {
                CategoryBackup(id: $0.id, name: $0.name, icon: $0.icon, isDefault: $0.isDefault)
            },
            debts: debts.map {
                DebtBackup(id: $0.id, counterpartyName: $0.counterpartyName, direction: $0.directionRaw, originalAmount: $0.originalAmount, remainingAmount: $0.remainingAmount, note: $0.note, dueDate: $0.dueDate, isSettled: $0.isSettled, createdAt: $0.createdAt)
            },
            installments: installments.map {
                InstallmentBackup(id: $0.id, itemName: $0.itemName, totalAmount: $0.totalAmount, totalTerms: $0.totalTerms, paidTerms: $0.paidTerms, startDate: $0.startDate, accountID: $0.account?.id, createdAt: $0.createdAt)
            },
            tasks: tasks.map { task in
                TaskBackup(
                    id: task.id, title: task.title, notes: task.notes, isDone: task.isDone, createdAt: task.createdAt,
                    dueDate: task.dueDate, hasReminder: task.hasReminder, priority: task.priorityRaw, tags: task.tags,
                    recurrence: task.recurrenceRaw, recurrenceParentID: task.recurrenceParentID,
                    subtasks: task.subtasks.map { SubTaskBackup(id: $0.id, title: $0.title, isDone: $0.isDone, order: $0.order) }
                )
            },
            clothingItems: clothingItems.map {
                ClothingItemBackup(
                    itemCode: $0.itemCode, id: $0.id, name: $0.name, category: $0.categoryRaw, brand: $0.brand, color: $0.color,
                    notes: $0.notes, photoFilename: $0.photoFilename, purchaseDate: $0.purchaseDate, createdAt: $0.createdAt,
                    laundryStatus: $0.laundryStatusRaw, lastWornDate: $0.lastWornDate, lastWashedDate: $0.lastWashedDate,
                    washStartedDate: $0.washStartedDate, wearCountSinceWash: $0.wearCountSinceWash,
                    usageDurationDays: $0.usageDurationDays, wearCycleStartDate: $0.wearCycleStartDate
                )
            },
            journalEntries: journalEntries.map {
                JournalEntryBackup(id: $0.id, date: $0.date, mood: $0.moodRaw, reflection: $0.reflection, tags: $0.tags, photoFilenames: $0.photoFilenames, createdAt: $0.createdAt)
            },
            scheduleEvents: scheduleEvents.map {
                ScheduleEventBackup(id: $0.id, title: $0.title, startDate: $0.startDate, endDate: $0.endDate, note: $0.note, colorTag: $0.colorTag, createdAt: $0.createdAt)
            },
            transactions: transactions.map {
                TransactionBackup(
                    id: $0.id, date: $0.date, amount: $0.amount, type: $0.typeRaw, note: $0.note,
                    fromAccountID: $0.fromAccount?.id, toAccountID: $0.toAccount?.id, categoryID: $0.category?.id,
                    isReimbursable: $0.isReimbursable, reimburseStatus: $0.reimburseStatusRaw,
                    receiptImageFilename: $0.receiptImageFilename, itemImageFilename: $0.itemImageFilename,
                    isRecurring: $0.isRecurring, recurrenceFrequency: $0.recurrenceFrequencyRaw,
                    nextOccurrenceDate: $0.nextOccurrenceDate, linkedDebtID: $0.linkedDebtID, createdAt: $0.createdAt
                )
            },
            images: images
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)

        let filename = "TidyUp-Backup-\(Int(Date.now.timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Import (replaces all existing data)

    func importBackup(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(BackupPayload.self, from: data)

        try deleteAll(Transaction.self)
        try deleteAll(Installment.self)
        try deleteAll(TaskItem.self) // cascades to SubTask
        try deleteAll(ClothingItem.self)
        try deleteAll(JournalEntry.self)
        try deleteAll(ScheduleEvent.self)
        try deleteAll(Debt.self)
        try deleteAll(TransactionCategory.self)
        try deleteAll(Account.self)

        for (filename, imageData) in payload.images {
            imageStorageService.restoreRawData(imageData, filename: filename)
        }

        var accountsByID: [UUID: Account] = [:]
        for dto in payload.accounts {
            let account = Account(id: dto.id, name: dto.name, type: AccountType(rawValue: dto.type) ?? .cash, balance: dto.balance, creditLimit: dto.creditLimit)
            account.isArchived = dto.isArchived
            account.createdAt = dto.createdAt
            context.insert(account)
            accountsByID[dto.id] = account
        }

        var categoriesByID: [UUID: TransactionCategory] = [:]
        for dto in payload.categories {
            let category = TransactionCategory(id: dto.id, name: dto.name, icon: dto.icon, isDefault: dto.isDefault)
            context.insert(category)
            categoriesByID[dto.id] = category
        }

        for dto in payload.debts {
            let debt = Debt(id: dto.id, counterpartyName: dto.counterpartyName, direction: DebtDirection(rawValue: dto.direction) ?? .iOwe, originalAmount: dto.originalAmount, note: dto.note, dueDate: dto.dueDate)
            debt.remainingAmount = dto.remainingAmount
            debt.isSettled = dto.isSettled
            debt.createdAt = dto.createdAt
            context.insert(debt)
        }

        for dto in payload.installments {
            let installment = Installment(id: dto.id, itemName: dto.itemName, totalAmount: dto.totalAmount, totalTerms: dto.totalTerms, paidTerms: dto.paidTerms, startDate: dto.startDate)
            installment.account = dto.accountID.flatMap { accountsByID[$0] }
            installment.createdAt = dto.createdAt
            context.insert(installment)
        }

        for dto in payload.tasks {
            let task = TaskItem(
                id: dto.id, title: dto.title, notes: dto.notes, isDone: dto.isDone, dueDate: dto.dueDate,
                hasReminder: dto.hasReminder, priority: TaskPriority(rawValue: dto.priority) ?? .medium,
                tags: dto.tags, recurrence: RecurrenceFrequency(rawValue: dto.recurrence) ?? .none,
                recurrenceParentID: dto.recurrenceParentID
            )
            task.createdAt = dto.createdAt
            task.subtasks = dto.subtasks.map { subDTO in
                let sub = SubTask(id: subDTO.id, title: subDTO.title, isDone: subDTO.isDone, order: subDTO.order)
                sub.parentTask = task
                return sub
            }
            context.insert(task)
        }

        for dto in payload.clothingItems {
            let item = ClothingItem(
                id: dto.id, itemCode: dto.itemCode, name: dto.name, category: ClothingCategory(rawValue: dto.category) ?? .others,
                brand: dto.brand, color: dto.color, notes: dto.notes, photoFilename: dto.photoFilename,
                purchaseDate: dto.purchaseDate, usageDurationDays: dto.usageDurationDays
            )
            item.createdAt = dto.createdAt
            item.laundryStatusRaw = dto.laundryStatus
            item.lastWornDate = dto.lastWornDate
            item.lastWashedDate = dto.lastWashedDate
            item.washStartedDate = dto.washStartedDate
            item.wearCountSinceWash = dto.wearCountSinceWash
            item.wearCycleStartDate = dto.wearCycleStartDate
            context.insert(item)
        }

        for dto in payload.journalEntries {
            let entry = JournalEntry(id: dto.id, date: dto.date, mood: MoodType(rawValue: dto.mood) ?? .neutral, reflection: dto.reflection, tags: dto.tags, photoFilenames: dto.photoFilenames)
            entry.createdAt = dto.createdAt
            context.insert(entry)
        }

        for dto in payload.scheduleEvents {
            let event = ScheduleEvent(id: dto.id, title: dto.title, startDate: dto.startDate, endDate: dto.endDate, note: dto.note, colorTag: dto.colorTag)
            event.createdAt = dto.createdAt
            context.insert(event)
        }

        for dto in payload.transactions {
            let transaction = Transaction(
                id: dto.id, date: dto.date, amount: dto.amount, type: TransactionType(rawValue: dto.type) ?? .expense, note: dto.note,
                fromAccount: dto.fromAccountID.flatMap { accountsByID[$0] },
                toAccount: dto.toAccountID.flatMap { accountsByID[$0] },
                category: dto.categoryID.flatMap { categoriesByID[$0] },
                isReimbursable: dto.isReimbursable, reimburseStatus: ReimburseStatus(rawValue: dto.reimburseStatus) ?? .pending,
                receiptImageFilename: dto.receiptImageFilename, itemImageFilename: dto.itemImageFilename,
                isRecurring: dto.isRecurring, recurrenceFrequency: RecurrenceFrequency(rawValue: dto.recurrenceFrequency) ?? .none,
                nextOccurrenceDate: dto.nextOccurrenceDate
            )
            transaction.linkedDebtID = dto.linkedDebtID
            transaction.createdAt = dto.createdAt
            context.insert(transaction)
        }

        try context.save()
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let all = try context.fetch(FetchDescriptor<T>())
        for item in all { context.delete(item) }
    }
}
