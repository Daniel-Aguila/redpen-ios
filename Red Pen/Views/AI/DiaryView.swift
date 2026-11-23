//
//  DiaryView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ProgressStore.self) private var progress
    @AppStorage("hideGochi") private var hideGochi = false
    @AppStorage("diaryDraft") private var text = ""
    @State private var result: GochiAI.DiaryFix?
    @State private var loading = false
    @State private var errorMessage: String?
    @State private var saved: Set<GochiAI.DiaryFix.Note> = []
    @FocusState private var focused: Bool

    private let limit = 1500

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let result {
                        resultView(result)
                    } else {
                        editor
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(NotebookPaper())
            .navigationTitle("Gochi's diary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                if !hideGochi {
                    GochiView(xp: progress.xp, mood: .happy)
                        .frame(width: 64, height: 64)
                }
                Text("오늘 어땠어요? Tell me about your day in Korean, and I'll fix it with you.")
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemBackground), in: .rect(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                    }
            }
            TextEditor(text: $text)
                .focused($focused)
                .frame(minHeight: 220)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(Color(.systemBackground), in: .rect(cornerRadius: 16))
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(verbatim: "오늘은 친구를 만났어요...")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
                .onChange(of: text) { _, new in
                    if new.count > limit { text = String(new.prefix(limit)) }
                }

            HStack {
                Spacer()
                Text("\(text.count) / \(limit)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.gochiRed)
            }

            Button {
                Task { await check() }
            } label: {
                HStack(spacing: 8) {
                    if loading { ProgressView().tint(.white) }
                    Text(loading ? "Gochi is reading…" : "Check with Gochi")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color.gochiRed)
            .disabled(loading || text.trimmed.isEmpty)
        }
    }

    private func resultView(_ r: GochiAI.DiaryFix) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Label(r.notes.isEmpty ? "Perfect, no mistakes!" : "Gochi's version",
                      systemImage: r.notes.isEmpty ? "checkmark.seal.fill" : "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(r.notes.isEmpty ? Color.green : Color.gochiRed)
                Text(verbatim: r.corrected)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Spacer()
                    Button {
                        Speaker.shared.speak(r.corrected)
                    } label: {
                        Label("Listen", systemImage: "speaker.wave.2.fill")
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(Color.gochiRed)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard()

            if !r.notes.isEmpty {
                Text("What Gochi fixed")
                    .font(.headline)
                ForEach(r.notes, id: \.self) { note in
                    noteCard(note)
                }
            }

            Button {
                text = ""
                saved = []
                withAnimation(.snappy) { result = nil }
            } label: {
                Text("Write a new entry").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color.gochiRed)

            Button("Edit this entry") {
                withAnimation(.snappy) { result = nil }
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func noteCard(_ note: GochiAI.DiaryFix.Note) -> some View {
        let isSaved = saved.contains(note)
        return VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: note.original)
                .strikethrough(color: .gochiRed)
                .foregroundStyle(.secondary)
            Text(verbatim: note.corrected)
                .font(.headline)
            Text(note.why)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                save(note)
            } label: {
                Label(isSaved ? "Saved to notebook" : "Save to notebook",
                      systemImage: isSaved ? "checkmark" : "plus")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .tint(isSaved ? Color.green : Color.gochiRed)
            .disabled(isSaved)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard()
    }

    private func save(_ note: GochiAI.DiaryFix.Note) {
        let c = Correction(original: note.original, corrected: note.corrected, note: note.why)
        c.type = MistakeDetector.detect(original: note.original, corrected: note.corrected)
        c.source = .diary
        modelContext.insert(c)
        withAnimation(.snappy) { _ = saved.insert(note) }
    }

    private func check() async {
        focused = false
        loading = true
        errorMessage = nil
        defer { loading = false }
        do {
            let r = try await GochiAI.diary(text.trimmed)
            withAnimation(.snappy) { result = r }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
