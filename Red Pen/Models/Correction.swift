//
//  Correction.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import Foundation
import SwiftData
import SwiftUI

enum MistakeType: String, Codable, CaseIterable {
    case particle, speechLevel, tense, spelling, spacing, wordChoice, other

    var label: String {
        switch self {
        case .particle: String(localized: "Particle")
        case .speechLevel: String(localized: "Speech level")
        case .spelling: String(localized: "Spelling")
        case .spacing: String(localized: "Spacing")
        case .wordChoice: String(localized: "Word choice")
        case .other: String(localized: "Other")
        case .tense: String(localized: "Tense")
        }
    }

    var symbol: String {
        switch self {
        case .particle: "link"
        case .speechLevel: "person.2"
        case .spelling: "textformat.abc"
        case .spacing: "space"
        case .wordChoice: "character.book.closed"
        case .other: "questionmark.circle"
        case .tense: "clock.arrow.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .particle: Color(hex: 0x3B82C4)     // 하늘 sky blue
        case .speechLevel: Color(hex: 0x9B59B6)  // 보라 purple
        case .spacing: Color(hex: 0xF2A93B)      // 노랑 amber
        case .spelling: Color(hex: 0xE5677D)     // 분홍 pink
        case .wordChoice: Color(hex: 0x4CAF7A)   // 연두 green
        case .other: Color(hex: 0x8E8A84)        // warm stone
        case .tense: Color(hex: 0x2BB3A3)        // in color, 청록 teal
        }
    }
}

@Model
final class Correction {
    var original: String = ""
    var corrected: String = ""
    var note: String = ""
    var language: String = "ko"
    var typeRaw: String = MistakeType.other.rawValue
    var isTypeManual: Bool = false
    var createdAt: Date = Date.now
    
    //scheduling
    var dueDate: Date = Date.now
    var intervalDays: Int = 0
    var ease: Double = 2.5
    var type: MistakeType {
        get { MistakeType(rawValue: typeRaw) ?? .other}
        set { typeRaw = newValue.rawValue}
    }
    
    //init
    init(original: String, corrected: String, note: String = ""){
        self.original = original
        self.corrected = corrected
        self.note = note
    }
}
