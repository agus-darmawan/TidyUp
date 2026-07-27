//
//  AddScheduleEventView.swift
//  TidyUp
//

import SwiftUI

struct AddScheduleEventView: View {
    @Environment(\.dismiss) private var dismiss

    let initialDate: Date
    let onSave: (ScheduleEvent) -> Void

    @State private var title = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var note = ""

    private let colorOptions = ["#3B82F6", "#22C55E", "#8B5CF6", "#EF4444", "#F59E0B"]
    @State private var selectedColor = "#3B82F6"

    init(initialDate: Date, onSave: @escaping (ScheduleEvent) -> Void) {
        self.initialDate = initialDate
        self.onSave = onSave
        _startDate = State(initialValue: initialDate)
        _endDate = State(initialValue: initialDate.adding(days: 0).addingTimeInterval(3600))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    DatePicker("Starts", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Ends", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                }

                Section("Color") {
                    HStack {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke(Color.primary, lineWidth: selectedColor == hex ? 2 : 0)
                                )
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedColor = hex }
                        }
                    }
                }

                Section("Note") {
                    TextField("Note", text: $note, axis: .vertical).lineLimit(2...4)
                }
            }
            .navigationTitle("New Event")
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
        let event = ScheduleEvent(title: title, startDate: startDate, endDate: endDate, note: note, colorTag: selectedColor)
        onSave(event)
        dismiss()
    }
}
