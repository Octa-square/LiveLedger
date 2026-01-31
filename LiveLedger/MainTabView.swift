//
//  MainTabView.swift
//  LiveLedger
//
//  ADAPTIVE LAYOUT - Supports iPhone AND iPad
//  iPhone: Static single-screen layout
//  iPad: Same layout with minimum window size; scroll in HomeScreenView when short
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - Main View (Adaptive for iPhone and iPad)
struct MainTabView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @StateObject private var viewModel = SalesViewModel()
    @StateObject private var themeManager: ThemeManager

    init(authManager: AuthManager, localization: LocalizationManager) {
        self.authManager = authManager
        self.localization = localization
        _viewModel = StateObject(wrappedValue: SalesViewModel())
        _themeManager = StateObject(wrappedValue: ThemeManager(userId: authManager.currentUser?.id ?? ""))
    }

    var body: some View {
        HomeScreenView(
            viewModel: viewModel,
            themeManager: themeManager,
            authManager: authManager,
            localization: localization
        )
        .onAppear {
            print("[SampleData] MainTabView appeared")
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.sizeRestrictions?.minimumSize = CGSize(width: 660, height: 1000)
                }
            }
            #endif
            viewModel.authManager = authManager
            viewModel.loadData() // Load this user's data (per-user keys)
            if let email = authManager.currentUser?.email {
                if email.lowercased() == "applereview@liveledger.com" {
                    let hasProducts = !viewModel.products.isEmpty && !viewModel.products.allSatisfy { $0.isEmpty }
                    if !hasProducts {
                        viewModel.populateDemoData(email: email, isPro: authManager.currentUser?.isPro ?? false)
                    }
                } else {
                    viewModel.clearSampleDataForNonReviewUser(currentEmail: email)
                }
            }
        }
    }
}

