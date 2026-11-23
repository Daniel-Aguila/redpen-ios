//
//  ShareInbox.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/22/26.
//

import Foundation

struct SharedCorrection: Codable {
    var original: String
    var corrected: String
    var date: Date
}

enum ShareInbox {
    static let groupID = "group.com.danielaguila.redpen"
    private static let key = "shareInbox"
    
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: groupID)
    }
    
    static func add(_ item: SharedCorrection){
        var items = pending()
        items.append(item)
        if let data = try? JSONEncoder().encode(items) {
            defaults?.set(data, forKey: key)
        }
    }
    
    static func pending() -> [SharedCorrection] {
        guard let data = defaults?.data(forKey: key),
              let items = try? JSONDecoder().decode([SharedCorrection].self, from: data) else { return [] }
        return items
    }
    
    static func takeAll() -> [SharedCorrection] {
        let items = pending()
        defaults?.removeObject(forKey: key)
        return items
    }
}
