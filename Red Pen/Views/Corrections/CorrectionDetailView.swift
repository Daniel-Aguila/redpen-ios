//
//  CorrectionDetailView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import SwiftUI
import SwiftData

struct CorrectionDetailView: View {
    @State private var showingEdit = false
    let correction: Correction

    var body: some View {
        List {
            Section("What you wrote") {
                Text(correction.original)
                    .font(.title3)
                    .strikethrough(color: .accentColor)
                    .foregroundStyle(.secondary)
            }
            .onPaper()

            Section("Corrected") {
                HStack {
                    Text(correction.corrected)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Button {
                        Speaker.shared.speak(correction.corrected)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .onPaper()

            Section("Mistake type") {
                Label(correction.type.label, systemImage: correction.type.symbol)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(correction.type.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(correction.type.color.opacity(0.12), in: Capsule())

                if correction.type == .particle {
                    let changes = MistakeDetector.particleChanges(original: correction.original,
                                                                  corrected: correction.corrected)
                    ForEach(changes, id: \.from) { change in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(change.from)
                                    .strikethrough(color: .accentColor)
                                    .foregroundStyle(.secondary)
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(.secondary)
                                Text(change.to)
                                    .foregroundStyle(correction.type.color)
                            }
                            .font(.title3.weight(.semibold))

                            if let why = MistakeDetector.explanation(stem: change.stem, particle: change.to) {
                                Text(why)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else if correction.type == .speechLevel {
                    if let from = MistakeDetector.speechLevel(of: correction.original),
                       let to = MistakeDetector.speechLevel(of: correction.corrected) {
                        HStack(spacing: 8) {
                            Text(from.label)
                                .strikethrough(color: .accentColor)
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.secondary)
                            Text(to.label)
                                .foregroundStyle(correction.type.color)
                        }
                        .font(.headline)
                    }
                }
            }
            .onPaper()

            if !correction.note.isEmpty {
                Section("Note") {
                    Text(correction.note)
                }
                .onPaper()
            }

            Section {
                LabeledContent("Saved") {
                    Text(correction.createdAt, style: .date)
                }
            }
            .onPaper()
        }
        .navigationTitle("Correction")
        .navigationBarTitleDisplayMode(.inline)
        .paperBackground()
        .toolbar {
            Button("Edit") {
                showingEdit = true
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddCorrectionView(correction: correction)
        }
    }
}

#Preview {
    let c = Correction(original: "저는 학생가 아니에요", corrected: "저는 학생이 아니에요")
    c.type = .particle
    return NavigationStack {
        CorrectionDetailView(correction: c)
    }
    .modelContainer(for: Correction.self, inMemory: true)
}
