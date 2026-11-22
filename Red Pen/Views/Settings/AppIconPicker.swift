//
//  AppIconPicker.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/22/26.
//

import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case classic, notebook, taegeuk, midnight, night, sunset
    case sakura, winter, rainy, onsen, tangerine, strawberry
    case study, graduate, music, party, royal, moonrabbit

    var id: String { rawValue }

    var iconName: String? {
        self == .classic ? nil : "AppIcon-\(rawValue.capitalized)"
    }

    var title: String {
        switch self {
        case .moonrabbit: "Moon Rabbit"
        default: rawValue.capitalized
        }
    }

    var requiredTier: ProStore.Tier {
        switch self {
        case .classic: .free
        case .royal, .moonrabbit: .pro
        default: .plus
        }
    }

    static var current: AppIcon {
        allCases.first { $0.iconName == UIApplication.shared.alternateIconName } ?? .classic
    }
}

struct AppIconPicker: View {
    @Environment(ProStore.self) private var store
    @State private var selected = AppIcon.current
    @State private var paywallPlan: PaywallView.Plan?

    private let columns = [GridItem(.adaptive(minimum: 88), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(AppIcon.allCases) { icon in
                    Button {
                        choose(icon)
                    } label: {
                        tile(icon)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
            .padding()
        }
        .navigationTitle("App icon")
        .sheet(item: $paywallPlan) { plan in
            PaywallView(startOn: plan)
        }
    }

    private func tile(_ icon: AppIcon) -> some View {
        VStack(spacing: 8) {
            Image("IconPreview-\(icon.rawValue)")
                .resizable()
                .frame(width: 72, height: 72)
                .clipShape(.rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(selected == icon ? Color.gochiRed : .clear, lineWidth: 3)
                        .padding(-5)
                }
                .overlay(alignment: .topTrailing) {
                    if store.tier < icon.requiredTier {
                        Text(icon.requiredTier == .pro ? "PRO" : "PLUS")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(icon.requiredTier == .pro ? Color.gochiBlue : Color.gochiRed, in: .capsule)
                            .offset(x: 6, y: -6)
                    }
                }
            Text(icon.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }

    private func choose(_ icon: AppIcon) {
        guard store.tier >= icon.requiredTier else {
            paywallPlan = icon.requiredTier == .pro ? .pro : .plus
            return
        }
        guard icon != selected else { return }
        Task {
            try? await UIApplication.shared.setAlternateIconName(icon.iconName)
            selected = AppIcon.current
        }
    }
}

#Preview {
    NavigationStack {
        AppIconPicker()
    }
    .environment(ProStore())
}
