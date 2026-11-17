//
//  GochiForm.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/16/26.
//

import Foundation

enum GochiForm: Int, CaseIterable {
    case bean = 1, sprout, baby, kinder, young, student,
         adult, teacher, scholar, sage, king, dragon
    
    var minXP: Int {
        switch self {
        case .bean: 0
        case .sprout: 5
        case .baby: 15
        case .kinder: 40
        case .young: 80
        case .student: 150
        case .adult: 250
        case .teacher: 400
        case .scholar: 600
        case .sage: 900
        case .king: 1300
        case .dragon: 1800
        }
    }
    
    var assetName: String { "Gochi/\(rawValue)-\(self)" }
    
    var next: GochiForm? { GochiForm(rawValue: rawValue + 1) }

    static func forXP(_ xp: Int) -> GochiForm {
        allCases.last { xp >= $0.minXP } ?? .bean
    }
}
