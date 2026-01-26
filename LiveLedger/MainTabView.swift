//
//  MainTabView.swift
//  LiveLedger
//
//  ADAPTIVE LAYOUT - Supports iPhone AND iPad
//  Automatically adapts to window size changes (Split View, Slide Over, resizing)
//  BREAKPOINTS:
//  - Width >= 700: Two-column layout (iPad landscape)
//  - Width 500-700: Single column with comfortable spacing
//  - Width 400-500: Compact single column
//  - Width < 400: Ultra-compact with vertical stacking
//

import SwiftUI

// MARK: - Main View (Universal Adaptive Layout)
struct MainTabView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @StateObject private var viewModel = SalesViewModel()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        AdaptiveHomeScreenView(
            viewModel: viewModel,
            themeManager: themeManager,
            authManager: authManager,
            localization: localization
        )
    }
}

// MARK: - Adaptive Home Screen (Responds to all window sizes)
struct AdaptiveHomeScreenView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var showAnalytics = false
    
    // Environment for detecting size class changes (iPad Split View, etc.)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
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
    
    // MARK: - Layout Constants
    private let containerCornerRadius: CGFloat = 12
    private var containerBorderColor: Color { theme.accentColor }
    private let containerBorderWidth: CGFloat = 2
    private var containerBackground: Color { theme.isDarkTheme ? Color.black.opacity(0.75) : Color.white.opacity(0.85) }
    
    // MARK: - Responsive Margins/Padding
    private func horizontalMargin(for width: CGFloat) -> CGFloat {
        if width < 400 { return 8 }
        if width < 600 { return 12 }
        return 16
    }
    
    private func sectionGap(for width: CGFloat) -> CGFloat {
        if width < 400 { return 4 }
        if width < 600 { return 6 }
        return 8
    }
    
    private func internalPadding(for width: CGFloat) -> CGFloat {
        if width < 400 { return 4 }
        if width < 600 { return 6 }
        return 8
    }
    
    // MARK: - Grid Container
    private func gridContainer<Content: View>(width: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(internalPadding(for: width))
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
            // LAYER 1: Main Dashboard Content
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let margin = horizontalMargin(for: width)
                let gap = sectionGap(for: width)
                let safeWidth = max(280, width - (margin * 2)) // Ensure minimum content width
                
                // Determine layout mode based on width
                // Use actual geometry width, not size class (more accurate for Split View)
                let useTwoColumn = width >= 700
                
                // Debug: Log layout changes (remove in production)
                let _ = print("📐 Layout: \(Int(width))x\(Int(height)), columns: \(useTwoColumn ? 2 : 1), sizeClass: \(horizontalSizeClass == .compact ? "compact" : "regular")")
                
                ZStack {
                    // Background
                    backgroundView(geometry: geometry)
                    
                    // Content - always in ScrollView to handle any size
                    ScrollView(.vertical, showsIndicators: false) {
                        if useTwoColumn {
                            // TWO-COLUMN LAYOUT (iPad landscape, wide windows)
                            twoColumnLayout(safeWidth: safeWidth, height: height, margin: margin, gap: gap)
                        } else {
                            // SINGLE-COLUMN ADAPTIVE LAYOUT
                            singleColumnLayout(width: width, safeWidth: safeWidth, height: height, margin: margin, gap: gap)
                        }
                    }
                    .scrollDisabled(height > 600 && !useTwoColumn && width >= 320) // Only disable when content fits
                }
            }
            .ignoresSafeArea(.keyboard)
            
            // LAYER 2: Buyer Popup
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
    
    // MARK: - Background View
    @ViewBuilder
    private func backgroundView(geometry: GeometryProxy) -> some View {
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
    }
    
    // MARK: - Single Column Layout (phones, narrow iPad windows)
    @ViewBuilder
    private func singleColumnLayout(width: CGFloat, safeWidth: CGFloat, height: CGFloat, margin: CGFloat, gap: CGFloat) -> some View {
        let isVeryNarrow = width < 400
        let isNarrow = width < 500
        
        // Calculate heights based on available space
        // Use minimum heights to prevent content from getting too small
        let minHeaderHeight: CGFloat = isVeryNarrow ? 120 : 140
        let minPlatformHeight: CGFloat = isVeryNarrow ? 60 : 70
        let minProductsHeight: CGFloat = isVeryNarrow ? 80 : 90
        let minOrdersHeight: CGFloat = 150
        
        // Calculate proportional heights if we have enough space
        let totalMinHeight = minHeaderHeight + minPlatformHeight + minProductsHeight + minOrdersHeight + (gap * 3) + 12
        let availableHeight = max(height, totalMinHeight)
        
        // Use proportional heights when space allows, minimum heights otherwise
        let headerHeight: CGFloat = max(minHeaderHeight, availableHeight * 0.22)
        let platformHeight: CGFloat = max(minPlatformHeight, availableHeight * 0.12)
        let productsHeight: CGFloat = max(minProductsHeight, availableHeight * 0.15)
        let ordersHeight: CGFloat = max(minOrdersHeight, availableHeight - headerHeight - platformHeight - productsHeight - (gap * 3) - 12)
        
        VStack(spacing: gap) {
            // Header
            gridContainer(width: width) {
                HeaderView(
                    viewModel: viewModel,
                    themeManager: themeManager,
                    authManager: authManager,
                    localization: localization,
                    showSettings: $showSettings,
                    showSubscription: $showSubscription
                )
            }
            .frame(width: safeWidth)
            .frame(minHeight: minHeaderHeight, idealHeight: headerHeight)
            
            // Platform
            gridContainer(width: width) {
                PlatformSelectorView(
                    viewModel: viewModel,
                    themeManager: themeManager,
                    localization: localization
                )
            }
            .frame(width: safeWidth)
            .frame(minHeight: minPlatformHeight, idealHeight: platformHeight)
            
            // Products
            gridContainer(width: width) {
                QuickAddView(
                    viewModel: viewModel,
                    themeManager: themeManager,
                    authManager: authManager,
                    localization: localization,
                    onLimitReached: { handleLimitReached() },
                    onProductSelected: { product in handleProductSelected(product) }
                )
            }
            .frame(width: safeWidth)
            .frame(minHeight: minProductsHeight, idealHeight: productsHeight)
            
            // Orders
            gridContainer(width: width) {
                OrdersListView(
                    viewModel: viewModel,
                    themeManager: themeManager,
                    localization: localization,
                    authManager: authManager
                )
            }
            .frame(width: safeWidth)
            .frame(minHeight: minOrdersHeight, idealHeight: ordersHeight)
        }
        .padding(.horizontal, margin)
        .padding(.vertical, 6)
    }
    
    // MARK: - Two Column Layout (wide screens)
    @ViewBuilder
    private func twoColumnLayout(safeWidth: CGFloat, height: CGFloat, margin: CGFloat, gap: CGFloat) -> some View {
        let columnWidth = (safeWidth - gap) / 2
        let minColumnWidth: CGFloat = 320
        
        HStack(alignment: .top, spacing: gap) {
            // LEFT COLUMN: Header + Platform + Products
            VStack(spacing: gap) {
                // Header
                gridContainer(width: safeWidth) {
                    HeaderView(
                        viewModel: viewModel,
                        themeManager: themeManager,
                        authManager: authManager,
                        localization: localization,
                        showSettings: $showSettings,
                        showSubscription: $showSubscription
                    )
                }
                .frame(minWidth: minColumnWidth, idealWidth: columnWidth)
                .frame(minHeight: 160, idealHeight: height * 0.30)
                
                // Platform
                gridContainer(width: safeWidth) {
                    PlatformSelectorView(
                        viewModel: viewModel,
                        themeManager: themeManager,
                        localization: localization
                    )
                }
                .frame(minWidth: minColumnWidth, idealWidth: columnWidth)
                .frame(minHeight: 80, idealHeight: height * 0.15)
                
                // Products
                gridContainer(width: safeWidth) {
                    QuickAddView(
                        viewModel: viewModel,
                        themeManager: themeManager,
                        authManager: authManager,
                        localization: localization,
                        onLimitReached: { handleLimitReached() },
                        onProductSelected: { product in handleProductSelected(product) }
                    )
                }
                .frame(minWidth: minColumnWidth, idealWidth: columnWidth)
                .frame(minHeight: 100)
                
                Spacer(minLength: 0)
            }
            .frame(width: columnWidth)
            
            // RIGHT COLUMN: Orders (full height)
            gridContainer(width: safeWidth) {
                OrdersListView(
                    viewModel: viewModel,
                    themeManager: themeManager,
                    localization: localization,
                    authManager: authManager
                )
            }
            .frame(minWidth: minColumnWidth, idealWidth: columnWidth)
            .frame(minHeight: height - 24)
        }
        .padding(.horizontal, margin)
        .padding(.vertical, 12)
    }
    
    // MARK: - Helper Functions
    private func handleLimitReached() {
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
    }
    
    private func handleProductSelected(_ product: Product) {
        buyerName = ""
        orderQuantity = 1
        withAnimation(.easeIn(duration: 0.2)) {
            selectedProductForOrder = product
        }
    }
}

