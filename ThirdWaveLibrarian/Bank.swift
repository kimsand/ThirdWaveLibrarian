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
    var dirURL = URL.currentDirectory()
}
