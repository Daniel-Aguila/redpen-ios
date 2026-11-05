import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    let exercise: Exercise
    let onFinish: (Rating) -> Void

    @State private var picked: String? = nil
    @State private var revealed: Bool = false
    @State private var typed: String = ""
    @State private var result: AnswerResult? = nil
    @FocusState private var fieldFocused: Bool

    private var instruction: String {
        switch exercise.kind {
        case .fillGap: String(localized: "Fill in the blank")
        case .flashcard: String(localized: "How would you fix this?")
        case .typeFix: String(localized: "Type the corrected sentence")
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
            case .typeFix: typeFixView
            }
        }
        .padding()
        .sensoryFeedback(trigger: picked) { _, newValue in
            guard let newValue else { return nil }
            return newValue == exercise.answer ? .success : .error
        }
        .sensoryFeedback(trigger: result) { _, newValue in
            switch newValue {
            case .correct: .success
            case .almost: .warning
            case .wrong: .error
            case nil: nil
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: revealed)
    }

    private var typeFixView: some View {
        VStack(spacing: 16) {
            if revealed {
                flashcardView
            } else if let result {
                typeFixResult(result)
            } else {
                TextField("Type the correction", text: $typed)
                    .font(.title3)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($fieldFocused)
                    .submitLabel(.done)
                    .onSubmit(check)

                Button {
                    check()
                } label: {
                    Text("Check")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(typed.trimmed.isEmpty)

                Button("Show answer") {
                    revealed = true
                }
                .font(.subheadline)
            }
        }
        .onAppear {
            typed = exercise.prompt
            fieldFocused = true
        }
    }

    @ViewBuilder
    private func typeFixResult(_ result: AnswerResult) -> some View {
        switch result {
        case .correct:
            Text("맞아요! Correct").font(.headline).foregroundStyle(.green)
        case .almost:
            Text("거의 다 왔어요! Almost: check the spacing").font(.headline).foregroundStyle(.orange)
        case .wrong:
            Text("아쉬워요! Not quite").font(.headline).foregroundStyle(Color.accentColor)
        }

        if result != .correct {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your answer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(Self.marked(typed, against: exercise.answer, color: .red, strike: true))
                Text("Correct")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                Text(Self.marked(exercise.answer, against: typed, color: .green, strike: false))
            }
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }

        if let explanation {
            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }

        if result != .correct, let note = exercise.correction.type.note {
            DisclosureGroup("How it works") {
                GrammarNoteView(note: note, tint: exercise.correction.type.color)
                    .padding(.top, 8)
            }
            .card()
        }

        HStack {
            speakButton
            if result == .almost {
                Button {
                    onFinish(.good)
                } label: {
                    Text("Count it").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Button {
                    onFinish(.again)
                } label: {
                    Text("Practice again").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button {
                    onFinish(result == .correct ? .good : .again)
                } label: {
                    Text("Next").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
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
                piece.backgroundColor = color.opacity(0.18)
                if strike { piece.strikethroughStyle = .single }
            }
            out += piece
        }
        return out
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

                if picked != exercise.answer, let note = exercise.correction.type.note {
                    DisclosureGroup("How it works") {
                        GrammarNoteView(note: note, tint: exercise.correction.type.color)
                            .padding(.top, 8)
                    }
                    .card()
                }

                HStack {
                    speakButton
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

    private var speakButton: some View {
        Button {
            Speaker.shared.speak(exercise.correction.corrected)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    private func ratingButton(_ title: LocalizedStringKey, rating: Rating, color: Color) -> some View {
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

    private func check() {
        guard !typed.trimmed.isEmpty else { return }
        fieldFocused = false
        withAnimation {
            result = AnswerChecker.check(typed,
                                         against: exercise.answer,
                                         spacingMatters: exercise.correction.type == .spacing)
        }
    }
}

#Preview {
    let c = Correction(original: "저는 학생가 아니에요", corrected: "저는 학생이 아니에요")
    c.type = .particle
    let ex = Exercise(correction: c, kind: .typeFix,
                      prompt: c.original,
                      choices: [],
                      answer: c.corrected)
    return ExerciseCardView(exercise: ex) { rating in
        print(rating)
    }
    .modelContainer(for: Correction.self, inMemory: true)
}
