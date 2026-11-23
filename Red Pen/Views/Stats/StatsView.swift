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
    @Environment(ProStore.self) private var store
    @State private var gochiTaps = 0
    @State private var showPaywall = false
    @AppStorage("hideGochi") private var hideGochi = false

    private struct TypeMastery: Identifiable {
        let type: MistakeType
        let total: Int
        let mastered: Int
        var id: MistakeType { type }
        var ratio: Double { total == 0 ? 0 : Double(mastered) / Double(total) }
    }

    private var isPlus: Bool { store.tier >= .plus }

    private var freezeAllowance: Int { isPlus ? ProgressStore.plusFreezesPerMonth : 0 }

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
        progress.streakIsAlive(freezeAllowance: freezeAllowance) ? progress.streak : 0
    }

    private var mastery: [TypeMastery] {
        MistakeType.allCases
            .map { type in
                let ofType = corrections.filter { $0.type == type }
                return TypeMastery(type: type, total: ofType.count,
                                   mastered: ofType.filter(Scheduler.isMastered).count)
            }
            .filter { $0.total > 0 }
            .sorted { $0.ratio < $1.ratio }
    }

    private var upcoming: [(day: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            let count = corrections.filter { c in
                let due = calendar.startOfDay(for: c.dueDate)
                return offset == 0 ? due <= day : due == day
            }.count
            return (day, count)
        }
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

                        if let top = countsByType.first,
                           countsByType.count == 1 || top.count > countsByType[1].count {
                            topMistake(top.type, count: top.count)
                        }

                        byTypeCard

                        if isPlus {
                            upcomingCard
                            masteryCard
                        } else {
                            lockedCard
                        }
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var gochiCard: some View {
        HStack(spacing: 14) {
            if !hideGochi {
                Button {
                    gochiTaps += 1
                } label: {
                    GochiView(xp: progress.xp, celebrate: gochiTaps)
                        .frame(width: 64, height: 64)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: hideGochi ? "XP" : "고치 · \(progress.form.title)")
                    .font(.headline)
                Text("\(progress.xp) XP total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let next = progress.form.next {
                    Text(hideGochi ? String(localized: "\(next.minXP - progress.xp) XP to next level")
                                   : String(localized: "\(next.minXP - progress.xp) XP to \(next.title)"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !hideGochi {
                    NavigationLink {
                        GochiJourneyView()
                    } label: {
                        Label("Journey", systemImage: "map")
                            .font(.caption.weight(.semibold))
                    }
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
                if isPlus {
                    Label("\(progress.freezesLeft(allowance: freezeAllowance)) freezes", systemImage: "snowflake")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.cyan)
                }
            }
        }
        .card()
    }

    private var byTypeCard: some View {
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

    private var upcomingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Coming up")
                    .font(.headline)
                Spacer()
                Text("\(upcoming.map(\.count).reduce(0, +)) this week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Chart(upcoming, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Reviews", item.count),
                    width: .ratio(0.5)
                )
                .foregroundStyle(Color.gochiRed.gradient)
                .cornerRadius(4)
                .annotation(position: .top) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 120)
        }
        .card()
    }

    private var masteryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Needs work")
                .font(.headline)
            ForEach(mastery.prefix(4)) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: item.type.symbol)
                            .foregroundStyle(item.type.color)
                            .frame(width: 24)
                        Text(item.type.label)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(item.mastered)/\(item.total) solid")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: item.ratio)
                        .tint(item.type.color)
                }
            }
            Text("Smart review puts these first.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .card()
    }

    private var lockedCard: some View {
        masteryCard
            .blur(radius: 6)
            .allowsHitTesting(false)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                    Text("Detailed stats")
                        .font(.headline)
                    Text("See what's coming up and which mistakes need work.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button {
                        showPaywall = true
                    } label: {
                        Text("Get Plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 22)
                            .frame(height: 40)
                            .background(Color.gochiRed, in: .capsule)
                    }
                    .buttonStyle(PressableStyle())
                }
                .padding()
            }
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
        .environment(ProStore())
}
