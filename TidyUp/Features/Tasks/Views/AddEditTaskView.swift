//
//  AddEditTaskView.swift
//  TidyUp
//

import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    let existingTask: TaskItem?
    let onSave: (TaskItem) -> Void

    @State private var title: String
    @State private var notes: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var hasReminder: Bool
    @State private var priority: TaskPriority
    @State private var recurrence: RecurrenceFrequency
    @State private var tagInput = ""
    @State private var tags: [String]

    init(task: TaskItem?, onSave: @escaping (TaskItem) -> Void) {
        self.existingTask = task
        self.onSave = onSave
        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _dueDate = State(initialValue: task?.dueDate ?? .now)
        _hasReminder = State(initialValue: task?.hasReminder ?? false)
        _priority = State(initialValue: task?.priority ?? .medium)
        _recurrence = State(initialValue: task?.recurrence ?? .none)
        _tags = State(initialValue: task?.tags ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(3...6)
                }

                Section("Schedule") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        Toggle("Remind me", isOn: $hasReminder)
                        Picker("Repeat", selection: $recurrence) {
                            ForEach(RecurrenceFrequency.allCases) { Text($0.label).tag($0) }
                        }
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                        Button("Add") {
                            let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
                            tags.append(trimmed)
                            tagInput = ""
                        }
                    }
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    PATagChip(text: tag).onTapGesture { tags.removeAll { $0 == tag } }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(existingTask == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let task = existingTask ?? TaskItem(title: title)
        task.title = title
        task.notes = notes
        task.dueDate = hasDueDate ? dueDate : nil
        task.hasReminder = hasDueDate && hasReminder
        task.priority = priority
        task.recurrence = recurrence
        task.tags = tags
        onSave(task)
        dismiss()
    }
}
