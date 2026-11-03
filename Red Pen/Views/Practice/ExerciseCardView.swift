//
//  ExerciseCardView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/29/26.
//

import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    let exercise: Exercise
    let onFinish: (Rating) -> Void

    @State private var picked: String? = nil
    @State private var revealed = false

    private var instruction: String {
        switch exercise.kind {
        case .fillGap: String(localized: "Fill in the blank")
        case .flashcard: String(localized: "How would you fix this?")
        }
    }

    private var explanation: String? {
        guard let change = MistakeDetector.particleChanges(original: exercise.correction.original,
                                                           corrected: exercise.correction.corrected).first
        else { return nil }
        return MistakeDetector.explanation(stem: change.stem, particle: change.to)
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(instruction)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(exercise.prompt)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .card()

            switch exercise.kind {
            case .fillGap: choicesView
            case .flashcard: flashcardView
            }
        }
        .padding()
        .sensoryFeedback(trigger: picked) { _, newValue in
            guard let newValue else { return nil }
            return newValue == exercise.answer ? .success : .error
        }
        .sensoryFeedback(.impact(weight: .light), trigger: revealed)
    }

    private var choicesView: some View {
        VStack(spacing: 12) {
            ForEach(exercise.choices, id: \.self) { choice in
                Button {
                    picked = choice
                } label: {
                    Text(choice)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(color(for: choice), in: .rect(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                }
                .disabled(picked != nil)
            }

            if let picked {
                VStack(spacing: 6) {
                    (picked == exercise.answer ? Text("맞아요! Correct") : Text("아쉬워요! Not quite"))
                        .font(.headline)
                        .foregroundStyle(picked == exercise.answer ? .green : Color.accentColor)
                    if let explanation {
                        Text(explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 4)

                HStack {
                    Button {
                        Speaker.shared.speak(exercise.correction.corrected)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button {
                        onFinish(picked == exercise.answer ? .good : .again)
                    } label: {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
    }

    private var flashcardView: some View {
        VStack(spacing: 16) {
            if revealed {
                HStack {
                    Text(exercise.answer)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Button {
                        Speaker.shared.speak(exercise.answer)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .card()

                HStack(spacing: 10) {
                    ratingButton("Again", rating: .again, color: Color.accentColor)
                    ratingButton("Good", rating: .good, color: .taegeukBlue)
                    ratingButton("Easy", rating: .easy, color: .green)
                }
            } else {
                Button {
                    revealed = true
                } label: {
                    Text("Show correction")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    private func ratingButton(_ title: LocalizedStringKey, rating: Rating, color: Color) -> some View {  // CHANGED
        Button {
            onFinish(rating)
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(color)
        .controlSize(.large)
    }

    private func color(for choice: String) -> Color {
        guard let picked else { return Color(.secondarySystemGroupedBackground) }
        if choice == exercise.answer { return .green.opacity(0.3) }
        if choice == picked { return .red.opacity(0.3) }
        return Color(.secondarySystemGroupedBackground)
    }
}

#Preview {
    let c = Correction(original: "저는 학생가 아니에요", corrected: "저는 학생이 아니에요")
    let ex = Exercise(correction: c, kind: .fillGap,
                      prompt: "저는 학생___ 아니에요",
                      choices: ["이", "가", "을", "도"],
                      answer: "이")
    return ExerciseCardView(exercise: ex) { rating in
        print(rating)
    }
    .modelContainer(for: Correction.self, inMemory: true)
}
