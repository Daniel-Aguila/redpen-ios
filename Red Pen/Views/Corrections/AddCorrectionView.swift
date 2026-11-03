//
//  AddCorrectionView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import SwiftUI
import SwiftData

struct AddCorrectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("xp") private var xp: Int = 0
    
    @State private var original = ""
    @State private var corrected = ""
    @State private var note = ""
    
    var correction: Correction? = nil
    
    private var detected: MistakeType? {
        guard !original.trimmed.isEmpty,
              !corrected.trimmed.isEmpty,
              original.trimmed != corrected.trimmed else { return nil }
        return MistakeDetector.detect(original: original, corrected: corrected)
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section("What you wrote") {
                    TextField("저는 학생이에요", text: $original, axis: .vertical)
                }
                Section("Corrected") {
                    TextField("Partner's correction", text: $corrected, axis: .vertical)
                }

                if !original.trimmed.isEmpty && original.trimmed == corrected.trimmed {
                    Text("The correction is the same as what you wrote.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .onPaper()
                }

                if let detected {
                    Section("Detected") {
                        Label(detected.label, systemImage: detected.symbol)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(detected.color)
                    }
                }
                
                Section("Note") {
                    TextField("Optional", text: $note, axis:.vertical)
                }
            }
            .navigationTitle(correction == nil ? String(localized: "New Correction")
                                               : String(localized: "Edit Correction"))
            .navigationBarTitleDisplayMode(.inline)
            .paperBackground()
            .onAppear {
                if let correction {
                    original = correction.original
                    corrected = correction.corrected
                    note = correction.note
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save"){
                        save()
                    }
                    .disabled(original.trimmed.isEmpty ||
                              corrected.trimmed.isEmpty ||
                              original.trimmed == corrected.trimmed)
                }
            }
        }
    }
    
    private func save() {
        let o = original.trimmed
        let c = corrected.trimmed
        let n = note.trimmed

        if let correction {
            if !correction.isTypeManual {
                correction.type = MistakeDetector.detect(original: o, corrected: c)
            }
            correction.original = o
            correction.corrected = c
            correction.note = n
        } else {
            let cr = Correction(original: o, corrected: c, note: n)
            cr.type = MistakeDetector.detect(original: o, corrected: c)
            modelContext.insert(cr)
            xp += 5
        }
        dismiss()
    }
    
}

#Preview {
    AddCorrectionView()
        .modelContainer(for: Correction.self, inMemory: true)
}
