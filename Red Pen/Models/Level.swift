//
//  Level.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/31/26.
//

import Foundation

enum Level: Int, CaseIterable {
    case sprout = 1, student, senior, assistant, teacher

    var title: String {
        switch self {
        case .sprout: "새싹"
        case .student: "학생"
        case .senior: "선배"
        case .assistant: "조교"
        case .teacher: "선생님"
        }
    }

    var emoji: String {
        switch self {
        case .sprout: "🌱"
        case .student: "📚"
        case .senior: "🎒"
        case .assistant: "📝"
        case .teacher: "🖍️"
        }
    }

    var minXP: Int {
        switch self {
        case .sprout: 0
        case .student: 100
        case .senior: 300
        case .assistant: 700
        case .teacher: 1500
        }
    }

    var next: Level? { Level(rawValue: rawValue + 1) }

    static func forXP(_ xp: Int) -> Level {
        allCases.last { xp >= $0.minXP } ?? .sprout
    }
}
