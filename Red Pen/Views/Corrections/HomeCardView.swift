//
//  HomeCardView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/31/26.
//

import SwiftUI

struct HomeCardView: View {
    let dueCount: Int

    @Environment(ProgressStore.self) private var progress
    @AppStorage("dailyGoal") private var dailyGoal = 10
    @AppStorage("selectedTab") private var selectedTab = "practice"

    private var xp: Int { progress.xp }
    private var streak: Int { progress.streak }
    private var lastPracticeDay: Double { progress.lastPracticeDay }
    private var todayCount: Int { progress.todayCount }
    private var todayCountDay: Double { progress.todayCountDay }

    @State private var gochiTaps = 0

    private var gochi: GochiForm { .forXP(xp) }

    private var gochiProgress: Double {
        guard let next = gochi.next else { return 1 }
        return Double(xp - gochi.minXP) / Double(next.minXP - gochi.minXP)
    }

    private var gochiMood: GochiMood {
        if lastPracticeDay == 0 { return .awake }
        let today = Calendar.current.startOfDay(for: .now).timeIntervalSince1970
        if lastPracticeDay == today { return .happy }
        return currentStreak > 0 ? .awake : .sleepy
    }

    private var currentStreak: Int {
        DailyProgress.currentStreak(streak: streak, lastPracticeDay: lastPracticeDay)
    }

    private var answeredToday: Int {
        DailyProgress.answeredToday(count: todayCount, day: todayCountDay)
    }

    private var goalProgress: Double {
        min(Double(answeredToday) / Double(max(dailyGoal, 1)), 1)
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "좋은 아침이에요 ☀️"
        case 12..<18: return "안녕하세요 👋"
        default: return "오늘도 수고했어요 🌙"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(greeting)
                    .font(.headline)
                Spacer()
                KoreanFlag()
                    .frame(width: 28)
            }

            HStack(spacing: 14) {
                Button {
                    gochiTaps += 1
                } label: {
                    ZStack {
                        goalRing
                        GochiView(xp: xp, celebrate: gochiTaps, mood: gochiMood)
                            .padding(12)
                    }
                    .frame(width: 84, height: 84)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 5) {
                    Label(currentStreak == 0 ? String(localized: "Start a streak")
                                             : String(localized: "\(currentStreak) day streak"),
                          systemImage: currentStreak == 0 ? "flame" : "flame.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(currentStreak == 0 ? Color.secondary : Color.accentColor)
                    Text("\(answeredToday) / \(dailyGoal) today · \(dueCount) ready")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text(verbatim: "고치 · \(gochi.title)")
                            .font(.caption.weight(.semibold))
                        Spacer()
                        if let next = gochi.next {
                            Text("\(xp) / \(next.minXP) XP")
                        } else {
                            Text("Max level")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    ProgressView(value: gochiProgress)
                        .tint(.taegeukBlue)
                }
            }

            if dueCount > 0 {
                Button {
                    selectedTab = "practice"
                } label: {
                    Label("Practice now", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var goalRing: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 5)
            Circle()
                .trim(from: 0, to: goalProgress)
                .stroke(goalProgress >= 1 ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview {
    HomeCardView(dueCount: 3)
        .padding()
        .background(Color(.systemGroupedBackground))
        .environment(ProgressStore())
}
