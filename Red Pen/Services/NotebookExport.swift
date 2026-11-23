//
//  NotebookExport.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/22/26.
//

import Foundation

enum NotebookExport {
    static func csvFile(_ corrections: [Correction]) -> URL {
        var rows = ["Original,Corrected,Type,Folder,Learned,Next review"]
        for c in corrections {
            let fields = [
                c.original,
                c.corrected,
                c.type.label,
                c.folder?.name ?? "",
                c.isLearned ? "Yes" : "No",
                c.dueDate.formatted(date: .numeric, time: .omitted)
            ]
            rows.append(fields.map(quote).joined(separator: ","))
        }
        let url = FileManager.default.temporaryDirectory.appending(path: "Gochimi Notebook.csv")
        try? ("\u{FEFF}" + rows.joined(separator: "\n")).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func quote(_ field: String) -> String {
        "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
