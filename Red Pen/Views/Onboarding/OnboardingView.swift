import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedTab") private var selectedTab = "practice"
    @State private var page = 0

    var body: some View {
        TabView(selection: $page) {
            welcomePage.tag(0)
            howItWorksPage.tag(1)
            startPage.tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(NotebookPaper())
        .safeAreaInset(edge: .bottom) {
            if page < 2 {
                Button {
                    withAnimation { page += 1 }
                } label: {
                    Text("Next").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
            }
        }
    }

    // Page 1: what it is
    private var welcomePage: some View {
        VStack(spacing: 20) {
            PageTitle(marked: "오답", rest: "노트", subtitle: "Your Korean mistake notebook")
            Text("When a Korean speaker corrects your sentence, save it here. Red Pen explains the mistake and turns it into practice.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            exampleCard
        }
        .padding(.bottom, 60)
    }

    // Page 2: the 3 steps, showing the real + button
    private var howItWorksPage: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("How it works")
                .font(.largeTitle.weight(.heavy))
            step(1, title: "Get corrected",
                 text: "Chat in Korean. When someone fixes your sentence, copy it.") {
                Image(systemName: "bubble.left.and.bubble.right.fill")
            }
            step(2, title: "Tap the red +",
                 text: "Paste what you wrote and the corrected version, then Save.") {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor, in: Circle())
            }
            step(3, title: "Practice a few minutes a day",
                 text: "Open the Practice tab and tap Start.") {
                Image(systemName: "target")
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 60)
    }

    // Page 3: choose how to start
    private var startPage: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
            Text("Try it first?")
                .font(.largeTitle.weight(.heavy))
            Text("Start with 3 example corrections to see how it works. You can delete them anytime.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            VStack(spacing: 12) {
                Button {
                    SampleData.insert(into: modelContext)
                    finish()
                } label: {
                    Text("Start with examples").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    finish()
                } label: {
                    Text("Start with an empty notebook").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 60)
    }

    private func finish() {
        selectedTab = "notebook"
        dismiss()
    }

    private func step<Icon: View>(_ n: Int, title: String, text: String,
                                  @ViewBuilder icon: () -> Icon) -> some View {
        HStack(alignment: .top, spacing: 16) {
            icon()
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(n). \(title)").font(.headline)
                Text(text).foregroundStyle(.secondary)
            }
        }
    }

    private var exampleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("저는 학생가 아니에요")
                .strikethrough(color: .accentColor)
                .foregroundStyle(.secondary)
            Text("저는 학생이 아니에요")
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
}

#Preview {
    OnboardingView()
        .modelContainer(for: Correction.self, inMemory: true)
}
