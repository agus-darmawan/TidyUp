//
//  OutfitCartViewModel.swift
//  TidyUp
//
//  The "keranjang pakai baju" idea: browse the wardrobe, tap items to
//  add them to today's outfit selection, then confirm once — logging
//  the wear across every selected piece in one action, instead of
//  tapping "wear" one item at a time.
//

import Foundation
import Observation

@Observable
final class OutfitCartViewModel {
    private(set) var selectedItemIDs: Set<UUID> = []

    var count: Int { selectedItemIDs.count }
    var isEmpty: Bool { selectedItemIDs.isEmpty }

    func isSelected(_ item: ClothingItem) -> Bool {
        selectedItemIDs.contains(item.id)
    }

    func toggle(_ item: ClothingItem) {
        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }
    }

    func clear() {
        selectedItemIDs.removeAll()
    }
}
