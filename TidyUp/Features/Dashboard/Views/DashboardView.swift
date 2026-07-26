//
//  DashboardView.swift
//  TidyUp
//
//  Home tab — full layout rework: gradient hero header, quick actions
//  for jumping straight into adding a task/transaction/journal entry
//  without leaving Home, a stats overview, and "See All" links that
//  jump to the relevant tab via TabRouter.
//

import SwiftUI

struct DashboardView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(TabRouter.self) private var tabRouter
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: DashboardViewModel?
    @State private var showingAddTask = false
    @State private var showingAddTransaction = false
    @State private var showingAddJournal = false
    @State private var showingCalendar = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                        .transition(.opacity)
                } else {
                    ProgressView()
                }
            }
            .animation(AppTheme.Motion.snappy, value: viewModel == nil)
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $showingAddTask) {
                AddEditTaskView(task: nil) { task in
                    container.taskRepository.save(task)
                    viewModel?.load()
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddEditTransactionView(
                    transaction: nil,
                    accounts: (try? container.accountRepository.fetchAll()) ?? [],
                    categories: (try? container.transactionRepository.fetchCategories()) ?? []
                ) {
                    viewModel?.load()
                }
            }
            .sheet(isPresented: $showingAddJournal) {
                AddEditJournalView(entry: nil) { entry in
                    container.journalRepository.save(entry)
                    viewModel?.load()
                }
            }
            .sheet(isPresented: $showingCalendar) {
                NavigationStack { CalendarView() }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = DashboardViewModel(
                        taskRepository: container.taskRepository,
                        journalRepository: container.journalRepository,
                        accountRepository: container.accountRepository,
                        transactionRepository: container.transactionRepository,
                        wardrobeRepository: container.wardrobeRepository
                    )
                }
                viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private func content(_ viewModel: DashboardViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                heroHeader

                quickActions

                overviewSection(viewModel)
                tasksSection(viewModel)
                journalSection(viewModel)
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    // MARK: - Hero header

    private var heroHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            MascotAvatarView(size: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text("TidyUp")
                    .font(AppTheme.Typography.display)
                    .foregroundStyle(.white)
                Text(Date.now.formatted(.full))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }
            Spacer()
            Button {} label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.18))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, 76)
        .padding(.bottom, AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.walletGradient(for: 0))
        .overlay(colorScheme == .dark ? Color.black.opacity(0.18) : Color.clear)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: AppTheme.Radius.xl, bottomTrailingRadius: AppTheme.Radius.xl))
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            quickActionButton(icon: "checklist", label: "Task", color: AppTheme.Colors.accent) { showingAddTask = true }
            quickActionButton(icon: "banknote.fill", label: "Expense", color: AppTheme.Colors.success) { showingAddTransaction = true }
            quickActionButton(icon: "book.closed.fill", label: "Journal", color: AppTheme.Colors.reimburse) { showingAddJournal = true }
            quickActionButton(icon: "calendar", label: "Calendar", color: AppTheme.Colors.warning) { showingCalendar = true }
        }
        .padding(.horizontal)
    }

    private func quickActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 52, height: 52)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Sections

    private func overviewSection(_ viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionLabel("Today Overview")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.md) {
                DashboardSummaryCard(
                    icon: "checklist", title: "Tasks Left",
                    value: "\(viewModel.todayTasks.count - viewModel.completedTodayCount)",
                    tint: .cream
                )
                DashboardSummaryCard(
                    icon: "banknote.fill", title: "Spent Today",
                    value: CurrencyFormatter.format(viewModel.todaySpending),
                    tint: .mint
                )
                DashboardSummaryCard(
                    icon: "tshirt.fill", title: "Laundry",
                    value: "\(viewModel.dirtyClothingCount) dirty",
                    tint: .coral
                )
                DashboardSummaryCard(
                    icon: "wallet.pass.fill", title: "Net Worth",
                    value: CurrencyFormatter.format(viewModel.netWorth),
                    tint: .neutral
                )
            }
        }
        .padding(.horizontal)
    }

    private func tasksSection(_ viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                sectionLabel("Today's Tasks")
                Spacer()
                if !viewModel.todayTasks.isEmpty {
                    Button("See All") { tabRouter.go(to: .tasks) }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
            .padding(.horizontal)

            if viewModel.todayTasks.isEmpty {
                Text("Nothing due today 🎉")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .padding(.horizontal)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(viewModel.todayTasks.prefix(4)) { task in
                        TaskRowView(task: task) {}
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func journalSection(_ viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                sectionLabel("Recent Journal")
                Spacer()
                if !viewModel.recentJournalEntries.isEmpty {
                    Button("See All") { tabRouter.go(to: .more) }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent)
                }
            }
            .padding(.horizontal)

            if viewModel.recentJournalEntries.isEmpty {
                Text("No journal entries yet")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(viewModel.recentJournalEntries) { entry in
                            JournalCardView(entry: entry)
                                .frame(width: 260)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.Colors.accent)
                .frame(width: 3, height: 14)
            Text(text.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }
}

#Preview {
    DashboardView()
        .environment(DependencyContainer.preview)
        .environment(TabRouter())
}
