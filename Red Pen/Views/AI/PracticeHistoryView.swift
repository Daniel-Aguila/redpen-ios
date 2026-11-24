//
//  PracticeHistoryView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import SwiftUI

enum StoryPalette {
    static let colors: [Color] = [.gochiRed, .gochiBlue, Color(hex: 0x2BB3A3), Color(hex: 0xF2A93B), Color(hex: 0x9B59B6)]

    static func color(for item: SavedPractice) -> Color {
        colors[Int(item.id.uuid.0) % colors.count]
    }
}

struct PracticeHistoryView: View {
    @Environment(ProgressStore.self) private var progress
    @AppStorage("hideGochi") private var hideGochi = false
    @State private var taps = 0
    private let library = PracticeLibrary.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                if library.items.isEmpty {
                    emptyState
                } else {
                    ForEach(library.items) { item in
                        NavigationLink {
                            SavedPracticeDetail(item: item)
                        } label: {
                            bookCard(item)
                        }
                        .buttonStyle(PressableStyle())
                        .contextMenu {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                withAnimation(.snappy) { library.delete(item) }
                            }
                        }
                    }

                    Text("Press and hold a story to delete it.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .background(NotebookPaper())
        .navigationTitle("My stories")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 14) {
            if !hideGochi {
                GochiView(xp: progress.xp, celebrate: taps, mood: .happy)
                    .frame(width: 72, height: 72)
                    .onTapGesture { taps += 1 }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Gochi's bookshelf")
                    .font(.title2.bold())
                Text(library.items.count == 1
                     ? String(localized: "1 story from your mistakes")
                     : String(localized: "\(library.items.count) stories from your mistakes"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, 6)
    }

    private func bookCard(_ item: SavedPractice) -> some View {
        let color = StoryPalette.color(for: item)
        return HStack(spacing: 0) {
            Rectangle()
                .fill(color.gradient)
                .frame(width: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: item.practice.story.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                if let first = item.practice.story.sentences.first {
                    Text(verbatim: first.ko)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                HStack(spacing: 12) {
                    Label("\(item.practice.exercises.count)", systemImage: "pencil.line")
                    Label("\(item.practice.story.sentences.count)", systemImage: "text.alignleft")
                    Spacer()
                    Text(item.date, format: .dateTime.month(.abbreviated).day())
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(14)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.trailing, 14)
        }
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            if !hideGochi {
                GochiView(xp: progress.xp, mood: .sleepy)
                    .frame(width: 90, height: 90)
            }
            Text("No stories yet")
                .font(.headline)
            Text("Finish a Gochi's practice to get your first story.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct SavedPracticeDetail: View {
    let item: SavedPractice
    @State private var redo = false
    @State private var translating = false
    @State private var translateError: String?

    private var current: SavedPractice {
        PracticeLibrary.shared.items.first { $0.id == item.id } ?? item
    }

    private var needsTranslation: Bool {
        current.lang != GochiAI.languageCode
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StoryHeader(title: current.practice.story.title,
                            subtitle: String(localized: "\(current.date.formatted(date: .abbreviated, time: .omitted)) · \(current.practice.exercises.count) exercises"),
                            color: StoryPalette.color(for: current))

                if needsTranslation {
                    translateButton
                }

                StoryContent(story: current.practice.story, color: StoryPalette.color(for: current))

                Button {
                    redo = true
                } label: {
                    Label("Redo the exercises", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color.gochiRed)
            }
            .padding()
        }
        .background(NotebookPaper())
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $redo) {
            GochiPracticeView(mistakes: [], saved: current)
        }
    }

    private var translateButton: some View {
        VStack(spacing: 6) {
            Button {
                Task { await translate() }
            } label: {
                Group {
                    if translating {
                        ProgressView()
                    } else {
                        Label("Translate into my language", systemImage: "character.bubble")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(Color.gochiRed)
            .disabled(translating)

            if let translateError {
                Text(translateError)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func translate() async {
        translating = true
        translateError = nil
        defer { translating = false }
        do {
            try await PracticeLibrary.shared.retranslate(current)
        } catch {
            translateError = error.localizedDescription
        }
    }
}
