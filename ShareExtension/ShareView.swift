//
//  ShareView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/22/26.
//

import SwiftUI

struct ShareView: View {
    @State private var original: String
    @State private var corrected = ""
    @FocusState private var focused: Bool

    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    init(original: String, onSave: @escaping (String, String) -> Void, onCancel: @escaping () -> Void) {
        _original = State(initialValue: original)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    private func clean(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("What you wrote") {
                    TextField("Original", text: $original, axis: .vertical)
                }
                Section("Correct version") {
                    TextField("Corrected", text: $corrected, axis: .vertical)
                        .focused($focused)
                }
                Section {
                    Text("It'll be in your notebook next time you open Gochimi.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Save to Gochimi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(clean(original), clean(corrected)) }
                        .disabled(clean(original).isEmpty || clean(corrected).isEmpty)
                }
            }
            .onAppear { focused = true }
        }
    }
}
