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
    @Environment(ProgressStore.self) private var progress
    
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    
    @State private var folder: Folder? = nil
    @State private var showingNewFolder = false
    @State private var original = ""
    @State private var corrected = ""
    @State private var note = ""
    @State private var audience: Audience = .unknown
    
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
                Section("Talking to") {
                    Picker("Talking to", selection: $audience) {
                        ForEach(Audience.allCases, id: \.self) { a in
                            Label(a.label, systemImage: a.symbol).tag(a)
                        }
                    }
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
                            Text(verbatim: f.name).tag(Optional(f))
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
                    audience = correction.audience
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
            .sheet(isPresented: $showingNewFolder) {
                FolderEditorView { folder = $0 }
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
            correction.audience = audience
        } else {
            let cr = Correction(original: o, corrected: c, note: n)
            cr.folder = folder
            cr.audience = audience
            cr.type = MistakeDetector.detect(original: o, corrected: c)
            modelContext.insert(cr)
            progress.earn(5)
        }
        dismiss()
    }
    
}

#Preview {
    AddCorrectionView()
        .modelContainer(for: [Correction.self, Folder.self], inMemory: true)
        .environment(ProgressStore())
}
