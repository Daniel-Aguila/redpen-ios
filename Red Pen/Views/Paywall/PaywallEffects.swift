//
//  PaywallEffects.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/20/26.
//

import SwiftUI

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

struct StaggerIn: ViewModifier {
    let index: Int
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 6)
            .onAppear {
                if reduceMotion {
                    shown = true
                } else {
                    withAnimation(.easeOut(duration: 0.3).delay(Double(index) * 0.05)) {
                        shown = true
                    }
                }
            }
    }
}

struct ShineOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            if !reduceMotion {
                LinearGradient(colors: [.clear, .white.opacity(0.35), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .frame(width: geo.size.width * 0.35)
                    .keyframeAnimator(initialValue: -0.4, repeating: true) { content, x in
                        content.offset(x: x * geo.size.width)
                    } keyframes: { _ in
                        CubicKeyframe(1.1, duration: 1.2)
                        LinearKeyframe(1.1, duration: 1.8)
                    }
            }
        }
        .clipShape(.capsule)
        .allowsHitTesting(false)
    }
}

struct Sparkle: View {
    let color: Color
    let size: CGFloat
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(color)
            .keyframeAnimator(initialValue: 0.0, repeating: !reduceMotion) { content, t in
                content
                    .opacity(reduceMotion ? 0.8 : t)
                    .scaleEffect(reduceMotion ? 1 : 0.5 + 0.5 * t)
            } keyframes: { _ in
                LinearKeyframe(0, duration: delay)
                CubicKeyframe(1, duration: 0.6)
                CubicKeyframe(0, duration: 0.6)
                LinearKeyframe(0, duration: max(0.1, 1.2 - delay))
            }
            .accessibilityHidden(true)
    }
}
