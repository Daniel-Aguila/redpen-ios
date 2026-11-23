//
//  Lesson.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import Foundation

struct Course: Codable {
    let units: [CourseUnit]
}

struct CourseUnit: Codable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let lessons: [Lesson]

    var isFree: Bool { id <= 2 }
}

struct Lesson: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let steps: [Step]
}

struct Step: Codable, Hashable {
    enum Kind: String, Codable {
        case say, example, choice, build
    }

    let kind: Kind
    var text: String?
    var ko: String?
    var translation: String?
    var options: [String]?
    var answer: Int?
    var words: [String]?
    var why: String?
}

@Observable
final class CourseStore {
    static let shared = CourseStore()

    let course: Course
    private(set) var done: Set<String>

    private init() {
        let lang = Bundle.main.preferredLocalizations.first ?? "en"
        if let url = Bundle.main.url(forResource: "course.\(lang)", withExtension: "json")
            ?? Bundle.main.url(forResource: "course", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(Course.self, from: data) {
            course = decoded
        } else {
            course = Course(units: [])
        }
        done = Set(UserDefaults.standard.stringArray(forKey: "lessonsDone") ?? [])
    }

    func markDone(_ lesson: Lesson) {
        done.insert(lesson.id)
        UserDefaults.standard.set(Array(done), forKey: "lessonsDone")
    }

    func isDone(_ lesson: Lesson) -> Bool {
        done.contains(lesson.id)
    }
}
