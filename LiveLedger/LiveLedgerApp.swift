//
//  LiveLedgerApp.swift
//  LiveLedger
//
//  Live Sales Tracker App - Auto-save on background
//

import SwiftUI
import StoreKit
#if os(iOS)
import UIKit
#endif

/// Per-user keys so returning users skip onboarding/plan selection
private func onboardingKey(_ userId: String) -> String { "hasCompletedOnboarding_\(userId)" }
private func planKey(_ userId: String) -> String { "hasSelectedPlan_\(userId)" }

@main
struct LiveLedgerApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasSelectedLanguage") private var hasSelectedLanguage = false
    @State private var hasCompletedOnboarding = false
    @State private var hasSelectedPlan = false
    @StateObject private var authManager = AuthManager()
    @StateObject private var localization = LocalizationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        #if targetEnvironment(simulator)
        resetForSimulator()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSelectedLanguage {
                    LanguageSelectionView(localization: localization, hasSelectedLanguage: $hasSelectedLanguage)
                } else if !isLoggedIn {
                    SimpleAuthView(authManager: authManager)
                        .onChange(of: authManager.isAuthenticated) { _, authenticated in
                            if authenticated { isLoggedIn = true }
                        }
                } else if !hasCompletedOnboarding {
                    OnboardingView(authManager: authManager, localization: localization, hasCompletedOnboarding: Binding(
                        get: { hasCompletedOnboarding },
                        set: { v in
                            hasCompletedOnboarding = v
                            if let id = authManager.currentUser?.id { UserDefaults.standard.set(v, forKey: onboardingKey(id)) }
                        }
                    ))
                } else if !hasSelectedPlan {
                    PlanSelectionView(authManager: authManager, hasSelectedPlan: Binding(
                        get: { hasSelectedPlan },
                        set: { v in
                            hasSelectedPlan = v
                            if let id = authManager.currentUser?.id { UserDefaults.standard.set(v, forKey: planKey(id)) }
                        }
                    ))
                } else {
                    MainAppView(authManager: authManager, localization: localization)
                }
            }
            .environmentObject(localization)
            .onAppear {
                if authManager.isAuthenticated { isLoggedIn = true }
                refreshPerUserFlags()
                setMinimumWindowSize()
            }
            .onChange(of: authManager.currentUser?.id) { _, _ in
                refreshPerUserFlags()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background || newPhase == .inactive {
                    NotificationCenter.default.post(name: .autoSaveData, object: nil)
                }
            }
        }
        #if os(iOS)
        .defaultSize(width: 680, height: 1100)
        .windowResizability(.contentMinSize)
        #endif
        // Only open when user taps the app icon – do not auto-open from external events (e.g. URL, Handoff)
        .handlesExternalEvents(matching: Set<String>())
    }
    
    private func refreshPerUserFlags() {
        let userId = authManager.currentUser?.id ?? ""
        hasCompletedOnboarding = userId.isEmpty ? false : UserDefaults.standard.bool(forKey: onboardingKey(userId))
        hasSelectedPlan = userId.isEmpty ? false : UserDefaults.standard.bool(forKey: planKey(userId))
    }
    
    private func setMinimumWindowSize() {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 660, height: 1000)
            }
        }
        #endif
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
        defaults.removeObject(forKey: "sample_data_loaded_for_review_account")
        defaults.removeObject(forKey: "hasSelectedLanguage")
        defaults.removeObject(forKey: "currentUser")
        defaults.removeObject(forKey: "allAccounts")
        defaults.removeObject(forKey: "savedProducts")
        defaults.removeObject(forKey: "savedOrders")
        defaults.removeObject(forKey: "selectedTheme")
        defaults.removeObject(forKey: "overlay_position_x")
        defaults.removeObject(forKey: "overlay_position_y")
        defaults.removeObject(forKey: "app_language")
        defaults.synchronize()
        
        print("🔄 Simulator: All data cleared for fresh start")
    }
}

// MARK: - Login View (shown when not logged in)
struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        AuthView(authManager: authManager)
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
                    OnboardingView(authManager: authManager, localization: localization, hasCompletedOnboarding: $hasCompletedOnboarding)
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
        #if os(iOS)
        .frame(minWidth: UIDevice.current.userInterfaceIdiom == .pad ? 660 : nil, minHeight: UIDevice.current.userInterfaceIdiom == .pad ? 1000 : nil)
        .onAppear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                for scene in UIApplication.shared.connectedScenes {
                    guard let windowScene = scene as? UIWindowScene else { continue }
                    windowScene.sizeRestrictions?.minimumSize = CGSize(width: 660, height: 1000)
                }
            }
        }
        #endif
    }
}

