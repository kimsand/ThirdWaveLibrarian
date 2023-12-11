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
                                let lastLane = min(subDirNames.count, 5)
                                var lane = 0

                                for subDirName in subDirNames[lane..<lastLane] {
                                    if let bankType = BankType.allCases[safeIndex: lane] {
                                        let bankURL = dirURL.appendingPathComponent(subDirName, conformingTo: .directory)
                                        let patchList = await fileHandler.openDir(at: bankURL, intoLane: lane)
                                        banks.load(patches: patchList, toBank: bankType, dirURL: bankURL)
                                        banks.rename(bank: bankType, withTitle: subDirName)
                                        lane += 1
                                    }
                                }
                            }
                        }
                    }
                }.keyboardShortcut("o")

                Divider()

                ForEach(BankType.allCases, id: \.self) { type in
                    Button("Load bank into lane \(type.rawValue+1)...") {
                        let panel = NSOpenPanel()

                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false

                        if panel.runModal() == .OK {
                            Task {
                                if let dirURL = panel.url {
                                    let fileHandler = FileHandler()

                                    let patchList = await fileHandler.openDir(at: dirURL, intoLane: type.rawValue)
                                    banks.load(patches: patchList, toBank: type, dirURL: dirURL)
                                    banks.rename(bank: type, withTitle: dirURL.lastPathComponent)
                                }
                            }
                        }
                    }.keyboardShortcut(KeyboardShortcut(KeyEquivalent(Character("\(type.rawValue+1)"))))
                }

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
