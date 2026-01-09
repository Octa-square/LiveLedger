//
//  StoreKitManager.swift
//  LiveLedger
//
//  LiveLedger - StoreKit 2 Subscription Management
//

import StoreKit
import SwiftUI
import Combine

// Type alias to avoid conflict with app's Product model
typealias StoreProduct = StoreKit.Product

// MARK: - Product Identifiers
enum ProductID: String, CaseIterable {
    case proMonthly = "com.octasquare.liveledger.pro.monthly"
    case proYearly = "com.octasquare.liveledger.pro.yearly"
    
    var displayName: String {
        switch self {
        case .proMonthly: return "Pro Monthly"
        case .proYearly: return "Pro Yearly"
        }
    }
    
    var isYearly: Bool {
        self == .proYearly
    }
}

// MARK: - Purchase Error
enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case purchaseCancelled
    case purchasePending
    case verificationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found. Please try again later."
        case .purchaseFailed: return "Purchase failed. Please try again."
        case .purchaseCancelled: return "Purchase was cancelled."
        case .purchasePending: return "Purchase is pending approval."
        case .verificationFailed: return "Could not verify purchase. Please contact support."
        case .unknown: return "An unknown error occurred."
        }
    }
}

// MARK: - Subscription Status
enum SubscriptionStatus: Equatable {
    case notSubscribed
    case subscribed(expirationDate: Date)
    case expired
    case inGracePeriod(expirationDate: Date)
    
    var isActive: Bool {
        switch self {
        case .subscribed, .inGracePeriod:
            return true
        case .notSubscribed, .expired:
            return false
        }
    }
}

// MARK: - StoreKit Manager
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published private(set) var products: [StoreProduct] = []
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    private var isPreviewMode: Bool = false
    
    init(isPreviewMode: Bool = false) {
        self.isPreviewMode = isPreviewMode
        
        // Skip StoreKit in preview mode
        guard !isPreviewMode else {
            print("⚠️ StoreKitManager in preview mode - skipping initialization")
            return
        }
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load products and check subscription status
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs: Set<String> = Set(ProductID.allCases.map { $0.rawValue })
            let storeProducts = try await StoreProduct.products(for: productIDs)
            products = Array(storeProducts)
            print("✅ Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
            errorMessage = "Failed to load products. Please check your connection."
        }
    }
    
    // MARK: - Purchase Product
    func purchase(_ product: StoreProduct) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                // Update subscription status
                await updateSubscriptionStatus()
                
                // Finish the transaction
                await transaction.finish()
                
                print("✅ Purchase successful!")
                
            case .userCancelled:
                throw PurchaseError.purchaseCancelled
                
            case .pending:
                throw PurchaseError.purchasePending
                
            @unknown default:
                throw PurchaseError.unknown
            }
        } catch let error as PurchaseError {
            errorMessage = error.localizedDescription
            throw error
        } catch {
            print("❌ Purchase failed: \(error)")
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw PurchaseError.purchaseFailed
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("✅ Purchases restored")
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            errorMessage = "Failed to restore purchases. Please try again."
        }
    }
    
    // MARK: - Update Subscription Status
    func updateSubscriptionStatus() async {
        var foundActiveSubscription = false
        
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check both monthly and yearly subscriptions
                if transaction.productID == ProductID.proMonthly.rawValue ||
                   transaction.productID == ProductID.proYearly.rawValue {
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            // Check if in grace period (billing retry)
                            if transaction.revocationDate == nil {
                                subscriptionStatus = .subscribed(expirationDate: expirationDate)
                                foundActiveSubscription = true
                            }
                        }
                    }
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        if !foundActiveSubscription {
            // Check if previously subscribed (for expired status)
            let wasSubscribed = UserDefaults.standard.bool(forKey: "was_pro_subscriber")
            subscriptionStatus = wasSubscribed ? .expired : .notSubscribed
        } else {
            // Mark that user has subscribed before
            UserDefaults.standard.set(true, forKey: "was_pro_subscriber")
        }
        
        // Sync with AuthManager
        await syncWithAuthManager()
    }
    
    // MARK: - Sync with AuthManager
    private func syncWithAuthManager() async {
        // Update the user's pro status in AuthManager
        NotificationCenter.default.post(
            name: .subscriptionStatusChanged,
            object: nil,
            userInfo: ["isPro": subscriptionStatus.isActive]
        )
    }
    
    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("❌ Transaction update failed verification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Get Pro Products
    var proMonthlyProduct: StoreProduct? {
        products.first { $0.id == ProductID.proMonthly.rawValue }
    }
    
    var proYearlyProduct: StoreProduct? {
        products.first { $0.id == ProductID.proYearly.rawValue }
    }
    
    // MARK: - Format Price
    func formattedPrice(for product: StoreProduct) -> String {
        product.displayPrice
    }
    
    // MARK: - Subscription Expiration Date
    var expirationDateString: String? {
        switch subscriptionStatus {
        case .subscribed(let date), .inGracePeriod(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        default:
            return nil
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}

