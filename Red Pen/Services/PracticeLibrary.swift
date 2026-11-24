//
//  PracticeLibrary.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import Foundation
import SwiftUI
import Observation

struct SavedPractice: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    let mistakeKeys: [String]
    var practice: GochiAI.Practice
    var lang: String?
}

extension GochiAI.MistakeInput {
    var key: String { original + "|" + corrected }
}

@MainActor
@Observable
final class PracticeLibrary {
    static let shared = PracticeLibrary()

    private(set) var items: [SavedPractice] = []
    private let url = URL.documentsDirectory.appending(path: "gochi-practice.json")
    private let maxItems = 30

    init() {
        load()
    }

    func add(_ practice: GochiAI.Practice, keys: [String]) {
        items.insert(SavedPractice(mistakeKeys: keys, practice: practice, lang: GochiAI.languageCode), at: 0)
        if items.count > maxItems {
            items.removeLast(items.count - maxItems)
        }
        save()
    }

    func retranslate(_ item: SavedPractice) async throws {
        let fresh = try await GochiAI.translate(item.practice)
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[i].practice = fresh
        items[i].lang = GochiAI.languageCode
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }
    
    func delete(_ item: SavedPractice) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func similarRecent(to keys: [String], threshold: Double = 0.75) -> SavedPractice? {
        guard let last = items.first else { return nil }
        return Self.similarity(last.mistakeKeys, keys) >= threshold ? last : nil
    }

    static func similarity(_ a: [String], _ b: [String]) -> Double {
        let sa = Set(a), sb = Set(b)
        let union = sa.union(sb).count
        return union == 0 ? 0 : Double(sa.intersection(sb).count) / Double(union)
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([SavedPractice].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
