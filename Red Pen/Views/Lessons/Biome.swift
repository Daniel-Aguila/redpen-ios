//
//  Biome.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import SwiftUI

struct Biome {
    enum PadStyle { case lily, stone, ice }

    let name: String
    let skyTop: Color
    let skyBottom: Color
    let hillBack: Color
    let hillFront: Color
    let water: Color
    let pad: PadStyle
    let padLight: Color
    let padDark: Color
    let numberColor: Color
    let doneMark: String
    let plants: [String]
    let particle: String?
    let particleSpeed: Double
    let skyIcon: String
    var isDark: Bool = false

    static let all: [Biome] = [
        Biome(name: String(localized: "Spring pond"),
              skyTop: rgb(1.0, 0.93, 0.95), skyBottom: rgb(0.90, 0.96, 0.88),
              hillBack: rgb(0.80, 0.90, 0.76), hillFront: rgb(0.70, 0.85, 0.65),
              water: rgb(0.66, 0.85, 0.95), pad: .lily,
              padLight: rgb(0.62, 0.82, 0.50), padDark: rgb(0.35, 0.65, 0.33), numberColor: .white,
              doneMark: "🌸", plants: ["🌷", "🌿", "🌸", "🐸"],
              particle: "🌸", particleSpeed: 1, skyIcon: "☀️"),
        Biome(name: String(localized: "Summer river"),
              skyTop: rgb(0.85, 0.95, 1.0), skyBottom: rgb(0.86, 0.95, 0.80),
              hillBack: rgb(0.70, 0.88, 0.62), hillFront: rgb(0.55, 0.80, 0.50),
              water: rgb(0.45, 0.78, 0.92), pad: .lily,
              padLight: rgb(0.55, 0.80, 0.42), padDark: rgb(0.28, 0.60, 0.30), numberColor: .white,
              doneMark: "🪷", plants: ["🌻", "🌿", "🐸", "🌾"],
              particle: "🦋", particleSpeed: 0.5, skyIcon: "☀️"),
        Biome(name: String(localized: "Autumn forest"),
              skyTop: rgb(1.0, 0.92, 0.82), skyBottom: rgb(0.98, 0.88, 0.76),
              hillBack: rgb(0.93, 0.72, 0.50), hillFront: rgb(0.85, 0.55, 0.35),
              water: rgb(0.55, 0.75, 0.80), pad: .lily,
              padLight: rgb(0.95, 0.65, 0.35), padDark: rgb(0.82, 0.42, 0.22), numberColor: .white,
              doneMark: "🍁", plants: ["🍄", "🌰", "🍂", "🦔"],
              particle: "🍁", particleSpeed: 0.9, skyIcon: "🌤️"),
        Biome(name: String(localized: "Snowy onsen"),
              skyTop: rgb(0.85, 0.91, 1.0), skyBottom: rgb(0.95, 0.97, 1.0),
              hillBack: rgb(0.82, 0.88, 0.96), hillFront: rgb(0.92, 0.95, 1.0),
              water: rgb(0.70, 0.84, 0.95), pad: .ice,
              padLight: rgb(0.97, 0.99, 1.0), padDark: rgb(0.62, 0.80, 0.96), numberColor: rgb(0.35, 0.55, 0.80),
              doneMark: "❄️", plants: ["⛄️", "🌲", "❄️", "🦌"],
              particle: "❄️", particleSpeed: 0.7, skyIcon: "🌨️"),
        Biome(name: String(localized: "Bamboo grove"),
              skyTop: rgb(0.90, 0.97, 0.90), skyBottom: rgb(0.80, 0.92, 0.78),
              hillBack: rgb(0.62, 0.80, 0.55), hillFront: rgb(0.45, 0.68, 0.42),
              water: rgb(0.55, 0.80, 0.78), pad: .stone,
              padLight: rgb(0.78, 0.76, 0.70), padDark: rgb(0.45, 0.62, 0.42), numberColor: .white,
              doneMark: "🍃", plants: ["🎋", "🍃", "🎍", "🐼"],
              particle: "🍃", particleSpeed: 0.8, skyIcon: "⛅️"),
        Biome(name: String(localized: "Jeju tangerine farm"),
              skyTop: rgb(0.85, 0.94, 1.0), skyBottom: rgb(1.0, 0.95, 0.82),
              hillBack: rgb(0.75, 0.85, 0.55), hillFront: rgb(0.60, 0.75, 0.40),
              water: rgb(0.40, 0.72, 0.90), pad: .stone,
              padLight: rgb(0.45, 0.45, 0.48), padDark: rgb(0.98, 0.60, 0.20), numberColor: .white,
              doneMark: "🍊", plants: ["🍊", "🌴", "🐴", "🌼"],
              particle: nil, particleSpeed: 1, skyIcon: "☀️"),
        Biome(name: String(localized: "Han river at night"),
              skyTop: rgb(0.10, 0.13, 0.30), skyBottom: rgb(0.18, 0.20, 0.40),
              hillBack: rgb(0.15, 0.17, 0.34), hillFront: rgb(0.11, 0.13, 0.27),
              water: rgb(0.22, 0.38, 0.64), pad: .stone,
              padLight: rgb(0.40, 0.45, 0.62), padDark: rgb(0.98, 0.80, 0.35), numberColor: .white,
              doneMark: "⭐️", plants: ["🏮", "🌉", "✨", "🏙️"],
              particle: "✨", particleSpeed: 0.25, skyIcon: "🌙", isDark: true),
        Biome(name: String(localized: "Mountain temple"),
              skyTop: rgb(0.93, 0.90, 0.97), skyBottom: rgb(0.90, 0.93, 0.92),
              hillBack: rgb(0.75, 0.75, 0.85), hillFront: rgb(0.62, 0.68, 0.75),
              water: rgb(0.62, 0.78, 0.88), pad: .stone,
              padLight: rgb(0.82, 0.80, 0.78), padDark: rgb(0.75, 0.45, 0.45), numberColor: .white,
              doneMark: "🏮", plants: ["🏯", "🌲", "🍵", "🔔"],
              particle: nil, particleSpeed: 1, skyIcon: "🌄"),
    ]

