//
//  GochiAI.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/22/26.
//

import Foundation
import StoreKit

enum GochiAI {
    static let endpoint = URL(string: "https://gochimi-ai.gochimi.workers.dev")!

    enum AIError: LocalizedError {
        case notPro, dailyLimit, slowDown, failed

        var errorDescription: String? {
            switch self {
            case .notPro: String(localized: "This needs an active Pro plan.")
            case .dailyLimit: String(localized: "Gochi needs a rest. Try again tomorrow.")
            case .failed: String(localized: "Something went wrong. Check your connection and try again.")
            case .slowDown: String(localized: "Gochi is catching his breath. Try again in a minute.")
            }
        }
    }

    struct MistakeInput: Encodable {
        let original: String
        let corrected: String
        let type: String
        var talkingTo: String?
        var note: String?
    }

    private struct PracticeInput: Encodable { let mistakes: [MistakeInput] }
    private struct DiaryInput: Encodable { let text: String }

    struct Example: Codable, Hashable {
        let ko: String
        let translation: String
    }

    struct Explanation: Codable {
        let explanation: String
        let tip: String
        let examples: [Example]
    }

    struct Practice: Codable {
        struct Exercise: Codable, Hashable {
            let prompt: String
            let answer: String
            let hint: String
        }
        struct Story: Codable {
            let title: String
            let sentences: [Example]
        }
        let exercises: [Exercise]
        let story: Story
    }

    struct DiaryFix: Codable {
        struct Note: Codable, Hashable {
            let original: String
            let corrected: String
            let why: String
        }
        let corrected: String
        let notes: [Note]
    }

    static func explain(_ mistake: MistakeInput) async throws -> Explanation {
        try await send("explain", input: mistake)
    }

    static func practice(_ mistakes: [MistakeInput]) async throws -> Practice {
        try await send("practice", input: PracticeInput(mistakes: Array(mistakes.prefix(10))))
    }

    static func diary(_ text: String) async throws -> DiaryFix {
        try await send("diary", input: DiaryInput(text: String(text.prefix(1500))))
    }

    private struct FeedbackBody: Encodable {
        let transaction: String
        let vote: String
        let task: String
        let input: MistakeInput
        let output: Explanation
        let lang: String
    }

    static func sendFeedback(up: Bool, mistake: MistakeInput, explanation: Explanation) async {
        guard let jws = await proTransaction() else { return }
        var request = URLRequest(url: endpoint.appending(path: "feedback"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        request.httpBody = try? JSONEncoder().encode(
            FeedbackBody(transaction: jws, vote: up ? "up" : "down", task: "explain",
                         input: mistake, output: explanation, lang: languageCode)
        )
        _ = try? await URLSession.shared.data(for: request)
    }

    private struct Body<Input: Encodable>: Encodable {
        let transaction: String
        let task: String
        let input: Input
        let lang: String
    }

    private struct Envelope<Result: Decodable>: Decodable {
        let result: Result
    }

    private static func send<Input: Encodable, Result: Decodable>(_ task: String, input: Input) async throws -> Result {
        guard let jws = await proTransaction() else { throw AIError.notPro }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = task == "explain" ? 30 : 60
        request.httpBody = try JSONEncoder().encode(Body(transaction: jws, task: task, input: input, lang: languageCode))

        let (data, response) = try await URLSession.shared.data(for: request)
        #if DEBUG
        print("GochiAI", (response as? HTTPURLResponse)?.statusCode ?? 0, String(data: data, encoding: .utf8) ?? "")
        #endif
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
        case 200: break
        case 403: throw AIError.notPro
        case 429:
            throw String(data: data, encoding: .utf8)?.contains("slow_down") == true ? AIError.slowDown : AIError.dailyLimit
        default: throw AIError.failed
        }
        do {
            return try JSONDecoder().decode(Envelope<Result>.self, from: data).result
        } catch {
            throw AIError.failed
        }
    }

    private static func proTransaction() async -> String? {
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, ProStore.proIDs.contains(t.productID) {
                return result.jwsRepresentation
            }
        }
        return nil
    }

    static var languageCode: String {
        let lang = Locale.preferredLanguages.first ?? "en"
        if lang.hasPrefix("zh-Hant") || lang.hasPrefix("zh-TW") || lang.hasPrefix("zh-HK") { return "zh-Hant" }
        if lang.hasPrefix("zh") { return "zh-Hans" }
        return String(lang.prefix(2))
    }
}
