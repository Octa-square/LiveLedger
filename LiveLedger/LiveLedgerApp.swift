//
//  LiveLedgerApp.swift
//  LiveLedger
//
//  Live Sales Tracker App - Auto-save on background
//

import SwiftUI

@main
struct LiveLedgerApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var localization = LocalizationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootView(authManager: authManager, localization: localization)
                .environmentObject(localization)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .background || newPhase == .inactive {
                        // Auto-save when app goes to background
                        NotificationCenter.default.post(name: .autoSaveData, object: nil)
                    }
                }
        }
    }
}

// Root view that switches between Auth, Onboarding, Plan Selection, and Main content
struct RootView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var hasSelectedPlan = UserDefaults.standard.bool(forKey: "hasSelectedPlan")
    
    var body: some View {
        if authManager.isAuthenticated {
            if hasCompletedOnboarding {
                if hasSelectedPlan || authManager.currentUser?.isPro == true {
                    // Main app - user has selected a plan or is already Pro (demo)
                    MainTabView(authManager: authManager, localization: localization)
                } else {
                    // Plan selection screen - shown after onboarding, before main app
                    PlanSelectionView(authManager: authManager, hasSelectedPlan: $hasSelectedPlan)
                }
            } else {
                OnboardingView(localization: localization, hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        } else {
            AuthView(authManager: authManager)
        }
    }
}

// MARK: - Plan Selection View (Shown before entering app)
struct PlanSelectionView: View {
    @ObservedObject var authManager: AuthManager
    @Binding var hasSelectedPlan: Bool
    @State private var selectedPlan: PlanType = .pro
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var showSubscribeConfirmation = false
    
    enum PlanType {
        case basic, pro
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Header - Compact
                    VStack(spacing: 8) {
                        // L² Logo - Smaller
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.05, green: 0.59, blue: 0.41), Color(red: 0.04, green: 0.47, blue: 0.34)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            HStack(alignment: .top, spacing: -2) {
                                Text("L")
                                    .font(.system(size: 30, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("²")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .baselineOffset(14)
                            }
                        }
                        
                        Text("Choose Your Plan")
                            .font(.system(size: 22, weight: .bold))
                        
                        Text("Select how you want to use LiveLedger")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    
                    // Plan Cards - Compact
                    VStack(spacing: 10) {
                        // Basic Plan Card
                        SelectablePlanCard(
                            title: "Basic",
                            price: "Free",
                            period: "forever",
                            description: "Great for getting started",
                            features: [
                                "First 20 orders free",
                                "Basic inventory management",
                                "10 CSV exports",
                                "Standard reports"
                            ],
                            limitations: [
                                "Limited orders",
                                "No advanced filters",
                                "No product images"
                            ],
                            isSelected: selectedPlan == .basic,
                            isPro: false
                        ) {
                            withAnimation { selectedPlan = .basic }
                        }
                        
                        // Pro Plan Card (Recommended)
                        SelectablePlanCard(
                            title: "Pro",
                            price: "$49.99",
                            period: "/month",
                            description: "Unlimited everything for serious sellers",
                            features: [
                                "Unlimited orders",
                                "Unlimited exports",
                                "Product images",
                                "Advanced analytics",
                                "Order filters",
                                "Priority support",
                                "All future features"
                            ],
                            limitations: [],
                            isSelected: selectedPlan == .pro,
                            isPro: true
                        ) {
                            withAnimation { selectedPlan = .pro }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Continue Button
                    Button {
                        Task {
                            await selectPlan()
                        }
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: selectedPlan == .pro ? .black : .white))
                            } else {
                                if selectedPlan == .pro {
                                    Image(systemName: "crown.fill")
                                }
                                Text(selectedPlan == .pro ? "Continue with Pro" : "Continue with Basic")
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(selectedPlan == .pro ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedPlan == .pro ?
                            LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color(hex: "00CC88"), Color(hex: "00AA77")], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isProcessing)
                    .padding(.horizontal)
                    
                    if selectedPlan == .pro {
                        Text("Cancel anytime • 7-day free trial")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Welcome to Pro! 🎉", isPresented: $showSuccess) {
                Button("Let's Go!") {
                    completePlanSelection()
                }
            } message: {
                Text("Your Pro subscription is now active. Enjoy unlimited orders and all premium features!")
            }
            .sheet(isPresented: $showSubscribeConfirmation) {
                subscriptionConfirmationSheet
            }
        }
    }
    
    // MARK: - Subscription Confirmation Sheet
    private var subscriptionConfirmationSheet: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("Upgrade to Pro")
                    .font(.title2.bold())
                
                Text("$49.99/month")
                    .font(.title3)
                    .foregroundColor(.orange)
            }
            .padding(.top, 30)
            
            // Benefits
            VStack(alignment: .leading, spacing: 10) {
                benefitRow(icon: "infinity", text: "Unlimited orders")
                benefitRow(icon: "photo.fill", text: "Product images")
                benefitRow(icon: "chart.bar.fill", text: "Advanced analytics")
                benefitRow(icon: "arrow.down.doc.fill", text: "Unlimited exports")
                benefitRow(icon: "star.fill", text: "Priority support")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            // Subscribe Button
            Button {
                Task {
                    await processSubscription()
                }
            } label: {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Image(systemName: "creditcard.fill")
                        Text("Subscribe Now")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            .padding(.horizontal)
            
            // Cancel Button
            Button {
                showSubscribeConfirmation = false
            } label: {
                Text("Maybe Later")
                    .foregroundColor(.gray)
            }
            .disabled(isProcessing)
            .padding(.bottom, 30)
        }
        .presentationDetents([.medium])
    }
    
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
        }
    }
    
    private func selectPlan() async {
        if selectedPlan == .basic {
            // Continue with Basic - no subscription needed
            completePlanSelection()
        } else {
            // Show subscription confirmation for Pro
            showSubscribeConfirmation = true
        }
    }
    
    private func processSubscription() async {
        isProcessing = true
        
        // Simulate subscription processing
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Upgrade to Pro
        authManager.upgradeToPro()
        
        // Play success sound
        SoundManager.shared.playOrderAddedSound()
        
        isProcessing = false
        showSuccess = true
    }
    
    private func completePlanSelection() {
        UserDefaults.standard.set(true, forKey: "hasSelectedPlan")
        hasSelectedPlan = true
    }
}

// MARK: - Selectable Plan Card
struct SelectablePlanCard: View {
    let title: String
    let price: String
    let period: String
    let description: String
    let features: [String]
    let limitations: [String]
    let isSelected: Bool
    let isPro: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - Compact
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                        
                        if isPro {
                            Text("BEST")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .cornerRadius(3)
                        }
                    }
                    
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack(alignment: .bottom, spacing: 1) {
                        Text(price)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isPro ? .orange : .primary)
                        Text(period)
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                    }
                }
            }
            
            Divider()
            
            // Features - Compact
            VStack(alignment: .leading, spacing: 3) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        
                        Text(feature)
                            .font(.system(size: 11))
                    }
                }
                
                // Limitations (for Basic)
                ForEach(limitations, id: \.self) { limitation in
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text(limitation)
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
            }
            
            // Selection indicator
            HStack {
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? (isPro ? .orange : .green) : .gray.opacity(0.5))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? (isPro ? Color.orange : Color.green) : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .shadow(color: isSelected ? (isPro ? Color.orange.opacity(0.3) : Color.green.opacity(0.3)) : Color.clear, radius: 10)
        )
        .onTapGesture(perform: onSelect)
    }
}

// Notification for auto-save
extension Notification.Name {
    static let autoSaveData = Notification.Name("autoSaveData")
}
