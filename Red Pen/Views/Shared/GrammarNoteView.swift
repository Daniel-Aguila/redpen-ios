//
//  GrammarNoteView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/4/26.
//

import SwiftUI

struct GrammarNoteView: View {
    let note: GrammarNote
    var tint: Color = .accentColor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Label(note.title, systemImage: "book.pages")
                .font(.headline)
                .foregroundStyle(tint)
            
            Text(note.summary)
                .font(.subheadline)
            
            ForEach(note.examples, id: \.self) { example in
                HStack(alignment: .top, spacing: 6) {
                    Text("•").foregroundStyle(tint)
                    Text(example).font(.subheadline)
                }
            }
            
            if let tip = note.tip {
                Label(tip, systemImage: "lightbulb")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GrammarNoteView(note: MistakeType.honorific.note!, tint: MistakeType.honorific.color)
        .padding()
}
