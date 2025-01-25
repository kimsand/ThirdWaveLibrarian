//
//  ThirdWaveTool.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 24/01/2024.
//

import Foundation
import ThirdWaveLibrary
import ArgumentParser

@available(macOS 13.0, *)
@main
struct ThirdWaveTool: ParsableCommand {
    @Option(name: .shortAndLong, help: "The directory to read the banks from. The path must be absolute, e.g. \"/users/me/3w/banks\" or \"c:\\users\\me\\3w\\banks\".")
    var fromDir: String

    @Option(name: .shortAndLong, help: "The text file to write the bank info to. The path must be absolute, e.g. \"/users/me/3w/banks.txt\" or \"c:\\users\\me\\3w\\banks.txt\".")
    var toFile: String

    mutating func run() throws {
        let semaphore = DispatchSemaphore(value: 0)

        let dirURL = URL(filePath: fromDir, relativeTo: URL(filePath: "/"))
        let fileURL = URL(filePath: toFile, relativeTo: URL(filePath: "/"))
        var banks = Banks()

        Task(priority: .userInitiated) {
            defer {
                semaphore.signal()
            }

            do {
                try await banks.load(dirURL: dirURL)
                banks.writeBankTextToFile(fileURL: fileURL)
                print("Wrote patch names for \(banks.banks.count) banks to \"\(fileURL.lastPathComponent)\".")
            } catch let error as FileError {
                print(error.recoverySuggestion ?? "Ensure all files are valid patch files and are named correctly.")
            }
        }

        semaphore.wait()
    }
}
