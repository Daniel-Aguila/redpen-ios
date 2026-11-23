//
//  ProStore.swift
//  Red Pen
//
//  Created by Daniel Aguila on 11/20/26.
//

import Foundation
import StoreKit

@MainActor
@Observable
final class ProStore {
    enum Tier: Int, Comparable {
        case free, plus, pro
        static func < (a: Tier, b: Tier) -> Bool { a.rawValue < b.rawValue}
    }
    
    static let plusMonthly = "com.danielaguila.redpen.plus.monthly"
    static let plusYearly = "com.danielaguila.redpen.plus.yearly"
    static let plusLifetime = "com.danielaguila.redpen.plus.lifetime"
    nonisolated static let proMonthly = "com.danielaguila.redpen.pro.monthly"
    nonisolated static let proYearly = "com.danielaguila.redpen.pro.yearly"
    static let tangerinePacks: [String: Int] = [
        "com.danielaguila.redpen.tangerines.400": 400,
        "com.danielaguila.redpen.tangerines.2400": 2400,
        "com.danielaguila.redpen.tangerines.5500": 5500,
    ]
    
    nonisolated static let proIDs: Set<String> = [proMonthly, proYearly]
    static let plusIDs: Set<String> = [plusMonthly, plusYearly, plusLifetime]
    static let allIDs = proIDs.union(plusIDs).union(tangerinePacks.keys)
    
    private(set) var products: [Product] = []
    private(set) var tier: Tier = .free
    private(set) var isLoaded = false
    
    private var onTangerines: ((Int) -> Void)?
    private var updatesTask: Task<Void, Never>?
    
    func start(onTangerines: @escaping (Int) -> Void) async {
        guard updatesTask == nil else { return }
        self.onTangerines = onTangerines
        
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
        
        for await result in Transaction.unfinished {
            await handle(result)
        }

        await loadProducts()
        await refresh()
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.allIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("Loading products failed: \(error)")
        }
        
        isLoaded = true
    }
    
    func product(_ id: String) -> Product? {
        products.first { $0.id == id }
    }
    
    func refresh() async {
        var best: Tier = .free
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let t) = result, t.revocationDate == nil else { continue }
            if Self.proIDs.contains(t.productID) {
                best = .pro
            } else if Self.plusIDs.contains(t.productID) {
                best = max(best, .plus)
            }
        }
        tier = best
    }
    
    @discardableResult
    func purchase(_ product: Product) async throws -> Bool {
        switch try await product.purchase() {
        case .success(let verification):
            await handle(verification)
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }
    
    func restore() async {
        try? await AppStore.sync()
        await refresh()
    }
    
    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let signedType) = result else {
            return
        }
        if let amount = Self.tangerinePacks[signedType.productID], signedType.revocationDate == nil {
            onTangerines?(amount)
        }
        await signedType.finish()
        await refresh()
    }
}
