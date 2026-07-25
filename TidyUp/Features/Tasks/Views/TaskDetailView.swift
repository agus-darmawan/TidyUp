//
//  TaskDetailView.swift
//  TidyUp
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var currentTask: TaskItem
    @State private var newSubtaskTitle = ""
    @State private var showingEdit = false

    init(task: TaskItem) {
        _currentTask = State(initialValue: task)
    }

    var body: some View {
        List {
            Section("Details") {
                if !currentTask.notes.isEmpty {
                    Text(currentTask.notes).foregroundStyle(AppTheme.Colors.secondaryText)
                }
                if let due = currentTask.dueDate {
                    Label(due.formatted(.medium), systemImage: "calendar")
                }
                Label(currentTask.priority.label, systemImage: "flag.fill")
                    .foregroundStyle(AppTheme.Colors.forPriority(currentTask.priority))
                if currentTask.recurrence != .none {
                    Label(currentTask.recurrence.label, systemImage: "repeat")
                }
            }

            if !currentTask.tags.isEmpty {
                Section("Tags") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(currentTask.tags, id: \.self) { PATagChip(text: $0) }
                        }
                    }
                }
            }

            Section("Subtasks") {
                ForEach(currentTask.subtasks.sorted(by: { $0.order < $1.order })) { subtask in
                    SubtaskRowView(
                        subtask: subtask,
                        onToggle: {
                            subtask.isDone.toggle()
                            container.taskRepository.save(currentTask)
                        },
                        onDelete: {
                            currentTask.subtasks.removeAll { $0.id == subtask.id }
                            container.taskRepository.save(currentTask)
                        }
                    )
                }
                HStack {
                    TextField("Add subtask", text: $newSubtaskTitle)
                    Button("Add") {
                        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        let subtask = SubTask(title: trimmed, order: currentTask.subtasks.count)
                        subtask.parentTask = currentTask
                        currentTask.subtasks.append(subtask)
                        container.taskRepository.save(currentTask)
                        newSubtaskTitle = ""
                    }
                    .disabled(newSubtaskTitle.isEmpty)
                }
            }
        }
        .navigationTitle(currentTask.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditTaskView(task: currentTask) { updated in
                currentTask = updated
                container.taskRepository.save(updated)
            }
        }
    }
}
