//
//  LessonPlayerView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import SwiftUI
import SwiftData

struct LessonPlayerView: View {
    let lesson: Lesson

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ProgressStore.self) private var progress
    @Environment(ProStore.self) private var store
    @Environment(Wallet.self) private var wallet
    @AppStorage("hideGochi") private var hideGochi = false

    @State private var index = 0
    @State private var picked: Int?
    @State private var shuffled: [String] = []
    @State private var built: [Int] = []
    @State private var checked = false
    @State private var wasRight = false
    @State private var saved = 0
    @State private var earned = 0
    @State private var hop = 0
    @State private var wobble = 0
    @State private var finished = false

    private var step: Step { lesson.steps[index] }
    private var isQuestion: Bool { step.kind == .choice || step.kind == .build }

    var body: some View {
        VStack(spacing: 0) {
            header
            if finished {
                doneView
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        gochiBubble
                        stepContent
                    }
                    .padding()
                    .id(index)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .opacity))
                }
                footer
            }
        }
        .background(NotebookPaper())
        .sensoryFeedback(.success, trigger: hop)
        .sensoryFeedback(.error, trigger: wobble)
        .onAppear(perform: prepare)
        .task(id: index) {
            if step.kind == .example, let ko = step.ko {
                try? await Task.sleep(for: .milliseconds(250))
                Speaker.shared.speak(ko)
            }
        }
    }
    
    private func koreanSentence(_ text: String) -> String {
        guard let blank = text.range(of: "___") else { return text }
        func isKorean(_ c: Character) -> Bool {
            c == " " || c == "_" || c == "." || c == "?" || ("가"..."힣").contains(c)
        }
        var start = blank.lowerBound
        while start > text.startIndex, isKorean(text[text.index(before: start)]) {
            start = text.index(before: start)
        }
        var end = blank.upperBound
        while end < text.endIndex, isKorean(text[end]) {
            end = text.index(after: end)
        }
        return text[start..<end].trimmingCharacters(in: .whitespaces)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(finished ? lesson.steps.count : index),
                         total: Double(lesson.steps.count))
                .tint(Color.gochiRed)
        }
        .padding()
    }

    private var gochiBubble: some View {
        HStack(alignment: .top, spacing: 12) {
            if !hideGochi {
                GochiView(xp: progress.xp, celebrate: hop, mood: .happy)
                    .frame(width: 72, height: 72)
                    .keyframeAnimator(initialValue: 0.0, trigger: wobble) { content, angle in
                        content.rotationEffect(.degrees(angle))
                    } keyframes: { _ in
                        KeyframeTrack {
                            LinearKeyframe(-12, duration: 0.07)
                            LinearKeyframe(12, duration: 0.07)
                            LinearKeyframe(-8, duration: 0.07)
                            LinearKeyframe(0, duration: 0.07)
                        }
                    }
            }
            bubbleText
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .softCard()
        }
    }

    private var bubbleText: Text {
        switch step.kind {
        case .say, .choice:
            Text(verbatim: step.text ?? "")
        case .example:
            Text("Listen, then say it out loud.")
        case .build:
            Text("Put the words in order: \(step.translation ?? "")")
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step.kind {
        case .say:
            EmptyView()
        case .example:
            exampleCard
        case .choice:
            choiceView
        case .build:
            buildView
        }
    }

    private var exampleCard: some View {
        Button {
            Speaker.shared.speak(step.ko ?? "")
        } label: {
            VStack(spacing: 10) {
                Text(verbatim: step.ko ?? "")
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                Text(verbatim: step.translation ?? "")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(Color.gochiRed)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal)
            .softCard()
        }
        .buttonStyle(.plain)
    }

    private var choiceView: some View {
        VStack(spacing: 10) {
            ForEach(Array((step.options ?? []).enumerated()), id: \.offset) { i, option in
                Button {
                    if !checked { picked = i }
                } label: {
                    Text(verbatim: option)
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(optionFill(i), in: .rect(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(optionBorder(i), lineWidth: 2)
                        }
                }
                .buttonStyle(.plain)
            }
            if checked { feedback }
        }
    }

    private func optionFill(_ i: Int) -> Color {
        if checked {
            if i == step.answer { return .green.opacity(0.15) }
            if i == picked { return Color.gochiRed.opacity(0.12) }
        } else if i == picked {
            return Color.gochiRed.opacity(0.08)
        }
        return Color(.systemBackground)
    }

    private func optionBorder(_ i: Int) -> Color {
        if checked {
            if i == step.answer { return .green }
            if i == picked { return Color.gochiRed }
        } else if i == picked {
            return Color.gochiRed
        }
        return Color.primary.opacity(0.06)
    }

    private var buildView: some View {
        VStack(spacing: 24) {
            WordFlow {
                ForEach(built, id: \.self) { i in
                    Button {
                        if !checked {
                            withAnimation(.snappy) { built.removeAll { $0 == i } }
                        }
                    } label: {
                        chip(shuffled[i])
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .topLeading)
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.primary.opacity(0.15))
                    .frame(height: 1)
            }

            WordFlow {
                ForEach(shuffled.indices, id: \.self) { i in
                    let used = built.contains(i)
                    Button {
                        withAnimation(.snappy) { built.append(i) }
                    } label: {
                        chip(shuffled[i])
                            .opacity(used ? 0.25 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(used || checked)
                }
            }

            if checked { feedback }
        }
    }

    private func chip(_ word: String) -> some View {
        Text(verbatim: word)
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
            }
    }

    private var feedback: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: wasRight ? "checkmark.circle.fill" : "xmark.circle.fill")
                wasRight ? Text(verbatim: "정답!") : Text("Not quite")
            }
            .font(.headline)
            .foregroundStyle(wasRight ? Color.green : Color.gochiRed)

            if !wasRight, step.kind == .build {
                Text(verbatim: (step.words ?? []).joined(separator: " "))
                    .font(.title3.weight(.semibold))
            }
            if let why = step.why {
                Text(verbatim: why)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .softCard()
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var footer: some View {
        Button {
            if isQuestion && !checked { check() } else { next() }
        } label: {
            (isQuestion && !checked ? Text("Check") : Text("Continue"))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Color.gochiRed)
        .disabled(!canPress)
        .padding()
    }

    private var canPress: Bool {
        guard isQuestion, !checked else { return true }
        if step.kind == .choice { return picked != nil }
        return built.count == shuffled.count
    }

    private var doneView: some View {
        VStack(spacing: 16) {
            Spacer()
            if hideGochi {
                Text("🎉").font(.system(size: 72))
            } else {
                GochiView(xp: progress.xp, celebrate: hop, mood: .happy)
                    .frame(height: 120)
                    .task {
                        try? await Task.sleep(for: .milliseconds(300))
                        hop += 1
                    }
            }
            Text(verbatim: "잘했어요!")
                .font(.largeTitle.weight(.heavy))
            Text(verbatim: lesson.title)
                .foregroundStyle(.secondary)
            if earned > 0 {
                Text("+\(earned) 🍊")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange, in: Capsule())
            }
            if saved > 0 {
                Text("\(saved) mistakes saved to your notebook")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Done").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color.gochiRed)
        }
        .padding()
        .transition(.opacity)
    }

    private func prepare() {
        picked = nil
        built = []
        checked = false
        wasRight = false
        let words = step.words ?? []
        var mixed = words.shuffled()
        var tries = 0
        while mixed == words && words.count > 1 && tries < 5 {
            mixed.shuffle()
            tries += 1
        }
        shuffled = mixed
    }

    private func check() {
        let right: Bool
        switch step.kind {
        case .choice: right = picked == step.answer
        case .build: right = built.map { shuffled[$0] } == (step.words ?? [])
        default: right = true
        }
        withAnimation(.snappy) {
            checked = true
            wasRight = right
        }
        if right {
            hop += 1
        } else {
            wobble += 1
            saveMistake()
        }
    }

    private func saveMistake() {
        let original: String
        let corrected: String
        switch step.kind {
        case .choice:
            guard let text = step.text, text.contains("___"),
                  let options = step.options, let picked, let answer = step.answer else { return }
            let sentence = koreanSentence(text)
            original = sentence.replacingOccurrences(of: "___", with: options[picked])
            corrected = sentence.replacingOccurrences(of: "___", with: options[answer])
        case .build:
            original = built.map { shuffled[$0] }.joined(separator: " ")
            corrected = (step.words ?? []).joined(separator: " ")
        default:
            return
        }
        let c = Correction(original: original, corrected: corrected, note: step.why ?? "")
        c.type = MistakeDetector.detect(original: original, corrected: corrected)
        c.source = .lesson
        modelContext.insert(c)
        saved += 1
    }

    private func next() {
        if index + 1 < lesson.steps.count {
            withAnimation(.snappy) {
                index += 1
                prepare()
            }
        } else {
            finish()
        }
    }

    private func finish() {
        let firstTime = !CourseStore.shared.isDone(lesson)
        CourseStore.shared.markDone(lesson)
        if firstTime {
            earned = wallet.earn(20)
            progress.earn(15)
        }
        progress.recordPracticeDay(freezeAllowance: store.tier >= .plus ? ProgressStore.plusFreezesPerMonth : 0)
        withAnimation(.snappy) { finished = true }
    }
}

struct WordFlow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: min(widest, maxWidth), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
