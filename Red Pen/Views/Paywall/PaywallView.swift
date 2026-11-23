//
//  PaywallView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/20/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    enum Plan: Identifiable { case plus, pro; var id: Self { self } }
    enum Billing { case monthly, yearly, lifetime }

    @Environment(\.dismiss) private var dismiss
    @Environment(ProStore.self) private var store
    @Environment(ProgressStore.self) private var progress

    @State private var plan: Plan = .plus
    @State private var billing: Billing = .yearly
    @State private var gochiTaps = 0
    @State private var trialEligible = false
    @State private var isBuying = false
    @State private var errorMessage: String?
    
    
    init(startOn: Plan = .plus) {
        _plan = State(initialValue: startOn)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                topBar
                header
                planTiles
                whatYouGet
                howYouPay
                buyButton
                links
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .task(id: store.isLoaded) {
            let plusYearly = store.product(ProStore.plusYearly)
            trialEligible = await plusYearly?.subscription?.isEligibleForIntroOffer ?? false
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var accent: Color { plan == .plus ? .gochiRed : .gochiBlue }

    private var productID: String {
        switch (plan, billing) {
        case (.plus, .monthly): ProStore.plusMonthly
        case (.plus, .yearly): ProStore.plusYearly
        case (.plus, .lifetime): ProStore.plusLifetime
        case (.pro, .monthly): ProStore.proMonthly
        case (.pro, _): ProStore.proYearly
        }
    }

    private var selectedProduct: Product? { store.product(productID) }

    private var perks: [String] {
        plan == .plus
        ? ["Every lesson, including new ones",
           "Every story in the library",
           "Smart review and streak freeze",
           "iCloud sync and a Plus outfit",
           "App icons, stats and export"]
        : ["Everything in Plus",
           "Personal help on every mistake",
           "Practice and stories from your mistakes",
           "Write a diary, Gochi corrects it",
           "Exclusive outfits and early stories"]
    }

    private func perMonth(_ id: String) -> String {
        guard let p = store.product(id) else { return "" }
        return (p.price / 12).formatted(p.priceFormatStyle)
    }

    private var yearlyNote: String {
        if plan == .plus {
            return trialEligible
                ? "7 days free · save 48%"
                : "Save 48% · \(perMonth(ProStore.plusYearly))/mo"
        }
        return "Save 44% · \(perMonth(ProStore.proYearly))/mo"
    }

    private var buttonTitle: String {
        if billing == .lifetime { return "Get Plus for life" }
        if plan == .plus && billing == .yearly && trialEligible { return "Start my free week" }
        return plan == .plus ? "Get Plus" : "Get Pro"
    }

    private var finePrint: String {
        guard let p = selectedProduct else { return "" }
        switch billing {
        case .lifetime:
            return "One-time purchase of \(p.displayPrice). Yours to keep, no renewals."
        case .yearly where plan == .plus && trialEligible:
            return "7 days free, then \(p.displayPrice) per year. Cancel anytime in Settings at least 24 hours before the trial ends."
        case .yearly:
            return "\(p.displayPrice) per year. Renews automatically, cancel anytime in Settings."
        case .monthly:
            return "\(p.displayPrice) per month. Renews automatically, cancel anytime in Settings."
        }
    }

    private func buy() async {
        guard let product = selectedProduct else { return }
        isBuying = true
        defer { isBuying = false }
        do {
            if try await store.purchase(product) { dismiss() }
        } catch {
            errorMessage = "The purchase didn't go through. Please try again."
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.tertiarySystemFill), in: .circle)
            }
            .accessibilityLabel("Close")

            Spacer()

            Button("Restore") {
                Task { await store.restore() }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var header: some View {
        HStack(spacing: 14) {
            GochiView(xp: progress.xp, celebrate: gochiTaps, mood: .happy)
                .font(.system(size: 44))
                .frame(width: 72, height: 72)
                .onTapGesture { gochiTaps += 1 }
                .overlay(alignment: .topLeading) {
                    Sparkle(color: .orange, size: 12, delay: 0).offset(x: -6, y: 2)
                }
                .overlay(alignment: .topTrailing) {
                    Sparkle(color: .gochiRed, size: 9, delay: 0.4).offset(x: 6, y: 16)
                }
                .overlay(alignment: .bottomLeading) {
                    Sparkle(color: .gochiBlue, size: 8, delay: 0.8).offset(x: 2, y: 2)
                }
            Text("Learn more\nwith Gochi")
                .font(.title.bold())
                .multilineTextAlignment(.leading)
        }
    }

    private var planTiles: some View {
        HStack(spacing: 10) {
            tile(.plus, title: "Plus", subtitle: "Course and stories", color: .gochiRed)
            tile(.pro, title: "Pro", subtitle: "Built around you", color: .gochiBlue)
        }
    }

    private func tile(_ p: Plan, title: String, subtitle: String, color: Color) -> some View {
        let selected = plan == p
        return Button {
            withAnimation(.snappy) {
                plan = p
                if p == .pro && billing == .lifetime { billing = .yearly }
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(color)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(selected ? color.opacity(0.08) : Color(.secondarySystemGroupedBackground),
                        in: .rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(selected ? color : Color(.separator), lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.heavy))
            .tracking(0.6)
            .foregroundStyle(.secondary)
    }

    private var whatYouGet: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("WHAT YOU GET")
            ForEach(Array(perks.enumerated()), id: \.element) { index, perk in
                Label {
                    Text(perk)
                } icon: {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                        .foregroundStyle(accent)
                }
                .font(.body.weight(.medium))
                .modifier(StaggerIn(index: index))
            }
        }
        .id(plan)
        .transition(.opacity)
    }

    private var howYouPay: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("HOW YOU PAY")
            billingRow(.monthly, title: "Monthly", note: nil,
                       id: plan == .plus ? ProStore.plusMonthly : ProStore.proMonthly, unit: "/month")
            billingRow(.yearly, title: "Yearly", note: yearlyNote,
                       id: plan == .plus ? ProStore.plusYearly : ProStore.proYearly, unit: "/year")
            if plan == .plus {
                billingRow(.lifetime, title: "Lifetime", note: "Pay once, no subscription",
                           id: ProStore.plusLifetime, unit: "")
            }
        }
    }

    private func billingRow(_ b: Billing, title: String, note: String?, id: String, unit: String) -> some View {
        let selected = billing == b
        return Button {
            withAnimation(.snappy) { billing = b }
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .strokeBorder(selected ? accent : Color(.tertiaryLabel), lineWidth: selected ? 6 : 2)
                    .frame(width: 20, height: 20)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.headline)
                    if let note {
                        Text(note)
                            .font(.caption.bold())
                            .foregroundStyle(b == .yearly ? Color.green : .secondary)
                    }
                }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(store.product(id)?.displayPrice ?? "–").font(.headline)
                    Text(unit).font(.footnote).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(selected ? accent : Color(.separator), lineWidth: 2)
            }
        }
        .buttonStyle(PressableStyle())
    }

    private var buyButton: some View {
        VStack(spacing: 8) {
            Button {
                Task { await buy() }
            } label: {
                Group {
                    if isBuying {
                        ProgressView().tint(.white)
                    } else {
                        Text(buttonTitle).font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(.white)
                .background(accent, in: .capsule)
                .overlay { ShineOverlay() }
            }
            .buttonStyle(.plain)
            .disabled(selectedProduct == nil || isBuying)

            Text(finePrint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var links: some View {
        HStack(spacing: 16) {
            Link("Terms of Use", destination: URL(string: "https://gochimi.com/terms")!)
            Link("Privacy Policy", destination: URL(string: "https://gochimi.com/privacy")!)
        }
        .font(.caption.bold())
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
    }
}

extension Color {
    static let gochiRed = Color(red: 205 / 255, green: 46 / 255, blue: 58 / 255)
    static let gochiBlue = Color(red: 0 / 255, green: 71 / 255, blue: 160 / 255)
}

#Preview {
    PaywallView()
        .environment(ProStore())
        .environment(ProgressStore())
}
