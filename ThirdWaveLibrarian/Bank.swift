//
//  Bank.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 10/12/2023.
//

import Foundation

@available(macOS 15.0, *)
public struct Bank: Sendable {
    public var patches = [Patch]()
    public var selections = Set<Patch>()
    public var title: String
    let saveName: String
    var dirURL = URL.documentsDirectory
    var isDirLoaded = false
    public var placeholder = [Patch(name: "Placeholder", index: 0, lane: 0)]
    public var hasUnsavedChanges = false

    public init(patches: [Patch]? = nil, title: String, saveName: String) {
        if let patches {
            self.patches = patches
        } else {
            self.patches = [Patch]()
        }
        self.title = title
        self.saveName = saveName
    }
}
