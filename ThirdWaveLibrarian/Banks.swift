//
//  Banks.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 27/11/2023.
//

import Foundation

enum BankType: Int, CaseIterable {
    case bank1 = 1, bank2, bank3, bank4, bank5
}

struct Banks {
    var bank1 = [Patch]()
    var bank2 = [Patch]()
    var bank3 = [Patch]()
    var bank4 = [Patch]()
    var bank5 = [Patch]()

    var selBank1 = Set<Patch>()
    var selBank2 = Set<Patch>()
    var selBank3 = Set<Patch>()
    var selBank4 = Set<Patch>()
    var selBank5 = Set<Patch>()

    var cutBank = Set<Patch>()
    var cutBankType = BankType.bank1

    var bank1Title = "Bank lane 1"
    var bank2Title = "Bank lane 2"
    var bank3Title = "Bank lane 3"
    var bank4Title = "Bank lane 4"
    var bank5Title = "Bank lane 5"

    var bank1URL = URL.currentDirectory()
    var bank2URL = URL.currentDirectory()
    var bank3URL = URL.currentDirectory()
    var bank4URL = URL.currentDirectory()
    var bank5URL = URL.currentDirectory()

    private func dirURL(forBank type: BankType) -> URL {
        switch type {
        case .bank1:
            return bank1URL
        case .bank2:
            return bank2URL
        case .bank3:
            return bank3URL
        case .bank4:
            return bank4URL
        case .bank5:
            return bank5URL
        }
    }

    mutating func rename(bank type: BankType, withTitle title: String) {
        switch type {
        case .bank1:
            bank1Title = title
        case .bank2:
            bank2Title = title
        case .bank3:
            bank3Title = title
        case .bank4:
            bank4Title = title
        case .bank5:
            bank5Title = title
        }
    }

    mutating func load(patches patchList: [Patch], toBank type: BankType, dirURL: URL) {
        switch type {
        case .bank1:
            bank1URL = dirURL
            bank1.removeAll()
            selBank1.removeAll()
        case .bank2:
            bank2URL = dirURL
            bank2.removeAll()
            selBank2.removeAll()
        case .bank3:
            bank3URL = dirURL
            bank3.removeAll()
            selBank3.removeAll()
        case .bank4:
            bank4URL = dirURL
            bank4.removeAll()
            selBank4.removeAll()
        case .bank5:
            bank5URL = dirURL
            bank5.removeAll()
            selBank5.removeAll()
        }

        append(patches: patchList, toBank: type)
    }

    mutating func append(patches patchList: [Patch], toBank type: BankType) {
        switch type {
        case .bank1:
            bank1.append(contentsOf: patchList)
        case .bank2:
            bank2.append(contentsOf: patchList)
        case .bank3:
            bank3.append(contentsOf: patchList)
        case .bank4:
            bank4.append(contentsOf: patchList)
        case .bank5:
            bank5.append(contentsOf: patchList)
        }
    }

    private func updateIndices(forBank bank: inout [Patch]) {
        bank.enumerated().forEach { index, patch in
            if index+1 != patch.newIndex {
                var patch = patch
                patch.updateNewIndex(index+1)
                bank.replaceSubrange(index...index, with: [patch])
            }
        }
    }

    private func updateLanesAndIndices(forBank bank: inout [Patch], inLane lane: Int) {
        bank.enumerated().forEach { index, patch in
            if lane != patch.newLane || index+1 != patch.newIndex {
                var patch = patch
                if lane != patch.newLane {
                    patch.updateNewLane(lane)
                }
                if index+1 != patch.newIndex {
                    patch.updateNewIndex(index+1)
                }
                bank.replaceSubrange(index...index, with: [patch])
            }
        }
    }

    private func resetLanesAndIndices(forBank bank: inout [Patch]) {
        bank.enumerated().forEach { index, patch in
            if patch.lane != patch.newLane || patch.index != patch.newIndex {
                var patch = patch
                if patch.lane != patch.newLane {
                    patch.updateLane(patch.newLane)
                }
                if patch.index != patch.newIndex {
                    patch.updateIndex(patch.newIndex)
                }
                bank.replaceSubrange(index...index, with: [patch])
            }
        }
    }

    mutating func resetLanesAndIndices(forBank type: BankType) {
        switch type {
        case .bank1:
            resetLanesAndIndices(forBank: &bank1)
        case .bank2:
            resetLanesAndIndices(forBank: &bank2)
        case .bank3:
            resetLanesAndIndices(forBank: &bank3)
        case .bank4:
            resetLanesAndIndices(forBank: &bank4)
        case .bank5:
            resetLanesAndIndices(forBank: &bank5)
        }
    }

