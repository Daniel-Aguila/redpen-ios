//
//  SettingsView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/30/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage("dailyGoal") private var dailyGoal = 10
    @AppStorage("reminderOn") private var reminderOn = false
    @AppStorage("reminderMinutes") private var reminderMinutes = 20 * 60
    @AppStorage("hideGochi") private var hideGochi = false
    @Environment(ProgressStore.self) private var progress
    @Environment(ProStore.self) private var store
    @Environment(Wallet.self) private var wallet

    @State private var showPaywall = false
    @State private var showManage = false
    @State private var showShop = false
    
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: reminderMinutes / 60,
                                      minute: reminderMinutes % 60,
                                      second: 0, of: .now) ?? .now
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderMinutes = (parts.hour ?? 20) * 60 + (parts.minute ?? 0)
            }
        )
    }

    private func refreshReminder() {
        Reminder.refresh(enabled: reminderOn, minutesAfterMidnight: reminderMinutes,
                         practicedToday: progress.practicedToday)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if store.tier == .free {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Get Gochimi Plus or Pro", systemImage: "sparkles")
                        }
                    } else {
                        LabeledContent("Your plan", value: store.tier == .pro ? "Gochimi Pro" : "Gochimi Plus")
                        Button("Manage subscription") { showManage = true }
                    }
                } footer: {
                    Text(store.tier == .free
                         ? "Every lesson, every story, and more."
                         : "Change or cancel anytime in your Apple account.")
                }

                Section {
                    Picker("Questions per day", selection: $dailyGoal) {
                        Text("5").tag(5)
                        Text("10").tag(10)
                        Text("20").tag(20)
                        Text("30").tag(30)
                    }
                    .pickerStyle(.segmented)
                    Stepper("\(dailyGoal) questions per day", value: $dailyGoal, in: 1...100)
                } header: {
                    Text("Daily goal")
                } footer: {
                    Text("How many questions count as a full day of practice.")
                }

                Section {
                    Toggle("Daily reminder", isOn: $reminderOn)
                    if reminderOn {
                        DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("A gentle nudge to keep your streak going.")
                }

                Section {
                    Toggle("Hide Gochi", isOn: $hideGochi)
                } footer: {
                    Text("Hides the pet and the evolution screen. Your XP and streak still count.")
                }

                #if DEBUG
                Section("Developer") {
                    Button("Show intro again") {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                    }
                    Button("Show What's New again") {
                        UserDefaults.standard.set("", forKey: "whatsNewSeen")
                    }
                }

                Section("Store (debug)") {
                    Button("Show paywall") { showPaywall = true }
                    Button("Show shop") { showShop = true }
                    LabeledContent("Tier", value: "\(store.tier)")
                    LabeledContent("Tangerines", value: "\(wallet.balance)")
                    LabeledContent("Earned today", value: "\(wallet.earnedToday) / \(Wallet.dailyCap)")

                    if !store.isLoaded {
                        ProgressView()
                    }

                    ForEach(store.products, id: \.id) { product in
                        Button {
                            Task { try? await store.purchase(product) }
                        } label: {
                            LabeledContent(
                                product.displayName.isEmpty ? product.id : product.displayName,
                                value: product.displayPrice
                            )
                        }
                    }

                    Button("Restore purchases") {
                        Task { await store.restore() }
                    }
                    Button("Reset paywall rules") { PaywallPolicy.reset() }
                }
                #endif
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showShop) {
                ShopView()
            }
            .manageSubscriptionsSheet(isPresented: $showManage)
            .onChange(of: reminderOn) { _, isOn in
                Task {
                    if isOn, !(await Reminder.requestPermission()) {
                        reminderOn = false
                        return
                    }
                    refreshReminder()
                }
            }
            .onChange(of: reminderMinutes) {
                refreshReminder()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(ProgressStore())
        .environment(ProStore())
        .environment(Wallet())
}
