//
//  ProConsent.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/23/26.
//

import SwiftUI

enum ProConsent {
    static let key = "proDataConsent"
    static var agreed: Bool { UserDefaults.standard.bool(forKey: key) }
}

struct ProConsentSheet: View {
    var onAgree: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Before you continue")
                .font(.title2.bold())
            Text("To make this for you, Gochimi sends the text of your saved mistakes to our server. A third-party AI provider (Anthropic) writes the response and sends it back. We don't store your text.")
                .fixedSize(horizontal: false, vertical: true)
            Link("Privacy Policy", destination: URL(string: "https://gochimi.com/privacy")!)
                .font(.subheadline.bold())
            Spacer(minLength: 0)
            Button {
                onAgree()
                dismiss()
            } label: {
                Text("Continue").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color.gochiBlue)
            Button("Not now") { dismiss() }
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}

struct ProConsentGate: ViewModifier {
    @Binding var pending: (() -> Void)?

    func body(content: Content) -> some View {
        content.sheet(isPresented: Binding(
            get: { pending != nil },
            set: { if !$0 { pending = nil } }
        )) {
            ProConsentSheet {
                UserDefaults.standard.set(true, forKey: ProConsent.key)
                let run = pending
                pending = nil
                run?()
            }
        }
    }
}

extension View {
    func proConsent(_ pending: Binding<(() -> Void)?>) -> some View {
        modifier(ProConsentGate(pending: pending))
    }
}
