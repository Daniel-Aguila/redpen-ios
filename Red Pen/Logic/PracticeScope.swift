//
//  PracticeScope.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/4/26.
//

import Foundation

enum PracticeScope: Hashable {
    case all
    case folder(Folder)
    case type(MistakeType)
}
