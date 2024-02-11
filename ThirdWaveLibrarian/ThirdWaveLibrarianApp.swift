//
//  ThirdWaveLibrarianApp.swift
//  ThirdWaveLibrarian
//
//  Created by Kim André Sand on 26/11/2023.
//

import SwiftUI

@main
struct ThirdWaveLibrarianApp: App {
    @State private var banks = Banks()
    @State private var doShowAlert = false
    @State private var error: FileError? = nil

    var body: some Scene {
        Window("Third Wave Librarian", id: "banks-window") {
            BanksView(banks: $banks)
                .alert(isPresented: $doShowAlert, error: error) { _ in
                } message: { error in
                    Text(error.recoverySuggestion ?? "Ensure all files are valid patch files and are named correctly.")
                }
        }.commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("Load banks into all lanes...") {
                    let panel = NSOpenPanel()

                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false

                    if panel.runModal() == .OK {
                        Task {
                            do {
                                if let dirURL = panel.url {
                                    let fileHandler = FileHandler()

                                    banks = Banks()

                                    let subDirNames = try await fileHandler.subDirNames(at: dirURL)
                                    let lastLane = min(subDirNames.count, 5)
                                    var lane = 0

                                    for subDirName in subDirNames[lane..<lastLane] {
                                        if let bankType = BankType.allCases[safeIndex: lane] {
                                            let bankURL = dirURL.appendingPathComponent(subDirName, conformingTo: .directory)
                                            let patchList = try await fileHandler.openDir(at: bankURL, intoLane: lane)
                                            banks.load(patches: patchList, toBank: bankType, dirURL: bankURL)
                                            banks.rename(bank: bankType, withTitle: subDirName)
                                            lane += 1
                                        }
                                    }
                                }
                            } catch let error as FileError {
                                self.error = error
                                doShowAlert = true
                            }
                        }
                    }
                }.keyboardShortcut("o")

                Divider()

                ForEach(BankType.allCases, id: \.rawValue) { type in
                    Button("Load bank into lane \(type.rawValue+1)...") {
                        let panel = NSOpenPanel()

                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false

                        if panel.runModal() == .OK {
                            Task {
                                do {
                                    if let dirURL = panel.url {
                                        let fileHandler = FileHandler()

                                        let patchList = try await fileHandler.openDir(at: dirURL, intoLane: type.rawValue)
                                        banks.load(patches: patchList, toBank: type, dirURL: dirURL)
                                        banks.rename(bank: type, withTitle: dirURL.lastPathComponent)
                                    }
                                } catch let error as FileError {
                                    self.error = error
                                    doShowAlert = true
                                }
                            }
                        }
                    }.keyboardShortcut(KeyboardShortcut(KeyEquivalent(Character("\(type.rawValue+1)"))))
                }

                Divider()

                Button("Save all lanes") {
                    let tempPatches = BankType.allCases.flatMap({banks.saveReorderedPatchesToTemp(forBank: $0)})
                    banks.saveTempPatchesAfterMove(patches: tempPatches)
                    BankType.allCases.forEach({banks.resetLanesAndIndices(forBank: $0)})
                    BankType.allCases.forEach({banks.saveRenamedPatches(forBank: $0)})
                    BankType.allCases.forEach({banks.resetPatchNames(forBank: $0)})
                }.keyboardShortcut("s")
            }
        }
    }
}
