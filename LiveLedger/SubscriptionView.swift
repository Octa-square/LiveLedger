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
                VStack(spacing: 14) {
                    // Header (Compact)
                    VStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange],
                                              startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text("Upgrade to Pro")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Unlock all features and grow your business")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                    
                    // Current Status (if Pro)
                    if storeKit.subscriptionStatus.isActive {
                        CompactSubscriptionBanner(expirationDate: storeKit.expirationDateString)
                            .padding(.horizontal, 16)
                    }
                    
                    // Plan Cards (Compact)
                    VStack(spacing: 10) {
                        // Basic Plan
                        CompactPlanCard(
                            title: "Basic",
                            price: "Free",
                            period: "forever",
                            features: [
                                ("checkmark", "20 free orders", true),
                                ("checkmark", "Inventory management", true),
                                ("checkmark", "10 CSV exports", true),
                                ("xmark", "Order filters", false),
                                ("xmark", "Unlimited orders", false)
                            ],
                            isSelected: selectedPlan == .basic,
                            isPro: false
                        ) {
                            selectedPlan = .basic
                        }
                        
                        // Pro Plan
                        CompactPlanCard(
                            title: "Pro",
                            price: storeKit.proMonthlyProduct?.displayPrice ?? "$49.99",
                            period: "/mo",
                            features: [
                                ("checkmark", "Unlimited orders", true),
                                ("checkmark", "Order filters", true),
                                ("checkmark", "Unlimited exports", true),
                                ("checkmark", "Product images", true),
                                ("checkmark", "Barcode scanning", true)
                            ],
                            isSelected: selectedPlan == .pro,
                            isPro: true
                        ) {
                            selectedPlan = .pro
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Subscribe Button
                    if selectedPlan == .pro && !storeKit.subscriptionStatus.isActive {
                        VStack(spacing: 8) {
                            Button {
                                Task {
                                    await purchaseProSubscription()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 12))
                                        Text("Subscribe - \(storeKit.proMonthlyProduct?.displayPrice ?? "$49.99")/mo")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(colors: [.yellow, .orange],
                                                  startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(8)
                            }
                            .disabled(isPurchasing || storeKit.proMonthlyProduct == nil)
                            
                            if storeKit.proMonthlyProduct == nil {
                                Button {
                                    Task { await storeKit.loadProducts() }
                                } label: {
                                    Text("⚠️ Tap to load products")
                                        .font(.system(size: 10))
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            HStack(spacing: 16) {
                                Text("Cancel anytime")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                
                                Button {
                                    Task { await storeKit.restorePurchases() }
                                } label: {
                                    Text("Restore Purchases")
                                        .font(.system(size: 10))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Already Pro - Manage Subscription
                    if storeKit.subscriptionStatus.isActive {
                        Button {
                            openSubscriptionManagement()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "gear")
                                    .font(.system(size: 12))
                                Text("Manage Subscription")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Why Pro Section (Compact)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Why Go Pro?")
                            .font(.system(size: 14, weight: .bold))
                        
                        CompactWhyProRow(icon: "infinity", color: .blue,
                                        title: "Unlimited Everything",
                                        subtitle: "No limits on orders or exports")
                        
                        CompactWhyProRow(icon: "photo.stack", color: .purple,
                                        title: "Product Images",
                                        subtitle: "Add photos for easy identification")
                        
                        CompactWhyProRow(icon: "barcode", color: .green,
                                        title: "Barcode Support",
                                        subtitle: "Scan barcodes to find products")
                        
                        CompactWhyProRow(icon: "line.3.horizontal.decrease.circle", color: .orange,
                                        title: "Order Filters",
                                        subtitle: "Filter by platform and status")
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    // Terms (Compact)
                    VStack(spacing: 4) {
                        Text("Subscription renews monthly. Manage in iOS Settings.")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 12) {
                            Link("Terms", destination: URL(string: "https://octasquare.com/liveledger/terms")!)
                                .font(.system(size: 9))
                            Link("Privacy", destination: URL(string: "https://octasquare.com/liveledger/privacy")!)
                                .font(.system(size: 9))
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(.system(size: 14))
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
                Text("Your Pro subscription is now active!")
            }
        }
    }
    
    // MARK: - Purchase Function
    private func purchaseProSubscription() async {
        guard let product = storeKit.proMonthlyProduct else {
            errorMessage = "Product not available. Please try again."
            showError = true
            return
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            try await storeKit.purchase(product)
            authManager.upgradeToPro()
            showSuccess = true
        } catch PurchaseError.purchaseCancelled {
            // User cancelled
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Compact Subscription Banner
struct CompactSubscriptionBanner: View {
    let expirationDate: String?
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 14))
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Pro Active")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
                if let date = expirationDate {
                    Text("Renews \(date)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16))
                .foregroundColor(.green)
        }
        .padding(10)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Compact Plan Card
struct CompactPlanCard: View {
    let title: String
    let price: String
    let period: String
    let features: [(icon: String, text: String, included: Bool)]
    let isSelected: Bool
    let isPro: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                        
                        if isPro {
                            Text("POPULAR")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .cornerRadius(3)
                        }
                    }
                    
                    HStack(alignment: .bottom, spacing: 1) {
                        Text(price)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isPro ? .orange : .primary)
                        Text(period)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? (isPro ? .orange : .blue) : .gray)
            }
            
            Divider()
            
            // Features (Compact Grid)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(features, id: \.text) { feature in
                    HStack(spacing: 4) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 9))
                            .foregroundColor(feature.included ? .green : .gray.opacity(0.4))
                            .frame(width: 12)
                        
                        Text(feature.text)
                            .font(.system(size: 10))
                            .foregroundColor(feature.included ? .primary : .gray.opacity(0.4))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isSelected ? (isPro ? Color.orange : Color.blue) : Color.gray.opacity(0.3),
                                     lineWidth: isSelected ? 2 : 1)
                )
        )
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Compact Why Pro Row
struct CompactWhyProRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 26, height: 26)
                .background(color.opacity(0.15))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SubscriptionView(authManager: AuthManager())
}