// MARK: - Home Screen (STATIC LAYOUT - Fits One iPhone Screen)
struct HomeScreenView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var showAnalytics = false
    
    // Dynamic alert titles for lapsed vs new subscribers
    private var limitAlertTitle: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Subscription Expired" : "Upgrade Required"
    }
    
    private var limitAlertButtonText: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Resubscribe to Pro" : "Upgrade to Pro"
    }
    
    // Buyer popup state - managed at top level so popup is independent of content
    @State private var selectedProductForOrder: Product?
    @State private var buyerName: String = ""
    @State private var orderQuantity: Int = 1
    @State private var buyerPhone: String = ""
    @State private var buyerNotes: String = ""
    @State private var orderSource: OrderSource = .liveStream
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    // Grid container styling - RESPONSIVE LAYOUT
    private let containerCornerRadius: CGFloat = 12
    private var containerBorderColor: Color { theme.accentColor }
    private let containerBorderWidth: CGFloat = 2
    private var containerBackground: Color { theme.isDarkTheme ? Color.black.opacity(0.75) : Color.white.opacity(0.85) }
    private let horizontalMargin: CGFloat = 16  // 16pt from screen edges
    private let internalPadding: CGFloat = 6    // Tight internal padding
    
    // UNIFORM TIGHT SPACING - Same gap everywhere
    private let sectionGap: CGFloat = 6  // 6pt uniform gap between all grids
    
    private func gridContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(internalPadding)
            .background(
                RoundedRectangle(cornerRadius: containerCornerRadius)
                    .fill(containerBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: containerCornerRadius)
                    .strokeBorder(containerBorderColor, lineWidth: containerBorderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: containerCornerRadius)) // CRITICAL: Hard clip
    }
    
    var body: some View {
        // ROOT ZSTACK: Background covers entire app, content scrolls on top
        ZStack {
            // Background - Must cover entire screen (outside ScrollView)
            GeometryReader { geometry in
                Group {
                    if theme.hasWallpaper {
                        Image(theme.backgroundImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                            )
                            .clipped()
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        Color.black.opacity(0.15)
                    } else {
                        LinearGradient(
                            colors: theme.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.all)
            
            // LAYER 1: Main Dashboard Content - ScrollView so all content visible when window short
            GeometryReader { geometry in
                let safeWidth = geometry.size.width - (horizontalMargin * 2)
                let safeHeight = geometry.size.height
                let totalGaps: CGFloat = (sectionGap * 3) + 6 + 6
                let availableHeight = safeHeight - totalGaps
                let headerHeight: CGFloat = availableHeight * 0.20
                let platformHeight: CGFloat = availableHeight * 0.13
                let productsHeight: CGFloat = availableHeight * 0.18
                let ordersHeight: CGFloat = availableHeight - headerHeight - platformHeight - productsHeight
                
                ScrollView(.vertical, showsIndicators: true) {
                    // Content VStack
                    VStack(spacing: sectionGap) {
                        // Header
                        gridContainer {
                            HeaderView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                authManager: authManager,
                                localization: localization,
                                showSettings: $showSettings,
                                showSubscription: $showSubscription
                            )
                        }
                        .frame(width: safeWidth, height: headerHeight)
                        
                        // Platform
                        gridContainer {
                            PlatformSelectorView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization
                            )
                        }
                        .frame(width: safeWidth, height: platformHeight)
                        
                        // Products
                        gridContainer {
                            QuickAddView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                authManager: authManager,
                                localization: localization,
                                onLimitReached: {
                                    if authManager.currentUser?.isLapsedSubscriber == true {
                                        if let expiredDate = authManager.currentUser?.formattedExpirationDate {
                                            limitAlertMessage = "You've reached your free tier limit. Your Pro subscription expired on \(expiredDate). Resubscribe to Pro for unlimited orders!"
                                        } else {
                                            limitAlertMessage = "You've reached your free tier limit. Your Pro subscription has expired. Resubscribe to Pro for unlimited orders!"
                                        }
                                    } else {
                                        limitAlertMessage = "You've used all 20 free orders. Upgrade to Pro for unlimited orders!"
                                    }
                                    showLimitAlert = true
                                },
                                onProductSelected: { product in
                                    buyerName = ""
                                    orderQuantity = 1
                                    withAnimation(.easeIn(duration: 0.2)) { selectedProductForOrder = product }
                                },
                                onUpgrade: { showSubscription = true }
                            )
                        }
                        .frame(width: safeWidth, height: productsHeight)
                        
                        // Orders
                        gridContainer {
                            OrdersListView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization,
                                authManager: authManager
                            )
                        }
                        .frame(width: safeWidth, height: ordersHeight)
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 6)
                    .padding()
                    .frame(width: geometry.size.width)
                }
            }
            .ignoresSafeArea(.keyboard)
            
            // LAYER 2: Buyer Popup - RESPONDS TO KEYBOARD (moves up when keyboard appears)
            if let product = selectedProductForOrder {
                BuyerPopupView(
                    product: product,
                    viewModel: viewModel,
                    buyerName: $buyerName,
                    orderQuantity: $orderQuantity,
                    phoneNumber: $buyerPhone,
                    customerNotes: $buyerNotes,
                    orderSource: $orderSource,
                    onCancel: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                        buyerPhone = ""
                        buyerNotes = ""
                    },
                    onAdd: {
                        let platform = viewModel.selectedPlatform ?? .all
                        let finalName = buyerName.isEmpty ? "SN-\(viewModel.orders.count + 1)" : buyerName
                        viewModel.createOrder(
                            product: product,
                            buyerName: finalName,
                            phoneNumber: buyerPhone,
                            address: "",
                            customerNotes: buyerNotes.isEmpty ? nil : buyerNotes,
                            orderSource: orderSource,
                            platform: platform,
                            quantity: orderQuantity
                        )
                        authManager.incrementOrderCount()
                        #if os(iOS)
                        AppReviewHelper.notifyOrderCountReached(viewModel.orders.count)
                        #endif
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                        buyerPhone = ""
                        buyerNotes = ""
                    }
                )
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization, viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
        }
        .sheet(isPresented: $viewModel.showingExportSheet) {
            if let url = viewModel.csvURL {
                if let user = authManager.currentUser, !user.isPro && !user.canExport {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Export Limit Reached")
                            .font(.title2.bold())
                        Text("You've used all 10 free exports. Upgrade to Pro for unlimited exports.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        Button("Upgrade to Pro") {
                            viewModel.showingExportSheet = false
                            showSubscription = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    ShareSheet(items: [url])
                        .onAppear {
                            authManager.incrementExportCount()
                            #if os(iOS)
                            AppReviewHelper.notifyExportCompleted()
                            #endif
                        }
                }
            }
        }
        .sheet(isPresented: $showAnalytics) {
            NavigationStack {
                AnalyticsView(viewModel: viewModel, localization: localization)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert(limitAlertTitle, isPresented: $showLimitAlert) {
            Button(limitAlertButtonText) { showSubscription = true }
            Button("Later", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
    }
}

// MARK: - iPad Home Screen View (Optimized for Larger Screens)
struct iPadHomeScreenView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var showAnalytics = false
    
    // Dynamic alert titles for lapsed vs new subscribers
    private var limitAlertTitle: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Subscription Expired" : "Upgrade Required"
    }
    
    private var limitAlertButtonText: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Resubscribe to Pro" : "Upgrade to Pro"
    }
    
    // Buyer popup state
    @State private var selectedProductForOrder: Product?
    @State private var buyerName: String = ""
    @State private var orderQuantity: Int = 1
    @State private var buyerPhone: String = ""
    @State private var buyerNotes: String = ""
    @State private var orderSource: OrderSource = .liveStream
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    // iPad-specific styling - larger containers and spacing
    private let containerCornerRadius: CGFloat = 16
    private var containerBorderColor: Color { theme.accentColor }
    private let containerBorderWidth: CGFloat = 2
    private var containerBackground: Color { theme.isDarkTheme ? Color.black.opacity(0.75) : Color.white.opacity(0.85) }
    private let horizontalMargin: CGFloat = 24  // Larger margins for iPad
    private let internalPadding: CGFloat = 12   // More padding inside containers
    private let sectionGap: CGFloat = 12        // Larger gaps for iPad
    
    private func gridContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(internalPadding)
            .background(
                RoundedRectangle(cornerRadius: containerCornerRadius)
                    .fill(containerBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: containerCornerRadius)
                    .strokeBorder(containerBorderColor, lineWidth: containerBorderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: containerCornerRadius))
    }
    
    var body: some View {
        ZStack {
            // Main content
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                let safeWidth = geometry.size.width - (horizontalMargin * 2)
                let safeHeight = geometry.size.height
                
                ZStack {
                    // Background
                    if theme.hasWallpaper {
                        Image(theme.backgroundImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                            )
                            .clipped()
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .ignoresSafeArea(.all, edges: .all)
                        
                        Color.black.opacity(0.15)
                            .ignoresSafeArea(.all, edges: .all)
                    } else {
                        LinearGradient(
                            colors: theme.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea(.all, edges: .all)
                    }
                    
                    // iPad-optimized layout: Two columns
                    if isLandscape {
                        // Landscape: Side-by-side layout
                        HStack(spacing: sectionGap) {
                            // LEFT COLUMN: Header + Platform + Products
                            VStack(spacing: sectionGap) {
                                // Header
                                gridContainer {
                                    HeaderView(
                                        viewModel: viewModel,
                                        themeManager: themeManager,
                                        authManager: authManager,
                                        localization: localization,
                                        showSettings: $showSettings,
                                        showSubscription: $showSubscription
                                    )
                                }
                                .frame(height: safeHeight * 0.28)
                                
                                // Platform
                                gridContainer {
                                    PlatformSelectorView(
                                        viewModel: viewModel,
                                        themeManager: themeManager,
                                        localization: localization
                                    )
                                }
                                .frame(height: safeHeight * 0.18)
                                
                                // Products
                                gridContainer {
                                    QuickAddView(
                                        viewModel: viewModel,
                                        themeManager: themeManager,
                                        authManager: authManager,
                                        localization: localization,
                                        onLimitReached: {
                                            if authManager.currentUser?.isLapsedSubscriber == true {
                                                if let expiredDate = authManager.currentUser?.formattedExpirationDate {
                                                    limitAlertMessage = "You've reached your free tier limit. Your Pro subscription expired on \(expiredDate). Resubscribe to Pro for unlimited orders!"
                                                } else {
                                                    limitAlertMessage = "You've reached your free tier limit. Your Pro subscription has expired. Resubscribe to Pro for unlimited orders!"
                                                }
                                            } else {
                                                limitAlertMessage = "You've used all 20 free orders. Upgrade to Pro for unlimited orders!"
                                            }
                                            showLimitAlert = true
                                        },
                                        onProductSelected: { product in
                                            buyerName = ""
                                            orderQuantity = 1
                                            withAnimation(.easeIn(duration: 0.2)) {
                                                selectedProductForOrder = product
                                            }
                                        },
                                        onUpgrade: { showSubscription = true }
                                    )
                                }
                            }
                            .frame(width: (safeWidth - sectionGap) / 2)
                            
                            // RIGHT COLUMN: Orders (full height)
                            gridContainer {
                                OrdersListView(
                                    viewModel: viewModel,
                                    themeManager: themeManager,
                                    localization: localization,
                                    authManager: authManager
                                )
                            }
                            .frame(width: (safeWidth - sectionGap) / 2)
                        }
                        .padding(.horizontal, horizontalMargin)
                        .padding(.vertical, sectionGap)
                    } else {
                        // Portrait: Stacked layout (similar to iPhone but with better proportions)
                        let totalGaps: CGFloat = (sectionGap * 3) + 12 + 12
                        let availableHeight = safeHeight - totalGaps
                        
                        // Better proportions for iPad portrait
                        let headerHeight: CGFloat = availableHeight * 0.18
                        let platformHeight: CGFloat = availableHeight * 0.12
                        let productsHeight: CGFloat = availableHeight * 0.22
                        let ordersHeight: CGFloat = availableHeight - headerHeight - platformHeight - productsHeight
                        
                        VStack(spacing: sectionGap) {
                            // Header
                            gridContainer {
                                HeaderView(
                                    viewModel: viewModel,
                                    themeManager: themeManager,
                                    authManager: authManager,
                                    localization: localization,
                                    showSettings: $showSettings,
                                    showSubscription: $showSubscription
                                )
                            }
                            .frame(width: safeWidth, height: headerHeight)
                            
                            // Platform
                            gridContainer {
                                PlatformSelectorView(
                                    viewModel: viewModel,
                                    themeManager: themeManager,
                                    localization: localization
                                )
                            }
                            .frame(width: safeWidth, height: platformHeight)
                            
                            // Products
                            gridContainer {
                                QuickAddView(
                                    viewModel: viewModel,
                                    themeManager: themeManager,
                                    authManager: authManager,
                                    localization: localization,
                                    onLimitReached: {
                                        if authManager.currentUser?.isLapsedSubscriber == true {
                                            if let expiredDate = authManager.currentUser?.formattedExpirationDate {
                                                limitAlertMessage = "You've reached your free tier limit. Your Pro subscription expired on \(expiredDate). Resubscribe to Pro for unlimited orders!"
                                            } else {
                                                limitAlertMessage = "You've reached your free tier limit. Your Pro subscription has expired. Resubscribe to Pro for unlimited orders!"
                                            }
                                        } else {
                                            limitAlertMessage = "You've used all 20 free orders. Upgrade to Pro for unlimited orders!"
                                        }
                                        showLimitAlert = true
                                    },
                                    onProductSelected: { product in
                                        buyerName = ""
                                        orderQuantity = 1
                                        withAnimation(.easeIn(duration: 0.2)) {
                                            selectedProductForOrder = product
                                        }
                                    },
                                    onUpgrade: { showSubscription = true }
                                )
                            }
                            .frame(width: safeWidth, height: productsHeight)
                            
                            // Orders
                            gridContainer {
                                OrdersListView(
                                    viewModel: viewModel,
                                    themeManager: themeManager,
                                    localization: localization,
                                    authManager: authManager
                                )
                            }
                            .frame(width: safeWidth, height: ordersHeight)
                        }
                        .padding(.horizontal, horizontalMargin)
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            
            // Buyer Popup
            if let product = selectedProductForOrder {
                BuyerPopupView(
                    product: product,
                    viewModel: viewModel,
                    buyerName: $buyerName,
                    orderQuantity: $orderQuantity,
                    phoneNumber: $buyerPhone,
                    customerNotes: $buyerNotes,
                    orderSource: $orderSource,
                    onCancel: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                        buyerPhone = ""
                        buyerNotes = ""
                    },
                    onAdd: {
                        let platform = viewModel.selectedPlatform ?? .all
                        let finalName = buyerName.isEmpty ? "SN-\(viewModel.orders.count + 1)" : buyerName
                        viewModel.createOrder(
                            product: product,
                            buyerName: finalName,
                            phoneNumber: buyerPhone,
                            address: "",
                            customerNotes: buyerNotes.isEmpty ? nil : buyerNotes,
                            orderSource: orderSource,
                            platform: platform,
                            quantity: orderQuantity
                        )
                        authManager.incrementOrderCount()
                        #if os(iOS)
                        AppReviewHelper.notifyOrderCountReached(viewModel.orders.count)
                        #endif
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                        buyerPhone = ""
                        buyerNotes = ""
                    }
                )
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization, viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
        }
        .sheet(isPresented: $viewModel.showingExportSheet) {
            if let url = viewModel.csvURL {
                if let user = authManager.currentUser, !user.isPro && !user.canExport {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Export Limit Reached")
                            .font(.title2.bold())
                        Text("You've used all 10 free exports. Upgrade to Pro for unlimited exports.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        Button("Upgrade to Pro") {
                            viewModel.showingExportSheet = false
                            showSubscription = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    ShareSheet(items: [url])
                        .onAppear {
                            authManager.incrementExportCount()
                            #if os(iOS)
                            AppReviewHelper.notifyExportCompleted()
                            #endif
                        }
                }
            }
        }
        .sheet(isPresented: $showAnalytics) {
            NavigationStack {
                AnalyticsView(viewModel: viewModel, localization: localization)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert(limitAlertTitle, isPresented: $showLimitAlert) {
            Button(limitAlertButtonText) { showSubscription = true }
            Button("Later", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView(
        authManager: AuthManager(),
        localization: LocalizationManager.shared
    )
}
