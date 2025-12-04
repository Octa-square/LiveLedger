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
    @State private var selectedPlan: Plan = .pro
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    enum Plan {
        case basic, pro
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange],
                                              startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text("Upgrade to Pro")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Unlock all features and grow your business")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Current Status (if Pro)
                    if storeKit.subscriptionStatus.isActive {
                        CurrentSubscriptionBanner(
                            expirationDate: storeKit.expirationDateString
                        )
                        .padding(.horizontal)
                    }
                    
                    // Plan Cards
                    VStack(spacing: 16) {
                        // Basic Plan
                        PlanCard(
                            title: "Basic",
                            price: "Free",
                            period: "forever",
                            features: [
                                ("checkmark", "First 20 orders free", true),
                                ("checkmark", "Choose your currency", true),
                                ("checkmark", "Inventory management", true),
                                ("checkmark", "Basic reports", true),
                                ("checkmark", "10 CSV exports", true),
                                ("xmark", "Order filters", false),
                                ("xmark", "Product images", false),
                                ("xmark", "Barcode scanning", false),
                                ("xmark", "Unlimited orders", false),
                                ("xmark", "Unlimited exports", false),
                                ("xmark", "Priority support", false)
                            ],
                            isSelected: selectedPlan == .basic,
                            isPro: false
                        ) {
                            selectedPlan = .basic
                        }
                        
                        // Pro Plan
                        PlanCard(
                            title: "Pro",
                            price: storeKit.proMonthlyProduct?.displayPrice ?? "$49.99",
                            period: "/month",
                            features: [
                                ("checkmark", "Unlimited orders", true),
                                ("checkmark", "Order filters (platform & price)", true),
                                ("checkmark", "Choose your currency", true),
                                ("checkmark", "Advanced inventory", true),
                                ("checkmark", "Advanced analytics", true),
                                ("checkmark", "Unlimited CSV exports", true),
                                ("checkmark", "Product images", true),
                                ("checkmark", "Barcode scanning", true),
                                ("checkmark", "Multi-platform insights", true),
                                ("checkmark", "Priority support", true)
                            ],
                            isSelected: selectedPlan == .pro,
                            isPro: true
                        ) {
                            selectedPlan = .pro
                        }
                    }
                    .padding(.horizontal)
                    
                    // Subscribe Button
                    if selectedPlan == .pro && !storeKit.subscriptionStatus.isActive {
                        VStack(spacing: 12) {
                            Button {
                                Task {
                                    await purchaseProSubscription()
                                }
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Image(systemName: "crown.fill")
                                        Text("Subscribe to Pro - \(storeKit.proMonthlyProduct?.displayPrice ?? "$49.99")/mo")
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
                            .disabled(isPurchasing || storeKit.proMonthlyProduct == nil)
                            
                            // Show if product not loaded
                            if storeKit.proMonthlyProduct == nil {
                                VStack(spacing: 8) {
                                    Text("⚠️ Products not loaded")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    
                                    Button {
                                        Task {
                                            await storeKit.loadProducts()
                                        }
                                    } label: {
                                        Text("Tap to Retry")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            } else {
                                Text("Cancel anytime in Settings")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
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
                        
                        WhyProRow(icon: "line.3.horizontal.decrease.circle", color: .orange,
                                 title: "Order Filters",
                                 subtitle: "Filter orders by platform and discount status for better insights.")
                        
                        WhyProRow(icon: "chart.line.uptrend.xyaxis", color: .pink,
                                 title: "Advanced Analytics",
                                 subtitle: "Deep insights into sales trends, top products, and more.")
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
                            Link("Terms of Service", destination: URL(string: "https://octasquare.com/liveledger/terms")!)
                                .font(.caption2)
                            Link("Privacy Policy", destination: URL(string: "https://octasquare.com/liveledger/privacy")!)
                                .font(.caption2)
                        }
                    }
                    .padding()
                    
                    Spacer(minLength: 30)
                }
            }
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
            .alert("Welcome to Pro! 🎉", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your Pro subscription is now active. Enjoy unlimited orders and all premium features!")
            }
        }
    }
    
    // MARK: - Purchase Function
    private func purchaseProSubscription() async {
        guard let product = storeKit.proMonthlyProduct else {
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
            showSuccess = true
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

#Preview {
    SubscriptionView(authManager: AuthManager())
}
