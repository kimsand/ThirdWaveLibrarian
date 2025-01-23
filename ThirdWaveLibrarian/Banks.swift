//
//  Banks.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 27/11/2023.
//

import Foundation

public enum BankType: Int, CaseIterable, Sendable {
    case bank1, bank2, bank3, bank4, bank5
}

@available(macOS 15.0, *)
public struct Banks: Sendable {
    private let fileHandler = FileHandler()

    public var banks: [Bank] = []

    private(set) var cutBank = Set<Patch>()
    private(set) var cutBankType = BankType.bank1
    private(set) var isCopyAndPaste = false
    private(set) var toBeDeleted = [Patch]()

    public init(banks: [Bank]? = nil) {
        if let banks {
            self.banks = banks
        } else {
            self.banks =
            [
                Bank(title: "Bank lane 1", saveName: "Bank 1"),
                Bank(title: "Bank lane 2", saveName: "Bank 2"),
                Bank(title: "Bank lane 3", saveName: "Bank 3"),
                Bank(title: "Bank lane 4", saveName: "Bank 4"),
                Bank(title: "Bank lane 5", saveName: "Bank 5")
            ]
        }
    }
    
    public func saveName(forBank type: BankType) -> String {
        if banks[type.rawValue].isDirLoaded {
            banks[type.rawValue].title
        } else {
            banks[type.rawValue].saveName
        }
    }

    private func patchWithID(_ patchID: Patch.ID) -> Patch? {
        BankType.allCases.compactMap({banks[$0.rawValue].patches.first(where: {$0.id == patchID})}).first
    }

    private func dirURL(forBank type: BankType) -> URL {
        banks[type.rawValue].dirURL
    }

    private mutating func rename(bank type: BankType, withTitle title: String) {
        banks[type.rawValue].title = title
    }

    private mutating func load(patches patchList: [Patch], toBank type: BankType, dirURL: URL) {
        banks[type.rawValue].dirURL = dirURL
        banks[type.rawValue].isDirLoaded = true

        // Remove any existing patches in the lane
        banks[type.rawValue].patches.removeAll()
        banks[type.rawValue].selections.removeAll()

        append(patches: patchList, toBank: type)

        // Mark bank as no longer having unsaved changes
        clearSaveStatus(forBank: type)
    }

    private mutating func append(patches patchList: [Patch], toBank type: BankType) {
        banks[type.rawValue].patches.append(contentsOf: patchList)
    }

