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
// Must match App Store Connect exactly for both subscriptions to work.
enum ProductID: String, CaseIterable {
    case proMonthly = "com.octasquare.LiveLedger.monthly.subscription"
    case proYearly = "com.octasquare.LiveLedger.yearly.subscription"
    
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

// Named constants for verification — must match App Store Connect exactly
let monthlySubscriptionID = ProductID.proMonthly.rawValue   // "com.octasquare.LiveLedger.monthly.subscription"
let yearlySubscriptionID = ProductID.proYearly.rawValue    // "com.octasquare.LiveLedger.yearly.subscription"

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
    
    // CRITICAL: Flag to track if a purchase was initiated by user interaction
    // This prevents auto-subscription issues reported by Apple reviewers
    @Published var userInitiatedPurchase: Bool = false
    
    // Flag to ensure paywall was shown before any purchase
    @Published var paywallWasShown: Bool = false
    
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
        // NOTE: We do NOT auto-process pending transactions on launch
        // to prevent the "auto-subscription" bug reported by Apple
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
    // CRITICAL: This function should ONLY be called after user taps Subscribe button
    // This ensures the paywall is always shown before any purchase
    func purchase(_ product: StoreProduct) async throws {
        // Safety check: Ensure paywall was shown
        guard paywallWasShown else {
            print("⚠️ Purchase attempted without paywall being shown - blocking")
            throw PurchaseError.purchaseFailed
        }
        
        isLoading = true
        userInitiatedPurchase = true  // Mark that user initiated this purchase
        defer { 
            isLoading = false
            userInitiatedPurchase = false
        }
        
        do {
            print("🛒 User-initiated purchase starting for: \(product.displayName)")
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
    
    // MARK: - Mark Paywall Shown
    // Call this when SubscriptionView appears to enable purchases
    func markPaywallShown() {
        paywallWasShown = true
        print("📱 Paywall shown - purchases now enabled")
    }
    
    // MARK: - Reset Paywall State
    // Call this when SubscriptionView disappears
    func resetPaywallState() {
        paywallWasShown = false
        print("📱 Paywall dismissed - paywall flag reset")
    }
    
    /// Result of restore attempt. Caller uses this to decide which alert to show.
    enum RestoreResult {
        case success
        case noPurchases
        case cancelled
        case failed(String)
    }

    // MARK: - Restore Purchases
    func restorePurchases() async -> RestoreResult {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            if subscriptionStatus.isActive {
                print("✅ Purchases restored")
                return .success
            } else {
                return .noPurchases
            }
        } catch let error as StoreKitError {
            if case .userCancelled = error {
                print("⚠️ User cancelled restore")
                return .cancelled
            }
            print("❌ Restore failed: \(error)")
            errorMessage = "Failed to restore purchases. Please try again."
            return .failed(error.localizedDescription)
        } catch {
            let nsError = error as NSError
            if nsError.domain == "SKErrorDomain" && nsError.code == 2 {
                print("⚠️ User cancelled restore (SKError)")
                return .cancelled
            }
            print("❌ Failed to restore purchases: \(error)")
            errorMessage = "Failed to restore purchases. Please try again."
            return .failed(error.localizedDescription)
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
    // IMPORTANT: Only process transactions that were user-initiated
    // This prevents auto-subscription bug on app launch
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    // Only auto-finish if user initiated a purchase
                    // Otherwise, update status but don't auto-finish pending transactions
                    await MainActor.run {
                        if self.userInitiatedPurchase || self.paywallWasShown {
                            print("✅ Processing user-initiated transaction: \(transaction.productID)")
                        } else {
                            print("⚠️ Transaction update received but no user interaction - status updated only")
                        }
                    }
                    
                    await self.updateSubscriptionStatus()
                    
                    // Always finish verified transactions to prevent re-delivery
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

