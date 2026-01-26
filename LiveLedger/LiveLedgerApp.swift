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
    
    init() {
        // DEBUG: Reset all data on simulator launch for fresh testing
        #if targetEnvironment(simulator)
        resetForSimulator()
        #endif
    }
    
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
            // NOTE: Do NOT use .frame(minWidth:minHeight:) here as it prevents
            // iPad Split View/Slide Over from resizing the window properly.
            // The adaptive layout in MainTabView handles all window sizes.
        }
        // NOTE: .defaultSize is macOS only - removed for iOS compatibility
    }
    
    /// Clears all app data for fresh simulator testing
    private func resetForSimulator() {
        let defaults = UserDefaults.standard
        
        // Clear all UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
        
        // Clear specific keys
        defaults.removeObject(forKey: "hasCompletedOnboarding")
        defaults.removeObject(forKey: "hasSelectedPlan")
        defaults.removeObject(forKey: "currentUser")
        defaults.removeObject(forKey: "allAccounts")
        defaults.removeObject(forKey: "savedProducts")
        defaults.removeObject(forKey: "savedOrders")
        defaults.removeObject(forKey: "selectedTheme")
        defaults.removeObject(forKey: "overlay_position_x")
        defaults.removeObject(forKey: "overlay_position_y")
        defaults.synchronize()
        
        print("🔄 Simulator: All data cleared for fresh start")
    }
}

// Root view that switches between Auth, Onboarding, Plan Selection, and Main content
struct RootView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var hasSelectedPlan = UserDefaults.standard.bool(forKey: "hasSelectedPlan")
    @State private var showWelcome = false
    
    var body: some View {
        Group {
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
        .onChange(of: authManager.isAuthenticated) { _, isAuth in
            if isAuth {
                // Refresh flags when user authenticates
                hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                hasSelectedPlan = UserDefaults.standard.bool(forKey: "hasSelectedPlan")
                
                // Show welcome for new users
                if !hasCompletedOnboarding {
                    showWelcome = true
                }
            }
        }
        .alert("Welcome to LiveLedger! 🎉", isPresented: $showWelcome) {
            Button("Let's Get Started!") { }
        } message: {
            Text("Thanks for joining! Let us show you around the app.")
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
                                "No product images",
                                "No barcode scanning"
                            ],
                            isSelected: selectedPlan == .basic,
                            isPro: false
                        ) {
                            withAnimation { selectedPlan = .basic }
                        }
                        
                        // Pro Plan Card (Recommended) - Shows starting price, full options in next screen
                        SelectablePlanCard(
                            title: "Pro",
                            price: "From $15.83",
                            period: "/month",
                            description: "Monthly or Yearly • Save 20% with annual",
                            features: [
                                "Unlimited orders",
                                "Unlimited exports",
                                "Product images",
                                "Barcode scanning",
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
                        Text("Cancel anytime • Secure payment via Apple")
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
    // Shows both Monthly and Yearly subscription options
    private var subscriptionConfirmationSheet: some View {
        SubscriptionConfirmationContent(
            isProcessing: isProcessing,
            onSubscribeMonthly: {
                Task {
                    await processSubscription(isYearly: false)
                }
            },
            onSubscribeYearly: {
                Task {
                    await processSubscription(isYearly: true)
                }
            },
            onDismiss: {
                showSubscribeConfirmation = false
            }
        )
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
    
    private func processSubscription(isYearly: Bool) async {
        isProcessing = true
        
        // Log which plan was selected
        print("📱 Processing subscription: \(isYearly ? "Yearly ($189.99/year)" : "Monthly ($19.99/month)")")
        
        // Simulate subscription processing
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Upgrade to Pro
        authManager.upgradeToPro()
        
        // Play success sound
        SoundManager.shared.playOrderAddedSound()
        
        isProcessing = false
        showSubscribeConfirmation = false
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

// MARK: - Subscription Confirmation Content
// Compact layout with Monthly/Yearly subscription options
struct SubscriptionConfirmationContent: View {
    let isProcessing: Bool
    let onSubscribeMonthly: () -> Void
    let onSubscribeYearly: () -> Void
    let onDismiss: () -> Void
    
    @State private var selectedPlan: SubscriptionPlan = .yearly  // Default to yearly (best value)
    
    enum SubscriptionPlan {
        case monthly, yearly
        
        var price: String {
            switch self {
            case .monthly: return "$19.99"
            case .yearly: return "$189.99"
            }
        }
        
        var period: String {
            switch self {
            case .monthly: return "/month"
            case .yearly: return "/year"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // X button row
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                .disabled(isProcessing)
                .padding(.trailing, 16)
                .padding(.top, 8)
            }
            
            // Header
            VStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.yellow)
                
                Text("Upgrade to Pro")
                    .font(.title3.bold())
            }
            
            // SUBSCRIPTION OPTIONS - Monthly vs Yearly
            VStack(spacing: 8) {
                // Yearly Option (Best Value)
                SubscriptionOptionRow(
                    title: "Yearly",
                    price: "$189.99",
                    period: "/year",
                    savingsText: "Save 20%",
                    isSelected: selectedPlan == .yearly,
                    isBestValue: true
                ) {
                    selectedPlan = .yearly
                }
                
                // Monthly Option
                SubscriptionOptionRow(
                    title: "Monthly",
                    price: "$19.99",
                    period: "/month",
                    savingsText: nil,
                    isSelected: selectedPlan == .monthly,
                    isBestValue: false
                ) {
                    selectedPlan = .monthly
                }
            }
            .padding(.horizontal)
            
            // Benefits - Compact
            VStack(alignment: .leading, spacing: 4) {
                compactBenefitRow(icon: "infinity", text: "Unlimited orders")
                compactBenefitRow(icon: "arrow.down.doc.fill", text: "Unlimited exports")
                compactBenefitRow(icon: "photo.fill", text: "Product images")
                compactBenefitRow(icon: "barcode.viewfinder", text: "Barcode scanning")
                compactBenefitRow(icon: "star.fill", text: "Priority support")
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Subscribe Button - Shows selected plan price
            Button {
                if selectedPlan == .yearly {
                    onSubscribeYearly()
                } else {
                    onSubscribeMonthly()
                }
            } label: {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Image(systemName: "creditcard.fill")
                        Text("Subscribe - \(selectedPlan.price)\(selectedPlan.period)")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(10)
            }
            .disabled(isProcessing)
            .padding(.horizontal)
            
            // Maybe Later Button
            Button("Maybe Later", action: onDismiss)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .disabled(isProcessing)
                .padding(.top, 2)
                .padding(.bottom, 4)
        }
        .frame(maxWidth: 500)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func compactBenefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.green)
                .frame(width: 16)
            
            Text(text)
                .font(.system(size: 13))
            
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Subscription Option Row
struct SubscriptionOptionRow: View {
    let title: String
    let price: String
    let period: String
    let savingsText: String?
    let isSelected: Bool
    let isBestValue: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .orange : .gray.opacity(0.5))
                
                // Plan details
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(3)
                        }
                    }
                    
                    if let savings = savingsText {
                        Text(savings)
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 0) {
                    Text(price)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isSelected ? .orange : .primary)
                    Text(period)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Notification for auto-save
extension Notification.Name {
    static let autoSaveData = Notification.Name("autoSaveData")
}
