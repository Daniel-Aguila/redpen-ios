//
//  SampleData.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/3/26.
//

import Foundation
import SwiftData

enum SampleData {
    static let pairs: [(original: String, corrected: String, note: String)] = [
        ("저는 학생가 아니에요", "저는 학생이 아니에요", ""),
        ("밥 먹었어", "밥 먹었어요", "We just met, so 해요체"),
        ("할수있어요", "할 수 있어요", "수 is always spaced"),
    ]

    static func insert(into context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Correction>())) ?? 0
        guard count == 0 else { return }
        for pair in pairs {
            let c = Correction(original: pair.original, corrected: pair.corrected, note: pair.note)
            c.type = MistakeDetector.detect(original: pair.original, corrected: pair.corrected)
            context.insert(c)
        }
    }
}
