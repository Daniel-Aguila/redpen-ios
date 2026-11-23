//
//  CourseView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//
import SwiftUI

struct CourseView: View {
    @Environment(ProStore.self) private var store
    @Environment(ProgressStore.self) private var progress
    @AppStorage("hideGochi") private var hideGochi = false
    @State private var playing: Lesson?
    @State private var showPaywall = false
    @State private var showPlacement = false
    @State private var expanded: Set<Int> = []

    private let library = CourseStore.shared
    private let rowHeight: CGFloat = 124

    private var allLessons: [Lesson] { library.course.units.flatMap(\.lessons) }
    private var doneCount: Int { allLessons.filter(library.isDone).count }
    private var next: Lesson? { library.nextLesson { !isLocked($0) } }
    private var currentUnit: CourseUnit? {
        library.course.units.first { unit in unit.lessons.contains { $0.id == next?.id } }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    PageTitle(marked: "수업", subtitle: "Learn Korean step by step")
                        .padding(.leading, 20)

                    header

                    if doneCount == 0 {
                        placementButton
                    }

                    ForEach(library.course.units) { unit in
                        unitSection(unit)
                            .id(unit.id)
                    }
                }
                .padding()
                .padding(.bottom, 60)
            }
            .safeAreaInset(edge: .top) {
                unitStrip(proxy)
            }
            .task {
                guard doneCount > 0, let unit = currentUnit else { return }
                try? await Task.sleep(for: .milliseconds(300))
                withAnimation(.snappy) { proxy.scrollTo(unit.id, anchor: .top) }
            }
        }
        .background(NotebookPaper())
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $playing) { lesson in
            LessonPlayerView(lesson: lesson)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(startOn: .plus)
        }
        .sheet(isPresented: $showPlacement) {
            PlacementView { passed in
                for unit in library.course.units.prefix(passed) {
                    for lesson in unit.lessons {
                        library.markDone(lesson)
                    }
                }
            }
        }
    }

    private func isLocked(_ unit: CourseUnit) -> Bool {
        !unit.isFree && store.tier < .plus
    }

    private var header: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !hideGochi {
                GochiView(xp: progress.xp, mood: .happy)
                    .frame(width: 72, height: 72)
            }
            VStack(alignment: .leading, spacing: 10) {
                if let next {
                    Text(doneCount == 0 ? "Let's start with \(next.title)!" : "Ready for \(next.title)?")
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("You finished every lesson. 대단해요!")
                        .font(.subheadline.weight(.semibold))
                }
                ProgressView(value: Double(doneCount), total: Double(max(allLessons.count, 1)))
                    .tint(Color.gochiRed)
                HStack {
                    Text("\(doneCount) of \(allLessons.count) lessons")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let next {
                        Button {
                            playing = next
                        } label: {
                            Text(doneCount == 0 ? "Start" : "Continue")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gochiRed, in: Capsule())
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }
            .padding(14)
            .softCard()
        }
    }

    private var placementButton: some View {
        Button {
            showPlacement = true
        } label: {
            HStack(spacing: 12) {
                Text("🎯")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Already know some Korean?")
                        .font(.subheadline.weight(.semibold))
                    Text("Take a 2-minute check and skip ahead")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.taegeukBlue.opacity(0.08), in: .rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.taegeukBlue.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(PressableStyle())
    }

    private func unitSection(_ unit: CourseUnit) -> some View {
        let locked = isLocked(unit)
        let complete = unit.lessons.allSatisfy(library.isDone)
        let isCurrent = unit.id == currentUnit?.id
        let open = !locked && (isCurrent != expanded.contains(unit.id))
        let ink: Color = unit.biome.isDark ? .white : .secondary

        return VStack(spacing: 12) {
            Button {
                if locked {
                    showPaywall = true
                    return
                }
                withAnimation(.snappy) {
                    if expanded.contains(unit.id) {
                        expanded.remove(unit.id)
                    } else {
                        expanded.insert(unit.id)
                    }
                }
            } label: {
                unitBanner(unit, color: unit.color, locked: locked)
            }
            .buttonStyle(.plain)

            if open {
                lessonPath(unit, locked: locked)
                    .transition(.opacity)
            } else {
                Group {
                    if locked {
                        Text("\(unit.lessons.count) lessons · Unlock with Plus")
                    } else if complete {
                        Text("Completed · tap to review")
                    } else {
                        Text("\(unit.lessons.count) lessons · tap to open")
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(ink)
                .padding(.bottom, 4)
            }
        }
        .padding(12)
        .background {
            BiomeBackground(biome: unit.biome)
        }
        .clipShape(.rect(cornerRadius: 32))
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(.black.opacity(0.06), lineWidth: 1)
        }
    }

    private func unitStrip(_ proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(library.course.units) { unit in
                    let done = unit.lessons.allSatisfy(library.isDone)
                    let current = unit.id == currentUnit?.id
                    let locked = isLocked(unit)
                    Button {
                        withAnimation(.snappy) {
                            if !locked {
                                if current { expanded.remove(unit.id) } else { expanded.insert(unit.id) }
                            }
                            proxy.scrollTo(unit.id, anchor: .top)
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Text(verbatim: unit.emoji)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(unit.color.opacity(locked ? 0.1 : 0.2), in: Circle())
                                .overlay {
                                    Circle().strokeBorder(current ? unit.color : .clear, lineWidth: 2.5)
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    if done {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.green)
                                            .background(Circle().fill(.white))
                                    } else if locked {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.secondary)
                                            .padding(3)
                                            .background(Circle().fill(.white))
                                    }
                                }
                            (unit.id == 0 ? Text("Hangul") : Text("Unit \(unit.id)"))
                                .font(.caption2.weight(current ? .bold : .medium))
                                .foregroundStyle(current ? unit.color : .secondary)
                        }
                        .opacity(locked ? 0.6 : 1)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }

    private func unitBanner(_ unit: CourseUnit, color: Color, locked: Bool) -> some View {
        let done = unit.lessons.filter(library.isDone).count
        return HStack(spacing: 14) {
            Text(verbatim: unit.emoji)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(.white.opacity(0.22), in: .rect(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 2) {
                (unit.id == 0 ? Text("START HERE") : Text("UNIT \(unit.id)"))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white.opacity(0.85))
                Text(verbatim: unit.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text(verbatim: unit.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                Text(verbatim: "\(unit.biome.skyIcon) \(unit.biome.name)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.white.opacity(0.2), in: Capsule())
                    .padding(.top, 4)
            }
            Spacer()

            if locked {
                Text("PLUS")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white, in: Capsule())
            } else {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: Double(done) / Double(max(unit.lessons.count, 1)))
                        .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(done)/\(unit.lessons.count)")
                        .font(.caption2.weight(.bold).monospacedDigit())
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [color, color.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .rect(cornerRadius: 24)
        )
        .shadow(color: color.opacity(0.3), radius: 10, y: 5)
    }

    private func xOffset(_ i: Int, amp: CGFloat) -> CGFloat {
        let pattern: [CGFloat] = [0, -0.8, -1, -0.5, 0.3, 0.9, 1, 0.5]
        return pattern[i % pattern.count] * amp
    }

    private func riverPath(_ points: [CGPoint]) -> Path {
        Path { p in
            p.move(to: CGPoint(x: points[0].x, y: 0))
            p.addLine(to: points[0])
            for i in 1..<points.count {
                let a = points[i - 1]
                let b = points[i]
                p.addCurve(to: b,
                           control1: CGPoint(x: a.x, y: a.y + rowHeight / 2),
                           control2: CGPoint(x: b.x, y: b.y - rowHeight / 2))
            }
        }
    }

    private func lessonPath(_ unit: CourseUnit, locked: Bool) -> some View {
        let lessons = unit.lessons
        let biome = unit.biome
        let count = lessons.count + 1
        let unitDone = lessons.allSatisfy(library.isDone)
        let ink: Color = biome.isDark ? .white : .primary
        let softInk: Color = biome.isDark ? .white.opacity(0.7) : .secondary

        return GeometryReader { geo in
            let width = geo.size.width
            let mid = width / 2
            let amp = min(width * 0.2, 70)
            let points = (0..<count).map { i in
                CGPoint(x: mid + xOffset(i, amp: amp), y: CGFloat(i) * rowHeight + 56)
            }
            let last = points[count - 1]

            ZStack {
                riverPath(points)
                    .stroke(biome.water, style: StrokeStyle(lineWidth: 46, lineCap: .round, lineJoin: .round))
                riverPath(points)
                    .stroke(.white.opacity(biome.isDark ? 0.35 : 0.7),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [10, 18]))

                ForEach(0..<(count - 1), id: \.self) { i in
                    Text(verbatim: biome.plants[(unit.id + i) % biome.plants.count])
                        .font(.title3)
                        .position(x: i % 2 == 0 ? 20 : width - 20, y: points[i].y + rowHeight / 2)
                }

                ForEach(Array(lessons.enumerated()), id: \.element.id) { i, lesson in
                    let point = points[i]
                    let side: CGFloat = xOffset(i, amp: amp) <= 0 ? 1 : -1
                    let isNext = lesson.id == next?.id

                    padNode(lesson, number: i + 1, biome: biome, locked: locked, isNext: isNext)
                        .position(point)

                    VStack(alignment: side > 0 ? .leading : .trailing, spacing: 1) {
                        Text(verbatim: lesson.title)
                            .font(.caption.weight(isNext ? .bold : .semibold))
                            .foregroundStyle(locked ? softInk : ink)
                            .lineLimit(2)
                        if isNext {
                            Text("Gochi is waiting!")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(biome.padDark)
                        }
                    }
                    .multilineTextAlignment(side > 0 ? .leading : .trailing)
                    .frame(width: 116, alignment: side > 0 ? .leading : .trailing)
                    .position(x: point.x + side * 102, y: point.y)
                }

                hotSpring(done: unitDone)
                    .position(last)

                (unitDone ? Text("Soaking time! ♨️") : Text("Finish the unit to soak"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(unitDone ? ink : softInk)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.black.opacity(biome.isDark ? 0.25 : 0), in: Capsule())
                    .position(x: last.x, y: last.y + 48)
            }
        }
        .frame(height: CGFloat(count - 1) * rowHeight + 120)
    }

    @ViewBuilder
    private func padShape(_ biome: Biome, filled: Bool) -> some View {
        let fill = filled ? biome.padDark : biome.padLight
        switch biome.pad {
        case .lily:
            LilyPad()
                .fill(fill)
                .overlay {
                    LilyPad().stroke(biome.padDark.opacity(0.6), lineWidth: 2)
                }
                .frame(width: 72, height: 72)
                .scaleEffect(x: 1, y: 0.8)
        case .stone:
            Ellipse()
                .fill(LinearGradient(colors: [fill, fill.opacity(0.75)], startPoint: .top, endPoint: .bottom))
                .overlay {
                    Ellipse().stroke(.black.opacity(0.12), lineWidth: 2)
                }
                .frame(width: 74, height: 54)
        case .ice:
            RoundedRectangle(cornerRadius: 16)
                .fill(fill)
                .overlay {
                    RoundedRectangle(cornerRadius: 16).stroke(.white, lineWidth: 2)
                }
                .frame(width: 70, height: 50)
                .rotationEffect(.degrees(-6))
        }
    }

    private func padNode(_ lesson: Lesson, number: Int, biome: Biome, locked: Bool, isNext: Bool) -> some View {
        let done = library.isDone(lesson)

        return Button {
            if locked { showPaywall = true } else { playing = lesson }
        } label: {
            ZStack {
                if isNext {
                    Ellipse()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 92, height: 54)
                        .offset(y: 6)
                        .phaseAnimator([false, true]) { content, on in
                            content
                                .scaleEffect(on ? 1.3 : 0.85)
                                .opacity(on ? 0 : 0.9)
                        } animation: { _ in
                            .easeOut(duration: 1.6)
                        }
                }

                if locked {
                    Ellipse()
                        .fill(Color(.systemGray4))
                        .frame(width: 66, height: 50)
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 3)
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.white)
                } else {
                    padShape(biome, filled: done || isNext)
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 3)

                    if isNext {
                        if hideGochi {
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                        } else {
                            GochiView(xp: progress.xp, mood: .happy)
                                .frame(width: 62, height: 62)
                                .offset(y: -20)
                        }
                    } else if done {
                        Text(verbatim: biome.doneMark)
                            .font(.title2)
                            .offset(y: -6)
                    } else {
                        Text("\(number)")
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(biome.numberColor)
                    }
                }
            }
            .frame(width: 96, height: 96)
            .contentShape(Circle())
        }
        .buttonStyle(PressableStyle())
    }

    private func hotSpring(done: Bool) -> some View {
        ZStack {
            Ellipse()
                .fill(LinearGradient(colors: [Biome.springTop, Biome.springBottom], startPoint: .top, endPoint: .bottom))
                .overlay {
                    Ellipse().strokeBorder(Biome.rock, lineWidth: 5)
                }
                .frame(width: 112, height: 56)
                .opacity(done ? 1 : 0.6)
            if done && !hideGochi {
                GochiView(xp: progress.xp, mood: .happy)
                    .frame(width: 64, height: 64)
                    .offset(y: -14)
            }
            Text(verbatim: "♨️")
                .font(.title3)
                .offset(x: 44, y: -30)
                .opacity(done ? 1 : 0.5)
        }
    }
}

struct LessonsEntryCard: View {
    @Environment(ProStore.self) private var store
    @Environment(ProgressStore.self) private var progress
    @AppStorage("hideGochi") private var hideGochi = false

    private let library = CourseStore.shared

    var body: some View {
        let all = library.course.units.flatMap(\.lessons)
        let doneCount = all.filter(library.isDone).count
        let next = library.nextLesson { $0.isFree || store.tier >= .plus }

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Lessons")
                    .font(.title3.weight(.bold))
                if let next {
                    Text("Next: \(next.title)")
                        .font(.subheadline)
                        .opacity(0.9)
                } else {
                    Text("All lessons done. 대단해요!")
                        .font(.subheadline)
                        .opacity(0.9)
                }
                ProgressView(value: Double(doneCount), total: Double(max(all.count, 1)))
                    .tint(.white)
                    .padding(.top, 4)
                Text("\(doneCount) of \(all.count) lessons")
                    .font(.caption.weight(.semibold))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)

            Spacer(minLength: 8)

            if hideGochi {
                Text("📚").font(.system(size: 48))
            } else {
                GochiView(xp: progress.xp, mood: .happy)
                    .frame(width: 80, height: 80)
            }
        }
        .padding(18)
        .background(
            LinearGradient(colors: [Color.gochiRed, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .rect(cornerRadius: 24)
        )
        .shadow(color: Color.gochiRed.opacity(0.3), radius: 10, y: 5)
    }
}

extension CourseStore {
    func nextLesson(unlocked: (CourseUnit) -> Bool) -> Lesson? {
        for unit in course.units where unlocked(unit) {
            if let lesson = unit.lessons.first(where: { !isDone($0) }) {
                return lesson
            }
        }
        return nil
    }
}

extension CourseUnit {
    var emoji: String {
        let list = ["가", "👋", "👨‍👩‍👧", "☕️", "🏫", "🌦️", "💌", "📍", "📅", "⚽️", "🗓️",
                    "🍜", "🛍️", "🎤", "✈️", "💊", "🚇", "🏠", "🎭", "🧭", "🙇"]
        return id < list.count ? list[id] : "📘"
    }

    var color: Color {
        let palette: [Color] = [.gochiRed, .orange, .green, .taegeukBlue, .purple, .teal, .pink, .indigo]
        return palette[id % palette.count]
    }
}
