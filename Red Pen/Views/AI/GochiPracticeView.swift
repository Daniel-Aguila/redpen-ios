//
//  GochiPracticeView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/22/26.
//

import SwiftUI

struct GochiPracticeView: View {
    let mistakes: [GochiAI.MistakeInput]

    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var progress
    @Environment(ProStore.self) private var store

    @State private var practice: GochiAI.Practice?
    @State private var errorMessage: String?
    @State private var index = 0
    @State private var typed = ""
    @State private var result: AnswerResult?
    @State private var showHint = false
    @State private var correctCount = 0
    @State private var showStory = false
    @State private var showTranslations = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let practice {
                        if showStory {
                            storyView(practice.story, total: practice.exercises.count)
                        } else {
                            exerciseView(practice.exercises[index], total: practice.exercises.count)
                        }
                    } else if let errorMessage {
                        errorCard(errorMessage)
                    } else {
                        thinking
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(NotebookPaper())
            .navigationTitle(showStory ? "Gochi's story" : "Gochi's practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await load() }
        }
    }

    private var thinking: some View {
        VStack(spacing: 14) {
            GochiView(xp: progress.xp, mood: .awake)
                .frame(width: 90, height: 90)
            Text("Gochi is writing your practice…")
                .font(.headline)
            Text("Using your own mistakes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ProgressView()
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .softCard()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try again") {
                errorMessage = nil
                Task { await load() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.gochiRed)
        }
        .frame(maxWidth: .infinity)
        .softCard()
    }

    private func exerciseView(_ ex: GochiAI.Practice.Exercise, total: Int) -> some View {
        VStack(spacing: 16) {
            ProgressView(value: Double(index), total: Double(total))
                .tint(Color.gochiRed)

            VStack(spacing: 10) {
                Text("Fill in the blank")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(verbatim: ex.prompt)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                if showHint || result != nil {
                    Label(ex.hint, systemImage: "lightbulb.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .softCard()

            if let result {
                resultView(result, ex, total: total)
            } else {
                TextField("Your answer", text: $typed)
                    .font(.title3)
                    .padding()
                    .background(Color(.systemBackground), in: .rect(cornerRadius: 14))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { check(ex) }
                    .onAppear { focused = true }

                Button {
                    check(ex)
                } label: {
                    Text("Check").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color.gochiRed)
                .disabled(typed.trimmed.isEmpty)

                if !showHint {
                    Button("Show hint") { withAnimation(.snappy) { showHint = true } }
                        .font(.subheadline)
                }
            }
        }
    }

    @ViewBuilder
    private func resultView(_ result: AnswerResult, _ ex: GochiAI.Practice.Exercise, total: Int) -> some View {
        let full = ex.prompt.replacingOccurrences(of: "___", with: ex.answer)
        VStack(spacing: 10) {
            switch result {
            case .correct:
                Text("맞아요! Correct").font(.headline).foregroundStyle(.green)
            case .almost:
                Text("거의 다 왔어요! Almost").font(.headline).foregroundStyle(.orange)
            case .wrong:
                Text("아쉬워요! Not quite").font(.headline).foregroundStyle(Color.gochiRed)
            }
            HStack(spacing: 10) {
                Text(verbatim: full)
                    .font(.title3.weight(.semibold))
                Spacer(minLength: 0)
                Button {
                    Speaker.shared.speak(full)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(Color.gochiRed)
                        .frame(width: 36, height: 36)
                        .background(Color.gochiRed.opacity(0.1), in: .circle)
                }
                .buttonStyle(PressableStyle())
                .accessibilityLabel("Listen")
            }
        }
        .frame(maxWidth: .infinity)
        .softCard()

        Button {
            next(total: total)
        } label: {
            Text(index + 1 < total ? "Next" : "Read Gochi's story")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Color.gochiRed)
    }

    private func check(_ ex: GochiAI.Practice.Exercise) {
        guard !typed.trimmed.isEmpty else { return }
        focused = false
        let r = AnswerChecker.check(typed, against: ex.answer, spacingMatters: false)
        if r != .wrong { correctCount += 1 }
        progress.countAnswer()
        withAnimation(.snappy) { result = r }
    }

    private func next(total: Int) {
        if index + 1 < total {
            index += 1
            typed = ""
            result = nil
            showHint = false
        } else {
            progress.recordPracticeDay(freezeAllowance: store.tier >= .plus ? ProgressStore.plusFreezesPerMonth : 0)
            withAnimation(.snappy) { showStory = true }
        }
    }

    private func storyView(_ story: GochiAI.Practice.Story, total: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: story.title)
                    .font(.title2.bold())
                Text("\(correctCount) of \(total) exercises right")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Toggle("Translations", isOn: $showTranslations.animation(.snappy))
                    .font(.subheadline.weight(.semibold))
            }
            .softCard()

            VStack(alignment: .leading, spacing: 10) {
                ForEach(story.sentences, id: \.self) { s in
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(verbatim: s.ko)
                                .font(.body.weight(.semibold))
                            if showTranslations {
                                Text(s.translation)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 0)
                        Button {
                            Speaker.shared.speak(s.ko)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .foregroundStyle(Color.gochiRed)
                                .frame(width: 32, height: 32)
                                .background(Color.gochiRed.opacity(0.1), in: .circle)
                        }
                        .buttonStyle(PressableStyle())
                        .accessibilityLabel("Listen")
                    }
                }
            }
            .softCard()

            Button {
                Speaker.shared.speak(story.sentences.map(\.ko).joined(separator: " "))
            } label: {
                Label("Listen to the whole story", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(Color.gochiRed)

            Button {
                dismiss()
            } label: {
                Text("Done").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color.gochiRed)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func load() async {
        guard practice == nil else { return }
        do {
            let p = try await GochiAI.practice(mistakes)
            guard !p.exercises.isEmpty else {
                errorMessage = GochiAI.AIError.failed.localizedDescription
                return
            }
            withAnimation(.snappy) { practice = p }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
