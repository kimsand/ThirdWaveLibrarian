//
//  Bank.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 10/12/2023.
//

import Foundation

struct Bank {
    var patches = [Patch]()
    var selections = Set<Patch>()
    var title: String
    let saveName: String
    var dirURL = URL.documentsDirectory
    var isDirLoaded = false
    var placeholder = [Patch(name: "Placeholder", index: 0, lane: 0)]
    var hasUnsavedChanges = false
}
