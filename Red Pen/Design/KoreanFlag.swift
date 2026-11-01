//
//  KoreanFlag.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/31/26.
//

import SwiftUI

struct KoreanFlag: View {
    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let center = CGPoint(x: w / 2, y: h / 2)
            let r = h / 4
            let tilt = atan2(h, w)

            // White field
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))

            // Taegeuk (red over blue, tilted along the diagonal)
            var t = ctx
            t.translateBy(x: center.x, y: center.y)
            t.rotate(by: .radians(tilt))
            let circle = Path(ellipseIn: CGRect(x: -r, y: -r, width: 2 * r, height: 2 * r))
            t.fill(circle, with: .color(.taegeukBlue))
            t.drawLayer { layer in
                layer.clip(to: circle)
                layer.fill(Path(CGRect(x: -r, y: -r, width: 2 * r, height: r)),
                           with: .color(.taegeukRed))
            }
            t.fill(Path(ellipseIn: CGRect(x: -r, y: -r / 2, width: r, height: r)),
                   with: .color(.taegeukRed))
            t.fill(Path(ellipseIn: CGRect(x: 0, y: -r / 2, width: r, height: r)),
                   with: .color(.taegeukBlue))

            // Trigrams: direction + which bars are solid
            let trigrams: [(angle: Double, solid: [Bool])] = [
                (tilt + .pi, [true, true, true]),       // 건 upper-left
                (-tilt, [false, true, false]),          // 감 upper-right
                (tilt, [false, false, false]),          // 곤 lower-right
                (.pi - tilt, [true, false, true]),      // 이 lower-left
            ]

            let barW = h / 24
            let gap = h / 48
            let length = h / 4
            let distance = 11 * h / 24

            for trigram in trigrams {
                var g = ctx
                g.translateBy(x: center.x, y: center.y)
                g.rotate(by: .radians(trigram.angle))

                for (i, isSolid) in trigram.solid.enumerated() {
                    let x = distance + CGFloat(i - 1) * (barW + gap) - barW / 2
                    if isSolid {
                        g.fill(Path(CGRect(x: x, y: -length / 2, width: barW, height: length)),
                               with: .color(.black))
                    } else {
                        let half = (length - gap) / 2
                        g.fill(Path(CGRect(x: x, y: -length / 2, width: barW, height: half)),
                               with: .color(.black))
                        g.fill(Path(CGRect(x: x, y: gap / 2, width: barW, height: half)),
                               with: .color(.black))
                    }
                }
            }
        }
        .aspectRatio(3 / 2, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 3))
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(.black.opacity(0.15), lineWidth: 0.5))
    }
}

#Preview {
    KoreanFlag()
        .frame(width: 240)
        .padding()
}
