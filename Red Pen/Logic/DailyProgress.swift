//
//  DailyProgress.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/31/26.
//

import Foundation

enum DailyProgress {
    static func currentStreak(streak: Int, lastPracticeDay: Double) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let last = Date(timeIntervalSince1970: lastPracticeDay)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }

        if calendar.isDate(last, inSameDayAs: today) || calendar.isDate(last, inSameDayAs: yesterday) {
            return streak
        }
        return 0
    }

    static func answeredToday(count: Int, day: Double) -> Int {
        let today = Calendar.current.startOfDay(for: .now).timeIntervalSince1970
        return day == today ? count : 0
    }
}
