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
                VStack(alignment: .leading) {
                    List(selection: $banks.selBank1) {
                        Section {
                            ForEach($banks.bank1, id: \.self, editActions: .move) { $patch in
                                Text(patch.name)
                            }.onMove { from, to in
                                banks.reorderPatches(from: from, to: to, inBank: .bank1)
                            }
                        } header: {
                            Text(banks.bank1Title)
                        }
                    }.onDeleteCommand {
                        banks.removeSelectedPatches(fromBank: .bank1)
                    }.onCutCommand {
                        banks.cutPatches(fromBank: .bank1)
                        return [NSItemProvider(object: "ThirdWavePatch" as NSString)]
                    }.onPasteCommand(of: ["public.plain-text"]) { _ in
                        banks.pasteCutPatches(toBank: .bank1)
                    }
                    Text("\(banks.bank1.count) patch\(banks.bank1.count != 1 ? "es" : "")").padding(.leading, 14)
                }
                VStack(alignment: .leading) {
                    List(selection: $banks.selBank2) {
                        Section {
                            ForEach($banks.bank2, id: \.self, editActions: .move) { $patch in
                                Text(patch.name)
                            }.onMove { from, to in
                                banks.reorderPatches(from: from, to: to, inBank: .bank2)
                            }
                        } header: {
                            Text(banks.bank2Title)
                        }
                    }.onDeleteCommand {
                        banks.removeSelectedPatches(fromBank: .bank2)
                    }.onCutCommand {
                        banks.cutPatches(fromBank: .bank2)
                        return [NSItemProvider(object: "ThirdWavePatch" as NSString)]
                    }.onPasteCommand(of: ["public.plain-text"]) { _ in
                        banks.pasteCutPatches(toBank: .bank2)
                    }
                    Text("\(banks.bank2.count) patch\(banks.bank2.count != 1 ? "es" : "")").padding(.leading, 14)
                }
                VStack(alignment: .leading) {
                    List(selection: $banks.selBank3) {
                        Section {
                            ForEach($banks.bank3, id: \.self, editActions: .move) { $patch in
                                Text(patch.name)
                            }.onMove { from, to in
                                banks.reorderPatches(from: from, to: to, inBank: .bank3)
                            }
                        } header: {
                            Text(banks.bank3Title)
                        }
                    }.onDeleteCommand {
                        banks.removeSelectedPatches(fromBank: .bank3)
                    }.onCutCommand {
                        banks.cutPatches(fromBank: .bank3)
                        return [NSItemProvider(object: "ThirdWavePatch" as NSString)]
                    }.onPasteCommand(of: ["public.plain-text"]) { _ in
                        banks.pasteCutPatches(toBank: .bank3)
                    }
                    Text("\(banks.bank3.count) patch\(banks.bank3.count != 1 ? "es" : "")").padding(.leading, 14)
                }
                VStack(alignment: .leading) {
                    List(selection: $banks.selBank4) {
                        Section {
                            ForEach($banks.bank4, id: \.self, editActions: .move) { $patch in
                                Text(patch.name)
                            }.onMove { from, to in
                                banks.reorderPatches(from: from, to: to, inBank: .bank4)
                            }
                        } header: {
                            Text(banks.bank4Title)
                        }
                    }.onDeleteCommand {
                        banks.removeSelectedPatches(fromBank: .bank4)
                    }.onCutCommand {
                        banks.cutPatches(fromBank: .bank4)
                        return [NSItemProvider(object: "ThirdWavePatch" as NSString)]
                    }.onPasteCommand(of: ["public.plain-text"]) { _ in
                        banks.pasteCutPatches(toBank: .bank4)
                    }
                    Text("\(banks.bank4.count) patch\(banks.bank4.count != 1 ? "es" : "")").padding(.leading, 14)
                }
                VStack(alignment: .leading) {
                    List(selection: $banks.selBank5) {
                        Section {
                            ForEach($banks.bank5, id: \.self, editActions: .move) { $patch in
                                Text(patch.name)
                            }.onMove { from, to in
                                banks.reorderPatches(from: from, to: to, inBank: .bank5)
                            }
                        } header: {
                            Text(banks.bank5Title)
                        }
                    }.onDeleteCommand {
                        banks.removeSelectedPatches(fromBank: .bank5)
                    }.onCutCommand {
                        banks.cutPatches(fromBank: .bank5)
                        return [NSItemProvider(object: "ThirdWavePatch" as NSString)]
                    }.onPasteCommand(of: ["public.plain-text"]) { _ in
                        banks.pasteCutPatches(toBank: .bank5)
                    }
                    Text("\(banks.bank5.count) patch\(banks.bank5.count != 1 ? "es" : "")").padding(.leading, 14)
                }
            }
        }
        .padding()
    }
}

struct BanksView_Previews: PreviewProvider {
    static let dummyPatch1 = Patch(name: "Dummy Patch 1", index: 0, lane: 1)
    static let dummyPatch2 = Patch(name: "Dummy Patch 2", index: 0, lane: 2)
    static let dummyPatch3 = Patch(name: "Dummy Patch 3", index: 0, lane: 3)
    static let dummyPatch4 = Patch(name: "Dummy Patch 4", index: 0, lane: 4)
    static let dummyPatch5 = Patch(name: "Dummy Patch 5", index: 0, lane: 5)

    @State static var banks = Banks(
        bank1: [dummyPatch1],
        bank2: [dummyPatch2],
        bank3: [dummyPatch3],
        bank4: [dummyPatch4],
        bank5: [dummyPatch5]
    )

    static var previews: some View {
        return BanksView(banks: $banks)
    }
}

