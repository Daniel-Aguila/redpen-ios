import SwiftUI
import SwiftData

struct OnboardingView: View {
    enum StartLevel { case new, hangul, some }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ProgressStore.self) private var progress
    @Environment(ProStore.self) private var store
    @Environment(Wallet.self) private var wallet
    @AppStorage("whatsNewSeen") private var whatsNewSeen = ""
    @AppStorage("selectedTab") private var selectedTab = "practice"
    @AppStorage("reminderOn") private var reminderOn = false
    @AppStorage("reminderMinutes") private var reminderMinutes = 20 * 60
    @AppStorage("dailyGoal") private var dailyGoal = 10
    @State private var page = 0
    @State private var hops = [0, 0, 0]
    @State private var welcomeHop = 0
    @State private var level: StartLevel = .new
    @State private var addExamples = true
    @State private var showPlacement = false
    @State private var showPaywall = false

    private let lastPage = 4

    var body: some View {
        TabView(selection: $page) {
            stores(welcomePage).tag(0)
            stores(levelPage).tag(1)
            stores(howPage).tag(2)
            stores(goalPage).tag(3)
            stores(startPage).tag(4)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(NotebookPaper())
        .safeAreaInset(edge: .bottom) {
            if page < lastPage {
                Button {
                    withAnimation { page += 1 }
                } label: {
                    Text("Next").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color.gochiRed)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(400))
            welcomeHop += 1
        }
        .onChange(of: page) { _, newPage in
            guard newPage == 3 else { return }
            Task {
                for i in hops.indices {
                    try? await Task.sleep(for: .milliseconds(300))
                    hops[i] += 1
                }
            }
        }
        .sheet(isPresented: $showPlacement, onDismiss: openPaywall) {
            stores(PlacementView { passed in markUnitsDone(passed) })
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            PaywallPolicy.recordClosed(tier: store.tier)
            dismiss()
        }) {
            stores(PaywallView(startOn: .plus))
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 20) {
            Spacer()
            GochiView(xp: GochiForm.baby.minXP, hop: welcomeHop)
                .frame(width: 150, height: 150)
            bubble("안녕! I'm Gochi. Let's learn Korean together.")
                .padding(.horizontal, 32)
            PageTitle(marked: "고치", rest: "미", subtitle: "Learn Korean and fix your mistakes")
            Spacer()
            Spacer()
        }
    }

    private var levelPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            gochiSays("How much Korean do you know?")
                .padding(.bottom, 8)
            optionRow(selected: level == .new, emoji: "🌱",
                      title: "I'm brand new", subtitle: "Start from the Korean alphabet") {
                level = .new
            }
            optionRow(selected: level == .hangul, emoji: "가",
                      title: "I can read Hangul", subtitle: "Skip straight to Unit 1") {
                level = .hangul
            }
            optionRow(selected: level == .some, emoji: "🎯",
                      title: "I know some Korean", subtitle: "Take a 2-minute check to find your level") {
                level = .some
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 60)
    }

    private var howPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Two ways to learn")
                .font(.largeTitle.weight(.heavy))
            featureCard(emoji: "📚", title: "Lessons with Gochi",
                        text: "Short lessons from Hangul to real conversations.")
            featureCard(emoji: "📝", title: "Your mistake notebook",
                        text: "When someone corrects your Korean, tap the red + and save it. Gochi turns it into practice.")
            exampleCard
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 60)
    }

    private var goalPage: some View {
        VStack(spacing: 14) {
            HStack(alignment: .bottom, spacing: 6) {
                GochiView(xp: GochiForm.bean.minXP, hop: hops[0], styled: false)
                    .frame(width: 48, height: 48)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 16)
                GochiView(xp: GochiForm.baby.minXP, hop: hops[1], styled: false)
                    .frame(width: 64, height: 64)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 22)
                GochiView(xp: GochiForm.adult.minXP, hop: hops[2], styled: false)
                    .frame(width: 88, height: 88)
            }
            Text("Pick a daily goal")
                .font(.title.weight(.heavy))
            Text("Every answer helps Gochi grow, all the way to 용.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                optionRow(selected: dailyGoal == 5, emoji: "🌤️",
                          title: "Casual", subtitle: "5 answers a day") { dailyGoal = 5 }
                optionRow(selected: dailyGoal == 10, emoji: "☀️",
                          title: "Regular", subtitle: "10 answers a day") { dailyGoal = 10 }
                optionRow(selected: dailyGoal == 20, emoji: "🔥",
                          title: "Serious", subtitle: "20 answers a day") { dailyGoal = 20 }
            }

            if reminderOn {
                Label("Gochi will remind you to practice", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            } else {
                Button {
                    Task { await turnOnReminder() }
                } label: {
                    Label("Remind me to practice 🍊", systemImage: "bell.fill")
                }
                .buttonStyle(.bordered)
                .tint(Color.gochiRed)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 60)
    }

    private var startPage: some View {
        VStack(spacing: 20) {
            Spacer()
            GochiView(xp: GochiForm.baby.minXP, hop: welcomeHop)
                .frame(width: 120, height: 120)
            Text("You're all set!")
                .font(.largeTitle.weight(.heavy))
            Group {
                switch level {
                case .new: Text("First stop: Hangul. You'll be reading Korean in a few short lessons.")
                case .hangul: Text("First stop: Unit 1, Introductions.")
                case .some: Text("First, a quick check to find your level.")
                }
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 32)

            Toggle(isOn: $addExamples) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add \(SampleData.pairs.count) example corrections")
                        .font(.subheadline.weight(.semibold))
                    Text("So you can try practice right away. Delete them anytime.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(Color.gochiRed)
            .padding()
            .softCard()
            .padding(.horizontal, 24)

            Spacer()

            Button {
                finish()
            } label: {
                Text("Let's go!").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color.gochiRed)
            .padding(.horizontal, 32)
            .padding(.bottom, 56)
        }
    }

    private func bubble(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .softCard()
    }

    private func gochiSays(_ text: LocalizedStringKey) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            GochiView(xp: GochiForm.baby.minXP, hop: welcomeHop)
                .frame(width: 64, height: 64)
            Text(text)
                .font(.title3.weight(.bold))
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .softCard()
        }
    }

    private func optionRow(selected: Bool, emoji: String, title: LocalizedStringKey,
                           subtitle: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            HStack(spacing: 14) {
                Text(verbatim: emoji)
                    .font(.title2)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? Color.gochiRed : .secondary)
            }
            .padding()
            .background(Color(.systemBackground), in: .rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(selected ? Color.gochiRed : Color.primary.opacity(0.06),
                                  lineWidth: selected ? 2 : 1)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func featureCard(emoji: String, title: LocalizedStringKey, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(verbatim: emoji)
                .font(.title)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .softCard()
    }
    
    private func stores<V: View>(_ view: V) -> some View {
        view
            .environment(progress)
            .environment(store)
            .environment(wallet)
            .environment(\.modelContext, modelContext)
    }

    private var exampleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: "저는 학생가 아니에요")
                .strikethrough(color: .accentColor)
                .foregroundStyle(.secondary)
            Text(verbatim: "저는 학생이 아니에요")
                .font(.headline)
            Label("Particle  가 → 이", systemImage: "link")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MistakeType.particle.color)
            Text("생 ends in a consonant (받침), so use 이")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private func turnOnReminder() async {
        guard await Reminder.requestPermission() else { return }
        reminderOn = true
        Reminder.refresh(enabled: true, minutesAfterMidnight: reminderMinutes,
                         practicedToday: progress.practicedToday)
    }

    private func markUnitsDone(_ count: Int) {
        let library = CourseStore.shared
        for unit in library.course.units.prefix(count) {
            for lesson in unit.lessons {
                library.markDone(lesson)
            }
        }
    }

    private func finish() {
        if addExamples { SampleData.insert(into: modelContext) }
        if level == .hangul { markUnitsDone(1) }
        whatsNewSeen = WhatsNewView.version
        selectedTab = "practice"
        if level == .some {
            showPlacement = true
        } else {
            openPaywall()
        }
    }

    private func openPaywall() {
        if store.tier >= .plus {
            dismiss()
        } else {
            PaywallPolicy.recordShown()
            showPaywall = true
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: Correction.self, inMemory: true)
        .environment(ProgressStore())
        .environment(ProStore())
        .environment(Wallet())
}
