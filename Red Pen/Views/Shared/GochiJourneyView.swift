//
//  GochiJourneyView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/17/26.
//

import SwiftUI

struct GochiJourneyView: View {
    @Environment(ProgressStore.self) private var progress

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(GochiForm.allCases) { form in
                    cell(form)
                }
            }
            .padding()
        }
        .background(NotebookPaper())
        .navigationTitle("Gochi's journey")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func cell(_ form: GochiForm) -> some View {
        let unlocked = progress.xp >= form.minXP
        let isCurrent = form == progress.form

        return VStack(spacing: 6) {
            Image(form.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 72)
                .colorMultiply(unlocked ? .white : .black)
                .opacity(unlocked ? 1 : 0.25)
            Text(unlocked ? form.title : "???")
                .font(.subheadline.weight(.semibold))
            Text("\(form.minXP) XP")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay {
            if isCurrent {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.taegeukBlue, lineWidth: 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GochiJourneyView()
    }
    .environment(ProgressStore())
}
