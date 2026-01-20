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
    @StateObject private var storeKit = StoreKitManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass  // iPad detection
    @State private var selectedPlan: SubscriptionPlan = .yearly  // Default to best value
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header - Different messaging for lapsed vs new subscribers
                    // Apple reviewers using review@liveledger.app will see "Welcome Back!" header
                    VStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange],
                                              startPoint: .top, endPoint: .bottom)
                            )
                        
                        // Show "Welcome Back!" for lapsed subscribers, "Upgrade to Pro" for new users
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
                    
                    // Current Status (if Pro)
                    if storeKit.subscriptionStatus.isActive {
                        CurrentSubscriptionBanner(
                            expirationDate: storeKit.expirationDateString
                        )
                        .padding(.horizontal)
                    }
                    
                    // EXPIRED SUBSCRIPTION BANNER (for lapsed subscribers)
                    // Apple reviewers using review@liveledger.app will see this banner
                    if authManager.currentUser?.isLapsedSubscriber == true {
                        ExpiredSubscriptionBanner(
                            expirationDate: authManager.currentUser?.formattedExpirationDate,
                            remainingOrders: authManager.currentUser?.remainingFreeOrders ?? 0,
                            remainingExports: authManager.currentUser?.remainingFreeExports ?? 0
                        )
                        .padding(.horizontal)
                    }
                    
                    // PLAN CARDS: Basic (Free) and Pro (with Monthly/Yearly grid inside)
                    VStack(spacing: 12) {
                        // BASIC (FREE) PLAN CARD
                        BasicPlanCard(
                            isSelected: selectedPlan == .free,
                            onSelect: { selectedPlan = .free }
                        )
                        
                        // PRO PLAN CARD (contains Monthly/Yearly grid inside)
                        ProPlanCard(
                            selectedDuration: selectedPlan == .yearly ? .yearly : .monthly,
                            isProSelected: selectedPlan != .free,
                            monthlyPrice: storeKit.proMonthlyProduct?.displayPrice ?? "$19.99",
                            yearlyPrice: storeKit.proYearlyProduct?.displayPrice ?? "$189.99",
                            onSelectMonthly: { selectedPlan = .monthly },
                            onSelectYearly: { selectedPlan = .yearly }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Subscribe Button (only when Pro is selected)
                    if selectedPlan != .free && !storeKit.subscriptionStatus.isActive {
                        VStack(spacing: 12) {
                            Button {
                                Task {
                                    await purchaseSubscription()
                                }
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Image(systemName: "crown.fill")
                                        Text("Continue with Pro")
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
                            
                            // Restore Purchases
                            Button {
                                Task {
                                    await storeKit.restorePurchases()
                                }
                            } label: {
                                Text("Restore Purchases")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Continue with Free
                    if selectedPlan == .free && !storeKit.subscriptionStatus.isActive {
                        Button {
                            dismiss()
                        } label: {
                            Text("Continue with Free Plan")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Already Pro - Manage Subscription
                    if storeKit.subscriptionStatus.isActive {
                        Button {
                            openSubscriptionManagement()
                        } label: {
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
                    
                    // Why Pro Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Why Go Pro?")
                            .font(.headline)
                        
                        WhyProRow(icon: "infinity", color: .blue,
                                 title: "Unlimited Everything",
                                 subtitle: "No limits on orders or exports. Scale your business freely.")
                        
                        WhyProRow(icon: "photo.stack", color: .purple,
                                 title: "Product Images",
                                 subtitle: "Add photos to products for easy identification during live sales.")
                        
                        WhyProRow(icon: "barcode", color: .green,
                                 title: "Barcode Support",
                                 subtitle: "Scan barcodes to quickly find and add products.")
                        
                        WhyProRow(icon: "headphones", color: .orange,
                                 title: "Priority Support",
                                 subtitle: "Get faster responses and dedicated help when you need it.")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Terms
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
                    
                    // CRITICAL: "Maybe Later" dismiss button for iPad accessibility
                    // Apple requires a clear way to dismiss the paywall on iPad
                    Button("Maybe Later") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)  // Constrain width on iPad
            .navigationTitle("Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
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
            // CRITICAL: Mark paywall as shown when view appears
            // This prevents auto-subscription bug reported by Apple
            .onAppear {
                storeKit.markPaywallShown()
                print("📱 SubscriptionView appeared - paywall marked as shown")
            }
            .onDisappear {
                storeKit.resetPaywallState()
                print("📱 SubscriptionView disappeared - paywall state reset")
            }
        }
    }
    
    // MARK: - Purchase Function
    private func purchaseSubscription() async {
        // Debug logging for Apple review troubleshooting
        let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
        print("🔍 Purchase initiated - Device: \(deviceType), Plan: \(selectedPlan), Paywall shown: \(storeKit.paywallWasShown)")
        
        let product: StoreProduct?
        
        if selectedPlan == .yearly {
            product = storeKit.proYearlyProduct
        } else {
            product = storeKit.proMonthlyProduct
        }
        
        guard let product = product else {
            print("❌ Purchase failed: Product not available")
            errorMessage = "Product not available. Please try again later."
            showError = true
            return
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            try await storeKit.purchase(product)
            // Update auth manager
            authManager.upgradeToPro()
            print("✅ Purchase completed successfully - Plan: \(selectedPlan)")
            showSuccess = true
        } catch PurchaseError.purchaseCancelled {
            print("ℹ️ Purchase cancelled by user")
            // User cancelled, no error message needed
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
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

// MARK: - Basic (Free) Plan Card
struct BasicPlanCard: View {
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Basic")
                            .font(.title2.bold())
                        Text("Great for getting started")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Free")
                            .font(.title2.bold())
                        Text("forever")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRowItem(icon: "checkmark.circle.fill", text: "First 20 orders free", included: true)
                    FeatureRowItem(icon: "checkmark.circle.fill", text: "Basic inventory management", included: true)
                    FeatureRowItem(icon: "checkmark.circle.fill", text: "10 CSV exports", included: true)
                    FeatureRowItem(icon: "checkmark.circle.fill", text: "Standard reports", included: true)
                    FeatureRowItem(icon: "xmark.circle.fill", text: "Limited orders", included: false)
                    FeatureRowItem(icon: "xmark.circle.fill", text: "No product images", included: false)
                    FeatureRowItem(icon: "xmark.circle.fill", text: "No barcode scanning", included: false)
                }
                
                // Selection indicator
                HStack {
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .gray.opacity(0.4))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pro Plan Card (with Monthly/Yearly grid inside)
struct ProPlanCard: View {
    enum Duration { case monthly, yearly }
    
    let selectedDuration: Duration
    let isProSelected: Bool
    let monthlyPrice: String
    let yearlyPrice: String
    let onSelectMonthly: () -> Void
    let onSelectYearly: () -> Void
    
    // Calculate equivalent monthly price for yearly plan
    private var yearlyMonthlyEquivalent: String {
        // $189.99/12 ≈ $15.83
        if let yearlyValue = Double(yearlyPrice.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) {
            let monthly = yearlyValue / 12
            return String(format: "$%.2f", monthly)
        }
        return "$15.83"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Pro")
                            .font(.title2.bold())
                        
                        Text("BEST")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                    Text("Monthly or Yearly • Save 20% with annual")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("From \(yearlyMonthlyEquivalent)")
                        .font(.title3.bold())
                        .foregroundColor(.orange)
                    Text("/month")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // PRO FEATURES
            VStack(alignment: .leading, spacing: 8) {
                FeatureRowItem(icon: "checkmark.circle.fill", text: "Unlimited orders", included: true, highlight: true)
                FeatureRowItem(icon: "checkmark.circle.fill", text: "Unlimited exports", included: true, highlight: true)
                FeatureRowItem(icon: "checkmark.circle.fill", text: "Product images", included: true, highlight: true)
                FeatureRowItem(icon: "checkmark.circle.fill", text: "Barcode scanning", included: true, highlight: true)
                FeatureRowItem(icon: "checkmark.circle.fill", text: "Priority support", included: true, highlight: true)
                FeatureRowItem(icon: "checkmark.circle.fill", text: "All future features", included: true, highlight: true)
            }
            
            // MONTHLY/YEARLY SELECTION GRID (2 options side by side)
            HStack(spacing: 12) {
                // Monthly Option
                DurationOptionButton(
                    title: "Monthly",
                    price: monthlyPrice,
                    period: "/month",
                    savingsBadge: nil,
                    isSelected: isProSelected && selectedDuration == .monthly,
                    onSelect: onSelectMonthly
                )
                
                // Yearly Option
                DurationOptionButton(
                    title: "Yearly",
                    price: yearlyPrice,
                    period: "/year",
                    savingsBadge: "Save 20%",
                    isSelected: isProSelected && selectedDuration == .yearly,
                    onSelect: onSelectYearly
                )
            }
            .padding(.top, 4)
            
            // Selection indicator
            HStack {
                Spacer()
                Image(systemName: isProSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isProSelected ? .orange : .gray.opacity(0.4))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isProSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: isProSelected ? 2 : 1)
                )
        )
    }
}

// MARK: - Duration Option Button (for Monthly/Yearly selection inside Pro card)
struct DurationOptionButton: View {
    let title: String
    let price: String
    let period: String
    let savingsBadge: String?
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                // Title + Badge
                HStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    if let badge = savingsBadge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(3)
                    }
                }
                
                // Price
                Text(price)
                    .font(.title3.bold())
                    .foregroundColor(isSelected ? .orange : .primary)
                
                Text(period)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feature Row Item
struct FeatureRowItem: View {
    let icon: String
    let text: String
    let included: Bool
    var highlight: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(included ? .green : .gray.opacity(0.5))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(included ? (highlight ? .primary : .primary) : .gray.opacity(0.5))
        }
    }
}

#Preview {
    SubscriptionView(authManager: AuthManager())
}
