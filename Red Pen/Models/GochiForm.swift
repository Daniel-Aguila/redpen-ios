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
        case .sprout: 50
        case .baby: 150
        case .kinder: 400
        case .young: 800
        case .student: 1500
        case .adult: 2500
        case .teacher: 4000
        case .scholar: 6000
        case .sage: 9000
        case .king: 13000
        case .dragon: 18000
        }
    }
    
    var assetName: String { "Gochi/\(rawValue)-\(self)" }
    
    var next: GochiForm? { GochiForm(rawValue: rawValue + 1) }

    static func forXP(_ xp: Int) -> GochiForm {
        allCases.last { xp >= $0.minXP } ?? .bean
    }
}
