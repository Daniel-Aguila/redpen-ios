//
//  MistakeDetector.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import Foundation

enum SpeechLevel {
    case formal, polite, casual

    var label: String {
        switch self {
        case .formal: String(localized: "Formal (합쇼체)")
        case .polite: String(localized: "Polite (해요체)")
        case .casual: String(localized: "Casual (반말)")
        }
    }
}

enum Tense {
    case past, present, future
    
    var label: String {
        switch self {
        case .past: String(localized: "Past (과거)")
        case .present: String(localized: "Present (현재)")
        case .future: String(localized: "Future (미래)")
        }
    }
}

enum MistakeDetector {
    static let particles = ["에서", "에게", "한테", "으로",
                            "은", "는", "이", "가", "을", "를",
                            "와", "과", "로", "의", "에", "도", "만"]
    
    static let batchimPairs: [(batchim: String, noBatchim: String)] = [
         ("은", "는"), ("이", "가"), ("을", "를"), ("과", "와"), ("으로", "로")
     ]
    
    static func detect(original: String, corrected: String) -> MistakeType {
        let a = original.trimmed
        let b = corrected.trimmed

        if a != b && a.withoutSpaces == b.withoutSpaces {
            return .spacing
        }
        if !particleChanges(original: a, corrected: b).isEmpty {
            return .particle
        }
        if let levelA = speechLevel(of: a),
           let levelB = speechLevel(of: b),
           levelA != levelB {
            return .speechLevel
        }
        if let tenseA = tense(of: a),
           let tenseB = tense(of: b),
           tenseA != tenseB {
            return .tense
        }
        return .other
    }
    
    static func tense(of sentence: String) -> Tense? {
        let words = sentence.trimmed.withoutTrailingPunctuation
            .split(separator: " ").map(String.init)
        guard let last = words.last, last.last?.isHangulSyllable == true else {return nil}
        let chars = Array(last)
        
        // Future: ~ㄹ 거예요 / 겁니다 / 거야
        if words.count >= 2,
           last.hasPrefix("거") || last.hasPrefix("겁"),
           words[words.count - 2].last?.jongseong == 8 {
            return .future
        }
        
        // Future: ~겠어요
        if last.contains("겠") {return .future}
        
        // Future: ~ㄹ게요
        for i in 1..<chars.count where chars[i] == "게" && chars[i - 1].jongseong == 8 {
            return .future
        }
        
        // Past: ㅆ 받침 (갔, 했, 먹었), except 있 / 밌 ------ 20 is ㅆ
        if chars.contains(where: { $0.jongseong == 20 && $0 != "있" && $0 != "밌" }) {
            return .past
        }
        return .present
    }
    
    static func particleChanges(original: String, corrected: String) -> [(stem: String, from: String, to: String)]{
        let wordsA = original.split(separator: " ")
        let wordsB = corrected.split(separator: " ")
        
        guard wordsA.count == wordsB.count else {return []}
        
        var changes: [(stem: String, from: String, to: String)] = []
        for (wa, wb) in zip(wordsA, wordsB) where wa != wb {
            guard let change = particleSwap(String(wa), String(wb)) else {return []}
            changes.append(change)
        }
        return changes
    }
    
    private static func particleSwap(_ a: String, _ b: String) -> (stem: String, from: String, to: String)? {
        for p1 in particles where a.hasSuffix(p1) {
            let stem = a.dropLast(p1.count)
            for p2 in particles where p2 != p1 && b.hasSuffix(p2) {
                if b.dropLast(p2.count) == stem {
                    return (String(stem), p1, p2)
                }
            }
        }
        return nil
    }
    
    static func explanation(stem: String, particle: String) -> String? {
        guard let last = stem.last else{return nil}
        for pair in batchimPairs where pair.batchim == particle || pair.noBatchim == particle {
            if last.hasBatchim {
                return String(localized: "\(String(last)) ends in a consonant (받침), so use \(pair.batchim)")   // CHANGED
            } else {
                return String(localized: "\(String(last)) ends in a vowel, so use \(pair.noBatchim)")   // CHANGED
            }
        }
        return nil
    }
    
    static func speechLevel(of sentence: String) -> SpeechLevel? {
        let s = sentence.trimmed.withoutTrailingPunctuation
        guard let last = s.last, last.isHangulSyllable else { return nil }

        if s.hasSuffix("니다") || s.hasSuffix("니까") { return .formal }
        if s.hasSuffix("요") || s.hasSuffix("죠") { return .polite }
        return .casual
    }
}
