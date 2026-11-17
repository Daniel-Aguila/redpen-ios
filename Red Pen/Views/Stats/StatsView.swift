//
//  StatsView.swift
//  Red Pen
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var corrections: [Correction]
    @Environment(ProgressStore.self) private var progress
    @State private var gochiTaps = 0

    private var countsByType: [(type: MistakeType, count: Int)] {
        MistakeType.allCases
            .map { type in (type, corrections.filter { $0.type == type }.count) }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    private var learnedCount: Int {
        corrections.filter(\.isLearned).count
    }

    private var currentStreak: Int {
        DailyProgress.currentStreak(streak: progress.streak, lastPracticeDay: progress.lastPracticeDay)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PageTitle(marked: "통계", subtitle: "Your progress")
                        .padding(.leading, 20)

                    gochiCard

                    if corrections.isEmpty {
                        ContentUnavailableView("No stats yet",
                                               systemImage: "chart.bar",
                                               description: Text("Save a few corrections first."))
                    } else {
                        HStack(spacing: 12) {
                            statTile(value: corrections.count, label: "Saved",
                                     symbol: "book.closed.fill", color: .taegeukBlue)
                            statTile(value: learnedCount, label: "Learned",
                                     symbol: "checkmark.seal.fill", color: .green)
                        }

                        if let top = countsByType.first {
                            topMistake(top.type, count: top.count)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mistakes by type")
                                .font(.headline)
                            Chart(countsByType, id: \.type) { item in
                                BarMark(
                                    x: .value("Count", item.count),
                                    y: .value("Type", item.type.label)
                                )
                                .foregroundStyle(item.type.color.gradient)
                                .cornerRadius(6)
                                .annotation(position: .overlay, alignment: .trailing) {
                                    Text("\(item.count)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.trailing, 6)
                                }
                            }
                            .chartXAxis(.hidden)
                            .chartYAxis {
                                AxisMarks { _ in
                                    AxisValueLabel()
                                }
                            }
                            .frame(height: CGFloat(countsByType.count) * 36)
                        }
                        .card()
                    }
                }
                .padding()
            }
            .background(NotebookPaper())
            .hardTopEdge()
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
            }
        }
    }

    private var gochiCard: some View {
        HStack(spacing: 14) {
            Button {
                gochiTaps += 1
            } label: {
                GochiView(xp: progress.xp, celebrate: gochiTaps)
                    .frame(width: 64, height: 64)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "고치 · \(progress.form.title)")
                    .font(.headline)
                Text("\(progress.xp) XP total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let next = progress.form.next {
                    Text("\(next.minXP - progress.xp) XP to \(next.title)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                NavigationLink {
                    GochiJourneyView()
                } label: {
                    Label("Journey", systemImage: "map")
                        .font(.caption.weight(.semibold))
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Image(systemName: currentStreak == 0 ? "flame" : "flame.fill")
                    .font(.title2)
                    .foregroundStyle(currentStreak == 0 ? Color.secondary : Color.accentColor)
                Text("\(currentStreak)")
                    .font(.headline)
                Text("day streak")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }

    private func topMistake(_ type: MistakeType, count: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: type.symbol)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(type.color, in: .rect(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text("Your top mistake")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(type.label)
                    .font(.headline)
            }
            Spacer()
            Text("\(count)")
                .font(.title2.weight(.bold))
                .foregroundStyle(type.color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(type.color.opacity(0.14))
                )
        )
    }

    private func statTile(value: Int, label: LocalizedStringKey, symbol: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(color)
            Text("\(value)")
                .font(.title.weight(.bold))
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

#Preview {
    StatsView()
        .modelContainer(for: Correction.self, inMemory: true)
        .environment(ProgressStore())
}
