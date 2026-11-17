//
//  GochiView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/16/26.
//

import SwiftUI

struct GochiView: View {
    let xp: Int
    var celebrate: Int = 0

    private var form: GochiForm { .forXP(xp) }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image(form.assetName)
            .resizable()
            .scaledToFit()
            .keyframeAnimator(initialValue: Flip(), trigger: reduceMotion ? 0 :celebrate) { view, f in
                view
                    .rotationEffect(.degrees(f.spin))
                    .scaleEffect(x: f.squash, y: 1 / f.squash, anchor: .bottom)
                    .offset(y: f.jump)
            } keyframes: { _ in
                KeyframeTrack(\.jump) {
                    CubicKeyframe(0, duration: 0.12)
                    CubicKeyframe(-60, duration: 0.25)
                    CubicKeyframe(-60, duration: 0.08)
                    CubicKeyframe(0, duration: 0.2)
                    SpringKeyframe(0, duration: 0.3)
                }
                KeyframeTrack(\.spin) {
                    CubicKeyframe(0, duration: 0.15)
                    CubicKeyframe(360, duration: 0.45)
                }
                KeyframeTrack(\.squash) {
                    CubicKeyframe(1.2, duration: 0.12)
                    CubicKeyframe(0.85, duration: 0.15)
                    CubicKeyframe(1.0, duration: 0.3)
                    CubicKeyframe(1.8, duration: 0.1)
                    SpringKeyframe(1.0, duration: 0.3)
                }
            }
                
    }
}

private struct Flip {
    var jump = 0.0
    var spin = 0.0
    var squash = 1.0
}

#Preview {
    @Previewable @State var taps = 0
    VStack(spacing: 20) {
        GochiView(xp: 900, celebrate: taps)
            .frame(height: 160)
        Button("Go") { taps += 1 }
    }
}
