//
//  HomeCardView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/31/26.
//

import SwiftUI

struct HomeCardView: View {
    let dueCount: Int

    @AppStorage("xp") private var xp = 0
    @AppStorage("streak") private var streak = 0
    @AppStorage("lastPracticeDay") private var lastPracticeDay: Double = 0
    @AppStorage("dailyGoal") private var dailyGoal = 10
    @AppStorage("todayCount") private var todayCount = 0
    @AppStorage("todayCountDay") private var todayCountDay: Double = 0
    @AppStorage("selectedTab") private var selectedTab = "practice"

    private var level: Level { Level.forXP(xp) }

    private var levelProgress: Double {
        guard let next = level.next else { return 1 }
        return Double(xp - level.minXP) / Double(next.minXP - level.minXP)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(greeting)
                    .font(.title2.weight(.bold))
                Spacer()
                KoreanFlag()
                    .frame(width: 36)
            }
            // REMOVED: duplicate .font(.title2.weight(.bold)) that was here

            HStack(spacing: 16) {
                goalRing
                VStack(alignment: .leading, spacing: 6) {
                    Label(currentStreak == 0 ? "Start a streak" : "\(currentStreak) day streak",
                          systemImage: currentStreak == 0 ? "flame" : "flame.fill")
                        .font(.headline)
                        .foregroundStyle(currentStreak == 0 ? Color.secondary : Color.accentColor) // CHANGED
                    Text("\(dueCount) ready to practice")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(level.emoji) Lv \(level.rawValue) · \(level.title)")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if let next = level.next {
                        Text("\(xp) / \(next.minXP) XP")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Max level")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                ProgressView(value: levelProgress)
                    .tint(.taegeukBlue)
            }

            Button {
                selectedTab = "practice"
            } label: {
                Label("Practice now", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(dueCount == 0)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var goalRing: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
            Circle()
                .trim(from: 0, to: goalProgress)
                .stroke(goalProgress >= 1 ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(answeredToday)")
                    .font(.headline)
                Text("/ \(dailyGoal)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    HomeCardView(dueCount: 3)
        .padding()
}
