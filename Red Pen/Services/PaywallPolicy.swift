//
//  PaywallPolicy.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/20/26.
//

import Foundation

enum PaywallPolicy {
    static let minDaysBetween = 7.0
    static let maxDismissals = 3

    private static let lastShownKey = "paywallLastShown"
    private static let dismissalsKey = "paywallDismissals"

    static func canAutoShow(tier: ProStore.Tier,
                            now: Date = .now,
                            defaults: UserDefaults = .standard) -> Bool {
        guard tier == .free else { return false }
        guard defaults.integer(forKey: dismissalsKey) < maxDismissals else { return false }

        let last = defaults.double(forKey: lastShownKey)
        guard last > 0 else { return true }
        let daysSince = (now.timeIntervalSince1970 - last) / 86_400
        return daysSince >= minDaysBetween
    }

    static func recordShown(now: Date = .now, defaults: UserDefaults = .standard) {
        defaults.set(now.timeIntervalSince1970, forKey: lastShownKey)
    }

    static func recordClosed(tier: ProStore.Tier, defaults: UserDefaults = .standard) {
        guard tier == .free else { return }
        defaults.set(defaults.integer(forKey: dismissalsKey) + 1, forKey: dismissalsKey)
    }

    static func reset(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: lastShownKey)
        defaults.removeObject(forKey: dismissalsKey)
    }
}
