//
//  StatsView.swift
//  Red Pen
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var corrections: [Correction]

    private var countsByType: [(type: MistakeType, count: Int)] {
        MistakeType.allCases
            .map { type in (type, corrections.filter { $0.type == type }.count) }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    private var learnedCount: Int {
        corrections.filter { $0.intervalDays >= 7 }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        statTile(value: corrections.count, label: "Saved",
                                 symbol: "book.closed.fill", color: .taegeukBlue)
                        statTile(value: learnedCount, label: "Learned",
                                 symbol: "checkmark.seal.fill", color: .green)
                    }

                    if let top = countsByType.first {
                        HStack(spacing: 12) {
                            Image(systemName: top.type.symbol)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(top.type.color, in: .rect(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your top mistake")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(top.type.label)
                                    .font(.headline)
                            }
                            Spacer()
                            Text("\(top.count)")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(top.type.color)
                        }
                        .card()
                    }

                    if !countsByType.isEmpty {
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
            .navigationTitle("Stats")
            .background(NotebookPaper())
            .overlay {
                if corrections.isEmpty {
                    ContentUnavailableView("No stats yet",
                                           systemImage: "chart.bar",
                                           description: Text("Save a few corrections first."))
                }
            }
        }
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
        .card()
    }
}

#Preview {
    StatsView()
        .modelContainer(for: Correction.self, inMemory: true)
}
