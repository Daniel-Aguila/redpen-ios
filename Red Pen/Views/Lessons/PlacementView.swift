//
//  PlacementView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import SwiftUI

struct PlacementView: View {
    let onPlace: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var progress
    @AppStorage("hideGochi") private var hideGochi = false

    @State private var sections: [[Step]] = []
    @State private var unit = 0
    @State private var question = 0
    @State private var wrong = 0
    @State private var passed = 0
    @State private var finished = false

    private let library = CourseStore.shared
    private let perUnit = 4

    private var units: [CourseUnit] { library.course.units }
    private var total: Int { sections.reduce(0) { $0 + $1.count } }
    private var answered: Int { sections.prefix(unit).reduce(0) { $0 + $1.count } + question }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if finished {
                    result
                } else if unit < sections.count, question < sections[unit].count {
                    quiz(sections[unit][question])
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(NotebookPaper())
            .navigationTitle("Find your level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear(perform: build)
    }

    private func build() {
        sections = units.map { u in
            let choices = u.lessons.flatMap(\.steps).filter { $0.kind == .choice && ($0.options?.count ?? 0) > 1 }
            return Array(choices.shuffled().prefix(perUnit))
        }
    }

    private func quiz(_ step: Step) -> some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(answered), total: Double(max(total, 1)))
                .tint(Color.gochiRed)

            HStack(alignment: .top, spacing: 12) {
                if !hideGochi {
                    GochiView(xp: progress.xp, mood: .happy)
                        .frame(width: 64, height: 64)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Checking: \(units[unit].title)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(units[unit].color)
                    Text(verbatim: step.text ?? "")
                        .font(.body.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .softCard()
            }

            VStack(spacing: 10) {
                ForEach(Array((step.options ?? []).enumerated()), id: \.offset) { i, option in
                    Button {
                        answer(i == step.answer)
                    } label: {
                        Text(verbatim: option)
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground), in: .rect(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                            }
                    }
                    .buttonStyle(PressableStyle())
                }

                Button("I don't know") {
                    answer(false)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
            }
        }
        .id("\(unit)-\(question)")
        .transition(.opacity)
    }

    private func answer(_ right: Bool) {
        if !right { wrong += 1 }
        withAnimation(.snappy) {
            if wrong >= 2 {
                finished = true
                return
            }
            if question + 1 < sections[unit].count {
                question += 1
            } else {
                passed += 1
                if unit + 1 < sections.count {
                    unit += 1
                    question = 0
                    wrong = 0
                } else {
                    finished = true
                }
            }
        }
    }

    private var result: some View {
        VStack(spacing: 16) {
            Spacer()
            if hideGochi {
                Text("🎯").font(.system(size: 72))
            } else {
                GochiView(xp: progress.xp, celebrate: passed, mood: .happy)
                    .frame(height: 120)
            }

            if passed == 0 {
                Text("Let's start at the beginning")
                    .font(.title2.weight(.bold))
                Text("Hangul first. You'll be reading Korean in no time.")
                    .foregroundStyle(.secondary)
            } else if passed >= units.count {
                Text(verbatim: "대단해요!")
                    .font(.title2.weight(.bold))
                Text("You already know everything in the course so far. New units are on the way.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Start at \(units[passed].title)")
                    .font(.title2.weight(.bold))
                Text("Lessons before it will be marked as done. You can still replay them anytime.")
                    .foregroundStyle(.secondary)
            }
            Spacer()

            if passed > 0 {
                Button {
                    onPlace(passed)
                    dismiss()
                } label: {
                    Text("Skip ahead").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color.gochiRed)

                Button("Start from the beginning") { dismiss() }
                    .font(.subheadline.weight(.semibold))
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("Let's go").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color.gochiRed)
            }
        }
        .multilineTextAlignment(.center)
        .transition(.opacity)
    }
}
