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

    let imageStorageService: ImageStorageService
    let notificationService: NotificationService
    let pdfExportService: PDFExportService

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        self.imageStorageService = ImageStorageService()
        self.notificationService = NotificationService()

        self.taskRepository = TaskRepository(context: modelContext)
        self.wardrobeRepository = WardrobeRepository(context: modelContext)
        self.accountRepository = AccountRepository(context: modelContext)
        self.transactionRepository = TransactionRepository(context: modelContext, accountRepository: accountRepository)
        self.journalRepository = JournalRepository(context: modelContext)

        self.pdfExportService = PDFExportService(imageStorageService: imageStorageService)
    }

    func seedDefaultsIfNeeded() {
        transactionRepository.seedDefaultCategoriesIfNeeded()
    }

    @MainActor
    static var preview: DependencyContainer {
        let schema = Schema([
            TaskItem.self, SubTask.self,
            ClothingItem.self,
            Account.self, Transaction.self, TransactionCategory.self, Debt.self, Installment.self,
            JournalEntry.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let dependencyContainer = DependencyContainer(modelContext: container.mainContext)
        dependencyContainer.seedDefaultsIfNeeded()
        return dependencyContainer
    }
}
