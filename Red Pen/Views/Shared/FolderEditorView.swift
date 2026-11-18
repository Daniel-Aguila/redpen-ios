//
//  FolderEditorView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/17/26.
//

import SwiftUI
import SwiftData

struct FolderEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var folder: Folder? = nil
    var onCreate: (Folder) -> Void = { _ in }

    @State private var name = ""
    @State private var emoji = "📁"

    private let emojis = ["📁", "💼", "📚", "✈️", "💬", "❤️",
                          "🏫", "🧑‍🏫", "🗣️", "📝", "📱", "🎬",
                          "🎵", "🎮", "🍜", "☕️", "🏠", "👨‍👩‍👧",
                          "🛍️", "🏥", "💪", "🌸", "⭐️", "🇰🇷"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Work, HelloTalk, Trip…", text: $name)
                }
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(emojis, id: \.self) { e in
                            Button {
                                emoji = e
                            } label: {
                                Text(verbatim: e)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(emoji == e ? Color.accentColor.opacity(0.18) : .clear,
                                                in: .rect(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(folder == nil ? String(localized: "New Folder") : String(localized: "Edit Folder"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmed.isEmpty)
                }
            }
            .onAppear {
                if let folder {
                    name = folder.name
                    emoji = folder.emoji
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let n = name.trimmed
        if let folder {
            folder.name = n
            folder.emoji = emoji
        } else {
            let f = Folder(name: n, emoji: emoji)
            modelContext.insert(f)
            onCreate(f)
        }
        dismiss()
    }
}

#Preview {
    FolderEditorView()
        .modelContainer(for: Folder.self, inMemory: true)
}
