//
//  Scheduler.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/29/26.
//

import Foundation

enum Rating {
    case again, good, easy
}

enum Scheduler {
    static func apply(_ rating: Rating, to c: Correction) {
        switch rating {
        case .again:
            c.intervalDays = 0
            c.ease = max(1.3, c.ease - 0.2)
        case .good:
            c.intervalDays = c.intervalDays == 0 ? 1 : Int(Double(c.intervalDays) * c.ease)
        case .easy:
            c.intervalDays = c.intervalDays == 0 ? 3 : Int(Double(c.intervalDays) * c.ease * 1.3)
            c.ease += 0.15
        }
        c.dueDate = Calendar.current.date(byAdding: .day, value: c.intervalDays, to: .now) ?? .now
    }
    
    static func isMastered(_ c: Correction) -> Bool {
        c.isLearned || c.intervalDays >= 7
    }
    
    static func order(_ due: [Correction], all: [Correction], smart: Bool) -> [Correction] {
        guard smart else { return due.sorted {$0.dueDate < $1.dueDate }}
        var weakness: [MistakeType: Double] = [:]
        
        for type in MistakeType.allCases {
            let ofType = all.filter { $0.type == type }
            guard !ofType.isEmpty else { continue }
            
            let mastered = Double(ofType.filter(isMastered).count) / Double(ofType.count)
            let avgEase = ofType.map(\.ease).reduce(0,+) / Double(ofType.count)
            weakness[type] = (1-mastered) + max(0,2.5-avgEase)
        }
        
        func score(_ c: Correction) -> Double {
            (weakness[c.type] ?? 0) + max(0, 2.5 - c.ease) + (c.intervalDays == 0 ? 0.5 : 0)
        }

        return due.sorted {
            let a = score($0), b = score($1)
            return a == b ? $0.dueDate < $1.dueDate : a > b
        }
    }
}
