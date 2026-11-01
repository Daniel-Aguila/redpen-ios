//
//  Theme.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/30/26.
//

import SwiftUI

extension Color {
    init(hex: UInt) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }

    static let taegeukRed = Color(hex: 0xCD2E3A)
    static let taegeukBlue = Color(hex: 0x0047A0)

    static let dancheongGreen = Color(hex: 0x2A8C82)
    static let dancheongYellow = Color(hex: 0xE0A526)
    static let dancheongPink = Color(hex: 0xC2457A)
    static let dancheongPurple = Color(hex: 0x6B4C9A)
}

extension View {
    func paperBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(NotebookPaper())
    }
    
    func onPaper() -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
    
    func card() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }
}

struct NotebookPaper: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 32
            var y = spacing
            while y < size.height {
                var line = Path()
                line.move(to: CGPoint(x: 0, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(.blue.opacity(0.05)), lineWidth: 1)
                y += spacing
            }

            var margin = Path()
            margin.move(to: CGPoint(x: 24, y: 0))
            margin.addLine(to: CGPoint(x: 24, y: size.height))
            context.stroke(margin, with: .color(.red.opacity(0.3)), lineWidth: 1)
        }
        .background(Color.paper)
        .ignoresSafeArea()
    }
}
