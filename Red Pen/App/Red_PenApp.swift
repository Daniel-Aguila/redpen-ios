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
    @AppStorage("selectedTab") private var selectedTab = "practice"
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Correction.self,
            Folder.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                Tab("Practice", systemImage: "target", value: "practice") {
                    PracticeView()
                }
                Tab("Notebook", systemImage: "book.closed", value: "notebook") {
                    ContentView()
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
        }
        .modelContainer(sharedModelContainer)
    }
}
