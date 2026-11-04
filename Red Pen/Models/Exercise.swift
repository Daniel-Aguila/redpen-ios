//
//  Exercise.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/29/26.
//

import Foundation

enum ExerciseKind {
    case fillGap, flashcard, typeFix
}

struct Exercise: Identifiable {
    let id = UUID()
    let correction: Correction
    let kind: ExerciseKind
    let prompt: String
    let choices: [String]
    let answer: String
}

