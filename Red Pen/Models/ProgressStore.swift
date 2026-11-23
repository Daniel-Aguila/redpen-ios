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
    static let plusFreezesPerMonth = 2

    private let defaults: UserDefaults

    private(set) var xp: Int { didSet { defaults.set(xp, forKey: "xp") } }
    private(set) var streak: Int { didSet { defaults.set(streak, forKey: "streak") } }
    private(set) var lastPracticeDay: Double { didSet { defaults.set(lastPracticeDay, forKey: "lastPracticeDay") } }
    private(set) var todayCount: Int { didSet { defaults.set(todayCount, forKey: "todayCount") } }
    private(set) var todayCountDay: Double { didSet { defaults.set(todayCountDay, forKey: "todayCountDay") } }
    private(set) var freezesUsed: Int { didSet { defaults.set(freezesUsed, forKey: "freezesUsed") } }
    private(set) var freezeMonth: String { didSet { defaults.set(freezeMonth, forKey: "freezeMonth") } }

    var pendingEvolution: GochiForm? = nil

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        xp = defaults.integer(forKey: "xp")
        streak = defaults.integer(forKey: "streak")
        lastPracticeDay = defaults.double(forKey: "lastPracticeDay")
        todayCount = defaults.integer(forKey: "todayCount")
        todayCountDay = defaults.double(forKey: "todayCountDay")
        freezesUsed = defaults.integer(forKey: "freezesUsed")
        freezeMonth = defaults.string(forKey: "freezeMonth") ?? ""
    }

    var form: GochiForm { .forXP(xp) }

    var practicedToday: Bool {
        lastPracticeDay == Calendar.current.startOfDay(for: .now).timeIntervalSince1970
    }

    var missedDays: Int {
        guard lastPracticeDay > 0 else { return 0 }
        let calendar = Calendar.current
        let last = Date(timeIntervalSince1970: lastPracticeDay)
        let days = calendar.dateComponents([.day], from: last, to: calendar.startOfDay(for: .now)).day ?? 0
        return max(0, days - 1)
    }

    func freezesLeft(allowance: Int) -> Int {
        freezeMonth == Self.monthKey(.now) ? max(0, allowance - freezesUsed) : allowance
    }

    func streakIsAlive(freezeAllowance: Int) -> Bool {
        lastPracticeDay > 0 && missedDays <= freezesLeft(allowance: freezeAllowance)
    }

    func earn(_ amount: Int) {
        let before = form
        xp += amount
        if form != before { pendingEvolution = form }
    }

    func countAnswer() {
        let today = Calendar.current.startOfDay(for: .now).timeIntervalSince1970
        if todayCountDay != today {
            todayCount = 0
            todayCountDay = today
        }
        todayCount += 1
    }

    func recordPracticeDay(freezeAllowance: Int = 0) {
        let today = Calendar.current.startOfDay(for: .now)
        if practicedToday { return }

        let missed = missedDays
        if lastPracticeDay > 0 && missed == 0 {
            streak += 1
        } else if lastPracticeDay > 0 && missed <= freezesLeft(allowance: freezeAllowance) {
            let month = Self.monthKey(.now)
            if freezeMonth != month {
                freezeMonth = month
                freezesUsed = 0
            }
            freezesUsed += missed
            streak += 1
        } else {
            streak = 1
        }
        lastPracticeDay = today.timeIntervalSince1970
    }

    private static func monthKey(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)"
    }
}
