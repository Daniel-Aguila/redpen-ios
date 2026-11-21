//
//  ShopView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/21/26.
//

import SwiftUI
import StoreKit

struct ShopView: View {
    enum Section: String, CaseIterable {
        case decor = "Decor"
        case outfits = "Outfits"
        case tangerines = "Get 🍊"
    }

    enum Show: String, CaseIterable {
        case all = "All"
        case owned = "Owned"
        case forSale = "For sale"
    }

    enum ItemState {
        case placed, owned, buyable(Int), claimable, streakLocked(Int), plusLocked, proLocked
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(Wallet.self) private var wallet
    @Environment(ProStore.self) private var store
    @Environment(ProgressStore.self) private var progress

    @State private var section: Section = .decor
    @State private var category: ShopCategory?
    @State private var show: Show = .all
    @State private var pendingBuy: Item?
    @State private var notEnough = false
    @State private var showPaywall = false

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 10)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Section", selection: $section) {
                        ForEach(Section.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: section) { category = nil }

                    if section == .tangerines {
                        packs
                    } else {
                        filterBar
                        itemsList
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("상점")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    balanceChip
                }
            }
            .confirmationDialog(
                "Buy this item?",
                isPresented: Binding(get: { pendingBuy != nil }, set: { if !$0 { pendingBuy = nil } }),
                titleVisibility: .visible,
                presenting: pendingBuy
            ) { item in
                if case .price(let price) = item.unlock {
                    Button("Buy for \(price) 🍊") { buy(item) }
                }
            } message: { item in
                Text(verbatim: "\(item.korean) · \(item.english)")
            }
            .alert("Not enough 🍊", isPresented: $notEnough) {
                Button("Get 🍊") { section = .tangerines }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Practice due cards to earn more, or get a pack.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: Filters

    private var categoriesInSection: [ShopCategory] {
        ShopCategory.allCases.filter { $0.isOutfit == (section == .outfits) }
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("All", selected: category == nil) { category = nil }
                    ForEach(categoriesInSection) { c in
                        chip(c.english, selected: category == c) { category = c }
                    }
                }
            }
            Menu {
                Picker("Show", selection: $show) {
                    ForEach(Show.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
            } label: {
                Image(systemName: show == .all
                      ? "line.3.horizontal.decrease.circle"
                      : "line.3.horizontal.decrease.circle.fill")
                    .font(.title2)
                    .foregroundStyle(show == .all ? Color.secondary : Color.gochiRed)
            }
            .accessibilityLabel("Filter")
        }
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundStyle(selected ? .white : .primary)
                .background(selected ? Color.gochiRed : Color(.secondarySystemGroupedBackground), in: .capsule)
        }
        .buttonStyle(PressableStyle())
    }

    private func passesShow(_ item: Item) -> Bool {
        switch (show, state(of: item)) {
        case (.all, _): true
        case (.owned, .placed), (.owned, .owned): true
        case (.forSale, .buyable): true
        default: false
        }
    }

    private func items(in c: ShopCategory) -> [Item] {
        Catalog.items.filter { c.slots.contains($0.slot) && passesShow($0) }
    }

    @ViewBuilder
    private var itemsList: some View {
        if let category {
            let list = items(in: category)
            if list.isEmpty { emptyNote } else { grid(list) }
        } else {
            let groups = categoriesInSection.map { ($0, items(in: $0)) }.filter { !$0.1.isEmpty }
            if groups.isEmpty { emptyNote }
            ForEach(groups, id: \.0) { c, list in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(verbatim: c.korean).font(.headline)
                        Text(c.english).font(.subheadline).foregroundStyle(.secondary)
                    }
                    grid(list)
                }
                .padding(.top, 4)
            }
        }
    }

    private var emptyNote: some View {
        Text("Nothing here yet.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
    }

    // MARK: Cards

    private func grid(_ items: [Item]) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(items) { item in
                card(item)
            }
        }
    }

    private func card(_ item: Item) -> some View {
        let isPlaced = { if case .placed = state(of: item) { return true } else { return false } }()
        return VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                ItemArt(item: item)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 84)
                    .background(item.slot.tint.opacity(0.10), in: .rect(cornerRadius: 14))
                if isPlaced {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, .green)
                        .padding(5)
                }
            }
            .overlay(alignment: .topLeading) {
                if let label = item.rarity.label {
                    Text(label)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.rarity.color, in: .capsule)
                        .padding(6)
                }
            }
            Text(verbatim: item.korean)
                .font(.subheadline.bold())
                .lineLimit(1)
            Text(item.english)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            action(for: item)
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(item.rarity.color.opacity(0.6), lineWidth: item.rarity.label == nil ? 0 : 2)
        }
    }

    private func state(of item: Item) -> ItemState {
        if wallet.placedID(in: item.slot) == item.id {
            switch item.unlock {
            case .plus where store.tier < .plus: return .plusLocked
            case .pro where store.tier < .pro: return .proLocked
            default: return .placed
            }
        }
        switch item.unlock {
        case .starter:
            return .owned
        case .price(let price):
            return wallet.owns(item.id) ? .owned : .buyable(price)
        case .streak(let days):
            if wallet.owns(item.id) { return .owned }
            return progress.streak >= days ? .claimable : .streakLocked(days)
        case .plus:
            return store.tier >= .plus ? .owned : .plusLocked
        case .pro:
            return store.tier >= .pro ? .owned : .proLocked
        }
    }

    @ViewBuilder
    private func action(for item: Item) -> some View {
        switch state(of: item) {
        case .placed:
            pill("Placed", symbol: nil, fg: Color.secondary, bg: Color(.tertiarySystemFill))
        case .owned:
            Button { withAnimation(.snappy) { wallet.place(item.id, in: item.slot) } } label: {
                pill("Place", symbol: nil, fg: Color.blue, bg: Color.blue.opacity(0.12))
            }
            .buttonStyle(PressableStyle())
        case .buyable(let price):
            Button {
                if wallet.balance >= price { pendingBuy = item } else { notEnough = true }
            } label: {
                pill("🍊 \(price.formatted())", symbol: nil, fg: Color.orange, bg: Color.orange.opacity(0.15))
            }
            .buttonStyle(PressableStyle())
        case .claimable:
            Button { withAnimation(.snappy) { claim(item) } } label: {
                pill("Claim", symbol: "gift.fill", fg: Color.white, bg: Color.green)
            }
            .buttonStyle(PressableStyle())
        case .streakLocked(let days):
            pill("\(days) days", symbol: "flame.fill", fg: Color.secondary, bg: Color(.tertiarySystemFill))
        case .plusLocked:
            Button { showPaywall = true } label: {
                pill("PLUS", symbol: "lock.fill", fg: Color.white, bg: Color.gochiRed)
            }
            .buttonStyle(PressableStyle())
        case .proLocked:
            Button { showPaywall = true } label: {
                pill("PRO", symbol: "lock.fill", fg: Color.white, bg: Color.gochiBlue)
            }
            .buttonStyle(PressableStyle())
        }
    }

    private func pill(_ text: String, symbol: String?, fg: Color, bg: Color) -> some View {
        HStack(spacing: 3) {
            if let symbol { Image(systemName: symbol) }
            Text(text)
        }
        .font(.caption.bold())
        .foregroundStyle(fg)
        .frame(maxWidth: .infinity)
        .frame(height: 28)
        .background(bg, in: .capsule)
    }

    // MARK: Packs and balance

    private var balanceChip: some View {
        HStack(spacing: 4) {
            Text("🍊")
            Text(wallet.balance.formatted())
                .font(.headline)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .animation(.snappy, value: wallet.balance)
    }

    private var packs: some View {
        VStack(spacing: 10) {
            ForEach(ProStore.tangerinePacks.sorted { $0.value < $1.value }, id: \.key) { pack in
                if let product = store.product(pack.key) {
                    Button {
                        Task { try? await store.purchase(product) }
                    } label: {
                        HStack(spacing: 14) {
                            Text("🍊").font(.system(size: 36))
                            Text("\(pack.value.formatted()) 🍊").font(.headline)
                            Spacer()
                            Text(product.displayPrice)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.orange, in: .capsule)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
                    }
                    .buttonStyle(PressableStyle())
                }
            }
            Text("🍊 are only for decorations and outfits. Streak, Plus and Pro items can't be bought with them.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }

    private func buy(_ item: Item) {
        guard case .price(let price) = item.unlock else { return }
        if wallet.buy(item.id, price: price) {
            withAnimation(.snappy) { wallet.place(item.id, in: item.slot) }
        }
    }

    private func claim(_ item: Item) {
        wallet.give(item.id)
        wallet.place(item.id, in: item.slot)
    }
}

#Preview {
    ShopView()
        .environment(Wallet())
        .environment(ProStore())
        .environment(ProgressStore())
}
