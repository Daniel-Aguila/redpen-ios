//
//  PracticeView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/29/26.
//

import SwiftUI
import SwiftData

struct PracticeView: View {
    @Query private var corrections: [Correction]
    @Query(sort: \Folder.createdAt) private var folders: [Folder]

    @AppStorage("streak") private var streak = 0
    @AppStorage("lastPracticeDay") private var lastPracticeDay: Double = 0
    @AppStorage("todayCount") private var todayCount = 0
    @AppStorage("todayCountDay") private var todayCountDay: Double = 0
    @AppStorage("xp") private var xp = 0

    @State private var scope: PracticeScope = .all
    @State private var session: [Exercise] = []
    @State private var index = 0
    @State private var correctCount = 0
    @State private var sessionXP = 0
    @State private var showingChart = false

    private var pool: [Correction] {
        corrections.filter { c in
            switch scope {
            case .all: true
            case .folder(let f): c.folder == f
            case .type(let t): c.type == t
            }
        }
    }
    
    private var due: [Correction] {
        pool.filter { $0.dueDate <= .now }
    }

    private var dueByType: [(type: MistakeType, count: Int)] {
        MistakeType.allCases
            .map { type in (type, due.filter { $0.type == type }.count) }
            .filter { $0.count > 0 }
    }

    private var cheer: (emoji: String, text: String) {
        let ratio = session.isEmpty ? 0 : Double(correctCount) / Double(session.count)
        switch ratio {
        case 1: return ("🏆", "완벽해요!")
        case 0.7...: return ("🎉", "잘했어요!")
        case 0.4...: return ("💪", "좋아요!")
        default: return ("🌱", "화이팅!")
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if session.isEmpty {
                    startView
                } else if index < session.count {
                    ProgressView(value: Double(index), total: Double(session.count))
                        .padding()
                    Spacer()
                    ExerciseCardView(exercise: session[index]) { rating in
                        finish(rating)
                    }
                    .id(session[index].id)
                    Spacer()
                } else {
                    doneView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(NotebookPaper())
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Hangul chart", systemImage: "character.book.closed") {
                        showingChart = true
                    }
                }
            }
            .sheet(isPresented: $showingChart) {
                HangulChartView()
                    .presentationDetents([.medium, .large])
            }
            .onChange(of: folders) {
                if case .folder(let f) = scope, !folders.contains(f) {
                    scope = .all
                }
            }
        }
    }

    private var startView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageTitle(marked: "연습", subtitle: "Practice your mistakes")
                    .padding(.leading, 20)

                VStack(spacing: 16) {
                    if !folders.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                folderChip(String(localized: "All"), isOn: scope == .all) {
                                    scope = .all
                                }
                                ForEach(folders) { f in
                                    folderChip("\(f.emoji) \(f.name)", isOn: scope == .folder(f)) {
                                        scope = .folder(f)
                                    }
                                }
                            }
                        }
                    }

                    if due.isEmpty {
                        if pool.isEmpty {
                            Text("📭")
                                .font(.system(size: 56))
                            Text("Nothing here yet")
                                .font(.title2.weight(.bold))
                        } else {
                            Text("🎉")
                                .font(.system(size: 56))
                            Text("다 했어요!")
                                .font(.title2.weight(.bold))
                            Text("You're all caught up. New mistakes will show up here when they're due.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                            Button {
                                start(pool)
                            } label: {
                                Label("Review all \(pool.count)", systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    } else {
                        Text("\(due.count)")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                        (due.count == 1 ? Text("mistake ready") : Text("mistakes ready"))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            ForEach(dueByType, id: \.type) { item in
                                Label("\(item.count)", systemImage: item.type.symbol)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(item.type.color, in: Capsule())
                            }
                        }

                        Button {
                            start(due)
                        } label: {
                            Label("Start", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        if pool.count > due.count {
                            Button {
                                start(pool)
                            } label: {
                                Label("Review all \(pool.count)", systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .card()
            }
            .padding()
        }
    }

    private func folderChip(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isOn ? Color.accentColor : Color(.systemGray6), in: Capsule())
                .foregroundStyle(isOn ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private var doneView: some View {
        VStack(spacing: 16) {
            Text(cheer.emoji)
                .font(.system(size: 72))
            Text(cheer.text)
                .font(.largeTitle.weight(.heavy))
            Text("\(correctCount) / \(session.count) correct")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("+\(sessionXP) XP")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.taegeukBlue, in: Capsule())

            if correctCount < session.count {
                NavigationLink {
                    ProRoadmapView()
                } label: {
                    Label("Explanations for the ones you missed · Pro, coming soon",
                          systemImage: "sparkles")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
            }

            Button {
                session = []
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .card()
        .padding()
    }

    private func start(_ items: [Correction]) {
        session = items.shuffled().prefix(10).map { ExerciseGenerator.make(from: $0) }
        index = 0
        correctCount = 0
        sessionXP = 0
    }

    private func finish(_ rating: Rating) {
        let correction = session[index].correction
        if correction.modelContext != nil {
            Scheduler.apply(rating, to: correction)
        }
        countAnswer()

        let gained = rating == .again ? 2 : 10
        xp += gained
        sessionXP += gained

        if rating != .again { correctCount += 1 }
        index += 1

        if index == session.count {
            recordPracticeDay()
        }
    }

    private func recordPracticeDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let last = Date(timeIntervalSince1970: lastPracticeDay)

        if calendar.isDate(last, inSameDayAs: today) { return }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            streak += 1
        } else {
            streak = 1
        }
        lastPracticeDay = today.timeIntervalSince1970
    }

    private func countAnswer() {
        let today = Calendar.current.startOfDay(for: .now).timeIntervalSince1970
        if todayCountDay != today {
            todayCount = 0
            todayCountDay = today
        }
        todayCount += 1
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Correction.self, Folder.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let work = Folder(name: "Work", emoji: "💼")
    container.mainContext.insert(work)

    let samples = [
        ("저는 학생가 아니에요", "저는 학생이 아니에요"),
        ("밥 먹었어", "밥 먹었어요"),
        ("선생님이 가요", "선생님께서 가세요"),
        ("어제 학교에 가요", "어제 학교에 갔어요"),
        ("할수있어요", "할 수 있어요"),
    ]
    for (i, (original, corrected)) in samples.enumerated() {
        let c = Correction(original: original, corrected: corrected)
        c.type = MistakeDetector.detect(original: original, corrected: corrected)
        if i < 2 { c.folder = work }
        if i == 4 { c.dueDate = .now.addingTimeInterval(86_400) }
        container.mainContext.insert(c)
    }

    return PracticeView()
        .modelContainer(container)
}
