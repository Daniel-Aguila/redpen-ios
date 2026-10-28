//
//  Item.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
