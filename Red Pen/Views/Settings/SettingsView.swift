//
//  SettingsView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/30/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyGoal") private var dailyGoal = 10
    @AppStorage("reminderOn") private var reminderOn = false
    @AppStorage("reminderMinutes") private var reminderMinutes = 20 * 60

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

    var body: some View {
        NavigationStack {
            Form {
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

                #if DEBUG
                Section("Developer") {
                    Button("Show intro again") {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .onChange(of: reminderOn) { _, isOn in
                Task {
                    if isOn {
                        if await Reminder.requestPermission() {
                            Reminder.schedule(minutesAfterMidnight: reminderMinutes)
                        } else {
                            reminderOn = false
                        }
                    } else {
                        Reminder.cancel()
                    }
                }
            }
            .onChange(of: reminderMinutes) { _, minutes in
                if reminderOn {
                    Reminder.schedule(minutesAfterMidnight: minutes)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
