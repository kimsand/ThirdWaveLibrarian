//
//  Patch.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 26/11/2023.
//

import Foundation

struct Patch: Identifiable, Hashable, Comparable {
    let id = UUID()
    var name: String
    var index: Int
    var lane: Int
    var newIndex: Int
    var newLane: Int

    static func < (lhs: Patch, rhs: Patch) -> Bool {
        return lhs.index < rhs.index
    }

    init(name: String, index: Int, lane: Int) {
        self.name = name
        self.index = index
        self.lane = lane
        self.newIndex = index
        self.newLane = lane
    }

    mutating func updateIndex(_ updatedIndex: Int) {
        index = updatedIndex
    }

    mutating func updateLane(_ updatedLane: Int) {
        lane = updatedLane
    }

    mutating func updateNewIndex(_ updatedIndex: Int) {
        newIndex = updatedIndex
    }

    mutating func updateNewLane(_ updatedLane: Int) {
        newLane = updatedLane
    }
}
