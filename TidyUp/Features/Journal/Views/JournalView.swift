//
//  JournalView.swift
//  TidyUp
//

import SwiftUI

struct JournalView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: JournalViewModel?
    @State private var showingAdd = false

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.entries.isEmpty {
                    PAEmptyState(systemImage: "book.closed", title: "No journal entries yet", message: "Reflect on your day.", actionTitle: "New Entry") {
                        showingAdd = true
                    }
                } else {
                    List {
                        ForEach(viewModel.entries) { entry in
                            JournalCardView(entry: entry).listRowSeparator(.hidden)
                        }
                        .onDelete { indexSet in
                            for index in indexSet { viewModel.delete(viewModel.entries[index]) }
                        }
                    }
                    .listStyle(.plain)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Journal")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditJournalView(entry: nil) { entry in viewModel?.save(entry) }
        }
        .onAppear {
            if viewModel == nil { viewModel = JournalViewModel(repository: container.journalRepository) }
            viewModel?.load()
        }
    }
}
