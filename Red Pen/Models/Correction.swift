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
    case particle, speechLevel, honorific, tense, spelling, spacing, wordChoice, other

    var label: String {
        switch self {
        case .particle: String(localized: "Particle")
        case .speechLevel: String(localized: "Speech level")
        case .spelling: String(localized: "Spelling")
        case .spacing: String(localized: "Spacing")
        case .wordChoice: String(localized: "Word choice")
        case .other: String(localized: "Other")
        case .tense: String(localized: "Tense")
        case .honorific: String(localized: "Honorific")
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
        case .honorific: "hands.sparkles"
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
        case .honorific: Color(hex: 0xC2185B)    //(진분홍, deep rose)
        }
    }
}

enum CorrectionSource: String, Codable, CaseIterable {
    case manual, share, lesson, story, diary, ai
}

enum Audience: String, Codable, CaseIterable {
    case unknown, friend, younger, family, partner, coworker, boss, teacher, elder, stranger

    var label: String {
        switch self {
        case .unknown: String(localized: "Not sure")
        case .friend: String(localized: "Friend")
        case .younger: String(localized: "Someone younger")
        case .family: String(localized: "Family")
        case .partner: String(localized: "Partner")
        case .coworker: String(localized: "Coworker")
        case .boss: String(localized: "Boss")
        case .teacher: String(localized: "Teacher")
        case .elder: String(localized: "Elder")
        case .stranger: String(localized: "Stranger")
        }
    }

    var symbol: String {
        switch self {
        case .unknown: "questionmark"
        case .friend: "person.2"
        case .younger: "figure.and.child.holdinghands"
        case .family: "house"
        case .partner: "heart"
        case .coworker: "person.3"
        case .boss: "briefcase"
        case .teacher: "graduationcap"
        case .elder: "figure.walk"
        case .stranger: "person.fill.questionmark"
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
    var folder: Folder?
    var sourceRaw: String = CorrectionSource.manual.rawValue
    var audienceRaw: String = Audience.unknown.rawValue
    var explanationJSON: String = ""
    var explanationKey: String = ""
    
    //scheduling
    var dueDate: Date = Date.now
    var intervalDays: Int = 0
    var ease: Double = 2.5
    var type: MistakeType {
        get { MistakeType(rawValue: typeRaw) ?? .other}
        set { typeRaw = newValue.rawValue}
    }
    
    var source: CorrectionSource {
        get { CorrectionSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    var audience: Audience {
        get { Audience(rawValue: audienceRaw) ?? .unknown }
        set { audienceRaw = newValue.rawValue }
    }
    
    //init
    init(original: String, corrected: String, note: String = ""){
        self.original = original
        self.corrected = corrected
        self.note = note
    }
}

extension Correction {
    var isLearned: Bool { intervalDays >= 7 }
}

extension Correction {
    var aiInput: GochiAI.MistakeInput {
        GochiAI.MistakeInput(
            original: original,
            corrected: corrected,
            type: type.rawValue,
            talkingTo: audience == .unknown ? nil : audience.rawValue,
            note: note.isEmpty ? nil : note
        )
    }

    private var currentExplanationKey: String {
        [original, corrected, audienceRaw, note, GochiAI.languageCode].joined(separator: "|")
    }

    var savedExplanation: GochiAI.Explanation? {
        get {
            guard explanationKey == currentExplanationKey,
                  let data = explanationJSON.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode(GochiAI.Explanation.self, from: data)
        }
        set {
            guard let newValue,
                  let data = try? JSONEncoder().encode(newValue),
                  let json = String(data: data, encoding: .utf8) else {
                explanationJSON = ""
                explanationKey = ""
                return
            }
            explanationJSON = json
            explanationKey = currentExplanationKey
        }
    }
}
