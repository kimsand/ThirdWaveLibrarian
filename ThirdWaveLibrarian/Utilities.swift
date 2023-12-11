//
//  Utilities.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 29/11/2023.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }

    mutating func replace(
        _ newElement: Element,
        at i: Int
    ) {
        replaceSubrange(i...i, with: [newElement])
    }
}
