//
//  FileHandler.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 26/11/2023.
//

import Foundation

struct LineNumberFor {
    static let fileFormat = 0
    static let patchName = 1
}

enum FileError: LocalizedError {
    case invalidFileName(fileName: String)
    case duplicateFileIndex(dirName: String)
    case wrongFileHeader(fileName: String)
    case missingSubDir(dirName: String)
    case failedDirContents(dirName: String)
    case createDirFailed(dirName: String)

    var errorDescription: String? {
        switch self {
        case .invalidFileName(fileName: let fileName):
            "Invalid file name: \(fileName)"
        case .duplicateFileIndex(dirName: let dirName):
            "Duplicate file index: \(dirName)"
        case .wrongFileHeader(fileName: let fileName):
            "Invalid file header for \(fileName)"
        case .missingSubDir(dirName: let dirName):
            "Missing subdirectory in \(dirName)"
        case .failedDirContents(dirName: let dirName):
            "Failed to get directory contents of \(dirName)"
        case .createDirFailed(dirName: let dirName):
            "Failed to create directory named \(dirName)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidFileName:
            "The patch file names must end with NNN.PRO, where NNN is a 3 digit, zero-padded number like 001."
        case .duplicateFileIndex:
            "Patch file names within a bank directory must have unique indices (NNN.PRO), even if the file names are otherwise unique."
        case .wrongFileHeader:
            "This is not a supported patch file."
        case .missingSubDir:
            "When opening multiple banks, the root directory must contain a subdirectory for each bank."
        case .failedDirContents:
            "Ensure the directory exists and that this application has permission to read and write to it."
        case .createDirFailed:
            "Ensure the directory name is valid and that this application has permission to read and write to it."
        }
    }
}

private actor PatchActor {
    private var patches = [Patch]()

    func appendPatch(patch: Patch) {
        patches.append(patch)
    }

    func patchList() -> [Patch] {
        return patches.sorted()
    }
}

struct FileHandler {
    let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]

    func subDirNames(at dirURL: URL) async throws -> [String] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options:options).filter(\.hasDirectoryPath)
            guard !fileURLs.isEmpty else {
                throw FileError.missingSubDir(dirName: dirURL.lastPathComponent)
            }
            return fileURLs.map({$0.lastPathComponent}).sorted()
        } catch {
            throw FileError.failedDirContents(dirName: dirURL.lastPathComponent)
        }
    }

    private func filesInDirectory(at url: URL, options: FileManager.DirectoryEnumerationOptions) -> AsyncStream<URL> {
        AsyncStream { continuation in
            Task {
                let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)

                while let fileURL = enumerator?.nextObject() as? URL {
                    continuation.yield(fileURL)
                }

                continuation.finish()
            }
        }
    }

    func openDir(at dirURL: URL, intoLane lane: Int) async throws -> [Patch] {
        let patchActor = PatchActor()

        let task = Task {
            let filesInDir = filesInDirectory(at: dirURL, options: options)

            for await fileURL in filesInDir {
                guard !fileURL.hasDirectoryPath else {
                    continue
                }

                let fileName = fileURL.deletingPathExtension().lastPathComponent
                let fileSuffix = fileName.suffix(3)
                let suffixName = String(fileSuffix)

                guard
                    fileSuffix.count == 3,
                    let fileInt = Int(suffixName)
                else {
                    throw FileError.invalidFileName(fileName: fileName)
                }

                // Convert file suffix into patch index (1-indexed to 0-indexed)
                let index = fileInt - 1

                var lineNumber = 0
                for try await line in fileURL.lines.prefix(2) {
                    if lineNumber == LineNumberFor.fileFormat {
                        guard line.starts(with: "W3_PROG") else {
                            throw FileError.wrongFileHeader(fileName: fileName)
                        }
                    } else if lineNumber == LineNumberFor.patchName {
                        if fileName == suffixName {
                            await patchActor.appendPatch(patch: Patch(name: line, index: index, lane: lane))
                        } else {
                            var patch = Patch(name: line, index: index, lane: lane)
                            patch.setLongFileName(fileName)
                            await patchActor.appendPatch(patch: patch)
                        }
                    }

                    lineNumber += 1
                }
            }

            return await patchActor.patchList()
        }

        return try await task.value
    }

    func doesDirExist(dirURL: URL) -> Bool {
        FileManager.default.fileExists(atPath: dirURL.path(percentEncoded: false))
    }

    func createDir(dirURL: URL) throws {
        do {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: false)
        } catch {
            assertionFailure("Create directory failed! Error: \(error.localizedDescription)")
            throw FileError.createDirFailed(dirName: dirURL.lastPathComponent)
        }
    }

    func copyFile(fromURL: URL, toURL: URL) {
        do {
            try FileManager.default.copyItem(atPath: fromURL.relativePath, toPath: toURL.relativePath)
        } catch {
            assertionFailure("Copy file failed! Error: \(error.localizedDescription)")
        }
    }

    func renameFile(fromURL: URL, toURL: URL) {
        do {
            try FileManager.default.moveItem(atPath: fromURL.relativePath, toPath: toURL.relativePath)
        } catch {
            assertionFailure("Rename file failed! Error: \(error.localizedDescription)")
        }
    }

    func renamePatch(fileURL: URL, newName: String) {
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)

            guard let eolChar = text.firstMatch(of: /(\r\n|\r|\n)/)?.0 else {
                assertionFailure("Unable to find EOL character with regex!")
                return
            }

            var lines = text.components(separatedBy: eolChar)
            lines.replace(newName, at: LineNumberFor.patchName)
            let result = String(lines.joined(separator: eolChar))
            try result.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            assertionFailure("Rename patch failed! Error: \(error.localizedDescription)")
        }
    }

    func deleteFile(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.relativePath)
        } catch {
            assertionFailure("Delete file failed! Error: \(error.localizedDescription)")
        }
    }
}
