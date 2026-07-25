//
//  ClothingItem.swift
//  TidyUp
//
//  v2: no stock count — every physical item is unique (own itemCode),
//  since you don't own duplicates of the exact same piece. `.linens`
//  covers towels/bedsheets, which need periodic-replacement tracking
//  instead of just clean/dirty tracking.
//

import Foundation
import SwiftData

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case tops, bottoms, underwear, outerwear, sleepwear, sportswear, shoes, accessories, linens, other
    var id: String { rawValue }

    var label: String {
        switch self {
        case .tops: "Tops"
        case .bottoms: "Bottoms"
        case .underwear: "Underwear"
        case .outerwear: "Outerwear"
        case .sleepwear: "Sleepwear"
        case .sportswear: "Sportswear"
        case .shoes: "Shoes"
        case .accessories: "Accessories"
        case .linens: "Linens (Towel/Bedsheet)"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .tops: "tshirt.fill"
        case .bottoms: "figure.walk"
        case .underwear: "square.stack.fill"
        case .outerwear: "cloud.fill"
        case .sleepwear: "moon.fill"
        case .sportswear: "figure.run"
        case .shoes: "shoe.fill"
        case .accessories: "eyeglasses"
        case .linens: "bed.double.fill"
        case .other: "shippingbox.fill"
        }
    }

    /// Linens follow a replace-by-interval cycle instead of simple clean/dirty.
    var isLinen: Bool { self == .linens }
}

enum LaundryStatus: String, Codable {
    case clean, dirty
    var label: String { self == .clean ? "Clean" : "Dirty" }
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
    var photoFilenames: [String]
    var purchaseDate: Date?
    var createdAt: Date

    var laundryStatusRaw: String
    var lastWornDate: Date?
    var lastWashedDate: Date?
    var wearCountSinceWash: Int

    // Linens-only: replace-by-interval tracking.
    var replacementIntervalDays: Int?
    var lastReplacedDate: Date?

    init(
        id: UUID = UUID(),
        itemCode: String,
        name: String,
        category: ClothingCategory,
        brand: String = "",
        color: String = "",
        notes: String = "",
        photoFilenames: [String] = [],
        purchaseDate: Date? = nil,
        replacementIntervalDays: Int? = nil
    ) {
        self.id = id
        self.itemCode = itemCode
        self.name = name
        self.categoryRaw = category.rawValue
        self.brand = brand
        self.color = color
        self.notes = notes
        self.photoFilenames = photoFilenames
        self.purchaseDate = purchaseDate
        self.createdAt = .now
        self.laundryStatusRaw = LaundryStatus.clean.rawValue
        self.wearCountSinceWash = 0
        self.replacementIntervalDays = category.isLinen ? (replacementIntervalDays ?? 180) : nil
        self.lastReplacedDate = category.isLinen ? .now : nil
    }

    var category: ClothingCategory {
        get { ClothingCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var laundryStatus: LaundryStatus {
        get { LaundryStatus(rawValue: laundryStatusRaw) ?? .clean }
        set { laundryStatusRaw = newValue.rawValue }
    }

    /// One-tap action from the list row: "I'm wearing this today".
    func markWorn() {
        lastWornDate = .now
        wearCountSinceWash += 1
        laundryStatusRaw = LaundryStatus.dirty.rawValue
    }

    func markWashed() {
        lastWashedDate = .now
        wearCountSinceWash = 0
        laundryStatusRaw = LaundryStatus.clean.rawValue
    }

    /// For linens: true once it's past its replacement interval.
    var needsReplacement: Bool {
        guard category.isLinen, let interval = replacementIntervalDays, let lastReplaced = lastReplacedDate else { return false }
        return Date.now.daysSince(lastReplaced) >= interval
    }

    var daysUntilReplacement: Int? {
        guard category.isLinen, let interval = replacementIntervalDays, let lastReplaced = lastReplacedDate else { return nil }
        return interval - Date.now.daysSince(lastReplaced)
    }

    func markReplaced() {
        lastReplacedDate = .now
    }
}
