//
//  StoreKitManager.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/29/26.
//

import StoreKit
import SwiftUI

// Product IDs — must match exactly what you create in App Store Connect
enum TrackrProduct {
    static let lifetime = "com.Dylan-Choukalos.Trackr.lifetime"
    static let yearly   = "com.Dylan-Choukalos.Trackr.yearly"
    static let all      = [lifetime, yearly]
}

@Observable
@MainActor
final class StoreKitManager {
    static let shared = StoreKitManager()

    var products: [Product] = []
    var purchasedIDs: Set<String> = []
    var isLoading = false
    var purchaseError: String?

    var isPro: Bool { !purchasedIDs.isEmpty }

    var lifetimeProduct: Product? { products.first { $0.id == TrackrProduct.lifetime } }
    var yearlyProduct: Product?   { products.first { $0.id == TrackrProduct.yearly } }

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: TrackrProduct.all)
                .sorted { $0.price < $1.price }
            await refreshPurchasedStatus()
        } catch {
            purchaseError = "Could not load products: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshPurchasedStatus()
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Restore

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedStatus()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Status

    private func refreshPurchasedStatus() async {
        var active: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.revocationDate == nil {
                active.insert(transaction.productID)
            }
        }
        purchasedIDs = active
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await self.refreshPurchasedStatus()
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
