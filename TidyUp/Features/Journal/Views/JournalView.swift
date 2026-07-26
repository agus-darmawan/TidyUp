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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.md) {
                            ForEach(viewModel.entries) { entry in
                                JournalCardView(
                                    entry: entry,
                                    thumbnail: entry.photoFilenames.first.flatMap { container.imageStorageService.loadImage(filename: $0) }
                                )
                                .contextMenu {
                                    Button(role: .destructive) { viewModel.delete(entry) } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditJournalView(entry: nil) { entry in viewModel?.save(entry) }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            if viewModel == nil { viewModel = JournalViewModel(repository: container.journalRepository) }
            viewModel?.load()
        }
    }
}
