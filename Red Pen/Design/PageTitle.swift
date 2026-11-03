//
//  PageTitle.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/31/26.
//

import SwiftUI

struct PageTitle: View {
    let marked: String
    var rest: String = ""
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 0) {
                Text(marked)
                    .foregroundStyle(Color.accentColor)
                    .background(alignment: .bottom) {
                        Capsule()
                            .fill(Color.accentColor.opacity(0.22))
                            .frame(height: 12)
                            .offset(y: -4)
                            .rotationEffect(.degrees(-2))
                    }
                Text(rest)
            }
            .font(.largeTitle.weight(.heavy))

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PageTitle(marked: "오답", rest: "노트", subtitle: "Your wrong-answer notebook")
        .padding()
}
