//
//  DependencyContainer.swift
//  TidyUp
//
//  Composition root. Built once in TidyUpApp and injected via
//  `.environment(container)`. ViewModels ask the container for the
//  repositories/services they need instead of constructing them.
//

import Foundation
import SwiftData
import Observation

@Observable
final class DependencyContainer {
    let modelContext: ModelContext

    let taskRepository: TaskRepository
    let wardrobeRepository: WardrobeRepository
    let accountRepository: AccountRepository
    let transactionRepository: TransactionRepository
    let journalRepository: JournalRepository
    let scheduleEventRepository: ScheduleEventRepository
    let debtRepository: DebtRepository
    let installmentRepository: InstallmentRepository

    let imageStorageService: ImageStorageService
    let notificationService: NotificationService
    let pdfExportService: PDFExportService
    let backupService: BackupService

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        self.imageStorageService = ImageStorageService()
        self.notificationService = NotificationService()

        self.taskRepository = TaskRepository(context: modelContext)
        self.wardrobeRepository = WardrobeRepository(context: modelContext)
        self.accountRepository = AccountRepository(context: modelContext)
        self.transactionRepository = TransactionRepository(context: modelContext, accountRepository: accountRepository)
        self.journalRepository = JournalRepository(context: modelContext)
        self.scheduleEventRepository = ScheduleEventRepository(context: modelContext)
        self.debtRepository = DebtRepository(context: modelContext)
        self.installmentRepository = InstallmentRepository(context: modelContext)

        self.pdfExportService = PDFExportService(imageStorageService: imageStorageService)
        self.backupService = BackupService(context: modelContext, imageStorageService: imageStorageService)
    }

    /// Fixed, stable ID for the daily journal reminder — scheduling with
    /// the same ID every launch replaces the old request instead of
    /// stacking duplicates.
    static let journalReminderID = UUID(uuidString: "5A6E7B90-0000-4000-8000-000000000001")!

    func seedDefaultsIfNeeded() {
        transactionRepository.seedDefaultCategoriesIfNeeded()
    }

    @MainActor
    static var preview: DependencyContainer {
        let schema = Schema([
            TaskItem.self, SubTask.self,
            ClothingItem.self,
            Account.self, Transaction.self, TransactionCategory.self, Debt.self, Installment.self,
            JournalEntry.self,
            ScheduleEvent.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let dependencyContainer = DependencyContainer(modelContext: container.mainContext)
        dependencyContainer.seedDefaultsIfNeeded()
        return dependencyContainer
    }
}
