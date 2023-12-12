//
//  ViewUtilities.swift
//  Third Wave Librarian
//
//  Created by Kim André Sand on 12/12/2023.
//

import SwiftUI

// An "atomic" text field that only changes the bound text when the whole editing operation is complete.
// This avoids the text field being reloaded, and losing focus, on any single character edit.

struct AtomicTextField: View {
    private let label: String
    @State var changingText: String
    @Binding var finalText: String
    private let onEditingDone: () -> Void

    init(_ label: String, text: Binding<String>, onEditingDone: @escaping () -> Void = {}) {
        self.label = label
        _finalText = text
        changingText = text.wrappedValue
        self.onEditingDone = onEditingDone
    }

    var body: some View {
        TextField(changingText, text: $changingText, onEditingChanged: { isChanged in
            if !isChanged {
                finalText = changingText
                onEditingDone()
            }
        })
        .onSubmit {
            finalText = changingText
            onEditingDone()
        }
    }
}
