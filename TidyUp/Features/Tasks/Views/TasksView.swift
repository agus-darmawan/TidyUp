//
//  TasksView.swift
//  TidyUp
//

import SwiftUI

struct TasksView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: TaskListViewModel?
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditTaskView(task: nil) { newTask in
                    viewModel?.save(newTask)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = TaskListViewModel(repository: container.taskRepository, notificationService: container.notificationService)
                }
                viewModel?.load()
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
        }
    }

    @ViewBuilder
    private func content(_ viewModel: TaskListViewModel) -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: AppTheme.Spacing.sm) {
            TaskFilterBar(selected: $viewModel.filter)
                .padding(.horizontal)

            if viewModel.filteredTasks.isEmpty {
                PAEmptyState(systemImage: "checklist", title: "No tasks here", message: "Tap + to add your first task.")
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(viewModel.filteredTasks) { task in
                            NavigationLink {
                                TaskDetailView(task: task)
                            } label: {
                                TaskRowView(task: task) { viewModel.toggleDone(task) }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
        }
        .padding(.top, AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .searchable(text: $viewModel.searchText, prompt: "Search tasks or tags")
    }
}

#Preview {
    TasksView().environment(DependencyContainer.preview)
}
