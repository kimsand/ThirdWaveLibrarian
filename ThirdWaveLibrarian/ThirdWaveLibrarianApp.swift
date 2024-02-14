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
                                    banks = Banks()
                                    try await banks.load(dirURL: dirURL)
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
                                        try await banks.load(bank: type, dirURL: dirURL)
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
                    BankType.allCases.forEach { type in
                        if banks.isDirMissing(forBank: type) {
                            let panel = NSSavePanel()

                            panel.canCreateDirectories = true
                            panel.showsTagField = false
                            panel.message = "Choose where to create the directory for bank lane \(type.rawValue+1)"
                            panel.nameFieldLabel = "Bank name"
                            panel.nameFieldStringValue = banks.saveName(forBank: type)
                            panel.prompt = "Create bank"

                            if panel.runModal() == .OK {
                                Task {
                                    do {
                                        if let dirURL = panel.url {
                                            try banks.createDirIfMissing(forBank: type, dirURL: dirURL)
                                            banks.save()
                                        }
                                    } catch let error as FileError {
                                        self.error = error
                                        doShowAlert = true
                                    }
                                }
                            }
                        }
                    }

                    banks.save()
                }.keyboardShortcut("s")
            }
        }
    }
}
