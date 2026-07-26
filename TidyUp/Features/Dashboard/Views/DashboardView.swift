//
//  DashboardView.swift
//  TidyUp
//
//  Home tab — leads with Tasks and Money (the two main features), plus
//  a quick Wardrobe laundry stat and recent journal preview. Calendar is
//  intentionally not featured here since it's a secondary module.
//

import SwiftUI

struct DashboardView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                }
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
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
                header

                overviewSection(viewModel)
                tasksSection(viewModel)
                journalSection(viewModel)
            }
            .padding(.horizontal)
            .padding(.top, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private var header: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            MascotAvatarView(size: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text("TidyUp")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                Text("Your day, tidied up.")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            Spacer()
            Button {} label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.Colors.accent.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .padding(.bottom, AppTheme.Spacing.xs)
    }

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
    }

    private func tasksSection(_ viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionLabel("Today's Tasks")
            if viewModel.todayTasks.isEmpty {
                Text("Nothing due today 🎉")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(viewModel.todayTasks.prefix(5)) { task in
                        TaskRowView(task: task) {}
                    }
                }
            }
        }
    }

    private func journalSection(_ viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            sectionLabel("Recent Journal")
            if viewModel.recentJournalEntries.isEmpty {
                Text("No journal entries yet")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            } else {
                ForEach(viewModel.recentJournalEntries) { entry in
                    JournalCardView(entry: entry)
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
    DashboardView().environment(DependencyContainer.preview)
}
