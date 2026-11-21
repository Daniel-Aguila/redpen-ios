//
//  Wallet.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/21/26.
//

import Foundation
import Observation

enum Reward {
    static let correctDue = 3
    static let wrongDue = 1
    static let dailyGoal = 25
    static let lesson = 20
    static func streakBonus(_ streak: Int) -> Int { min(5*streak, 50)}
}

@MainActor
@Observable
final class Wallet {
    static let dailyCap = 150
    
    private let local: UserDefaults
    private let cloud = NSUbiquitousKeyValueStore.default
    
    private(set) var earned: Int
    private(set) var bought: Int
    private(set) var spent: Int
    private(set) var owned: Set<String>
    private(set) var earnedToday: Int
    private var earnedTodayDay: Double
    
    var balance: Int { earned + bought - spent }
    
    init(local: UserDefaults = .standard) {
        self.local = local
        earned = local.integer(forKey: Keys.earned)
        bought = local.integer(forKey: Keys.bought)
        spent = local.integer(forKey: Keys.spent)
        owned = Set(local.stringArray(forKey: Keys.owned) ?? [])
        earnedToday = local.integer(forKey: Keys.earnedToday)
        earnedTodayDay = local.double(forKey: Keys.earnedTodayDay)
            
        let legacy = local.integer(forKey: "tangerines")
        if legacy > 0 {
            bought += legacy
            local.removeObject(forKey: "tangerines")
        }
        
        NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: cloud, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.mergeFromCloud() }
        }
        
        cloud.synchronize()
        mergeFromCloud()
    }
    
    @discardableResult
    func earn(_ amount: Int) -> Int {
        rollDay()
        let allowed = max(0, min(amount, Self.dailyCap - earnedToday))
        guard allowed > 0 else { return 0 }
        earned += allowed
        earnedToday += allowed
        save()
        return allowed
    }
    
    func addPurchased(_ amount: Int) {
        bought += amount
        save()
    }
    
    func buy(_ itemID: String) -> Bool {
        owned.contains(itemID)
    }
    
    private func rollDay() {
        let today = Calendar.current.startOfDay(for: .now).timeIntervalSince1970
        if earnedTodayDay != today {
            earnedTodayDay = today
            earnedToday = 0
        }
    }
    
    private func save() {
        local.set(earned, forKey: Keys.earned)
        local.set(bought, forKey: Keys.bought)
        local.set(spent, forKey: Keys.spent)
        local.set(Array(owned), forKey: Keys.owned)
        local.set(earnedToday, forKey: Keys.earnedToday)
        local.set(earnedTodayDay, forKey: Keys.earnedTodayDay)

        cloud.set(Int64(earned), forKey: Keys.earned)
        cloud.set(Int64(bought), forKey: Keys.bought)
        cloud.set(Int64(spent), forKey: Keys.spent)
        cloud.set(Array(owned), forKey: Keys.owned)
    }
    
    private func mergeFromCloud() {
         earned = max(earned, Int(cloud.longLong(forKey: Keys.earned)))
         bought = max(bought, Int(cloud.longLong(forKey: Keys.bought)))
         spent = max(spent, Int(cloud.longLong(forKey: Keys.spent)))
         owned.formUnion(cloud.array(forKey: Keys.owned) as? [String] ?? [])
         save()
     }
    
    private enum Keys {
        static let earned = "wallet.earned"
        static let bought = "wallet.bought"
        static let spent = "wallet.spent"
        static let owned = "wallet.owned"
        static let earnedToday = "wallet.earnedToday"
        static let earnedTodayDay = "wallet.earnedTodayDay"
    }
}
