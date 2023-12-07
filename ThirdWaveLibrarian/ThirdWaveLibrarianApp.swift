//
//  ThirdWaveLibrarianApp.swift
//  ThirdWaveLibrarian
//
//  Created by Kim André Sand on 26/11/2023.
//

import SwiftUI

@main
struct ThirdWaveLibrarianApp: App {
//    @Environment(\.openWindow) private var openWindow

    @State private var banks = Banks()

    var body: some Scene {
        Window("Third Wave Librarian", id: "banks-window") {
            BanksView(banks: $banks)
        }.commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("Load banks into all lanes...") {
                    let panel = NSOpenPanel()

                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false

                    if panel.runModal() == .OK {
                        Task {
                            if let dirURL = panel.url {
                                let fileHandler = FileHandler()

                                banks = Banks()

                                let subDirNames = await fileHandler.subDirNames(at: dirURL)
                                let bankTypes = BankType.allCases

                                let lastLane = min(subDirNames.count, 5)
                                var lane = 1
                                for subDirName in subDirNames[lane-1..<lastLane] {
                                    if let bankType = bankTypes[safeIndex: lane-1] {
                                        let bankURL = dirURL.appendingPathComponent(subDirName, conformingTo: .directory)
                                        let patchList = await fileHandler.openDir(at: bankURL, intoLane: lane)
                                        banks.load(patches: patchList, toBank: bankType, dirURL: bankURL)
                                        banks.rename(bank: bankType, withTitle: subDirName)
                                        lane += 1
                                    }
                                }

//                                openWindow(id: "banks-window")
                            }
                        }
                    }
                }.keyboardShortcut("o")

                Divider()

                Button("Load bank into lane 1...") {
                    let panel = NSOpenPanel()

                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false

                    if panel.runModal() == .OK {
                        Task {
                            if let dirURL = panel.url {
                                let fileHandler = FileHandler()

                                let patchList = await fileHandler.openDir(at: dirURL, intoLane: 1)
                                banks.load(patches: patchList, toBank: .bank1, dirURL: dirURL)
                                banks.rename(bank: .bank1, withTitle: dirURL.lastPathComponent)
                            }
                        }
                    }
                }.keyboardShortcut("1")
                Button("Load bank into lane 2...") {
                    let panel = NSOpenPanel()

                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false

                    if panel.runModal() == .OK {
                        Task {
                            if let dirURL = panel.url {
                                let fileHandler = FileHandler()

                                let patchList = await fileHandler.openDir(at: dirURL, intoLane: 2)
                                banks.load(patches: patchList, toBank: .bank2, dirURL: dirURL)
                                banks.rename(bank: .bank2, withTitle: dirURL.lastPathComponent)
                            }
                        }
                    }
                }.keyboardShortcut("2")
                Button("Load bank into lane 3...") {
                    let panel = NSOpenPanel()

                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false

                    if panel.runModal() == .OK {
                        Task {
                            if let dirURL = panel.url {
                                let fileHandler = FileHandler()

                                let patchList = await fileHandler.openDir(at: dirURL, intoLane: 3)
                                banks.load(patches: patchList, toBank: .bank3, dirURL: dirURL)
                                banks.rename(bank: .bank3, withTitle: dirURL.lastPathComponent)
                            }
                        }
                    }
                }.keyboardShortcut("3")
                Button("Load bank into lane 4...") {
                    let panel = NSOpenPanel()

                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false

                    if panel.runModal() == .OK {
                        Task {
                            if let dirURL = panel.url {
                                let fileHandler = FileHandler()

                                let patchList = await fileHandler.openDir(at: dirURL, intoLane: 4)
                                banks.load(patches: patchList, toBank: .bank4, dirURL: dirURL)
                                banks.rename(bank: .bank4, withTitle: dirURL.lastPathComponent)
                            }
                        }
                    }
                }.keyboardShortcut("4")
                Button("Load bank into lane 5...") {
                    let panel = NSOpenPanel()

                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false

                    if panel.runModal() == .OK {
                        Task {
                            if let dirURL = panel.url {
                                let fileHandler = FileHandler()

                                let patchList = await fileHandler.openDir(at: dirURL, intoLane: 5)
                                banks.load(patches: patchList, toBank: .bank5, dirURL: dirURL)
                                banks.rename(bank: .bank5, withTitle: dirURL.lastPathComponent)
                            }
                        }
                    }
                }.keyboardShortcut("5")

                Divider()

                Button("Save all lanes") {
                    let patches = BankType.allCases.flatMap({banks.saveReorderedPatchesToTemp(forBank: $0)})
                    banks.saveTempPatchesAfterMove(patches: patches)
                    BankType.allCases.forEach({banks.resetLanesAndIndices(forBank: $0)})
                }.keyboardShortcut("s")
            }
        }
    }
}
