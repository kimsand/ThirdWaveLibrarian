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

    private var LoadBanksButton: some View {
        Button("Load banks into all lanes...") {
            let panel = NSOpenPanel()

            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false

            if panel.runModal() == .OK {
                Task(priority: .userInitiated) {
                    do {
                        if let dirURL = panel.url {
                            banks = Banks()
                            try await $banks.load(dirURL: dirURL)
                        }
                    } catch let error as FileError {
                        self.error = error
                        doShowAlert = true
                    }
                }
            }
        }
    }

    private func LoadBankButton(type: BankType) -> some View {
        Button("Load bank into lane \(type.rawValue+1)...") {
            let panel = NSOpenPanel()

            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false

            if panel.runModal() == .OK {
                Task(priority: .userInitiated) {
                    do {
                        if let dirURL = panel.url {
                            try await $banks.load(bank: type, dirURL: dirURL)
                        }
                    } catch let error as FileError {
                        self.error = error
                        doShowAlert = true
                    }
                }
            }
        }
    }
    
    private var SaveBanksButton: some View {
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
                        Task(priority: .userInitiated) {
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
        }
    }
    
    var body: some Scene {
        Window("Third Wave Librarian", id: "banks-window") {
            BanksView(banks: $banks)
                .alert(isPresented: $doShowAlert, error: error) { _ in
                } message: { error in
                    Text(error.recoverySuggestion ?? "Ensure all files are valid patch files and are named correctly.")
                }
        }.commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                LoadBanksButton
                    .keyboardShortcut("o")
                Divider()

                ForEach(BankType.allCases, id: \.rawValue) { type in
                    LoadBankButton(type: type)
                        .keyboardShortcut(KeyboardShortcut(KeyEquivalent(Character("\(type.rawValue+1)"))))
                }

                Divider()

                SaveBanksButton
                    .keyboardShortcut("s")
            }
        }
    }
}

// Calling mutating async functions is no longer allowed on a struct through a bound value (binding). However, the bound reference ($binding) can call these functions on its own wrapped value.

@MainActor
extension Binding where Value == Banks {
    func load(dirURL: URL) async throws {
        try await wrappedValue.load(dirURL: dirURL)
    }
    
    func load(bank type: BankType, dirURL: URL) async throws {
        try await wrappedValue.load(bank: type, dirURL: dirURL)
    }
}
