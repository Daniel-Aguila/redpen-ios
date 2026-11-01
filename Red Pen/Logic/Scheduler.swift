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
}
