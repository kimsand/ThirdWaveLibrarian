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
    case wrongFileHeader(fileName: String)
    case noFilesFound(dirName: String)
    case missingSubDir(dirName: String)
    case failedDirContents(dirName: String)

    var errorDescription: String? {
        switch self {
        case .invalidFileName(fileName: let fileName):
            "Invalid file name: \(fileName)"
        case .wrongFileHeader(fileName: let fileName):
            "Invalid file header for \(fileName)"
        case .noFilesFound(dirName: let dirName):
            "No files in \(dirName)"
        case .missingSubDir(dirName: let dirName):
            "Missing subdirectory in \(dirName)"
        case .failedDirContents(dirName: let dirName):
            "Failed to get directory contents of \(dirName)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidFileName:
            "The patch files must be named NNN.PRO, where NNN is a 3 digit, zero-padded number like 001."
        case .wrongFileHeader:
            "This is not a supported patch file."
        case .noFilesFound:
            "No files found in the provided directory."
        case .missingSubDir:
            "When opening multiple banks, the root directory must contain a subdirectory for each bank."
        case .failedDirContents:
            "Ensure the directory exists and that this application has permission to read and write to it."
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

                // Convert filename into patch index (1-indexed to 0-indexed)
                guard let fileInt = Int(fileName) else {
                    throw FileError.invalidFileName(fileName: fileName)
                }
                let index = fileInt - 1

                var lineNumber = 0
                for try await line in fileURL.lines.prefix(2) {
                    if lineNumber == LineNumberFor.fileFormat {
                        guard line.starts(with: "W3_PROG") else {
                            throw FileError.wrongFileHeader(fileName: fileName)
                        }
                    } else if lineNumber == LineNumberFor.patchName {
                        await patchActor.appendPatch(patch: Patch(name: line, index: index, lane: lane))
                    }

                    lineNumber += 1
                }
            }

            let patches = await patchActor.patchList()
            guard !patches.isEmpty else {
                throw FileError.noFilesFound(dirName: dirURL.lastPathComponent)
            }
            return patches
        }

        return try await task.value
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
            var lines = text.components(separatedBy: "\r\n")
            lines.replace(newName, at: LineNumberFor.patchName)
            let result = lines.joined(separator: "\r\n")
            try result.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            assertionFailure("Rename patch failed! Error: \(error.localizedDescription)")
        }
    }
}
