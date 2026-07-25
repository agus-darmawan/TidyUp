//
//  TransactionCategory.swift
//  TidyUp
//

import Foundation
import SwiftData

@Model
final class TransactionCategory {
    var id: UUID
    var name: String
    var icon: String
    var isDefault: Bool

    init(id: UUID = UUID(), name: String, icon: String = "tag.fill", isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDefault = isDefault
    }
}
