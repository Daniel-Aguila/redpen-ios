//
//  ProRoadmapView.swift
//  Gochim
//
//  Created by Daniel Aguila on 11/4/26.
//

import SwiftUI

struct ProRoadmapView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.accentColor)
                    Text("Gochimi Plus & Pro")
                        .font(.title.weight(.heavy))
                        .multilineTextAlignment(.center)
                    Text("Coming soon")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                    Text("Everything in Gochimi today stays free. Plus and Pro will add more on top. These features are planned and not available yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("Coming free for everyone") {
                feature("square.and.arrow.down", tint: .green,
                        title: "Share from any app",
                        text: "Save a correction straight from KakaoTalk, HelloTalk or Safari.")
                feature("calendar", tint: .green,
                        title: "Weekly recap",
                        text: "Your week with Gochi, ready to share.")
            }

            Section("Gochimi Plus") {
                feature("character.book.closed",
                        title: "Full Korean course",
                        text: "Short lessons built around common learner mistakes.")
                feature("books.vertical",
                        title: "Story library",
                        text: "Short stories with exercises, plus a free one every week.")
                feature("target",
                        title: "Smart review",
                        text: "Drills that focus on your weakest spots.")
                feature("icloud",
                        title: "iCloud sync and streak freezes",
                        text: "Your notebook on every device, and a safety net for busy days.")
                feature("tshirt",
                        title: "Gochi outfits",
                        text: "Hanbok, holidays, countries and more.")
            }

            Section {
                feature("text.bubble", tint: .taegeukBlue,
                        title: "Explain this mistake",
                        text: "A personal explanation of why your sentence was corrected.")
                feature("wand.and.stars", tint: .taegeukBlue,
                        title: "Story Mode",
                        text: "Describe any situation and get a short story to practice with.")
                feature("pencil.and.scribble", tint: .taegeukBlue,
                        title: "Diary correction",
                        text: "Write about your day and get it red-penned.")
                feature("arrow.triangle.2.circlepath", tint: .taegeukBlue,
                        title: "Fresh practice sentences",
                        text: "New sentences built from your own mistakes.")
            } header: {
                Text("Gochimi Pro")
            } footer: {
                Text("Everything in Plus, and more.")
            }
        }
        .navigationTitle("Plus & Pro")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func feature(_ symbol: String, tint: Color = .accentColor,
                         title: LocalizedStringKey, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ProRoadmapView()
    }
}
