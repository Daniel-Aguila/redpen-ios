//
//  Folder.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/4/26.
//

import Foundation
import SwiftData

@Model
final class Folder {
    var name: String = ""
    var emoji: String = "📁"
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Correction.folder)
    var corrections: [Correction]? = []

    init(name: String, emoji: String = "📁") {
        self.name = name
        self.emoji = emoji
    }
}
