//
//  Reminder.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/30/26.
//

import UserNotifications

enum Reminder {
    static let id = "daily-practice"
    
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }
    
    static func schedule(minutesAfterMidnight: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to practice"
        content.body = "Your mistakes are waiting. 오늘도 화이팅!"
        content.sound = .default
        
        var time = DateComponents()
        time.hour = minutesAfterMidnight / 60
        time.minute = minutesAfterMidnight % 60
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.add(request)
    }
    
    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
