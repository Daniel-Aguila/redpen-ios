//
//  FolderChipsBarView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/17/26.
//

import SwiftUI
import SwiftData

struct FolderChipsBar: View {
    let folders: [Folder]
    let selected: Folder?
    let count: (Folder?) -> Int
    let onSelect: (Folder?) -> Void
    var showsAdd = true
    var inset: CGFloat = 16

    @Environment(\.modelContext) private var modelContext
    @State private var showingNew = false
    @State private var editing: Folder? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                chip(String(localized: "All"), count: count(nil), isOn: selected == nil) {
                    onSelect(nil)
                }
                ForEach(folders) { f in
                    chip("\(f.emoji) \(f.name)", count: count(f), isOn: selected == f) {
                        onSelect(f)
                    }
                    .contextMenu {
                        Button {
                            editing = f
                        } label: {
                            Label("Edit folder", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            if selected == f { onSelect(nil) }
                            modelContext.delete(f)
                        } label: {
                            Label("Delete folder", systemImage: "trash")
                        }
                    }
                }
                if showsAdd {
                    Button {
                        showingNew = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .overlay(
                                Capsule().strokeBorder(Color.secondary.opacity(0.5),
                                                       style: StrokeStyle(lineWidth: 1, dash: [3]))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("New folder")
                }
            }
            .padding(.horizontal, inset)
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingNew) {
            FolderEditorView { onSelect($0) }
        }
        .sheet(item: $editing) { f in
            FolderEditorView(folder: f)
        }
    }

    private func chip(_ title: String, count: Int, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(verbatim: title)
                if count > 0 {
                    Text(verbatim: "\(count)")
                        .foregroundStyle(isOn ? Color.accentColor.opacity(0.7) : Color.secondary)
                }
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(isOn ? Color.accentColor : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isOn ? Color.accentColor.opacity(0.12) : Color(.secondarySystemGroupedBackground),
                        in: Capsule())
            .overlay(
                Capsule().strokeBorder(isOn ? Color.accentColor.opacity(0.6) : Color.primary.opacity(0.08),
                                       lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
