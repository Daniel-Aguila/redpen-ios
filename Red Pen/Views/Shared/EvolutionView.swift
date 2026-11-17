//
//  EvolutionView.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/16/26.
//

import SwiftUI

struct EvolutionView: View {
    let form: GochiForm
    
    @Environment(\.dismiss) private var dismiss
    @State private var showNew = false
    @State private var flash = false
    @State private var flips = 0
    
    private var previous: GochiForm { GochiForm(rawValue: form.rawValue - 1) ?? .bean}
    
    var body: some View {
        ZStack{
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 28){
                Spacer()
                Text(showNew ? "\(form.title)\(form.title.subjectParticle) 되었어요!" : "어...?")
                    .font(.largeTitle.weight(.heavy))
                    .contentTransition(.opacity)
                
                GochiView(xp: showNew ? form.minXP : previous.minXP, celebrate: flips)
                    .frame(height: 220)
                
                Text(showNew ? "Gochi grew into a new form" : " ")
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("좋아요!").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .opacity(showNew ? 1 : 0)
            }
            .padding(24)
            Color.white
                .ignoresSafeArea()
                .opacity(flash ? 1 : 0)
                .allowsHitTesting(false)
        }
        .sensoryFeedback(.success, trigger: showNew)
        .task {
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.easeIn(duration: 0.25)) { flash = true }
            try? await Task.sleep(for: .seconds(0.25))
            showNew = true
            withAnimation(.easeOut(duration: 0.6)) { flash = false }
            flips += 1
        }
    }
}

#Preview {
    EvolutionView(form: .sprout)
}
