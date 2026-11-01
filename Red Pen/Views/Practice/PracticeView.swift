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

    @AppStorage("streak") private var streak = 0
    @AppStorage("lastPracticeDay") private var lastPracticeDay: Double = 0
    @AppStorage("todayCount") private var todayCount = 0
    @AppStorage("todayCountDay") private var todayCountDay: Double = 0
    @AppStorage("xp") private var xp = 0

    @State private var session: [Exercise] = []
    @State private var index = 0
    @State private var correctCount = 0
    @State private var sessionXP = 0
    @State private var showingChart = false

    private var due: [Correction] {
        corrections.filter { $0.dueDate <= .now }
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
        }
    }

    private var startView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageTitle(marked: "연습", subtitle: "Practice your mistakes")
                    .padding(.leading, 20)

                VStack(spacing: 16) {
                    if due.isEmpty {
                        Text("🎉")
                            .font(.system(size: 56))
                        Text("다 했어요!")
                            .font(.title2.weight(.bold))
                        Text("You're all caught up. New mistakes will show up here when they're due.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(due.count)")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                        Text(due.count == 1 ? "mistake ready" : "mistakes ready")
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
                            start()
                        } label: {
                            Label("Start", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .frame(maxWidth: .infinity)
                .card()
            }
            .padding()
        }
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

    private func start() {
        session = due.shuffled().prefix(10).map { ExerciseGenerator.make(from: $0) }
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
    PracticeView()
        .modelContainer(for: Correction.self, inMemory: true)
}
