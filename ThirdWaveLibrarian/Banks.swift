//
//  Banks.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 27/11/2023.
//

import Foundation

enum BankType: Int, CaseIterable {
    case bank1, bank2, bank3, bank4, bank5
}

struct Banks {
    var banks = [
        Bank(title: "Bank lane 1"),
        Bank(title: "Bank lane 2"),
        Bank(title: "Bank lane 3"),
        Bank(title: "Bank lane 4"),
        Bank(title: "Bank lane 5")
    ]

    var cutBank = Set<Patch>()
    var cutBankType = BankType.bank1

    private func dirURL(forBank type: BankType) -> URL {
        banks[type.rawValue].dirURL
    }

    mutating func rename(bank type: BankType, withTitle title: String) {
        banks[type.rawValue].title = title
    }

    mutating func load(patches patchList: [Patch], toBank type: BankType, dirURL: URL) {
        banks[type.rawValue].dirURL = dirURL

        // Remove any existing patches in the lane
        banks[type.rawValue].patches.removeAll()
        banks[type.rawValue].selections.removeAll()
        
        append(patches: patchList, toBank: type)
    }

    mutating func append(patches patchList: [Patch], toBank type: BankType) {
        banks[type.rawValue].patches.append(contentsOf: patchList)
    }

    private func updateIndices(forPatches patches: inout [Patch]) {
        patches.enumerated().forEach { index, patch in
            if index != patch.newIndex {
                var patch = patch
                patch.updateNewIndex(index)
                patches.replace(patch, at: index)
            }
        }
    }

    private func updateLanesAndIndices(forPatches patches: inout [Patch], inLane lane: Int) {
        patches.enumerated().forEach { index, patch in
            if lane != patch.newLane || index != patch.newIndex {
                var patch = patch
                if lane != patch.newLane {
                    patch.updateNewLane(lane)
                }
                if index != patch.newIndex {
                    patch.updateNewIndex(index)
                }
                patches.replace(patch, at: index)
            }
        }
    }

    private func resetLanesAndIndices(forPatches patches: inout [Patch]) {
        patches.enumerated().forEach { index, patch in
            if patch.lane != patch.newLane || patch.index != patch.newIndex {
                var patch = patch
                if patch.lane != patch.newLane {
                    patch.updateLane(patch.newLane)
                }
                if patch.index != patch.newIndex {
                    patch.updateIndex(patch.newIndex)
                }
                patches.replace(patch, at: index)
            }
        }
    }

    mutating func resetLanesAndIndices(forBank type: BankType) {
        resetLanesAndIndices(forPatches: &banks[type.rawValue].patches)
    }

    mutating func reorderPatches(from indexSet: IndexSet, to index: Int, inBank type: BankType) {
        banks[type.rawValue].patches.move(fromOffsets: indexSet, toOffset: index)
        updateIndices(forPatches: &banks[type.rawValue].patches)

        // Remove selections since this is not automatic
        banks[type.rawValue].selections.removeAll()
    }

    mutating func removeSelectedPatches(fromBank type: BankType) {
        remove(patches: Array(banks[type.rawValue].selections), fromBank: type)

        // Remove selections since this is not automatic
        banks[type.rawValue].selections.removeAll()
    }

    private mutating func remove(patches patchList: [Patch], fromBank type: BankType) {
        banks[type.rawValue].patches.remove(
            atOffsets: IndexSet(patchList.compactMap({patch in
                banks[type.rawValue].patches.firstIndex(where: {patch.id == $0.id})
            }))
        )
    }

    mutating func cutPatches(fromBank type: BankType) {
        // Make a copy (assign by value) of the list of currently selected items for the bank
        cutBank = banks[type.rawValue].selections
        cutBankType = type
    }

    mutating func pasteCutPatches(toBank type: BankType) {
        guard !cutBank.isEmpty else {
            print("Paste skipped. Cutbank is empty.")
            return
        }

        // TODO: Allow only one selected destination patch when pasting or the result will be unpredictable
        guard let pastePatch = banks[type.rawValue].selections.first else {
            print("Paste skipped. No patch selected in destination lane.")
            return
        }

        guard let pasteIndex = banks[type.rawValue].patches.firstIndex(where: {pastePatch.id == $0.id}) else {
            assertionFailure("Paste failed! Selected patch not found in destination lane.")
            return
        }

        if cutBankType != type {
            // Insert patches in new lane
            banks[type.rawValue].patches.insert(contentsOf: cutBank, at: pasteIndex)
            updateLanesAndIndices(forPatches: &banks[type.rawValue].patches, inLane: type.rawValue)

            // Remove patches from old lane
            remove(patches: Array(cutBank), fromBank: cutBankType)
            updateLanesAndIndices(forPatches: &banks[type.rawValue].patches, inLane: type.rawValue)
        } else {
            // Reorder patches within lane
            banks[type.rawValue].patches.move(
                fromOffsets: IndexSet(cutBank.compactMap({patch in
                    banks[type.rawValue].patches.firstIndex(where: {patch.id == $0.id})
                })),
                toOffset: pasteIndex
            )
            updateIndices(forPatches: &banks[type.rawValue].patches)
        }

        // Remove selections involved in the cut-and-paste
        banks[cutBankType.rawValue].selections.removeAll()
        banks[type.rawValue].selections.removeAll()
        cutBank.removeAll()
    }

    private func movedPatches(forBank type: BankType) -> [Patch] {
        return banks[type.rawValue].patches.filter({$0.lane != $0.newLane || $0.index != $0.newIndex})
    }

    func saveReorderedPatchesToTemp(forBank toType: BankType) -> [Patch] {
        let patches = movedPatches(forBank: toType)

        let fileHandler = FileHandler()

        // Rename to temporary filenames to avoid clashing with existing filenames
        patches.forEach { patch in
            guard let fromType = BankType(rawValue: patch.lane) else {
                assertionFailure("Save to temp failed! Bank type for lane number not found.")
                return
            }

            let fromFileName = String(format: "%03d.PRO", patch.index+1)
            let fromDir = dirURL(forBank: fromType).appending(path: fromFileName)

            let toFileName = String(format: "%03dT.PRO", patch.newIndex+1)
            let toDir = dirURL(forBank: toType).appending(path: toFileName)

            fileHandler.renameFile(fromURL: fromDir, toURL: toDir)
        }

        return patches
    }

    func saveTempPatchesAfterMove(patches: [Patch]) {
        let fileHandler = FileHandler()

        // Rename to actual filenames when there is no longer a risk of name clash
        patches.forEach { patch in
            guard let type = BankType(rawValue: patch.newLane) else {
                assertionFailure("Save from temp failed! Bank type for lane number not found.")
                return
            }

            let fromFileName = String(format: "%03dT.PRO", patch.newIndex+1)
            let toFileName = String(format: "%03d.PRO", patch.newIndex+1)

            let fromDir = dirURL(forBank: type).appending(path: fromFileName)
            let toDir = dirURL(forBank: type).appending(path: toFileName)

            fileHandler.renameFile(fromURL: fromDir, toURL: toDir)
        }
    }
}