// MARK: - Legacy Home Screen View (for backwards compatibility)
// Redirects to AdaptiveHomeScreenView
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
        // Use the new adaptive view
        AdaptiveHomeScreenView(
            viewModel: viewModel,
            themeManager: themeManager,
            authManager: authManager,
            localization: localization
        )
    }
}

// MARK: - iPad Home Screen View (Optimized for Larger Screens)
// ADAPTIVE LAYOUT: Switches between two-column and single-column based on ACTUAL WIDTH
// This prevents UI overlap when iPad window is resized (Split View, Slide Over, etc.)
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
    
    // MINIMUM WIDTH THRESHOLDS - Prevents UI overlap
    private let minWidthForTwoColumn: CGFloat = 700  // Minimum width for side-by-side layout
    private let minColumnWidth: CGFloat = 320        // Minimum width per column
    
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
                let totalWidth = geometry.size.width
                let safeWidth = totalWidth - (horizontalMargin * 2)
                let safeHeight = geometry.size.height
                
                // ADAPTIVE LAYOUT: Use width-based check, not just orientation
                // Two-column layout requires BOTH:
                // 1. Sufficient width (>= minWidthForTwoColumn)
                // 2. Each column must be >= minColumnWidth
                let canUseTwoColumn = safeWidth >= minWidthForTwoColumn && 
                                       ((safeWidth - sectionGap) / 2) >= minColumnWidth
                
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
                    
                    // iPad-optimized layout: Two columns ONLY if width permits
                    if canUseTwoColumn {
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
                            .frame(width: (safeWidth - sectionGap) / 2, alignment: .top)
                            .frame(minWidth: minColumnWidth)
                            
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
                            .frame(minWidth: minColumnWidth)
                        }
                        .frame(minWidth: minWidthForTwoColumn)
                        .padding(.horizontal, horizontalMargin)
                        .padding(.vertical, sectionGap)
                    } else {
                        // SINGLE-COLUMN LAYOUT: Used when width is insufficient for two columns
                        // This handles: Portrait mode, Split View, Slide Over, narrow windows
                        let totalGaps: CGFloat = (sectionGap * 3) + 12 + 12
                        let availableHeight = safeHeight - totalGaps
                        
                        // Adaptive proportions based on available width
                        // Use smaller proportions when width is very narrow
                        let isNarrow = safeWidth < 400
                        let headerHeight: CGFloat = availableHeight * (isNarrow ? 0.20 : 0.18)
                        let platformHeight: CGFloat = availableHeight * (isNarrow ? 0.14 : 0.12)
                        let productsHeight: CGFloat = availableHeight * (isNarrow ? 0.24 : 0.22)
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
                            .frame(maxWidth: .infinity, minHeight: headerHeight)
                            
                            // Platform
                            gridContainer {
                                PlatformSelectorView(
                                    viewModel: viewModel,
                                    themeManager: themeManager,
                                    localization: localization
                                )
                            }
                            .frame(maxWidth: .infinity, minHeight: platformHeight)
                            
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
                            .frame(maxWidth: .infinity, minHeight: productsHeight)
                            
                            // Orders
                            gridContainer {
                                OrdersListView(
                                    viewModel: viewModel,
                                    themeManager: themeManager,
                                    localization: localization,
                                    authManager: authManager
                                )
                            }
                            .frame(maxWidth: .infinity, minHeight: ordersHeight)
                        }
                        .frame(minWidth: 280) // Minimum width constraint
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
