//
//  ProgressStore.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/17/26.
//

import Foundation
import Observation

@Observable
final class ProgressStore {
    private let defaults: UserDefaults

    private(set) var xp: Int { didSet { defaults.set(xp, forKey: "xp") } }
    private(set) var streak: Int { didSet { defaults.set(streak, forKey: "streak") } }
    private(set) var lastPracticeDay: Double { didSet { defaults.set(lastPracticeDay, forKey: "lastPracticeDay") } }
    private(set) var todayCount: Int { didSet { defaults.set(todayCount, forKey: "todayCount") } }
    private(set) var todayCountDay: Double { didSet { defaults.set(todayCountDay, forKey: "todayCountDay") } }
    private(set) var tangerines: Int { didSet { defaults.set(tangerines, forKey: "tangerines") } }

    var pendingEvolution: GochiForm? = nil

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        xp = defaults.integer(forKey: "xp")
        streak = defaults.integer(forKey: "streak")
        lastPracticeDay = defaults.double(forKey: "lastPracticeDay")
        todayCount = defaults.integer(forKey: "todayCount")
        todayCountDay = defaults.double(forKey: "todayCountDay")
        tangerines = defaults.integer(forKey: "tangerines")
    }

    var form: GochiForm { .forXP(xp) }
    var practicedToday: Bool {
        lastPracticeDay == Calendar.current.startOfDay(for: .now).timeIntervalSince1970
    }
    func earn(_ amount: Int) {
        let before = form
        xp += amount
        if form != before { pendingEvolution = form }
    }
    
    func addTangerines(_ amount: Int){
        tangerines += amount
    }

    func countAnswer() {
        let today = Calendar.current.startOfDay(for: .now).timeIntervalSince1970
        if todayCountDay != today {
            todayCount = 0
            todayCountDay = today
        }
        todayCount += 1
    }

    func recordPracticeDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let last = Date(timeIntervalSince1970: lastPracticeDay)

        if calendar.isDate(last, inSameDayAs: today) { return }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            streak += 1
        } else {
            streak = 1
        }
        lastPracticeDay = today.timeIntervalSince1970
    }
}