    mutating func reorderPatches(from indexSet: IndexSet, to index: Int, inBank type: BankType) {
        switch type {
        case .bank1:
            bank1.move(fromOffsets: indexSet, toOffset: index)
            updateIndices(forBank: &bank1)
            selBank1.removeAll()
        case .bank2:
            bank2.move(fromOffsets: indexSet, toOffset: index)
            updateIndices(forBank: &bank2)
            selBank2.removeAll()
        case .bank3:
            bank3.move(fromOffsets: indexSet, toOffset: index)
            updateIndices(forBank: &bank3)
            selBank3.removeAll()
        case .bank4:
            bank4.move(fromOffsets: indexSet, toOffset: index)
            updateIndices(forBank: &bank4)
            selBank4.removeAll()
        case .bank5:
            bank5.move(fromOffsets: indexSet, toOffset: index)
            updateIndices(forBank: &bank5)
            selBank5.removeAll()
        }
    }

    mutating func removeSelectedPatches(fromBank type: BankType) {
        switch type {
        case .bank1:
            remove(patches: Array(selBank1), fromBank: type)
            selBank1.removeAll()
        case .bank2:
            remove(patches: Array(selBank2), fromBank: type)
            selBank2.removeAll()
        case .bank3:
            remove(patches: Array(selBank3), fromBank: type)
            selBank3.removeAll()
        case .bank4:
            remove(patches: Array(selBank4), fromBank: type)
            selBank4.removeAll()
        case .bank5:
            remove(patches: Array(selBank5), fromBank: type)
            selBank5.removeAll()
        }
    }

    private mutating func remove(patches patchList: [Patch], fromBank type: BankType) {
        switch type {
        case .bank1:
            bank1.remove(atOffsets: IndexSet(patchList.compactMap({patch in bank1.firstIndex(where: {patch.id == $0.id})})))
        case .bank2:
            bank2.remove(atOffsets: IndexSet(patchList.compactMap({patch in bank2.firstIndex(where: {patch.id == $0.id})})))
        case .bank3:
            bank3.remove(atOffsets: IndexSet(patchList.compactMap({patch in bank3.firstIndex(where: {patch.id == $0.id})})))
        case .bank4:
            bank4.remove(atOffsets: IndexSet(patchList.compactMap({patch in bank4.firstIndex(where: {patch.id == $0.id})})))
        case .bank5:
            bank5.remove(atOffsets: IndexSet(patchList.compactMap({patch in bank5.firstIndex(where: {patch.id == $0.id})})))
        }
    }

    mutating func cutPatches(fromBank type: BankType) {
        // Make a copy of the list of currently selected items for the bank
        switch type {
        case .bank1:
            cutBank = selBank1
            cutBankType = .bank1
        case .bank2:
            cutBank = selBank2
            cutBankType = .bank2
        case .bank3:
            cutBank = selBank3
            cutBankType = .bank3
        case .bank4:
            cutBank = selBank4
            cutBankType = .bank4
        case .bank5:
            cutBank = selBank5
            cutBankType = .bank5
        }
    }

    private func pasteIndex(forBank type: BankType) -> Int? {
        let selBank: Set<Patch>
        var pasteBank: [Patch]

        switch type {
        case .bank1:
            selBank = selBank1
            pasteBank = bank1
        case .bank2:
            selBank = selBank2
            pasteBank = bank2
        case .bank3:
            selBank = selBank3
            pasteBank = bank3
        case .bank4:
            selBank = selBank4
            pasteBank = bank4
        case .bank5:
            selBank = selBank5
            pasteBank = bank5
        }

        // TODO: Allow only one selected destination patch when pasting or the result will be unpredictable

        guard let pastePatch = selBank.first else {
            print("No patch selected in destination lane")
            return nil
        }
        guard let pasteIndex = pasteBank.firstIndex(where: {pastePatch.id == $0.id}) else {
            print("Selected patch not found in destination lane")
            return nil
        }

        return pasteIndex
    }

