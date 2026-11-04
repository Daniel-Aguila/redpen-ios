//
//  ProRoadmapView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/4/26.
//

import SwiftUI

struct ProRoadmapView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 10){
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.accentColor)
                    Text("Red Pen Pro")
                        .font(.title.weight(.heavy))
                    Text("Coming soon")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                    Text("Everything in Red Pen today stays free. Pro will add deeper help on top. These features are planned and not available yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            Section("Planned") {
                feature("text.bubble",
                        title: "Explain this mistake",
                        text: "A personal explanation of why your sentence was corrected, in your language.")
                feature("person.2.wave.2",
                        title: "Context-aware feedback",
                        text: "Checks whether your speech level and honorifics fit who you're talking to.")
                feature("character.book.closed",
                        title: "Grammar lessons",
                        text: "Short lessons and topic decks built around common learner mistakes.")
            }
        }
        .navigationTitle("Pro")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func feature(_ symbol: String, title: LocalizedStringKey, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 14){
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2){
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
    ProRoadmapView()
}
