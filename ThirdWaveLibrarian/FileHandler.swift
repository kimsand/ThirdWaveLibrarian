//
//  FileHandler.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 26/11/2023.
//

import Foundation

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
                let index = Int(fileURL.deletingPathExtension().lastPathComponent) ?? 0

                var lineNumber = 0
                for try await line in fileURL.lines.prefix(5) {
                    if lineNumber == 1 {
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
        } catch let error as NSError {
            print("Error: \(error)")
        }
    }
}