    mutating func pasteCutPatches(toBank type: BankType) {
        guard !cutBank.isEmpty else {
            print("Cutbank is empty")
            return
        }
        guard let pasteIndex = pasteIndex(forBank: type) else {
            print("No selected destination to paste into")
            return
        }

        if cutBankType != type {
            // Insert patches in new lane
            switch type {
            case .bank1:
                bank1.insert(contentsOf: cutBank, at: pasteIndex)
                updateLanesAndIndices(forBank: &bank1, inLane: 1)
            case .bank2:
                bank2.insert(contentsOf: cutBank, at: pasteIndex)
                updateLanesAndIndices(forBank: &bank2, inLane: 2)
            case .bank3:
                bank3.insert(contentsOf: cutBank, at: pasteIndex)
                updateLanesAndIndices(forBank: &bank3, inLane: 3)
            case .bank4:
                bank4.insert(contentsOf: cutBank, at: pasteIndex)
                updateLanesAndIndices(forBank: &bank4, inLane: 4)
            case .bank5:
                bank5.insert(contentsOf: cutBank, at: pasteIndex)
                updateLanesAndIndices(forBank: &bank5, inLane: 5)
            }

            // Remove patches from old lane
            remove(patches: Array(cutBank), fromBank: cutBankType)
            switch cutBankType {
            case .bank1:
                updateLanesAndIndices(forBank: &bank1, inLane: 1)
            case .bank2:
                updateLanesAndIndices(forBank: &bank2, inLane: 2)
            case .bank3:
                updateLanesAndIndices(forBank: &bank3, inLane: 3)
            case .bank4:
                updateLanesAndIndices(forBank: &bank4, inLane: 4)
            case .bank5:
                updateLanesAndIndices(forBank: &bank5, inLane: 5)
            }

        } else {
            // Reorder patches within lane
            switch type {
            case .bank1:
                bank1.move(fromOffsets: IndexSet(cutBank.compactMap({patch in bank1.firstIndex(where: {patch.id == $0.id})})), toOffset: pasteIndex)
                updateIndices(forBank: &bank1)
            case .bank2:
                bank2.move(fromOffsets: IndexSet(cutBank.compactMap({patch in bank2.firstIndex(where: {patch.id == $0.id})})), toOffset: pasteIndex)
                updateIndices(forBank: &bank2)
            case .bank3:
                bank3.move(fromOffsets: IndexSet(cutBank.compactMap({patch in bank3.firstIndex(where: {patch.id == $0.id})})), toOffset: pasteIndex)
                updateIndices(forBank: &bank3)
            case .bank4:
                bank4.move(fromOffsets: IndexSet(cutBank.compactMap({patch in bank4.firstIndex(where: {patch.id == $0.id})})), toOffset: pasteIndex)
                updateIndices(forBank: &bank4)
            case .bank5:
                bank5.move(fromOffsets: IndexSet(cutBank.compactMap({patch in bank5.firstIndex(where: {patch.id == $0.id})})), toOffset: pasteIndex)
                updateIndices(forBank: &bank5)
            }
        }

        // Remove pasted patches from the selection bank
        switch cutBankType {
        case .bank1:
            cutBank.forEach({ selBank1.remove($0)})
        case .bank2:
            cutBank.forEach({ selBank2.remove($0)})
        case .bank3:
            cutBank.forEach({ selBank3.remove($0)})
        case .bank4:
            cutBank.forEach({ selBank4.remove($0)})
        case .bank5:
            cutBank.forEach({ selBank5.remove($0)})
        }

        switch type {
        case .bank1:
            selBank1.removeAll()
        case .bank2:
            selBank2.removeAll()
        case .bank3:
            selBank3.removeAll()
        case .bank4:
            selBank4.removeAll()
        case .bank5:
            selBank5.removeAll()
        }

        cutBank.removeAll()
    }

    private func movedPatches(forBank type: BankType) -> [Patch] {
        switch type {
        case .bank1:
            return bank1.filter({$0.lane != $0.newLane || $0.index != $0.newIndex})
        case .bank2:
            return bank2.filter({$0.lane != $0.newLane || $0.index != $0.newIndex})
        case .bank3:
            return bank3.filter({$0.lane != $0.newLane || $0.index != $0.newIndex})
        case .bank4:
            return bank4.filter({$0.lane != $0.newLane || $0.index != $0.newIndex})
        case .bank5:
            return bank5.filter({$0.lane != $0.newLane || $0.index != $0.newIndex})
        }
    }

    func saveReorderedPatchesToTemp(forBank toType: BankType) -> [Patch] {
        let patches = movedPatches(forBank: toType)

        let fileHandler = FileHandler()

        // Rename to temporary filenames to avoid clashing with existing filenames
        patches.forEach { patch in
            guard let fromType = BankType(rawValue: patch.lane) else {
                print("Bank type for lane number not found")
                return
            }

            let fromFileName = String(format: "%03d.PRO", patch.index)
            let fromDir = dirURL(forBank: fromType).appending(path: fromFileName)

            let toFileName = String(format: "%03dT.PRO", patch.newIndex)
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
                print("Bank type for lane number not found")
                return
            }

            let fromFileName = String(format: "%03dT.PRO", patch.newIndex)
            let toFileName = String(format: "%03d.PRO", patch.newIndex)

            let fromDir = dirURL(forBank: type).appending(path: fromFileName)
            let toDir = dirURL(forBank: type).appending(path: toFileName)

            fileHandler.renameFile(fromURL: fromDir, toURL: toDir)
        }
    }
}
