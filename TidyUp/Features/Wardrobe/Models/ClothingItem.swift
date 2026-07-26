//
//  ClothingItem.swift
//  TidyUp
//
//  v3: categories now reflect purpose (Work, Casual, Prayer, ...) rather
//  than raw garment type. Every physical item is still unique — no stock
//  counts. Most categories go dirty the instant they're worn (perWear),
//  but Outerwear (jackets) and Linens (blankets/bedsheets) use a
//  duration-based cycle instead — they stay "in use" for N days before
//  needing a wash, since you don't wash a jacket after one wear.
//

import Foundation
import SwiftData

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case work, casual, bottoms, underwear, prayer, outerwear, linens, others
    var id: String { rawValue }

    var label: String {
        switch self {
        case .work: "Work"
        case .casual: "Casual"
        case .bottoms: "Pants"
        case .underwear: "Underwear"
        case .prayer: "Prayer"
        case .outerwear: "Outerwear (Jacket)"
        case .linens: "Linens (Blanket/Bedsheet)"
        case .others: "Others"
        }
    }

    var icon: String {
        switch self {
        case .work: "briefcase.fill"
        case .casual: "tshirt.fill"
        case .bottoms: "figure.walk"
        case .underwear: "square.stack.fill"
        case .prayer: "hands.sparkles.fill"
        case .outerwear: "cloud.fill"
        case .linens: "bed.double.fill"
        case .others: "shippingbox.fill"
        }
    }

    /// These categories don't go dirty after a single wear — they're used
    /// continuously for a set number of days before needing a wash.
    var usesDurationCycle: Bool { self == .outerwear || self == .linens }

    var defaultUsageDurationDays: Int {
        self == .outerwear ? 7 : 30
    }
}

enum LaundryStatus: String, Codable {
    case clean, dirty, washing
    var label: String {
        switch self {
        case .clean: "Clean"
        case .dirty: "Dirty"
        case .washing: "In Laundry"
        }
    }
}

@Model
final class ClothingItem {
    var itemCode: String   // human-readable unique ID, e.g. "TU-0001"
    var id: UUID
    var name: String
    var categoryRaw: String
    var brand: String
    var color: String
    var notes: String
    var photoFilename: String?
    var purchaseDate: Date?
    var createdAt: Date

    var laundryStatusRaw: String
    var lastWornDate: Date?
    var lastWashedDate: Date?
    var washStartedDate: Date?
    var wearCountSinceWash: Int

    /// Duration-based wear cycle (jackets/linens only). `nil` for
    /// everything else, meaning "goes dirty after a single wear".
    var usageDurationDays: Int?
    var wearCycleStartDate: Date?

    init(
        id: UUID = UUID(),
        itemCode: String,
        name: String,
        category: ClothingCategory,
        brand: String = "",
        color: String = "",
        notes: String = "",
        photoFilename: String? = nil,
        purchaseDate: Date? = nil,
        usageDurationDays: Int? = nil
    ) {
        self.id = id
        self.itemCode = itemCode
        self.name = name
        self.categoryRaw = category.rawValue
        self.brand = brand
        self.color = color
        self.notes = notes
        self.photoFilename = photoFilename
        self.purchaseDate = purchaseDate
        self.createdAt = .now
        self.laundryStatusRaw = LaundryStatus.clean.rawValue
        self.wearCountSinceWash = 0
        self.usageDurationDays = category.usesDurationCycle ? (usageDurationDays ?? category.defaultUsageDurationDays) : nil
    }

    var category: ClothingCategory {
        get { ClothingCategory(rawValue: categoryRaw) ?? .others }
        set { categoryRaw = newValue.rawValue }
    }

    var laundryStatus: LaundryStatus {
        get { LaundryStatus(rawValue: laundryStatusRaw) ?? .clean }
        set { laundryStatusRaw = newValue.rawValue }
    }

    /// Logs a wear. Regular items go dirty immediately; jackets/linens
    /// only go dirty once their usage cycle (in days) has elapsed.
    func markWorn() {
        lastWornDate = .now
        wearCountSinceWash += 1

        guard let durationDays = usageDurationDays else {
            laundryStatusRaw = LaundryStatus.dirty.rawValue
            return
        }

        if wearCycleStartDate == nil { wearCycleStartDate = .now }
        if let cycleStart = wearCycleStartDate, Date.now.daysSince(cycleStart) >= durationDays {
            laundryStatusRaw = LaundryStatus.dirty.rawValue
        }
    }

    func markWashed() {
        lastWashedDate = .now
        wearCountSinceWash = 0
        wearCycleStartDate = nil
        washStartedDate = nil
        laundryStatusRaw = LaundryStatus.clean.rawValue
    }

    /// Dirty → In Laundry: starts the wash cycle with an estimated
    /// completion time (a typical wash-and-dry cycle, ~4 hours).
    func startWash() {
        washStartedDate = .now
        laundryStatusRaw = LaundryStatus.washing.rawValue
    }

    static let defaultWashDurationHours = 4

    /// Estimated time the laundry will be done, if currently washing.
    var estimatedWashDoneDate: Date? {
        guard laundryStatus == .washing, let started = washStartedDate else { return nil }
        return started.addingTimeInterval(TimeInterval(Self.defaultWashDurationHours * 3600))
    }

    var isWashReady: Bool {
        guard let doneDate = estimatedWashDoneDate else { return false }
        return Date.now >= doneDate
    }

    /// e.g. "Ready in 2h 15m" or "Ready now" — shown on the laundry badge.
    var washTimeRemainingLabel: String {
        guard let doneDate = estimatedWashDoneDate else { return "" }
        if Date.now >= doneDate { return "Ready now" }
        let totalMinutes = max(0, Int(doneDate.timeIntervalSince(.now) / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 { return "Ready in \(hours)h\(minutes > 0 ? " \(minutes)m" : "")" }
        return "Ready in \(minutes)m"
    }

    /// Days remaining before a duration-cycle item (jacket/linen) needs washing.
    var daysRemainingInCycle: Int? {
        guard let durationDays = usageDurationDays, let cycleStart = wearCycleStartDate else { return nil }
        return max(0, durationDays - Date.now.daysSince(cycleStart))
    }
}