// MARK: - Plan Selection View (Shown before entering app)
struct PlanSelectionView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization = LocalizationManager.shared
    @Binding var hasSelectedPlan: Bool
    @StateObject private var storeKit = StoreKitManager.shared
    @State private var selectedPlan: PlanType? = nil  // No default – user must choose
    @State private var isPurchasing = false
    @State private var purchaseError: String? = nil
    
    enum PlanType {
        case basic, monthly, yearly
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
                        
                        Text(localization.localized(.choosePlan))
                            .font(.system(size: 22, weight: .bold))
                        
                        Text(localization.localized(.selectPlanDescription))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    
                    // Plan Cards - 3 options: Basic, Monthly, Yearly
                    VStack(spacing: 10) {
                        // 1. Basic Plan Card
                        SelectablePlanCard(
                            localization: localization,
                            title: localization.localized(.basicPlan),
                            price: localization.localized(.free),
                            period: localization.localized(.forever),
                            description: localization.localized(.greatForStarting),
                            features: [
                                localization.localized(.firstOrdersFree),
                                localization.localized(.basicInventory),
                                localization.localized(.csvExports),
                                localization.localized(.standardReports)
                            ],
                            limitations: [
                                localization.localized(.limitedOrders),
                                localization.localized(.noAdvancedFilters),
                                localization.localized(.noProductImages)
                            ],
                            isSelected: selectedPlan == .basic,
                            isPro: false
                        ) {
                            withAnimation { selectedPlan = .basic }
                        }
                        
                        // 2. Pro Monthly Card (same Pro features as Yearly; only billing differs)
                        SelectablePlanCard(
                            localization: localization,
                            title: "Pro Monthly",
                            price: "$19.99",
                            period: localization.localized(.perMonth),
                            description: localization.localized(.unlimited),
                            features: [
                                localization.localized(.unlimitedOrders),
                                localization.localized(.unlimitedExports),
                                localization.localized(.productImages),
                                localization.localized(.prioritySupport),
                                localization.localized(.allFutureFeatures)
                            ],
                            limitations: [],
                            isSelected: selectedPlan == .monthly,
                            isPro: false
                        ) {
                            withAnimation { selectedPlan = .monthly }
                        }
                        
                        // 3. Pro Yearly Card (same Pro features as Monthly)
                        SelectablePlanCard(
                            localization: localization,
                            title: "Pro Yearly",
                            price: "$179.99",
                            period: "/year",
                            description: "Save $60 vs monthly",
                            features: [
                                localization.localized(.unlimitedOrders),
                                localization.localized(.unlimitedExports),
                                localization.localized(.productImages),
                                localization.localized(.prioritySupport),
                                localization.localized(.allFutureFeatures)
                            ],
                            limitations: [],
                            isSelected: selectedPlan == .yearly,
                            isPro: false
                        ) {
                            withAnimation { selectedPlan = .yearly }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Continue / Subscribe Button
                    Button {
                        if let plan = selectedPlan {
                            if plan == .basic {
                                completePlanSelection()
                            } else if plan == .monthly {
                                Task { await purchasePro(monthly: true) }
                            } else if plan == .yearly {
                                Task { await purchasePro(monthly: false) }
                            }
                        }
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: selectedPlan == .basic ? .white : .black))
                            } else if selectedPlan != .basic && selectedPlan != nil {
                                Image(systemName: "crown.fill")
                            }
                            Text(buttonTitle)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(selectedPlan == .basic ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedPlan == .basic ?
                            LinearGradient(colors: [Color(hex: "00CC88"), Color(hex: "00AA77")], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(selectedPlan == nil || isPurchasing)
                    .padding(.horizontal)
                    
                    if selectedPlan == .monthly || selectedPlan == .yearly {
                        Text("\(localization.localized(.cancelAnytime)) • \(localization.localized(.dayFreeTrial))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        selectedPlan = .basic
                        completePlanSelection()
                    }
                }
            }
            .onAppear {
                storeKit.markPaywallShown()
            }
            .alert("Purchase Error", isPresented: Binding(get: { purchaseError != nil }, set: { if !$0 { purchaseError = nil } })) {
                Button("OK") { purchaseError = nil }
            } message: {
                Text(purchaseError ?? "")
            }
        }
    }
    
    private var buttonTitle: String {
        if selectedPlan == nil { return "Select a Plan" }
        if selectedPlan == .basic { return localization.localized(.continueWithBasic) }
        if selectedPlan == .monthly {
            return "Subscribe - \(storeKit.proMonthlyProduct?.displayPrice ?? "$19.99")/month"
        }
        return "Subscribe - \(storeKit.proYearlyProduct?.displayPrice ?? "$179.99")/year"
    }
    
    private func completePlanSelection() {
        hasSelectedPlan = true
        // QA RULE: Sample products MUST load for applereview@liveledger.com. Post notification so observer loads after MainAppView exists.
        let email = (authManager.currentUser?.email ?? "").lowercased()
        if email == "applereview@liveledger.com" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .populateDemoData, object: nil, userInfo: ["email": authManager.currentUser?.email ?? "", "isPro": authManager.currentUser?.isPro ?? false])
            }
        }
    }
    
    private func purchasePro(monthly: Bool) async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        
        let product = monthly ? storeKit.proMonthlyProduct : storeKit.proYearlyProduct
        guard let product = product else {
            purchaseError = "Product not available. Please try again later."
            return
        }
        
        do {
            try await storeKit.purchase(product)
            await MainActor.run {
                authManager.upgradeToPro()
                completePlanSelection()
            }
        } catch let error as PurchaseError {
            await MainActor.run {
                if case .purchaseCancelled = error { return }
                purchaseError = error.localizedDescription
            }
        } catch {
            await MainActor.run {
                purchaseError = error.localizedDescription
            }
        }
    }
}

// MARK: - Selectable Plan Card
struct SelectablePlanCard: View {
    let localization: LocalizationManager
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
