//
//  Red_PenApp.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/28/26.
//

import SwiftUI
import SwiftData

@main
struct Red_PenApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("whatsNewSeen") private var whatsNewSeen = ""
    @AppStorage("selectedTab") private var selectedTab = "home"
    @AppStorage("reminderOn") private var reminderOn = false
    @AppStorage("hideGochi") private var hideGochi = false
    @AppStorage("iCloudSync") private var iCloudSync = false
    @AppStorage("reminderMinutes") private var reminderMinutes = 20 * 60
    @Environment(\.scenePhase) private var scenePhase
    @State private var progress = ProgressStore()
    @State private var store = ProStore()
    @State private var wallet = Wallet()
    @State private var container = Red_PenApp.makeContainer(
        sync: UserDefaults.standard.bool(forKey: "iCloudSync")
    )

    static func makeContainer(sync: Bool) -> ModelContainer {
        let schema = Schema([Correction.self, Folder.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: sync ? .automatic : .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                Tab("Practice", systemImage: "target", value: "practice") {
                    PracticeView()
                }
                Tab("Notebook", systemImage: "book.closed", value: "notebook") {
                    ContentView()
                }
                Tab("Home", systemImage: "house.fill", value: "home") {
                    HabitatView()
                }
                Tab("Stats", systemImage: "chart.bar", value: "stats") {
                    StatsView()
                }
                Tab("Settings", systemImage: "gearshape", value: "settings") {
                    SettingsView()
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { !hasSeenOnboarding },
                set: { if !$0 { hasSeenOnboarding = true } }
            )) {
                OnboardingView()
            }
            .sheet(isPresented: Binding(
                get: { hasSeenOnboarding && whatsNewSeen != WhatsNewView.version },
                set: { if !$0 { whatsNewSeen = WhatsNewView.version } }
            )) {
                WhatsNewView()
            }
            .fullScreenCover(item: Binding(
                get: { hideGochi ? nil : progress.pendingEvolution },
                set: { progress.pendingEvolution = $0 }
            )) { form in
                EvolutionView(form: form)
            }
            .onChange(of: progress.pendingEvolution) { _, form in
                if hideGochi, form != nil { progress.pendingEvolution = nil }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { refreshReminder() }
            }
            .onChange(of: progress.lastPracticeDay) {
                refreshReminder()
            }
            .onChange(of: store.tier) { _, tier in
                if tier < .plus { iCloudSync = false }
                if AppIcon.current.requiredTier > tier {
                    Task { try? await UIApplication.shared.setAlternateIconName(nil) }
                }
            }
            .environment(progress)
            .environment(store)
            .environment(wallet)
            .task { await store.start { wallet.addPurchased($0) } }
        }
        .modelContainer(container)
    }

    private func refreshReminder() {
        Reminder.refresh(enabled: reminderOn, minutesAfterMidnight: reminderMinutes,
                         practicedToday: progress.practicedToday)
    }
}
