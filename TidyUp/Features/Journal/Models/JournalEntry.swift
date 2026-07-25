//
//  JournalEntry.swift
//  TidyUp
//

import Foundation
import SwiftData

enum MoodType: String, Codable, CaseIterable, Identifiable {
    case great, good, neutral, bad, terrible
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .great: "😄"
        case .good: "🙂"
        case .neutral: "😐"
        case .bad: "🙁"
        case .terrible: "😞"
        }
    }
    var label: String {
        switch self {
        case .great: "Great"
        case .good: "Good"
        case .neutral: "Neutral"
        case .bad: "Bad"
        case .terrible: "Terrible"
        }
    }
}

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var moodRaw: String
    var reflection: String
    var tags: [String]
    var photoFilenames: [String]
    var createdAt: Date

    init(id: UUID = UUID(), date: Date = .now, mood: MoodType = .neutral, reflection: String = "", tags: [String] = [], photoFilenames: [String] = []) {
        self.id = id
        self.date = date
        self.moodRaw = mood.rawValue
        self.reflection = reflection
        self.tags = tags
        self.photoFilenames = photoFilenames
        self.createdAt = .now
    }

    var mood: MoodType {
        get { MoodType(rawValue: moodRaw) ?? .neutral }
        set { moodRaw = newValue.rawValue }
    }
}
