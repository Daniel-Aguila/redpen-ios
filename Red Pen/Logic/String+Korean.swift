//
//  String+Korean.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var withoutSpaces: String {
        filter {!$0.isWhitespace}
    }
    
    var withoutTrailingPunctuation: String {
        var s = self
        while let last = s.last, last.isPunctuation || last == "~" {
            s.removeLast()
        }
        return s
    }
}

extension Character {
    var isHangulSyllable: Bool {
        guard let v = unicodeScalars.first?.value else {return false}
        return (0xAC00...0xD7A3).contains(v)
    }
    
    var hasBatchim: Bool {
        guard isHangulSyllable, let v = unicodeScalars.first?.value else {return false}
        return (v - 0xAC00) % 28 != 0
    }
}
