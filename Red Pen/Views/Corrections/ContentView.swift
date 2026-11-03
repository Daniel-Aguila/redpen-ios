//
//  ContentView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var showingAdd = false
    @State private var searchText = ""
    @State private var showingChart = false
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<Correction.ID>()
    @State private var showingDeleteConfirm = false

    @Query(sort: \Correction.createdAt, order: .reverse)
    private var corrections: [Correction]

    private var filtered: [Correction] {
        if searchText.isEmpty {
            return corrections
        }
        return corrections.filter {
            $0.original.localizedStandardContains(searchText) ||
            $0.corrected.localizedStandardContains(searchText) ||
            $0.note.localizedStandardContains(searchText)
        }
    }

    private var dueCount: Int {
        corrections.filter { $0.dueDate <= .now }.count
    }

    private var isSelecting: Bool { editMode.isEditing }

    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                if searchText.isEmpty && !isSelecting {
                    PageTitle(marked: "오답", rest: "노트", subtitle: "Your wrong-answer notebook")
                        .onPaper()
                        .listRowInsets(EdgeInsets(top: 0, leading: 36, bottom: 4, trailing: 20))
                }

                if searchText.isEmpty && !corrections.isEmpty && !isSelecting {
                    HomeCardView(dueCount: dueCount)
                        .onPaper()
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                ForEach(filtered) { c in
                    NavigationLink(value: c) {
                        HStack(spacing: 12) {
                            Image(systemName: c.type.symbol)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(c.type.color, in: .rect(cornerRadius: 9))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.corrected)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(c.original)
                                    .font(.subheadline)
                                    .strikethrough(color: .accentColor)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 10, leading: 28, bottom: 10, trailing: 28))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(c.type.color.opacity(0.14))
                            )
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                    )
                    .swipeActions {
                        Button(role: .destructive) {
                            modelContext.delete(c)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button {
                            withAnimation {
                                editMode = .active
                                selection = [c.id]
                            }
                        } label: {
                            Label("Select", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive) {
                            modelContext.delete(c)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("오답노트")
            .navigationBarTitleDisplayMode(.inline)
            .paperBackground()
            .listStyle(.plain)
            .contentMargins(.bottom, 88, for: .scrollContent)
            .searchable(text: $searchText, prompt: "Search your 오답노트")
            .overlay {
                if corrections.isEmpty {
                    ContentUnavailableView {
                        Label("Your notebook is empty", systemImage: "book.closed")
                    } description: {
                        Text("When someone corrects your Korean, save it here. Add one, or try a few examples first.")
                    } actions: {
                        Button("Add a correction") { showingAdd = true }
                            .buttonStyle(.borderedProminent)
                        Button("Try with examples") { SampleData.insert(into: modelContext) }
                    }
                } else if filtered.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !isSelecting {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.accentColor, in: Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .accessibilityLabel("Add correction")
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }
            .overlay(alignment: .bottom) {
                if isSelecting {
                    HStack {
                        Button(selection.count == filtered.count ? String(localized: "Deselect All") : String(localized: "Select All")) {
                            if selection.count == filtered.count {
                                selection.removeAll()
                            } else {
                                selection = Set(filtered.map(\.id))
                            }
                        }
                        Spacer()
                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            Text("Delete (\(selection.count))")
                                .fontWeight(.semibold)
                        }
                        .disabled(selection.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(.bar, in: .rect(cornerRadius: 20))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationDestination(for: Correction.self) { c in
                CorrectionDetailView(correction: c)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hangul chart", systemImage: "character.book.closed") {
                        showingChart = true
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !corrections.isEmpty {
                        Button(isSelecting ? String(localized: "Done") : String(localized: "Select")) {
                            withAnimation {
                                editMode = isSelecting ? .inactive : .active
                                selection.removeAll()
                            }
                        }
                    }
                }
            }
            .confirmationDialog("Delete \(selection.count) corrections?",
                                isPresented: $showingDeleteConfirm,
                                titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteSelected()
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddCorrectionView()
            }
            .sheet(isPresented: $showingChart) {
                HangulChartView()
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func deleteSelected() {
        for c in corrections where selection.contains(c.id) {
            modelContext.delete(c)
        }
        selection.removeAll()
        withAnimation { editMode = .inactive }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Correction.self, inMemory: true)
}
