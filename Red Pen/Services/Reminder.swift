//
//  Reminder.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/30/26.
//

import UserNotifications

enum Reminder {
    private static let legacyID = "daily-practice"
    private static let ids = (0..<7).map { "reminder-\($0)" }

    private static var messages: [String] {
        [
            String(localized: "고치가 배고파요 🍊 Practice a few mistakes?"),
            String(localized: "고치가 기다리고 있어요 Keep your streak going!"),
            String(localized: "오늘 연습했어요? Gochi misses you."),
        ]
    }

    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func refresh(enabled: Bool, minutesAfterMidnight: Int, practicedToday: Bool) {
        cancel()
        guard enabled else { return }

        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        for offset in 0..<7 {
            if offset == 0 && practicedToday { continue }
            guard let day = calendar.date(byAdding: .day, value: offset, to: .now),
                  let fire = calendar.date(bySettingHour: minutesAfterMidnight / 60,
                                           minute: minutesAfterMidnight % 60,
                                           second: 0, of: day),
                  fire > .now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Gochim"
            content.body = messages[offset % messages.count]
            content.sound = .default

            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            center.add(UNNotificationRequest(identifier: ids[offset], content: content, trigger: trigger))
        }
    }

    static func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ids + [legacyID])
    }
}
