//
//  WhatsNewView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/17/26.
//

import SwiftUI

struct WhatsNewView: View {
    static let version = "1.2"

    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var progress
    @AppStorage("selectedTab") private var selectedTab = "practice"
    @State private var flips = 0

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("New in Gochimi")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.15), in: Capsule())

            GochiView(xp: progress.xp, celebrate: flips)
                .frame(height: 140)

            Text("Gochi's big update")
                .font(.largeTitle.weight(.heavy))
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 14) {
                row("graduationcap.fill", .taegeukBlue,
                    "Lessons", "From Hangul to real conversations, with Gochi as your teacher.")
                row("house.fill", .orange,
                    "Gochi's home", "A hot spring to decorate with 🍊 you earn by practicing.")
                row("square.and.arrow.up.fill", .green,
                    "Save from any app", "Got corrected in KakaoTalk or HelloTalk? Share it straight to Gochimi.")
                row("star.fill", .gochiRed,
                    "Plus and Pro", "Streak freezes, smart review, and personal help for every mistake.")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard()

            Spacer()

            Button {
                selectedTab = "practice"
                dismiss()
            } label: {
                Text("Try a lesson").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color.gochiRed)

            Button("좋아요!") { dismiss() }
                .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 16)
        .background(NotebookPaper())
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            flips += 1
        }
    }

    private func row(_ symbol: String, _ color: Color, _ title: LocalizedStringKey, _ text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(color, in: .rect(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    WhatsNewView()
        .environment(ProgressStore())
}
