//
//  CorrectionDetailView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import SwiftUI
import SwiftData

struct CorrectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ProStore.self) private var store
    @Environment(ProgressStore.self) private var progress
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("hideGochi") private var hideGochi = false
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false
    @State private var showExplain = false
    @State private var showProPaywall = false
    @State private var showRule = false
    @State private var peeked = false
    @State private var gochiTaps = 0
    let correction: Correction

    private var tint: Color { correction.type.color }
    private var isPro: Bool { store.tier >= .pro }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sentenceCard
                explainSection
                if let note = correction.type.note {
                    ruleCard(note)
                }
                if !correction.note.isEmpty {
                    noteCard
                }
                footer
            }
            .padding()
        }
        .background(NotebookPaper())
        .navigationTitle("Correction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") { showingEdit = true }
        }
        .sheet(isPresented: $showingEdit) {
            AddCorrectionView(correction: correction)
        }
        .sheet(isPresented: $showExplain) {
            ExplainSheet(correction: correction)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showProPaywall) {
            PaywallView(startOn: .pro)
        }
        .confirmationDialog("Delete this correction?",
                            isPresented: $showingDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                dismiss()
                modelContext.delete(correction)
            }
        }
    }

    private var sentenceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                chip(correction.type.label, symbol: correction.type.symbol, color: tint)
                if correction.audience != .unknown {
                    chip(correction.audience.label, symbol: correction.audience.symbol, color: .secondary)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("You wrote")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(Self.marked(correction.original, against: correction.corrected, color: .gochiRed, strike: true))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Should be")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(alignment: .center, spacing: 10) {
                    Text(Self.marked(correction.corrected, against: correction.original, color: tint, strike: false))
                        .font(.title2.weight(.semibold))
                    Spacer(minLength: 0)
                    speakButton(correction.corrected, color: tint, size: 40)
                }
            }

            changeSummary
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(tint)
    }

    @ViewBuilder
    private var changeSummary: some View {
        switch correction.type {
        case .particle:
            let changes = MistakeDetector.particleChanges(original: correction.original,
                                                          corrected: correction.corrected)
            ForEach(changes, id: \.from) { change in
                changeBox(from: change.from, to: change.to,
                          why: MistakeDetector.explanation(stem: change.stem, particle: change.to))
            }
        case .speechLevel:
            if let from = MistakeDetector.speechLevel(of: correction.original),
               let to = MistakeDetector.speechLevel(of: correction.corrected) {
                changeBox(from: from.label, to: to.label, why: nil)
            }
        case .tense:
            if let from = MistakeDetector.tense(of: correction.original),
               let to = MistakeDetector.tense(of: correction.corrected) {
                changeBox(from: from.label, to: to.label, why: nil)
            }
        case .honorific:
            let before = MistakeDetector.honorifics(in: correction.original)
            let after = MistakeDetector.honorifics(in: correction.corrected)
            let added = after.subtracting(before).sorted()
            let removed = before.subtracting(after).sorted()
            if !added.isEmpty || !removed.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    if !added.isEmpty {
                        Text("Added: \(added.joined(separator: ", "))")
                            .foregroundStyle(tint)
                    }
                    if !removed.isEmpty {
                        Text("Removed: \(removed.joined(separator: ", "))")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(tint.opacity(0.08), in: .rect(cornerRadius: 14))
            }
        default:
            EmptyView()
        }
    }

    private func changeBox(from: String, to: String, why: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(from)
                    .strikethrough(color: .gochiRed)
                    .foregroundStyle(.secondary)
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(to)
                    .foregroundStyle(tint)
            }
            .font(.headline)
            if let why {
                Text(why)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.08), in: .rect(cornerRadius: 14))
    }

    private func chip(_ text: String, symbol: String, color: Color) -> some View {
        Label(text, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12), in: .capsule)
    }

    private func speakButton(_ text: String, color: Color, size: CGFloat) -> some View {
        Button {
            Speaker.shared.speak(text)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(size > 36 ? .subheadline : .caption)
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(color.opacity(0.12), in: .circle)
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Listen")
    }

    @ViewBuilder
    private var explainSection: some View {
        if isPro, let saved = correction.savedExplanation {
            VStack(alignment: .leading, spacing: 12) {
                Label("Gochi explains", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tint)
                ExplanationContent(explanation: saved, tint: tint) { up in
                    Task { await GochiAI.sendFeedback(up: up, mistake: correction.aiInput, explanation: saved) }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard(.gochiRed)
            .background(alignment: .topTrailing) {
                if !hideGochi {
                    GochiView(xp: progress.xp, celebrate: gochiTaps, mood: .happy)
                        .frame(width: 84, height: 84)
                        .offset(x: -22, y: peeked ? -54 : 0)
                        .onTapGesture { gochiTaps += 1 }
                }
            }
            .padding(.top, hideGochi ? 0 : 40)
            .onAppear {
                withAnimation(reduceMotion ? nil : .spring(duration: 0.55, bounce: 0.45).delay(0.25)) {
                    peeked = true
                }
            }
        } else {
            ExplainButtonCard(isPro: isPro) {
                if isPro { showExplain = true } else { showProPaywall = true }
            }
        }
    }

    private func ruleCard(_ note: GrammarNote) -> some View {
        DisclosureGroup(isExpanded: $showRule) {
            GrammarNoteView(note: note, tint: tint)
                .padding(.top, 8)
        } label: {
            Label("The rule: \(correction.type.label)", systemImage: "book.closed.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
        }
        .tint(tint)
        .softCard(tint)
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Your note", systemImage: "pencil")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(hex: 0x8A6D1F))
            Text(correction.note)
                .foregroundStyle(Color(hex: 0x3D3220))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(hex: 0xFFF1A8), in: .rect(cornerRadius: 6))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .rotationEffect(.degrees(-0.8))
        .padding(.horizontal, 4)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Text("Saved \(correction.createdAt.formatted(date: .long, time: .omitted))")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Delete correction", role: .destructive) {
                showingDeleteConfirm = true
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
    
    private static func marked(_ text: String, against other: String,
                               color: Color, strike: Bool) -> AttributedString {
        let t = Array(text.trimmed)
        let o = Array(other.trimmed)
        var differs = Set<Int>()
        for change in o.difference(from: t) {
            if case let .remove(offset, _, _) = change { differs.insert(offset) }
        }
        var out = AttributedString()
        for (i, ch) in t.enumerated() {
            var piece = AttributedString(String(ch))
            if differs.contains(i) {
                piece.foregroundColor = color
                piece.backgroundColor = color.opacity(0.15)
                if strike { piece.strikethroughStyle = .single }
            }
            out += piece
        }
        return out
    }
}

struct ExplanationContent: View {
    let explanation: GochiAI.Explanation
    var tint: Color = .gochiRed
    var onVote: ((Bool) -> Void)? = nil

    @State private var voted: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(explanation.explanation)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(tint)
                Text(explanation.tip)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(0.08), in: .rect(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(explanation.examples, id: \.self) { ex in
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: ex.ko)
                                .font(.body.weight(.semibold))
                            Text(ex.translation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        Button {
                            Speaker.shared.speak(ex.ko)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .foregroundStyle(tint)
                                .frame(width: 32, height: 32)
                                .background(tint.opacity(0.12), in: .circle)
                        }
                        .buttonStyle(PressableStyle())
                        .accessibilityLabel("Listen")
                    }
                    .padding(12)
                    .background(Color.primary.opacity(0.03), in: .rect(cornerRadius: 14))
                }
            }

            if let onVote {
                HStack(spacing: 12) {
                    if let voted {
                        Label(voted ? "Thanks! Glad it helped." : "Thanks, Gochi will do better.",
                              systemImage: "checkmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Was this helpful?")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        voteButton(up: true, onVote: onVote)
                        voteButton(up: false, onVote: onVote)
                    }
                }
                .animation(.snappy, value: voted)
            }
        }
    }

    private func voteButton(up: Bool, onVote: @escaping (Bool) -> Void) -> some View {
        Button {
            voted = up
            onVote(up)
        } label: {
            Image(systemName: up ? "hand.thumbsup" : "hand.thumbsdown")
                .font(.subheadline)
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.1), in: .circle)
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel(up ? "Helpful" : "Not helpful")
    }
}

extension View {
    func softCard(_ color: Color = .clear) -> some View {
        self
            .padding(16)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

#Preview {
    let c = Correction(original: "저는 학생가 아니에요", corrected: "저는 학생이 아니에요")
    c.type = .particle
    c.note = "학생 ends in a consonant"
    return NavigationStack {
        CorrectionDetailView(correction: c)
    }
    .modelContainer(for: Correction.self, inMemory: true)
    .environment(ProStore())
    .environment(ProgressStore())
}
