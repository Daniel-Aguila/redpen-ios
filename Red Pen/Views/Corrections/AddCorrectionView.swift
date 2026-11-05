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
    
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    
    @State private var folder: Folder? = nil
    @State private var showingNewFolder = false
    @State private var newFolderName = ""
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
                
                Section("Folder") {
                    Picker("Folder", selection: $folder) {
                        Text("None").tag(Folder?.none)
                        ForEach(folders) { f in
                            Text(verbatim: "\(f.emoji) \(f.name)").tag(Optional(f))
                        }
                    }
                    Button("New folder…") {
                        showingNewFolder = true
                    }
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
                    folder = correction.folder
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
            .alert("New folder", isPresented: $showingNewFolder) {
                TextField("Name", text: $newFolderName)
                Button("Create") {
                    let f = Folder(name: newFolderName.trimmed)
                    modelContext.insert(f)
                    folder = f
                    newFolderName = ""
                }
                .disabled(newFolderName.trimmed.isEmpty)
                Button("Cancel", role: .cancel) {
                    newFolderName = ""
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
            correction.folder = folder
        } else {
            let cr = Correction(original: o, corrected: c, note: n)
            cr.folder = folder
            cr.type = MistakeDetector.detect(original: o, corrected: c)
            modelContext.insert(cr)
            xp += 5
        }
        dismiss()
    }
    
}

#Preview {
    AddCorrectionView()
        .modelContainer(for: [Correction.self, Folder.self], inMemory: true)
}