    private func validateIndices(forPatches patches: [Patch], dirName: String) throws {
        let uniqued = Set(patches.map({$0.index}))
        if patches.count != uniqued.count {
            throw FileError.duplicateFileIndex(dirName: dirName)
        }
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

    private mutating func resetLanesAndIndices(forBank type: BankType) {
        resetLanesAndIndices(forPatches: &banks[type.rawValue].patches)
    }

    private func resetPatchNames(forPatches patches: inout [Patch]) {
        patches.enumerated().forEach { index, patch in
            if patch.name != patch.storedName {
                var patch = patch
                patch.updateStoredName(patch.name)
                patches.replace(patch, at: index)
            }
        }
    }

    private mutating func resetPatchNames(forBank type: BankType) {
        resetPatchNames(forPatches: &banks[type.rawValue].patches)
    }

    private mutating func resetCopyStatuses(forBank type: BankType) {
        banks[type.rawValue].patches.enumerated().forEach { index, patch in
            if patch.sourceID != nil {
                var patch = patch
                patch.resetCopyStatus()
                banks[type.rawValue].patches.replace(patch, at: index)
            }
        }
    }

    private mutating func clearLongFileNames(forBank type: BankType) {
        banks[type.rawValue].patches.enumerated().forEach { index, patch in
            if patch.longFileName != nil {
                var patch = patch
                patch.clearLongFileName()
                banks[type.rawValue].patches.replace(patch, at: index)
            }
        }
    }

    private mutating func setSaveStatus(forBank type: BankType) {
        banks[type.rawValue].hasUnsavedChanges = true
    }

    private mutating func clearSaveStatus(forBank type: BankType) {
        banks[type.rawValue].hasUnsavedChanges = false
    }

    public mutating func reorderPatches(from indexSet: IndexSet, to index: Int, inBank type: BankType) {
        banks[type.rawValue].patches.moveSubranges(RangeSet(indexSet), to: index)
        updateIndices(forPatches: &banks[type.rawValue].patches)

        // Remove selections since this is not automatic
        banks[type.rawValue].selections.removeAll()

        // Mark bank as having unsaved changes
        setSaveStatus(forBank: type)
    }

    public mutating func removeSelectedPatches(fromBank type: BankType) {
        let patchList = Array(banks[type.rawValue].selections)
        markPatchesForDeletion(patches: patchList)
        remove(patches: patchList, fromBank: type)
        updateIndices(forPatches: &banks[type.rawValue].patches)

        // Remove selections since this is not automatic
        banks[type.rawValue].selections.removeAll()

        // Mark bank as having unsaved changes
        setSaveStatus(forBank: type)
    }

    private mutating func markPatchesForDeletion(patches patchList: [Patch]) {
        // Ignore patches needing file copies, to avoid deleting files belonging to their sources
        toBeDeleted.append(contentsOf: patchList.filter({$0.sourceID == nil}))
    }

    private mutating func remove(patches patchList: [Patch], fromBank type: BankType) {
        banks[type.rawValue].patches.removeSubranges(
            RangeSet(IndexSet(patchList.compactMap({patch in
                banks[type.rawValue].patches.firstIndex(where: {patch.id == $0.id})
            })))
        )
    }

    public mutating func patchHasBeenRenamed(patch: Patch, inBank type: BankType) {
        if let selPatch = banks[type.rawValue].selections.first(where: {$0.id == patch.id}) {
            banks[type.rawValue].selections.remove(selPatch)
            banks[type.rawValue].selections.insert(patch)
        }

        // Mark bank as having unsaved changes
        setSaveStatus(forBank: type)
    }

    public mutating func cutPatches(fromBank type: BankType) {
        // Make a copy (assign by value) of the list of currently selected items for the bank
        cutBank = banks[type.rawValue].selections
        cutBankType = type
        isCopyAndPaste = false
    }

    public mutating func copyPatches(fromBank type: BankType) {
        // Make a copy (assign by value) of the list of currently selected items for the bank
        cutBank = banks[type.rawValue].selections
        cutBankType = type
        isCopyAndPaste = true
    }

    public mutating func pasteCutPatches(toBank type: BankType) {
        let pasteIndex: Int

        guard !cutBank.isEmpty else {
            print("Paste skipped. Cutbank is empty.")
            return
        }

        if banks[type.rawValue].patches.isEmpty {
            pasteIndex = 0
        } else {
            // TODO: Allow only one selected destination patch when pasting or the result will be unpredictable
            guard let pastePatch = banks[type.rawValue].selections.first else {
                print("Paste skipped. No patch selected in destination lane with index \(type.rawValue).")
                return
            }

            guard let pastePatchIndex = banks[type.rawValue].patches.firstIndex(where: {pastePatch.id == $0.id}) else {
                assertionFailure("Paste failed! Selected patch not found in destination lane with index \(type.rawValue).")
                return
            }

            pasteIndex = pastePatchIndex
        }

        // Unselect all patches at the destination before pasting (which could mess up selection)
        banks[type.rawValue].selections.removeAll()

        if isCopyAndPaste {
            // Insert copies of patches at paste position
            banks[type.rawValue].patches.insert(contentsOf: cutBank.sorted().map({$0.copyWithNewID()}), at: pasteIndex)
            updateLanesAndIndices(forPatches: &banks[type.rawValue].patches, inLane: type.rawValue)
        } else if cutBankType != type {
            // Insert patches in new lane
            banks[type.rawValue].patches.insert(contentsOf: cutBank.sorted(), at: pasteIndex)
            updateLanesAndIndices(forPatches: &banks[type.rawValue].patches, inLane: type.rawValue)

            // Remove patches from old lane
            remove(patches: Array(cutBank), fromBank: cutBankType)
            updateIndices(forPatches: &banks[cutBankType.rawValue].patches)

            // Mark bank as having unsaved changes
            setSaveStatus(forBank: cutBankType)
        } else {
            // Reorder patches within lane
            banks[type.rawValue].patches.moveSubranges(RangeSet(IndexSet(cutBank.compactMap({patch in
                    banks[type.rawValue].patches.firstIndex(where: {patch.id == $0.id})
                }))),
                to: pasteIndex
            )
            updateIndices(forPatches: &banks[type.rawValue].patches)
        }

        // Unselect patches at the source that were selected to be cut
        cutBank.forEach({ banks[cutBankType.rawValue].selections.remove($0)})
        cutBank.removeAll()

        // Mark bank as having unsaved changes
        setSaveStatus(forBank: type)
    }

    private func movedPatches(forBank type: BankType) -> [Patch] {
        banks[type.rawValue].patches.filter({$0.sourceID == nil && ($0.lane != $0.newLane || $0.index != $0.newIndex)})
    }

    private func copiedPatches(forBank type: BankType) -> [Patch] {
        banks[type.rawValue].patches.filter({$0.sourceID != nil})
    }

    private func renamedPatches(forBank type: BankType) -> [Patch] {
        banks[type.rawValue].patches.filter({$0.name != $0.storedName})
    }

    private func longFileNamePatches(forBank type: BankType) -> [Patch] {
        banks[type.rawValue].patches.filter({$0.longFileName != nil})
    }

    private func truncateLongFileNames(forBank type: BankType) {
        longFileNamePatches(forBank: type).forEach { patch in
            guard let fromType = BankType(rawValue: patch.lane) else {
                assertionFailure("Truncate file name failed! Bank type for lane with index \(patch.lane) not found.")
                return
            }

            guard let longFileName = patch.longFileName else {
                assertionFailure("Truncate file name failed! Patch with index \(patch.index) not marked with long file name.")
                return
            }

            let fromFileName = "\(longFileName).PRO"
            let fromFileURL = dirURL(forBank: fromType).appending(path: fromFileName)

            let toFileName = String(format: "%03d.PRO", patch.index+1)
            let toFileURL = dirURL(forBank: fromType).appending(path: toFileName)

            fileHandler.renameFile(fromURL: fromFileURL, toURL: toFileURL)
        }
    }

    private func movePatchesToTemp(forBank toType: BankType) -> [Patch] {
        let patches = movedPatches(forBank: toType)

        // Rename to temporary filenames to avoid clashing with existing filenames
        patches.forEach { patch in
            guard let fromType = BankType(rawValue: patch.lane) else {
                assertionFailure("Save to temp failed! Bank type for lane with index \(patch.lane) not found.")
                return
            }

            let fromFileName = String(format: "%03d.PRO", patch.index+1)
            let fromFileURL = dirURL(forBank: fromType).appending(path: fromFileName)

            let toFileName = String(format: "%03dT.PRO", patch.newIndex+1)
            let toFileURL = dirURL(forBank: toType).appending(path: toFileName)

            fileHandler.renameFile(fromURL: fromFileURL, toURL: toFileURL)
        }

        return patches
    }

    private func copyPatchesToTemp(forBank toType: BankType) -> [Patch] {
        let patches = copiedPatches(forBank: toType)

        // Rename to temporary filenames to avoid clashing with existing filenames
        patches.forEach { patch in
            guard let fromType = BankType(rawValue: patch.lane) else {
                assertionFailure("Save to temp failed! Bank type for lane with index \(patch.lane) not found.")
                return
            }

            // Copy the file from the source patch, not from a copy of the source
            guard
                let sourceID = patch.sourceID,
                let sourcePatch = patchWithID(sourceID)
            else {
                assertionFailure("Copy file failed! Source patch for \(patch.name) not found.")
                return
            }

            let fromFileName = String(format: "%03d.PRO", sourcePatch.index+1)
            let fromFileURL = dirURL(forBank: fromType).appending(path: fromFileName)

            let toFileName = String(format: "%03dT.PRO", patch.newIndex+1)
            let toFileURL = dirURL(forBank: toType).appending(path: toFileName)

            fileHandler.copyFile(fromURL: fromFileURL, toURL: toFileURL)
        }

        return patches
    }

    private func renameTempPatches(_ patchList: [Patch]) {
        // Rename to actual filenames when there is no longer a risk of name clash
        patchList.forEach { patch in
            guard let type = BankType(rawValue: patch.newLane) else {
                assertionFailure("Save from temp failed! Bank type for lane with index \(patch.lane) not found.")
                return
            }

            let fromFileName = String(format: "%03dT.PRO", patch.newIndex+1)
            let toFileName = String(format: "%03d.PRO", patch.newIndex+1)

            let fromFileURL = dirURL(forBank: type).appending(path: fromFileName)
            let toFileURL = dirURL(forBank: type).appending(path: toFileName)

            fileHandler.renameFile(fromURL: fromFileURL, toURL: toFileURL)
        }
    }

    private func saveRenamedPatches(forBank type: BankType) {
        renamedPatches(forBank: type).forEach { patch in
            let fileName = String(format: "%03d.PRO", patch.index+1)
            let fileURL = dirURL(forBank: type).appending(path: fileName)
            fileHandler.renamePatch(fileURL: fileURL, newName: patch.name)
        }
    }

    private mutating func deleteMarkedPatches() {
        toBeDeleted.forEach { patch in
            guard let bankType = BankType(rawValue: patch.lane) else {
                assertionFailure("Deletion failed! Bank type for lane with index \(patch.lane) not found.")
                return
            }

            let fileName = String(format: "%03d.PRO", patch.index+1)
            let fileURL = dirURL(forBank: bankType).appending(path: fileName)

            fileHandler.deleteFile(fileURL: fileURL)
        }

        toBeDeleted.removeAll()
    }

    public func isDirMissing(forBank type: BankType) -> Bool {
        let hasPatches = !banks[type.rawValue].patches.isEmpty

        if banks[type.rawValue].isDirLoaded {
            return hasPatches && !fileHandler.doesDirExist(dirURL: dirURL(forBank: type))
        } else {
            return hasPatches
        }
    }

    private var areAllDirsLoaded: Bool {
        for type in BankType.allCases {
            if isDirMissing(forBank: type) {
                return false
            }
        }

        return true
    }

    public mutating func createDirIfMissing(forBank type: BankType, dirURL: URL) throws {
        try fileHandler.createDir(dirURL: dirURL)
        banks[type.rawValue].title = dirURL.lastPathComponent
        banks[type.rawValue].dirURL = dirURL
        banks[type.rawValue].isDirLoaded = true
    }

    public mutating func load(dirURL: URL) async throws {
        let subDirNames = try await fileHandler.subDirNames(at: dirURL)
        let lastLane = min(subDirNames.count, 5)
        var lane = 0

        for subDirName in subDirNames[lane..<lastLane] {
            if let bankType = BankType.allCases[safeIndex: lane] {
                let bankURL = dirURL.appending(path: subDirName)
                let patchList = try await fileHandler.openDir(at: bankURL, intoLane: lane)
                try validateIndices(forPatches: patchList, dirName: subDirName)
                load(patches: patchList, toBank: bankType, dirURL: bankURL)
                rename(bank: bankType, withTitle: subDirName)

                if !longFileNamePatches(forBank: bankType).isEmpty {
                    // Mark bank as having unsaved changes
                    setSaveStatus(forBank: bankType)
                }

                lane += 1
            }
        }
    }

    public mutating func load(bank type: BankType, dirURL: URL) async throws {
        let patchList = try await fileHandler.openDir(at: dirURL, intoLane: type.rawValue)
        try validateIndices(forPatches: patchList, dirName: dirURL.lastPathComponent)
        load(patches: patchList, toBank: type, dirURL: dirURL)
        rename(bank: type, withTitle: dirURL.lastPathComponent)

        if !longFileNamePatches(forBank: type).isEmpty {
            // Mark bank as having unsaved changes
            setSaveStatus(forBank: type)
        }
    }

    public mutating func save() {
        if areAllDirsLoaded {
            // Ensure long file names are truncated before performing operations relying on short names
            BankType.allCases.forEach({truncateLongFileNames(forBank: $0)})
            BankType.allCases.forEach({clearLongFileNames(forBank: $0)})

            // Ensure patch files are copied before potentially being moved or deleted
            let copyPatches = BankType.allCases.flatMap({copyPatchesToTemp(forBank: $0)})

            // Ensure all copies are done before any moves, to avoid renaming files before they are copied
            let movePatches = BankType.allCases.flatMap({movePatchesToTemp(forBank: $0)})

            // After copy operations, all patches have their own files and no longer need copying
            // Move operations must also be complete before resetting this status which these also rely upon
            BankType.allCases.forEach({resetCopyStatuses(forBank: $0)})

            // Delete marked patches before renaming temp patches to avoid name clashes
            deleteMarkedPatches()
            renameTempPatches(copyPatches + movePatches)

            BankType.allCases.forEach({resetLanesAndIndices(forBank: $0)})
            BankType.allCases.forEach({saveRenamedPatches(forBank: $0)})
            BankType.allCases.forEach({resetPatchNames(forBank: $0)})

            // Mark bank as no longer having unsaved changes
            BankType.allCases.forEach({clearSaveStatus(forBank: $0)})
        }
    }
}
