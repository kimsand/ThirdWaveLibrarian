//
//  FileHandler.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 26/11/2023.
//

import Foundation

struct LineNumberFor {
    static let patchName = 1
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

class FileHandler {
    let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]

    func subDirNames(at dirURL: URL) async -> [String] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options:options).filter(\.hasDirectoryPath)
            return fileURLs.map({$0.lastPathComponent}).sorted()
        } catch {
            return []
        }
    }

    private func filesInDirectory(at url: URL, options: FileManager.DirectoryEnumerationOptions) -> AsyncStream<URL> {
        AsyncStream { continuation in
            Task {
                let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)

                while let fileURL = enumerator?.nextObject() as? URL {
                    // fileURL.hasDirectoryPath
                    continuation.yield( fileURL )
                }

                continuation.finish()
            }
        }
    }

    func openDir(at dirURL: URL, intoLane lane: Int) async -> [Patch] {
        let patchActor = PatchActor()

        let value: ([Patch])? = try? await Task {
            let filesInDir = filesInDirectory(at: dirURL, options: options)

            for await fileURL in filesInDir {
                // Convert filename into patch index (1-indexed to 0-indexed)
                let index = (Int(fileURL.deletingPathExtension().lastPathComponent) ?? 1) - 1

                var lineNumber = 0
                for try await line in fileURL.lines.prefix(2) {
                    if lineNumber == LineNumberFor.patchName {
                        await patchActor.appendPatch(patch: Patch(name: line, index: index, lane: lane))
                    }

                    lineNumber += 1
                }
            }

            return await patchActor.patchList()
        }.value

        return value ?? [Patch]()
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
