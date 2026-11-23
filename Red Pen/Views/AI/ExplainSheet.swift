//
//  ExplainSheet.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/22/26.
//

import SwiftUI

struct ExplainSheet: View {
    let correction: Correction

    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var progress
    @State private var result: GochiAI.Explanation?
    @State private var errorMessage: String?
    @State private var loading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    pairCard

                    if loading {
                        thinking
                    } else if let errorMessage {
                        errorCard(errorMessage)
                    } else if let result {
                        answer(result)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Why?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await load() }
        }
    }

    private var pairCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: correction.original)
                .strikethrough(color: .gochiRed)
                .foregroundStyle(.secondary)
            Text(verbatim: correction.corrected)
                .font(.title3.weight(.semibold))
            if correction.audience != .unknown {
                Label(correction.audience.label, systemImage: correction.audience.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
    }

    private var thinking: some View {
        HStack(spacing: 12) {
            GochiView(xp: progress.xp, mood: .awake)
                .frame(width: 48, height: 48)
            Text("Gochi is thinking…")
                .foregroundStyle(.secondary)
            Spacer()
            ProgressView()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
    }

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try again") {
                Task { await load(force: true) }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.gochiRed)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
    }

    private func answer(_ r: GochiAI.Explanation) -> some View {
        ExplanationContent(explanation: r, tint: correction.type.color) { up in
            Task { await GochiAI.sendFeedback(up: up, mistake: correction.aiInput, explanation: r) }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }


    private func load(force: Bool = false) async {
        if !force, let saved = correction.savedExplanation {
            result = saved
            return
        }
        loading = true
        errorMessage = nil
        defer { loading = false }
        do {
            let r = try await GochiAI.explain(correction.aiInput)
            correction.savedExplanation = r
            withAnimation(.snappy) { result = r }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ExplainButtonCard: View {
    let isPro: Bool
    var hasSaved = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.gochiRed.gradient, in: .rect(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 2) {
                    Text(isPro && hasSaved ? "See Gochi's explanation" : "Explain my sentence")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(isPro ? "Gochi explains this exact sentence" : "Personal help with Pro")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isPro {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                } else {
                    Text("PRO")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gochiBlue, in: .capsule)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard()
        }
        .buttonStyle(PressableStyle())
    }
}
