//
//  GochiForm.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/16/26.
//

import Foundation
import SwiftUI

enum GochiMood {
    case happy, awake, sleepy
}

enum GochiForm: Int, CaseIterable, Identifiable {
    case bean = 1, sprout, baby, kinder, young, student,
         adult, teacher, scholar, sage, king, dragon
    
    var id: Int { rawValue }
    
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
    
    var center: UnitPoint {
        switch self {
        case .bean: UnitPoint(x: 0.5, y: 0.78)
        case .sprout: UnitPoint(x: 0.5, y: 0.66)
        case .baby: UnitPoint(x: 0.5, y: 0.60)
        case .kinder: UnitPoint(x: 0.5, y: 0.59)
        case .young: UnitPoint(x: 0.5, y: 0.57)
        case .student: UnitPoint(x: 0.5, y: 0.56)
        default: UnitPoint(x: 0.5, y: 0.55)
        }
    }
    
    var title: String {
        switch self {
        case .bean: "콩알"
        case .sprout: "새싹"
        case .baby: "아기"
        case .kinder: "유치원생"
        case .young: "어린이"
        case .student: "학생"
        case .adult: "어른"
        case .teacher: "선생님"
        case .scholar: "선비"
        case .sage: "도사"
        case .king: "왕"
        case .dragon: "용"
        }
    }
    
    var assetName: String { "Gochi/\(rawValue)-\(self)" }
    
    var next: GochiForm? { GochiForm(rawValue: rawValue + 1) }

    static func forXP(_ xp: Int) -> GochiForm {
        allCases.last { xp >= $0.minXP } ?? .bean
    }
}
