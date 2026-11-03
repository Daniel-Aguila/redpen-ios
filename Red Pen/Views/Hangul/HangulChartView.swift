//
//  HangulChartView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/30/26.
//

import SwiftUI

struct HangulChartView: View {
    private let columns = [GridItem(.adaptive(minimum: 72))]
    @State private var selected: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section("Consonants", items: HangulChart.consonants)
                    section("Vowels", items: HangulChart.vowels)
                }
                .padding()
            }
            .navigationTitle("Hangul")
            .navigationBarTitleDisplayMode(.inline)
            .paperBackground()
        }
    }
    
    private func section(_ title: LocalizedStringKey, items: [Jamo]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { jamo in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selected = jamo.letter
                        }
                        Speaker.shared.speak(jamo.sound)
                    } label: {
                        VStack(spacing: 4) {
                            Text(jamo.letter)
                                .font(.title)
                            Text(jamo.roman)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .background(selected == jamo.letter ? Color.accentColor.opacity(0.2): Color(.secondarySystemBackground),
                                    in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    HangulChartView()
}
