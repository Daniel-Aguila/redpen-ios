//
//  AnswerChecker.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/4/26.
//

import Foundation

enum AnswerResult {
    case correct
    case almost
    case wrong
}

enum AnswerChecker {
    static func check(_ typed: String, against answer: String, spacingMatters: Bool) -> AnswerResult{
        let t = normalize(typed)
        let a = normalize(answer)
        
        if t == a { return .correct}
        if t.withoutSpaces == a.withoutSpaces {
            return spacingMatters ? .wrong : .almost
        }
        return .wrong
    }
    
    private static func normalize(_ s: String) -> String {
        s.precomposedStringWithCanonicalMapping
            .trimmed
            .withoutTrailingPunctuation
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
