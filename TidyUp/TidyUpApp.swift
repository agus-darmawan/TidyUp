//
//  TidyUpApp.swift
//  TidyUp
//
//  Fully offline — single local SwiftData store, no network, no auth.
//

import SwiftUI
import SwiftData

@main
struct TidyUpApp: App {
    let modelContainer: ModelContainer
    @State private var container: DependencyContainer

    init() {
        let schema = Schema([
            TaskItem.self, SubTask.self,
            ClothingItem.self,
            Account.self, Transaction.self, TransactionCategory.self, Debt.self, Installment.self,
            JournalEntry.self,
            ScheduleEvent.self
        ])

        let configuration = ModelConfiguration("TidyUpStore", schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }

        _container = State(initialValue: DependencyContainer(modelContext: modelContainer.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
                .modelContainer(modelContainer)
                .task {
                    await container.notificationService.requestAuthorizationIfNeeded()
                    container.seedDefaultsIfNeeded()
                    container.notificationService.scheduleDailyReminder(
                        id: DependencyContainer.journalReminderID,
                        title: "Time to reflect 📝",
                        body: "Don't forget to write in your journal before bed.",
                        hour: 23, minute: 0
                    )
                }
        }
    }
}
