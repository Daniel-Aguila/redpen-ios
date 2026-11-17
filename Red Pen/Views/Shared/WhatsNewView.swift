//
//  WhatsNewView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/17/26.
//

import SwiftUI

struct WhatsNewView: View {
    static let version = "1.1"

    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var progress
    @State private var flips = 0

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("New in Gochim")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.15), in: Capsule())

            GochiView(xp: progress.xp, celebrate: flips)
                .frame(height: 160)

            Text("Meet 고치")
                .font(.largeTitle.weight(.heavy))

            if progress.form == .bean {
                Text("Your study buddy. Every mistake you practice helps Gochi grow, all the way to 용.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            } else {
                Text(verbatim: "\(progress.form.title)\(progress.form.title.subjectParticle) 되었어요!")
                    .font(.title3.weight(.bold))
                Text("Your practice so far already helped Gochi grow. Keep going, all the way to 용.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("Gochi's journey in Stats", systemImage: "map")
                Label("Who you're talking to, for speech-level practice", systemImage: "person.2")
                Label("Smarter reminders that skip days you practiced", systemImage: "bell")
            }
            .font(.subheadline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("좋아요!").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
        .background(NotebookPaper())
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            flips += 1
        }
    }
}

#Preview {
    WhatsNewView()
        .environment(ProgressStore())
}
