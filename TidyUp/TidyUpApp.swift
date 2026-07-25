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
            JournalEntry.self
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
                }
        }
    }
}
