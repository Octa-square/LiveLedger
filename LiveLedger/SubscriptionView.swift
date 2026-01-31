//
//  SubscriptionView.swift
//  LiveLedger
//
//  LiveLedger - Subscription Plans with StoreKit 2
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @ObservedObject var authManager: AuthManager
    /// When set, pre-selects this plan (e.g. from plan selection screen).
    var initialPlan: SubscriptionPlan? = nil
    /// Called when user completes a purchase or restore so the parent can advance (e.g. PlanSelectionView completes sign-up). Ensures Pro is only granted after Apple payment.
    var onPurchaseSuccess: (() -> Void)? = nil
    @StateObject private var storeKit = StoreKitManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedPlan: SubscriptionPlan = .yearly  // Default to best value
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var isRestoring = false
    @State private var showRestoreConfirm = false
    @State private var showRestoreSuccess = false
    @State private var showRestoreNoPurchases = false
    @State private var showRestoreError = false
    @State private var showPurchaseConfirm = false

    enum SubscriptionPlan {
        case free, monthly, yearly
    }
    
    // Dynamic success alert for new vs returning subscribers
    private var successAlertTitle: String {
        if authManager.currentUser?.isLapsedSubscriber == true {
            return "Welcome Back! 🎉"
        }
        return "Welcome to Pro! 🎉"
    }
    
    private var successAlertMessage: String {
        if authManager.currentUser?.isLapsedSubscriber == true {
            return "Your Pro subscription has been reactivated! Unlimited orders and all premium features are restored."
        }
        return "Your Pro subscription is now active. Enjoy unlimited orders and all premium features!"
    }

    private var purchaseConfirmMessage: String {
        let price = selectedPlan == .yearly
            ? (storeKit.proYearlyProduct?.displayPrice ?? "$179.99")
            : (storeKit.proMonthlyProduct?.displayPrice ?? "$19.99")
        let period = selectedPlan == .yearly ? "/year" : "/month"
        return "You will be charged \(price)\(period) through your Apple ID. The next screen will let you confirm or cancel the purchase."
    }

    @ViewBuilder private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange],
                                  startPoint: .top, endPoint: .bottom)
                )
            if authManager.currentUser?.isLapsedSubscriber == true {
                Text("Welcome Back!")
                    .font(.system(size: 28, weight: .bold))
                Text("Reactivate your Pro subscription")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("Upgrade to Pro")
                    .font(.system(size: 28, weight: .bold))
                Text("Unlock all features and grow your business")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top)
    }

    @ViewBuilder private var planOptionsSection: some View {
        VStack(spacing: 12) {
            SubscriptionOptionCard(
                title: "Yearly",
                price: storeKit.proYearlyProduct?.displayPrice ?? "$179.99",
                period: "/year",
                savings: "Best Value - Save $60",
                isSelected: selectedPlan == .yearly,
                isBestValue: true
            ) { selectedPlan = .yearly }
            SubscriptionOptionCard(
                title: "Monthly",
                price: storeKit.proMonthlyProduct?.displayPrice ?? "$19.99",
                period: "/month",
                savings: nil,
                isSelected: selectedPlan == .monthly,
                isBestValue: false
            ) { selectedPlan = .monthly }
            SubscriptionOptionCard(
                title: "Free",
                price: "$0",
                period: "",
                savings: "20 orders included",
                isSelected: selectedPlan == .free,
                isBestValue: false
            ) { selectedPlan = .free }
        }
        .padding(.horizontal)
    }

    @ViewBuilder private var proFeaturesSection: some View {
        if selectedPlan != .free {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pro includes:")
                    .font(.headline)
                    .padding(.bottom, 4)
                ProFeatureRow(icon: "infinity", text: "Unlimited orders")
                ProFeatureRow(icon: "square.and.arrow.up", text: "Unlimited CSV exports")
                ProFeatureRow(icon: "photo", text: "Product images")
                ProFeatureRow(icon: "headphones", text: "Priority support")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    @ViewBuilder private var subscribeActionsSection: some View {
        if selectedPlan != .free && authManager.currentUser?.isPro != true {
            VStack(spacing: 12) {
                Button {
                    showPurchaseConfirm = true
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Image(systemName: "crown.fill")
                            Text(selectedPlan == .yearly
                                ? "Subscribe - \(storeKit.proYearlyProduct?.displayPrice ?? "$179.99")/year"
                                : "Subscribe - \(storeKit.proMonthlyProduct?.displayPrice ?? "$19.99")/month")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.yellow, .orange],
                                      startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                }
                .disabled(isPurchasing || (selectedPlan == .yearly && storeKit.proYearlyProduct == nil) || (selectedPlan == .monthly && storeKit.proMonthlyProduct == nil))

                Text("Cancel anytime • Secure payment via Apple")
                    .font(.caption)
                    .foregroundColor(.gray)

                Button { dismiss() } label: {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)

                Button { showRestoreConfirm = true } label: {
                    HStack {
                        Text("Restore Purchases")
                            .font(.caption)
                            .foregroundColor(.blue)
                        if isRestoring {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isRestoring)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder private var continueFreeSection: some View {
        if selectedPlan == .free && !storeKit.subscriptionStatus.isActive {
            Button { dismiss() } label: {
                Text("Continue with Free Plan")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder private var manageSubscriptionSection: some View {
        if authManager.currentUser?.isPro == true {
            Button { openSubscriptionManagement() } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("Manage Subscription")
                }
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder private var whyProSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why Go Pro?")
                .font(.headline)
            WhyProRow(icon: "infinity", color: .blue,
                     title: "Unlimited Everything",
                     subtitle: "No limits on orders or exports. Scale your business freely.")
            WhyProRow(icon: "photo.stack", color: .purple,
                     title: "Product Images",
                     subtitle: "Add photos to products for easy identification during live sales.")
            WhyProRow(icon: "barcode.viewfinder", color: .green,
                     title: "Barcode Scanning",
                     subtitle: "Scan product barcodes with your camera for lightning-fast inventory and order entry.")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    @ViewBuilder private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Subscription automatically renews monthly unless cancelled at least 24 hours before the end of the current period. Manage your subscription in iOS Settings.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                Link("Terms of Service", destination: URL(string: "https://octa-square.github.io/LiveLedger/terms-of-service.html")!)
                    .font(.caption2)
                Link("Privacy Policy", destination: URL(string: "https://octa-square.github.io/LiveLedger/privacy-policy.html")!)
                    .font(.caption2)
            }
        }
        .padding()
    }

    @ViewBuilder private var scrollContent: some View {
        VStack(spacing: 24) {
            headerSection

            if authManager.currentUser?.isPro == true {
                CurrentSubscriptionBanner(expirationDate: storeKit.expirationDateString)
                    .padding(.horizontal)
            } else if authManager.currentUser?.isLapsedSubscriber == true {
                ExpiredSubscriptionBanner(
                    expirationDate: authManager.currentUser?.formattedExpirationDate,
                    remainingOrders: authManager.currentUser?.remainingFreeOrders ?? 0,
                    remainingExports: authManager.currentUser?.remainingFreeExports ?? 0
                )
                .padding(.horizontal)
            } else {
                BasicPlanBanner()
                    .padding(.horizontal)
            }

            planOptionsSection

            proFeaturesSection
            subscribeActionsSection
            continueFreeSection
            manageSubscriptionSection
            whyProSection
            termsSection

            Spacer(minLength: 30)
        }
    }

    private var navigationContent: some View {
        (
            ScrollView(.vertical, showsIndicators: true) {
                scrollContent
            }
        )
            .onAppear {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔍 PAYWALL:")
                print("Plan: \(selectedPlan)")
                print("StoreKit Active: \(storeKit.subscriptionStatus.isActive)")
                print("Auth Pro: \(authManager.currentUser?.isPro ?? false)")
                print("Monthly: \(storeKit.proMonthlyProduct?.displayPrice ?? "NIL")")
                print("Yearly: \(storeKit.proYearlyProduct?.displayPrice ?? "NIL")")
                print("Button Shows: \(selectedPlan != .free && authManager.currentUser?.isPro != true)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
            .navigationTitle("Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert(successAlertTitle, isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text(successAlertMessage)
            }
            .confirmationDialog("Confirm Subscription", isPresented: $showPurchaseConfirm, titleVisibility: .visible) {
                Button("Cancel", role: .cancel) {}
                Button("Continue to Payment") {
                    showPurchaseConfirm = false
                    Task { await purchaseSubscription() }
                }
            } message: {
                Text(purchaseConfirmMessage)
            }
            .confirmationDialog("Restore Purchases", isPresented: $showRestoreConfirm, titleVisibility: .visible) {
                Button("Cancel", role: .cancel) {}
                Button("OK") {
                    Task {
                        isRestoring = true
                        let result = await storeKit.restorePurchases()
                        isRestoring = false
                        #if os(iOS)
                        switch result {
                        case .success:
                            HapticManager.success()
                            authManager.upgradeToPro()
                            onPurchaseSuccess?()
                            showRestoreSuccess = true
                        case .noPurchases:
                            HapticManager.selection()
                            showRestoreNoPurchases = true
                        case .cancelled:
                            break
                        case .failed:
                            HapticManager.error()
                            showRestoreError = true
                        }
                        #endif
                    }
                }
            } message: {
                Text("Restore your Pro subscription from your Apple ID? You may be asked to sign in.")
            }
            .alert("Success", isPresented: $showRestoreSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your Pro subscription has been restored!")
            }
            .alert("No Purchases Found", isPresented: $showRestoreNoPurchases) {
                Button("OK") {}
            } message: {
                Text("We couldn't find any previous purchases for this Apple ID.")
            }
            .alert("Restore Failed", isPresented: $showRestoreError) {
                Button("OK") {}
            } message: {
                Text(storeKit.errorMessage ?? "Please try again or contact support.")
            }
            .onAppear {
                if let plan = initialPlan {
                    selectedPlan = plan
                }
                storeKit.markPaywallShown()
                print("📱 SubscriptionView appeared - paywall marked as shown")
            }
            .onDisappear {
                storeKit.resetPaywallState()
                print("📱 SubscriptionView disappeared - paywall state reset")
            }
    }

    var body: some View {
        NavigationStack {
            navigationContent
        }
    }
    
    // MARK: - Purchase Function
    private func purchaseSubscription() async {
        let product: StoreProduct?
        
        if selectedPlan == .yearly {
            product = storeKit.proYearlyProduct
        } else {
            product = storeKit.proMonthlyProduct
        }
        
        guard let product = product else {
            errorMessage = "Product not available. Please try again later."
            showError = true
            return
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            try await storeKit.purchase(product)
            // Update auth manager only after successful Apple purchase
            authManager.upgradeToPro()
            showSuccess = true
            // Dismiss paywall after brief delay so user sees success message, then complete plan selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onPurchaseSuccess?()
            }
        } catch PurchaseError.purchaseCancelled {
            // User cancelled, no error message needed
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    // MARK: - Open Subscription Management
    private func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Basic Plan Banner
struct BasicPlanBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Plan: Basic")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("20 orders included • Upgrade for unlimited orders and Pro features")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Current Subscription Banner
struct CurrentSubscriptionBanner: View {
    let expirationDate: String?
    
    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Pro Active")
                    .font(.headline)
                    .foregroundColor(.green)
                if let date = expirationDate {
                    Text("Renews \(date)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.title2)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Expired Subscription Banner
// This banner is shown to LAPSED subscribers (previously had Pro, now expired)
// Apple reviewers using review@liveledger.app will see this banner
struct ExpiredSubscriptionBanner: View {
    let expirationDate: String?
    let remainingOrders: Int
    let remainingExports: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Expired Status Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pro Subscription Expired")
                        .font(.headline)
                        .foregroundColor(.orange)
                    if let date = expirationDate {
                        Text("Expired on \(date)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "crown.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
            
            Divider()
            
            // Current Limits Status
            VStack(alignment: .leading, spacing: 6) {
                Text("You're now on the Free plan:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "cart.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("\(remainingOrders) orders left")
                            .font(.caption.bold())
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text("\(remainingExports) exports left")
                            .font(.caption.bold())
                    }
                }
            }
            
            // Resubscribe CTA
            Text("Resubscribe below to restore unlimited orders, exports, and all Pro features!")
                .font(.caption)
                .foregroundColor(.orange)
                .italic()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let features: [(icon: String, text: String, included: Bool)]
    let isSelected: Bool
    let isPro: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.title2.bold())
                        
                        if isPro {
                            Text("POPULAR")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(alignment: .bottom, spacing: 2) {
                        Text(price)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isPro ? .orange : .primary)
                        Text(period)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? (isPro ? .orange : .blue) : .gray)
            }
            
            Divider()
            
            // Features
            VStack(alignment: .leading, spacing: 10) {
                ForEach(features, id: \.text) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 12))
                            .foregroundColor(feature.included ? .green : .gray.opacity(0.5))
                            .frame(width: 16)
                        
                        Text(feature.text)
                            .font(.subheadline)
                            .foregroundColor(feature.included ? .primary : .gray.opacity(0.5))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isSelected ? (isPro ? Color.orange : Color.blue) : Color.gray.opacity(0.3),
                                     lineWidth: isSelected ? 2 : 1)
                )
        )
        .onTapGesture(perform: onSelect)
    }
}

struct WhyProRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Subscription Option Card
struct SubscriptionOptionCard: View {
    let title: String
    let price: String
    let period: String
    let savings: String?
    let isSelected: Bool
    let isBestValue: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .orange : .gray)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                    }
                    
                    if let savings = savings {
                        Text(savings)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing) {
                    Text(price)
                        .font(.title2.bold())
                        .foregroundColor(isSelected ? .orange : .primary)
                    if !period.isEmpty {
                        Text(period)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pro Feature Row
struct ProFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SubscriptionView(authManager: AuthManager())
}
