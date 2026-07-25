//
//  CalendarView.swift
//  TidyUp
//
//  Simple upcoming-events agenda — Calendar is secondary here, so this
//  intentionally stays lighter than a full month-grid picker.
//

import SwiftUI

struct CalendarView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: CalendarViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.upcomingEvents.isEmpty {
                    PAEmptyState(systemImage: "calendar", title: "Nothing upcoming", message: "Tasks, bills, and journal entries with dates show up here.")
                } else {
                    List {
                        ForEach(viewModel.upcomingEvents) { event in
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: event.kind.icon).foregroundStyle(event.kind.color).frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title).font(.system(size: 14))
                                    Text(event.date.formatted(.dayMonth)).font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Calendar")
        .onAppear {
            if viewModel == nil {
                viewModel = CalendarViewModel(
                    taskRepository: container.taskRepository,
                    journalRepository: container.journalRepository,
                    transactionRepository: container.transactionRepository
                )
            }
            viewModel?.load()
        }
    }
}
