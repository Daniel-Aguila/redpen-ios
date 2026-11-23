//
//  SlotPickerSheet.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/21/26.
//

import SwiftUI

struct SlotPickerSheet: View {
    let slot: Slot
    @Binding var preview: String?

    @Environment(\.dismiss) private var dismiss
    @Environment(Wallet.self) private var wallet
    @Environment(ProStore.self) private var store
    @Environment(ProgressStore.self) private var progress

    @State private var showPaywall = false
    @State private var notEnough = false

    private enum Access {
        case usable, buyable(Int), streakLocked(Int), plusLocked, proLocked
    }

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 10)]

    private var placedID: String {
        wallet.placedID(in: slot) ?? ""
    }

    private var selectedID: String {
        preview ?? placedID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(verbatim: slot.korean).font(.title2.bold())
                    Text("\(slot.english) · \(Catalog.items(in: slot).count) options")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("🍊")
                    Text(wallet.balance.formatted()).font(.headline)
                }
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    if slot.allowsEmpty {
                        tile(id: "", art: AnyView(
                            Image(systemName: "circle.slash")
                                .font(.system(size: 30))
                                .foregroundStyle(.secondary)
                        ), title: "None", status: "Remove", statusColor: .secondary)
                    }
                    ForEach(Catalog.items(in: slot)) { item in
                        tile(id: item.id, art: AnyView(ItemArt(item: item).padding(8)),
                             title: item.korean, status: statusText(item), statusColor: statusColor(item))
                    }
                }
            }

            footer
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .alert("Not enough 🍊", isPresented: $notEnough) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Practice due cards to earn more, or get a pack in the shop.")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: Access

    private func access(_ item: Item) -> Access {
        switch item.unlock {
        case .starter:
            return .usable
        case .price(let price):
            return wallet.owns(item.id) ? .usable : .buyable(price)
        case .streak(let days):
            return wallet.owns(item.id) || progress.streak >= days ? .usable : .streakLocked(days)
        case .plus:
            return store.tier >= .plus ? .usable : .plusLocked
        case .pro:
            return store.tier >= .pro ? .usable : .proLocked
        }
    }

    private func statusText(_ item: Item) -> String {
        if item.id == placedID { return "Placed" }
        switch access(item) {
        case .usable: return "Owned"
        case .buyable(let price): return "🍊 \(price.formatted())"
        case .streakLocked(let days): return "\(days) days"
        case .plusLocked: return "PLUS"
        case .proLocked: return "PRO"
        }
    }

    private func statusColor(_ item: Item) -> Color {
        if item.id == placedID { return .green }
        switch access(item) {
        case .usable: return .blue
        case .buyable: return .orange
        case .streakLocked: return .secondary
        case .plusLocked: return .gochiRed
        case .proLocked: return .gochiBlue
        }
    }

    // MARK: Tiles

    private func tile(id: String, art: AnyView, title: String, status: String, statusColor: Color) -> some View {
        let selected = id == selectedID
        return Button {
            tap(id)
        } label: {
            VStack(spacing: 4) {
                art
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                Text(verbatim: title)
                    .font(.caption.bold())
                    .lineLimit(1)
                Text(status)
                    .font(.caption2.bold())
                    .foregroundStyle(statusColor)
                    .lineLimit(1)
            }
            .padding(8)
            .background(selected ? Color.gochiRed.opacity(0.08) : Color(.secondarySystemGroupedBackground),
                        in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(selected ? Color.gochiRed : Color(.separator), lineWidth: selected ? 2 : 1)
            }
        }
        .buttonStyle(PressableStyle())
    }

    private func tap(_ id: String) {
        guard !id.isEmpty, let item = Catalog.item(id) else {
            wallet.place(nil, in: slot)
            preview = nil
            return
        }
        if case .usable = access(item) {
            if case .streak = item.unlock, !wallet.owns(item.id) { wallet.give(item.id) }
            wallet.place(item.id, in: slot)
            preview = nil
        } else {
            preview = item.id
        }
    }

    // MARK: Footer

    private var previewItem: Item? {
        preview.flatMap { Catalog.item($0) }
    }

    @ViewBuilder
    private var footer: some View {
        if let item = previewItem {
            HStack(spacing: 10) {
                Button("Cancel") { preview = nil }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay { Capsule().strokeBorder(Color(.separator), lineWidth: 2) }

                switch access(item) {
                case .buyable(let price):
                    Button {
                        if wallet.buy(item.id, price: price) {
                            wallet.place(item.id, in: slot)
                            preview = nil
                        } else {
                            notEnough = true
                        }
                    } label: {
                        Text("Buy for 🍊 \(price.formatted())")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .background(Color.gochiRed, in: .capsule)
                    }
                    .buttonStyle(PressableStyle())
                case .plusLocked, .proLocked:
                    Button {
                        showPaywall = true
                    } label: {
                        Text("Unlock with \(item.unlock == .pro ? "Pro" : "Plus")")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .background(item.unlock == .pro ? Color.gochiBlue : Color.gochiRed, in: .capsule)
                    }
                    .buttonStyle(PressableStyle())
                case .streakLocked(let days):
                    Text("Keep a \(days)-day streak")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                case .usable:
                    EmptyView()
                }
            }
            .layoutPriority(1)
        } else {
            Text("Tap an item to try it in your room.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
    }
}
