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
    private(set) var storedName: String
    private(set) var index: Int
    private(set) var newIndex: Int
    private(set) var lane: Int
    private(set) var newLane: Int
    private(set) var sourceID: UUID?
    private(set) var longFileName: String?

    static func < (lhs: Patch, rhs: Patch) -> Bool {
        return lhs.index < rhs.index
    }

    init(name: String, index: Int, lane: Int) {
        self.name = name
        self.storedName = name
        self.index = index
        self.newIndex = index
        self.lane = lane
        self.newLane = lane
    }

    mutating func updateStoredName(_ updatedName: String) {
        storedName = updatedName
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

    func copyWithNewID() -> Patch {
        var copy = Patch(name: name, index: index, lane: lane)
        // If copying from a copy, use the source ID for that copy
        copy.sourceID = sourceID ?? id
        return copy
    }

    mutating func resetCopyStatus() {
        sourceID = nil
    }

    mutating func setLongFileName(_ filename: String) {
        longFileName = filename
    }

    mutating func clearLongFileName() {
        longFileName = nil
    }
}