    static let springTop = rgb(1.0, 0.86, 0.72)
    static let springBottom = rgb(0.98, 0.70, 0.56)
    static let rock = rgb(0.72, 0.64, 0.57)
}

private func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color {
    Color(red: r, green: g, blue: b)
}

extension CourseUnit {
    var biome: Biome { Biome.all[id % Biome.all.count] }
}

struct BiomeBackground: View {
    let biome: Biome

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [biome.skyTop, biome.skyBottom], startPoint: .top, endPoint: .bottom)
            Hills(phase: 0.6, waves: 1.3)
                .fill(biome.hillBack)
                .frame(height: 150)
                .offset(y: -34)
            Hills(phase: 2.2, waves: 1.8)
                .fill(biome.hillFront)
                .frame(height: 120)
            if let particle = biome.particle {
                FallingParticles(symbol: particle, speed: biome.particleSpeed)
            }
        }
    }
}

struct Hills: Shape {
    var phase: Double
    var waves: Double

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        let steps = 48
        for s in 0...steps {
            let f = Double(s) / Double(steps)
            let x = rect.minX + rect.width * f
            let y = rect.minY + rect.height * (0.45 + 0.3 * sin(f * .pi * 2 * waves + phase))
            p.addLine(to: CGPoint(x: x, y: y))
        }
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct FallingParticles: View {
    let symbol: String
    var speed: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let glyph = context.resolve(Text(verbatim: symbol).font(.system(size: 15)))
                context.opacity = 0.75
                let height = size.height + 40
                for k in 0..<12 {
                    let seed = Double(k) * 97.3
                    let fall = (18 + Double(k % 4) * 7) * speed
                    let y = (t * fall + seed * 13).truncatingRemainder(dividingBy: height) - 20
                    let x = (seed * 7.1).truncatingRemainder(dividingBy: max(size.width, 1)) + sin(t * 0.8 + seed) * 16
                    context.draw(glyph, at: CGPoint(x: x, y: y))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct LilyPad: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var p = Path()
        p.move(to: center)
        p.addArc(center: center, radius: radius,
                 startAngle: .degrees(-75), endAngle: .degrees(255), clockwise: false)
        p.closeSubpath()
        return p
    }
}
