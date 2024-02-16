//
//  BanksView.swift
//  ThirdWaveLibrarian
//
//  Created by Kim André Sand on 26/11/2023.
//

import SwiftUI

struct BanksView: View {
    @Binding var banks: Banks

    var body: some View {
        VStack {
            HStack {
                ForEach(BankType.allCases, id: \.rawValue) { type in
                    VStack(alignment: .leading) {
                        if banks.banks[type.rawValue].patches.isEmpty {
                            List(selection: $banks.banks[type.rawValue].selections) {
                                Section {
                                    ForEach($banks.banks[type.rawValue].placeholder, id: \.self, editActions: .move) { $patch in
                                        Text(patch.name).foregroundStyle(Color.secondary)
                                        }
                                } header: {
                                    Text(banks.banks[type.rawValue].title)
                                }
                            }.onPasteCommand(of: ["public.plain-text"]) { _ in
                                banks.pasteCutPatches(toBank: type)
                            }
                        } else {
                            List(selection: $banks.banks[type.rawValue].selections) {
                                Section {
                                    ForEach($banks.banks[type.rawValue].patches, id: \.self, editActions: .move) { $patch in
                                        AtomicTextField(patch.storedName, text: $patch.name, onEditingDone: ({
                                            banks.updateSelectionAfterRename(patch: patch, inBank: type)
                                        }))
                                    }.onMove { from, to in
                                        banks.reorderPatches(from: from, to: to, inBank: type)
                                    }
                                } header: {
                                    Text(banks.banks[type.rawValue].title)
                                }
                            }.onDeleteCommand {
                                banks.removeSelectedPatches(fromBank: type)
                            }.onCutCommand {
                                banks.cutPatches(fromBank: type)
                                return [NSItemProvider(object: "ThirdWavePatch" as NSString)]
                            }.onCopyCommand {
                                banks.copyPatches(fromBank: type)
                                return [NSItemProvider(object: "ThirdWavePatch" as NSString)]
                            }.onPasteCommand(of: ["public.plain-text"]) { _ in
                                banks.pasteCutPatches(toBank: type)
                            }
                            Text("\(banks.banks[type.rawValue].patches.count) patch\(banks.banks[type.rawValue].patches.count != 1 ? "es" : "")")
                                .padding(.leading, 14)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct BanksView_Previews: PreviewProvider {
    static let dummyPatch1 = Patch(name: "Patch 1", index: 0, lane: 0)
    static let dummyPatch2 = Patch(name: "Patch 2", index: 0, lane: 1)
    static let dummyPatch3 = Patch(name: "Patch 3", index: 0, lane: 2)
    static let dummyPatch4 = Patch(name: "Patch 4", index: 0, lane: 3)
    static let dummyPatch5 = Patch(name: "Patch 5", index: 0, lane: 4)

    @State static var banks = Banks(banks: [
        Bank(patches: [dummyPatch1], title: "Bank 1", saveName: "Bank 1"),
        Bank(patches: [dummyPatch2], title: "Bank 2", saveName: "Bank 2"),
        Bank(patches: [dummyPatch3], title: "Bank 3", saveName: "Bank 3"),
        Bank(patches: [dummyPatch4, dummyPatch5], title: "Bank 4", saveName: "Bank 4"),
        Bank(patches: [], title: "Bank 5", saveName: "Bank 5")
        ]
    )

    static var previews: some View {
        return BanksView(banks: $banks)
    }
}
