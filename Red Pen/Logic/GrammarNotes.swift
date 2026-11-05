//
//  GrammarNotes.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/4/26.
//

import Foundation

struct GrammarNote {
    let title: String
    let summary: String
    let examples: [String]
    let tip: String?
}

extension MistakeType {
    var note: GrammarNote? {
        switch self {
        case .particle:
            GrammarNote(
                title: String(localized: "Particles (조사)"),
                summary: String(localized: "Particles attach to the end of a word to show its role in the sentence. Many come in pairs: the first form goes after a consonant (받침), the second after a vowel."),
                examples: [
                    String(localized: "은/는 topic: 책은, 저는"),
                    String(localized: "이/가 subject: 학생이, 친구가"),
                    String(localized: "을/를 object: 밥을, 커피를"),
                    String(localized: "과/와 \"and\": 빵과, 우유와"),
                    String(localized: "으로/로 \"by, toward\": 집으로, 버스로"),
                ],
                tip: String(localized: "Look at the last syllable: if it has a 받침, use the first form."))

        case .speechLevel:
            GrammarNote(
                title: String(localized: "Speech levels (말투)"),
                summary: String(localized: "Korean changes the verb ending depending on who you're talking to."),
                examples: [
                    String(localized: "반말 (casual): close friends, younger people: 먹어"),
                    String(localized: "해요체 (polite): strangers, coworkers, most situations: 먹어요"),
                    String(localized: "합쇼체 (formal): presentations, news, customer service: 먹습니다"),
                ],
                tip: String(localized: "When unsure, use 해요체."))

        case .honorific:
            GrammarNote(
                title: String(localized: "Honorifics (높임말)"),
                summary: String(localized: "Separate from politeness: honorifics show respect to the person you're talking about, even if they're not the one listening."),
                examples: [
                    String(localized: "-시- in the verb: 가요 → 가세요, 했어요 → 하셨어요"),
                    String(localized: "Particles: 이/가 → 께서, 에게 → 께"),
                    String(localized: "Special verbs: 먹다 → 드시다, 자다 → 주무시다, 있다 → 계시다"),
                    String(localized: "Humble verbs, about yourself: 주다 → 드리다, 묻다 → 여쭤보다"),
                ],
                tip: String(localized: "Never use -시- about yourself: 제가 가세요 is wrong."))

        case .tense:
            GrammarNote(
                title: String(localized: "Tense (시제)"),
                summary: String(localized: "Korean marks tense in the verb ending."),
                examples: [
                    String(localized: "Past, 았/었/였: 갔어요, 먹었어요, 했어요"),
                    String(localized: "Present: 가요, 먹어요, 해요"),
                    String(localized: "Future, -(으)ㄹ 거예요: 갈 거예요, 먹을 거예요"),
                ],
                tip: String(localized: "Time words like 어제 (yesterday) and 내일 (tomorrow) must match the verb's tense."))

        case .spacing:
            GrammarNote(
                title: String(localized: "Spacing (띄어쓰기)"),
                summary: String(localized: "Korean separates words with spaces, but particles and verb endings attach to the word before them."),
                examples: [
                    String(localized: "Particles attach: 학교에, not 학교 에"),
                    String(localized: "수, 것, 때 are separate words: 할 수 있어요, 먹을 것, 갈 때"),
                    String(localized: "Numbers and counters: 한 개, 세 명"),
                ],
                tip: String(localized: "If it could stand alone as a word, it gets a space."))

        case .spelling:
            GrammarNote(
                title: String(localized: "Spelling (맞춤법)"),
                summary: String(localized: "Some forms sound almost the same but are written differently."),
                examples: [
                    String(localized: "되 / 돼: 돼요 is short for 되어요"),
                    String(localized: "안 / 않: 안 가요, but 가지 않아요"),
                ],
                tip: String(localized: "Swap in 하 / 해: where 해 fits, write 돼."))

        case .wordChoice:
            GrammarNote(
                title: String(localized: "Word choice (어휘)"),
                summary: String(localized: "The grammar was fine, but a native speaker would use a different word or phrase."),
                examples: [
                    String(localized: "사진을 찍다, not 사진을 하다"),
                    String(localized: "결정을 내리다, not 결정을 만들다"),
                ],
                tip: String(localized: "Learn verbs together with their nouns as one chunk."))

        case .other:
            nil
        }
    }
}
