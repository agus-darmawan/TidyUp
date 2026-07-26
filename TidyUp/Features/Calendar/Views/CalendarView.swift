//
//  CalendarView.swift
//  TidyUp
//
//  A real calendar: month grid you can page through, tap any day to see
//  its agenda below (with times/duration). This is deliberately a
//  different, fuller layout than the small week-strip widget on Home.
//

import SwiftUI

struct CalendarView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: CalendarViewModel?
    @State private var showingAddEvent = false

    private let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.large)
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
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                monthGrid(viewModel)
                    .padding()
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(viewModel.selectedDate.isToday ? "Today" : viewModel.selectedDate.formatted(.medium))
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
            }
            .padding(.vertical)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private func monthGrid(_ viewModel: CalendarViewModel) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Button { viewModel.goToPreviousMonth() } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(viewModel.monthAnchor.formatted(.monthYear))
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button { viewModel.goToNextMonth() } label: { Image(systemName: "chevron.right") }
            }
            .foregroundStyle(AppTheme.Colors.primaryText)

            HStack {
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    Text(weekdaySymbols[index])
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(viewModel.daysGrid.indices, id: \.self) { index in
                    let date = viewModel.daysGrid[index]
                    CalendarMonthGridCell(
                        date: date,
                        isSelected: date.map { viewModel.selectedDate.isSameDay(as: $0) } ?? false,
                        hasEvents: date.map(viewModel.hasEvents(on:)) ?? false
                    ) {
                        if let date { viewModel.selectDate(date) }
                    }
                }
            }
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
