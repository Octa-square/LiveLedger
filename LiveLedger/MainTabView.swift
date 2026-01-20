//
//  MainTabView.swift
//  LiveLedger
//
//  ADAPTIVE LAYOUT - Supports iPhone AND iPad
//  iPhone: Static single-screen layout
//  iPad: Optimized two-column layout for larger screens
//

import SwiftUI

// MARK: - Main View (Adaptive for iPhone and iPad)
struct MainTabView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @StateObject private var viewModel = SalesViewModel()
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        // Adaptive layout based on device size class
        if horizontalSizeClass == .regular {
            // iPad layout - optimized for larger screens
            iPadHomeScreenView(
                viewModel: viewModel,
                themeManager: themeManager,
                authManager: authManager,
                localization: localization
            )
        } else {
            // iPhone layout - single screen
            HomeScreenView(
                viewModel: viewModel,
                themeManager: themeManager,
                authManager: authManager,
                localization: localization
            )
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
        // ROOT ZSTACK: Main content and popup are siblings (independent keyboard handling)
        ZStack {
            // LAYER 1: Main Dashboard Content - STAYS STATIC (ignores keyboard)
            GeometryReader { geometry in
                let safeWidth = geometry.size.width - (horizontalMargin * 2)
                let safeHeight = geometry.size.height
                
                // Calculate available height after gaps and padding
                // Total gaps: 3 x sectionGap + top padding + bottom padding
                let totalGaps: CGFloat = (sectionGap * 3) + 6 + 6  // 18 + 12 = 30pt
                let availableHeight = safeHeight - totalGaps
                
                // Fixed heights for each section (percentage of available height)
                // Header: 20% | Platform: 13% | Products: 18% | Orders: fills remaining
                let headerHeight: CGFloat = availableHeight * 0.20
                let platformHeight: CGFloat = availableHeight * 0.13
                let productsHeight: CGFloat = availableHeight * 0.18
                let ordersHeight: CGFloat = availableHeight - headerHeight - platformHeight - productsHeight  // Fill remaining
                
                ZStack {
                    // Background - either wallpaper or plain gradient
                    if theme.hasWallpaper {
                        // Wallpaper - STRETCHED HORIZONTALLY to fill screen width
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
                        
                        // Dark overlay for readability
                        Color.black.opacity(0.15)
                            .ignoresSafeArea(.all, edges: .all)
                    } else {
                        // Plain gradient background (no wallpaper)
                        LinearGradient(
                            colors: theme.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea(.all, edges: .all)
                    }
                    
                    // STATIC LAYOUT - All containers have FIXED heights
                    // NO overlap - each section has explicit size
                    VStack(spacing: sectionGap) {
                        // === CONTAINER 1: Header + Stats + Actions ===
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
                        .padding(.horizontal, horizontalMargin)
                        
                        // === CONTAINER 2: Platform Section ===
                        gridContainer {
                            PlatformSelectorView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization
                            )
                        }
                        .frame(width: safeWidth, height: platformHeight)
                        .padding(.horizontal, horizontalMargin)
                        
                        // === CONTAINER 3: My Products ===
                        gridContainer {
                            QuickAddView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                authManager: authManager,
                                localization: localization,
                                onLimitReached: {
                                    // Different message for lapsed subscribers vs new users
                                    // Apple reviewers using review@liveledger.app will see the lapsed subscriber message
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
                                }
                            )
                        }
                        .frame(width: safeWidth, height: productsHeight)
                        .padding(.horizontal, horizontalMargin)
                        
                        // === CONTAINER 4: Orders ===
                        // FIXED HEIGHT - internal scroll for content
                        gridContainer {
                            OrdersListView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization,
                                authManager: authManager
                            )
                        }
                        .frame(width: safeWidth, height: ordersHeight)
                        .padding(.horizontal, horizontalMargin)
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 6)
                }
            }
            .ignoresSafeArea(.keyboard) // Main dashboard stays static when keyboard appears
            
            // LAYER 2: Buyer Popup - RESPONDS TO KEYBOARD (moves up when keyboard appears)
            if let product = selectedProductForOrder {
                BuyerPopupView(
                    product: product,
                    buyerName: $buyerName,
                    orderQuantity: $orderQuantity,
                    onCancel: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                    },
                    onAdd: {
                        // Create the order
                        let platform = viewModel.selectedPlatform ?? .all
                        let finalName = buyerName.isEmpty ? "SN-\(viewModel.orders.count + 1)" : buyerName
                        viewModel.createOrder(
                            product: product,
                            buyerName: finalName,
                            phoneNumber: "",
                            address: "",
                            platform: platform,
                            quantity: orderQuantity
                        )
                        authManager.incrementOrderCount()
                        // Dismiss popup
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                    }
                )
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization)
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAnalytics) {
            NavigationStack {
                AnalyticsView(viewModel: viewModel, localization: localization)
            }
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
                                        }
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
                                    }
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
                    buyerName: $buyerName,
                    orderQuantity: $orderQuantity,
                    onCancel: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                    },
                    onAdd: {
                        let platform = viewModel.selectedPlatform ?? .all
                        let finalName = buyerName.isEmpty ? "SN-\(viewModel.orders.count + 1)" : buyerName
                        viewModel.createOrder(
                            product: product,
                            buyerName: finalName,
                            phoneNumber: "",
                            address: "",
                            platform: platform,
                            quantity: orderQuantity
                        )
                        authManager.incrementOrderCount()
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedProductForOrder = nil
                        }
                        buyerName = ""
                        orderQuantity = 1
                    }
                )
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization)
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAnalytics) {
            NavigationStack {
                AnalyticsView(viewModel: viewModel, localization: localization)
            }
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
