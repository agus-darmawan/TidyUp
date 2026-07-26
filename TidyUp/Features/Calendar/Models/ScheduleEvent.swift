//
//  ScheduleEvent.swift
//  TidyUp
//
//  A manually-added calendar event (with a real start/end time), distinct
//  from Tasks. This is what makes Calendar actually usable like a real
//  calendar — you can add "Team Meeting 10:00–11:00" directly here, not
//  just see Task due-dates.
//

import Foundation
import SwiftData

@Model
final class ScheduleEvent {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var note: String
    var colorTag: String   // hex string, so each event can have its own dot color
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        note: String = "",
        colorTag: String = "#3B82F6"
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.colorTag = colorTag
        self.createdAt = .now
    }

    var durationMinutes: Int {
        max(0, Int(endDate.timeIntervalSince(startDate) / 60))
    }

    var durationLabel: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 && minutes > 0 { return "\(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h" }
        return "\(minutes)m"
    }
}
