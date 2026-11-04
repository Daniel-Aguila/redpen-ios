//
//  ExerciseGenerator.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/29/26.
//

import Foundation

enum ExerciseGenerator {
    static func make(from correction: Correction) -> Exercise {
        if correction.type == .particle, Bool.random(), let gap = particleGap(correction) {
            return gap
        }
        return Exercise(correction: correction, kind: .typeFix, prompt: correction.original, choices: [], answer: correction.corrected)
    }
    
    private static func particleGap(_ correction: Correction) -> Exercise? {
        let changes = MistakeDetector.particleChanges(original: correction.original, corrected: correction.corrected)
        
        guard let change = changes.first else {return nil}
        
        let correctWord = change.stem + change.to
        let blankWord = change.stem + "___"
        let prompt = correction.corrected.replacingOccurrences(of: correctWord, with: blankWord)
        
        var options: Set<String> = [change.to, change.from]
        let pool = ["은", "는", "이", "가", "을", "를", "에", "도"]
        
        for p in pool.shuffled() where options.count < 4 {
            options.insert(p)
        }
        
        return Exercise(correction: correction,
                        kind: .fillGap,
                        prompt: prompt,
                        choices: options.shuffled(),
                        answer: change.to)
    }
}
