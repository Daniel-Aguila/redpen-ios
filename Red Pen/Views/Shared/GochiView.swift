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
    var hop: Int = 0
    var wobble: Int = 0
    var mood: GochiMood = .awake

    private var form: GochiForm { .forXP(xp) }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let k = geo.size.height / 160

            Image(form.assetName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .keyframeAnimator(initialValue: Flip(), trigger: reduceMotion ? 0 : celebrate) { view, f in
                    view
                        .scaleEffect(x: f.squash, y: 1 / f.squash, anchor: .bottom)
                        .rotationEffect(.degrees(f.spin), anchor: form.center)
                        .offset(y: f.jump * k)
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
                        CubicKeyframe(1.3, duration: 0.1)
                        SpringKeyframe(1.0, duration: 0.3)
                    }
                }
                .keyframeAnimator(initialValue: Flip(), trigger: reduceMotion ? 0 : hop) { view, h in
                    view
                        .scaleEffect(x: h.squash, y: 1 / h.squash, anchor: .bottom)
                        .offset(y: h.jump * k)
                } keyframes: { _ in
                    KeyframeTrack(\.jump) {
                        CubicKeyframe(0, duration: 0.08)
                        CubicKeyframe(-25, duration: 0.15)
                        CubicKeyframe(0, duration: 0.15)
                        CubicKeyframe(-10, duration: 0.1)
                        CubicKeyframe(0, duration: 0.1)
                    }
                    KeyframeTrack(\.squash) {
                        CubicKeyframe(1.12, duration: 0.08)
                        CubicKeyframe(0.92, duration: 0.15)
                        CubicKeyframe(1.12, duration: 0.15)
                        SpringKeyframe(1.0, duration: 0.2)
                    }
                }
                .keyframeAnimator(initialValue: Flip(), trigger: reduceMotion ? 0 : wobble) { view, w in
                    view
                        .rotationEffect(.degrees(w.spin), anchor: .bottom)
                        .scaleEffect(w.squash, anchor: .bottom)
                } keyframes: { _ in
                    KeyframeTrack(\.spin) {
                        CubicKeyframe(-8, duration: 0.1)
                        CubicKeyframe(8, duration: 0.12)
                        CubicKeyframe(-5, duration: 0.12)
                        CubicKeyframe(3, duration: 0.1)
                        CubicKeyframe(0, duration: 0.1)
                    }
                    KeyframeTrack(\.squash) {
                        CubicKeyframe(0.94, duration: 0.15)
                        CubicKeyframe(0.94, duration: 0.25)
                        SpringKeyframe(1.0, duration: 0.2)
                    }
                }
                .phaseAnimator([false, true]) { view, inhale in
                    view.scaleEffect(reduceMotion ? 1 : (inhale ? 1.025 : 1), anchor: .bottom)
                } animation: { _ in
                    .easeInOut(duration: mood == .sleepy ? 2.4 : 1.6)
                }
                .saturation(mood == .sleepy ? 0.6 : 1)
                .overlay {
                    let artH = min(geo.size.height, geo.size.width * 212 / 220)
                    let artW = artH * 220 / 212
                    let x0 = (geo.size.width - artW) / 2
                    let y0 = (geo.size.height - artH) / 2

                    switch mood {
                    case .happy:
                        Text("🍊")
                            .font(.system(size: 34 * k))
                            .position(x: x0 + artW * 0.88, y: y0 + artH * 0.86)
                    case .sleepy:
                        Text("z")
                            .font(.system(size: 30 * k, weight: .heavy))
                            .foregroundStyle(.secondary)
                            .position(x: x0 + artW * 0.80, y: y0 + artH * (form.center.y - 0.32))
                    case .awake:
                        EmptyView()
                    }
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
    @Previewable @State var flips = 0
    @Previewable @State var hops = 0
    @Previewable @State var wobbles = 0
    @Previewable @State var mood: GochiMood = .awake
    VStack(spacing: 20) {
        GochiView(xp: 900, celebrate: flips, hop: hops, wobble: wobbles, mood: mood)
            .frame(height: 160)
        HStack {
            Button("Flip") { flips += 1 }
            Button("Hop") { hops += 1 }
            Button("Wobble") { wobbles += 1 }
        }
        .buttonStyle(.bordered)
        Picker("Mood", selection: $mood) {
            Text("Happy").tag(GochiMood.happy)
            Text("Awake").tag(GochiMood.awake)
            Text("Sleepy").tag(GochiMood.sleepy)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}
