import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView {
            page(title: "Learn from every correction",
                 text: "When a Korean speaker fixes your sentence, save it in seconds.") {
                Image(systemName: "pencil.line")
                    .font(.system(size: 64))
                    .foregroundStyle(.red)
            }

            page(title: "Know what went wrong",
                 text: "Red Pen spots particle, speech level, and spacing mistakes, and shows the rule behind them.") {
                exampleCard
            }

            page(title: "Practice what you miss",
                 text: "A few minutes a day. Each mistake comes back right before you'd forget it.") {
                Image(systemName: "target")
                    .font(.system(size: 64))
                    .foregroundStyle(.red)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .safeAreaInset(edge: .bottom) {
            Button {
                dismiss()
            } label: {
                Text("Get started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
        }
    }

    private var exampleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("저는 학생가 아니에요")
                .strikethrough(color: .red)
                .foregroundStyle(.secondary)
            Text("저는 학생이 아니에요")
                .font(.headline)
            Label("Particle  가 → 이", systemImage: "link")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.red)
            Text("생 ends in a consonant (받침), so use 이")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }

    private func page<Visual: View>(title: String,
                                    text: String,
                                    @ViewBuilder visual: () -> Visual) -> some View {
        VStack(spacing: 24) {
            visual()
            Text(title)
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
            Text(text)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 60)
    }
}

#Preview {
    OnboardingView()
}
