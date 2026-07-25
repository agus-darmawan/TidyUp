//
//  AddEditJournalView.swift
//  TidyUp
//

import SwiftUI

struct AddEditJournalView: View {
    @Environment(\.dismiss) private var dismiss

    let existingEntry: JournalEntry?
    let onSave: (JournalEntry) -> Void

    @State private var date: Date
    @State private var mood: MoodType
    @State private var reflection: String
    @State private var tagInput = ""
    @State private var tags: [String]

    init(entry: JournalEntry?, onSave: @escaping (JournalEntry) -> Void) {
        self.existingEntry = entry
        self.onSave = onSave
        _date = State(initialValue: entry?.date ?? .now)
        _mood = State(initialValue: entry?.mood ?? .neutral)
        _reflection = State(initialValue: entry?.reflection ?? "")
        _tags = State(initialValue: entry?.tags ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("How are you feeling?") { MoodPicker(selection: $mood) }
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Write your reflection...", text: $reflection, axis: .vertical).lineLimit(6...12)
                }
                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                        Button("Add") {
                            let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
                            tags.append(trimmed); tagInput = ""
                        }
                    }
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { ForEach(tags, id: \.self) { tag in PATagChip(text: tag).onTapGesture { tags.removeAll { $0 == tag } } } }
                        }
                    }
                }
            }
            .navigationTitle(existingEntry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
            }
        }
    }

    private func save() {
        let entry = existingEntry ?? JournalEntry()
        entry.date = date
        entry.mood = mood
        entry.reflection = reflection
        entry.tags = tags
        onSave(entry)
        dismiss()
    }
}
