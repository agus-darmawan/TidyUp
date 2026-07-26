//
//  CalendarView.swift
//  TidyUp
//
//  Now actually functions like a real calendar: navigable week strip,
//  a selected-day schedule with start/end times and duration, and a
//  "+" button to add events directly here (Tasks with due dates still
//  show up too, whichever place you add them from).
//

import SwiftUI

struct CalendarView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: CalendarViewModel?
    @State private var showingAddEvent = false

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Calendar")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAddEvent = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddScheduleEventView(initialDate: viewModel?.selectedDate ?? .now) { event in
                viewModel?.addScheduleEvent(event)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            if viewModel == nil {
                viewModel = CalendarViewModel(
                    taskRepository: container.taskRepository,
                    journalRepository: container.journalRepository,
                    scheduleEventRepository: container.scheduleEventRepository
                )
            }
            viewModel?.load()
        }
    }

    @ViewBuilder
    private func content(_ viewModel: CalendarViewModel) -> some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                CalendarWeekStrip(
                    selected: $viewModel.selectedDate,
                    eventDates: Set(viewModel.upcomingEvents.map(\.date))
                )
                .padding()
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(viewModel.selectedDate.isToday ? "Today's Schedule" : viewModel.selectedDate.formatted(.medium))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .padding(.horizontal)

                    if viewModel.selectedDayEvents.isEmpty {
                        Text("Nothing scheduled")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(viewModel.selectedDayEvents) { event in
                                eventRow(event, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                if !viewModel.upcomingEvents.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Next Up")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .padding(.horizontal)

                        VStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(viewModel.upcomingEvents.filter { !$0.date.isSameDay(as: viewModel.selectedDate) }.prefix(8)) { event in
                                eventRow(event, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private func eventRow(_ event: CalendarEvent, viewModel: CalendarViewModel) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Circle().fill(event.kind.color).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title).font(.system(size: 14, weight: .medium))
                HStack(spacing: 6) {
                    Text(event.timeLabel).font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                    if case .schedule(let scheduleEvent) = event.kind {
                        Text("· \(scheduleEvent.durationLabel)")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
            }
            Spacer()
            Image(systemName: event.kind.icon)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .contextMenu {
            if case .schedule(let scheduleEvent) = event.kind {
                Button(role: .destructive) {
                    viewModel.deleteScheduleEvent(scheduleEvent)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
