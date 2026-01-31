//
//  MainAppView.swift
//  LiveLedger
//
//  Complete UI Implementation with Fixed Header and Scrollable Content
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct MainAppView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @StateObject private var viewModel: SalesViewModel
    @StateObject private var themeManager: ThemeManager

    init(authManager: AuthManager, localization: LocalizationManager) {
        self.authManager = authManager
        self.localization = localization
        _viewModel = StateObject(wrappedValue: SalesViewModel())
        _themeManager = StateObject(wrappedValue: ThemeManager(userId: authManager.currentUser?.id ?? ""))
    }
    @State private var selectedPlatform = "All"
    @State private var selectedStatus = "All"
    @State private var selectedProductForOrder: Product?
    @State private var buyerName: String = ""
    @State private var orderQuantity: Int = 1
    @State private var buyerPhone: String = ""
    @State private var buyerNotes: String = ""
    @State private var orderSource: OrderSource = .liveStream
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var showSubscription = false
    @State private var showAnalytics = false
    
    private var limitAlertTitle: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Subscription Expired" : "Upgrade Required"
    }
    
    private var limitAlertButtonText: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Resubscribe to Pro" : "Upgrade to Pro"
    }
    
    /// QA RULE: applereview@liveledger.com gets sample products when they reach the main app. Other emails stay blank.
    private func tryLoadSampleDataForReviewAccount() {
        guard let email = authManager.currentUser?.email else { return }
        if email.lowercased() == "applereview@liveledger.com" {
            let hasProducts = !viewModel.products.isEmpty && !viewModel.products.allSatisfy { $0.isEmpty }
            if !hasProducts {
                viewModel.populateDemoData(email: email, isPro: authManager.currentUser?.isPro ?? false)
            }
        } else {
            viewModel.clearSampleDataForNonReviewUser(currentEmail: email)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // FIXED HEADER - Logo left, Menu (Analytics + Settings) right
                FixedHeaderView(
                    viewModel: viewModel,
                    authManager: authManager,
                    themeManager: themeManager,
                    localization: localization,
                    showAnalytics: $showAnalytics,
                    showSubscription: $showSubscription
                )
                
                // MAIN CONTENT - All sections flow together, Orders extends to bottom
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 12) {
                        StatsAndActionsSection(
                            viewModel: viewModel,
                            themeManager: themeManager,
                            authManager: authManager,
                            localization: localization
                        )
                            
                            PlatformSection(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization,
                                selectedPlatform: $selectedPlatform
                            )
                            
                            ProductsSection(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                authManager: authManager,
                                localization: localization,
                                onProductSelected: { product in
                                    if authManager.currentUser?.isPro == false && viewModel.orderCount >= 20 {
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
                                    } else {
                                        buyerName = ""
                                        orderQuantity = 1
                                        withAnimation(.easeIn(duration: 0.2)) { selectedProductForOrder = product }
                                    }
                                },
                                onUpgrade: { showSubscription = true }
                            )
                            
                            // Orders Section - extends to bottom of screen
                            OrdersFlexibleSection(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization,
                                authManager: authManager,
                                selectedPlatform: $selectedPlatform,
                                selectedStatus: $selectedStatus
                            )
                            .frame(minHeight: max(300, geometry.size.height - 380))
                            // 380 = compact Stats + Platform + Products + spacing (more room for Orders)
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 15)
                        .padding(.bottom, 0)  // No bottom padding - Orders touches bottom
                    }
                }
            }
            .background(
                ZStack {
                    // Theme gradient background
                    LinearGradient(
                        colors: themeManager.currentTheme.gradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Theme wallpaper if available
                    if themeManager.currentTheme.hasWallpaper,
                       !themeManager.currentTheme.backgroundImageName.isEmpty {
                        Image(themeManager.currentTheme.backgroundImageName)
                            .resizable()
                            .scaledToFill()
                            .opacity(0.3)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            )
            
            // Buyer Popup - Overlay on top
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
        .onAppear {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.sizeRestrictions?.minimumSize = CGSize(width: 660, height: 1000)
                }
            }
            #endif
            viewModel.authManager = authManager
            viewModel.loadData() // Load this user's data (per-user keys)
            tryLoadSampleDataForReviewAccount()
        }
        .onChange(of: authManager.currentUser?.id) { _, _ in
            viewModel.authManager = authManager
            viewModel.loadData()
            tryLoadSampleDataForReviewAccount()
        }
        .alert(limitAlertTitle, isPresented: $showLimitAlert) {
            Button(limitAlertButtonText) { showSubscription = true }
            Button("Later", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
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
    }
}

// MARK: - Fixed Header Component
struct FixedHeaderView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var authManager: AuthManager
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @Binding var showAnalytics: Bool
    @Binding var showSubscription: Bool
    @State private var showSettings = false
    @State private var showNeedProAlert = false
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        HStack(spacing: 12) {
            // LEFT: Logo and App Info — fixed size, stays on left
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(
                            LinearGradient(
                                colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: theme.accentColor.opacity(0.4), radius: 7, x: 0, y: 3)
                    
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("LiveLedger")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("My Store")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textMuted)
                        .lineLimit(1)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            
            Spacer(minLength: 8)
            
            // RIGHT: Menu button — Analytics + Settings
            Menu {
                Button {
                    if authManager.currentUser?.isPro == true {
                        showAnalytics = true
                    } else {
                        showNeedProAlert = true
                    }
                } label: {
                    Label(localization.localized(.analytics), systemImage: "chart.bar.fill")
                }
                Button { showSettings = true } label: {
                    Label(localization.localized(.settings), systemImage: "gearshape.fill")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(theme.textPrimary)
                    .frame(width: 34, height: 34)
                    .background(theme.cardBackground)
                    .cornerRadius(7)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(theme.gradientColors.first ?? Color.black)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(theme.accentColor)
                .shadow(color: theme.accentColor.opacity(0.3), radius: 9, x: 0, y: 3),
            alignment: .bottom
        )
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization, viewModel: viewModel)
        }
        .alert("Pro Feature", isPresented: $showNeedProAlert) {
            Button("Upgrade to Pro") { showSubscription = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Analytics and charts require Pro. Upgrade to access detailed insights.")
        }
    }
}


// MARK: - Stats and Actions Section
struct StatsAndActionsSection: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    private var currencySymbol: String {
        authManager.currentUser?.currencySymbol ?? "$"
    }
    
    var topSellerName: String {
        let productCounts = Dictionary(grouping: viewModel.filteredOrders, by: { $0.productName })
            .mapValues { $0.reduce(0) { $0 + $1.quantity } }
        if let topProduct = productCounts.max(by: { $0.value < $1.value }) {
            return topProduct.key
        }
        return "—"
    }
    
    var totalStockLeft: Int {
        viewModel.products.reduce(0) { $0 + $1.stock }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                MainAppStatCard(
                    icon: "dollarsign.circle.fill",
                    value: "\(currencySymbol)\(String(format: "%.0f", viewModel.totalRevenue))",
                    label: localization.localized(.totalSales),
                    color: theme.accentColor,
                    theme: theme
                )
                MainAppStatCard(
                    icon: "flame.fill",
                    value: topSellerName,
                    label: localization.localized(.topSeller),
                    color: theme.warningColor,
                    theme: theme
                )
                MainAppStatCard(
                    icon: "cube.fill",
                    value: "\(totalStockLeft)",
                    label: localization.localized(.stockLeft),
                    color: theme.secondaryColor,
                    theme: theme
                )
                MainAppStatCard(
                    icon: "bag.fill",
                    value: "\(viewModel.orderCount)",
                    label: localization.localized(.totalOrders),
                    color: theme.accentColor,
                    theme: theme
                )
            }
            
            HStack(spacing: 8) {
                MainAppActionButton(
                    title: localization.localized(.clear),
                    icon: "trash.fill",
                    color: theme.dangerColor,
                    viewModel: viewModel,
                    localization: localization
                )
                MainAppActionButton(
                    title: localization.localized(.export),
                    icon: "square.and.arrow.up.fill",
                    color: theme.secondaryColor,
                    viewModel: viewModel,
                    localization: localization
                )
                MainAppActionButton(
                    title: localization.localized(.print),
                    icon: "printer.fill",
                    color: theme.secondaryColor,
                    viewModel: viewModel,
                    authManager: authManager,
                    localization: localization
                )
            }
            .padding(.top, 8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 11)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(theme.cardBorder, lineWidth: 1)
                )
        )
    }
}

struct MainAppStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(theme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(theme.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .strokeBorder(theme.cardBorder.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct MainAppActionButton: View {
    let title: String
    let icon: String
    let color: Color
    @ObservedObject var viewModel: SalesViewModel
    var authManager: AuthManager?
    @ObservedObject var localization: LocalizationManager
    @State private var showOptions = false
    
    init(title: String, icon: String, color: Color, viewModel: SalesViewModel, authManager: AuthManager? = nil, localization: LocalizationManager) {
        self.title = title
        self.icon = icon
        self.color = color
        self.viewModel = viewModel
        self.authManager = authManager
        self.localization = localization
    }
    
    var body: some View {
        Button(action: {
            showOptions = true
        }) {
            HStack(spacing: 5) {  // Reduced from 6px
                Image(systemName: icon)
                    .font(.system(size: 11))  // Reduced from 12px
                Text(title)
                    .font(.system(size: 12, weight: .semibold))  // Reduced from 13px
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)  // Reduced from 12px
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 7)  // Reduced from 8px
                    .fill(color)
            )
        }
        .sheet(isPresented: $showOptions) {
            if title == localization.localized(.clear) {
                ClearOptionsView(viewModel: viewModel)
            } else if title == localization.localized(.export) {
                ExportOptionsView(viewModel: viewModel, platforms: viewModel.platforms)
            } else if title == localization.localized(.print), let authManager = authManager {
                PrintOptionsView(viewModel: viewModel, authManager: authManager, platforms: viewModel.platforms)
            }
        }
    }
}

// Shared grid: Platform and Products match Stats (Total Sales, Top Seller, etc.) – same size and spacing
private let sharedGridBoxHeight: CGFloat = 50
private let sharedGridSpacing: CGFloat = 8

// MARK: - Platform Section
struct PlatformSection: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @Binding var selectedPlatform: String
    @State private var showingAddPlatform = false
    @State private var platformToDelete: Platform?
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    private var defaultPlatforms: [Platform] { viewModel.platforms.filter { !$0.isCustom } }
    private var customPlatforms: [Platform] { viewModel.platforms.filter { $0.isCustom } }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localization.localized(.platform))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                Spacer()
                Button(action: { showingAddPlatform = true }) {
                    Text("+ Add")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(theme.accentColor))
                }
            }
            
            GeometryReader { geo in
                let boxWidth = max(60, (geo.size.width - sharedGridSpacing * 3) / 4)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: sharedGridSpacing) {
                        platformBox(icon: "square.grid.2x2", title: localization.localized(.all),
                                   isSelected: selectedPlatform == "All" || viewModel.selectedPlatform == nil,
                                   iconColor: theme.textPrimary, width: boxWidth, onDelete: nil) {
                            selectedPlatform = "All"
                            viewModel.selectedPlatform = nil
                        }
                        ForEach(defaultPlatforms) { platform in
                            platformBox(icon: platform.icon, title: platform.name,
                                       isSelected: selectedPlatform == platform.name || viewModel.selectedPlatform?.id == platform.id,
                                       iconColor: platform.swiftUIColor, width: boxWidth, onDelete: nil) {
                                selectedPlatform = platform.name
                                viewModel.selectedPlatform = platform
                            }
                        }
                        ForEach(customPlatforms) { platform in
                            platformBox(icon: platform.icon, title: platform.name,
                                       isSelected: selectedPlatform == platform.name || viewModel.selectedPlatform?.id == platform.id,
                                       iconColor: platform.swiftUIColor, width: boxWidth, onDelete: { platformToDelete = platform }) {
                                selectedPlatform = platform.name
                                viewModel.selectedPlatform = platform
                            }
                        }
                    }
                }
            }
            .frame(height: sharedGridBoxHeight + 4)
            
            // 3-dot scroll hint below – always visible when custom platforms exist
            if !customPlatforms.isEmpty {
                HStack(spacing: 4) {
                    Spacer()
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(theme.textMuted.opacity(0.6))
                            .frame(width: 4, height: 4)
                    }
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 11)
                .fill(theme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(theme.cardBorder, lineWidth: 1))
        )
        .sheet(isPresented: $showingAddPlatform) {
            AddPlatformSheetWrapper(viewModel: viewModel, localization: localization, themeManager: themeManager)
        }
        .confirmationDialog("Delete Platform?", isPresented: Binding(
            get: { platformToDelete != nil },
            set: { if !$0 { platformToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let p = platformToDelete { viewModel.deletePlatform(p) }
                platformToDelete = nil
            }
            Button("Cancel", role: .cancel) { platformToDelete = nil }
        } message: {
            Text("Remove \"\(platformToDelete?.name ?? "")\" from your platforms?")
        }
    }
    
    private func platformBox(icon: String, title: String, isSelected: Bool, iconColor: Color, width: CGFloat, onDelete: (() -> Void)?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(isSelected ? theme.textPrimary : theme.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(width: width, height: sharedGridBoxHeight)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(isSelected ? theme.cardBackground : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(isSelected ? theme.accentColor : theme.cardBorder.opacity(0.3), lineWidth: 1)
                    )
            )
            .overlay(alignment: .topTrailing) {
                if onDelete != nil {
                    Button { onDelete?() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(theme.textMuted)
                    }
                    .padding(4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlatformButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var iconColor: Color = .white
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 19))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(isSelected ? theme.textPrimary : theme.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(isSelected ? theme.cardBackground : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(
                                isSelected ? theme.accentColor : theme.cardBorder.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

// MARK: - Products Section
struct ProductsSection: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    var onProductSelected: (Product) -> Void
    var onUpgrade: (() -> Void)? = nil
    @State private var showingAddProduct = false
    @State private var editingProduct: Product?
    @State private var newProductToAdd: Product?
    @State private var showMaxProductsAlert = false
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    private var activeProductCount: Int {
        viewModel.products.filter { !$0.isEmpty }.count
    }
    
    /// Non-empty products only (max 12), for grid display.
    private var displayProducts: [Product] {
        Array(viewModel.products.filter { !$0.isEmpty }.prefix(12))
    }
    
    /// Always at least 1 empty slot to prompt adding a product. Fill first row when < 4 products.
    private var placeholderCount: Int {
        let count = displayProducts.count
        return count < 4 ? (4 - count) : 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(localization.localized(.myProducts)) (\(activeProductCount)/12)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                Text(localization.localized(.tapSellHoldEdit))
                    .font(.system(size: 9))
                    .foregroundColor(theme.textMuted)
                
                Button(action: {
                    if activeProductCount >= 12 {
                        showMaxProductsAlert = true
                    } else {
                        newProductToAdd = Product(name: "", price: 0, stock: 0)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 19))
                        .foregroundColor(theme.accentColor)
                }
            }
            
            // Products Grid - 4 per row, same spacing as Stats and Platform
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: sharedGridSpacing),
                GridItem(.flexible(), spacing: sharedGridSpacing),
                GridItem(.flexible(), spacing: sharedGridSpacing),
                GridItem(.flexible(), spacing: sharedGridSpacing)
            ], spacing: sharedGridSpacing) {
                ForEach(displayProducts) { product in
                    ProductCard(
                        product: product,
                        theme: theme,
                        isPro: authManager.currentUser?.isPro ?? false,
                        onTap: {
                            guard product.stock > 0 else { return }
                            onProductSelected(product)
                        },
                        onHold: { editingProduct = product }
                    )
                }
                ForEach(0..<placeholderCount, id: \.self) { _ in
                    ProductPlaceholder(theme: theme) {
                        if activeProductCount >= 12 {
                            showMaxProductsAlert = true
                        } else {
                            newProductToAdd = Product(name: "", price: 0, stock: 0)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 11)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(theme.cardBorder, lineWidth: 1)
                )
        )
        .sheet(item: $editingProduct) { product in
            EditProductSheet(
                product: product,
                onSave: { updated in
                    viewModel.updateProduct(updated)
                    viewModel.saveData()
                    editingProduct = nil
                },
                onDelete: {
                    if let index = viewModel.products.firstIndex(where: { $0.id == product.id }) {
                        var updated = viewModel.products
                        updated.remove(at: index)
                        viewModel.products = updated
                        viewModel.saveData()
                    }
                    editingProduct = nil
                },
                onCancel: {
                    editingProduct = nil
                },
                isPro: authManager.currentUser?.isPro ?? false,
                onUpgrade: onUpgrade,
                authManager: authManager
            )
        }
        .sheet(item: $newProductToAdd) { product in
            EditProductSheet(
                product: product,
                onSave: { savedProduct in
                    if let index = viewModel.products.firstIndex(where: { $0.id == product.id }) {
                        viewModel.products[index] = savedProduct
                    } else {
                        viewModel.products.append(savedProduct)
                    }
                    viewModel.saveData()
                    newProductToAdd = nil
                },
                onDelete: {
                    newProductToAdd = nil
                },
                onCancel: {
                    newProductToAdd = nil
                },
                isPro: authManager.currentUser?.isPro ?? false,
                onUpgrade: onUpgrade,
                authManager: authManager
            )
        }
        .alert("Maximum Products Reached", isPresented: $showMaxProductsAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can have up to 12 products. Delete one to add a new product.")
        }
    }
}

struct ProductPlaceholder: View {
    let theme: AppTheme
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            ZStack {
                Rectangle()
                    .fill(theme.cardBackground.opacity(0.5))
                    .frame(height: sharedGridBoxHeight)
                
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 18))
                        .foregroundColor(theme.textMuted)
                    
                    Text("Hold to add\nproduct")
                        .font(.caption2)
                        .foregroundColor(theme.textMuted)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(height: sharedGridBoxHeight)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundColor(theme.accentColor)
            )
        }
    }
}

struct ProductCard: View {
    let product: Product
    let theme: AppTheme
    let isPro: Bool
    let onTap: () -> Void
    let onHold: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isPro, let imageData = product.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: sharedGridBoxHeight)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(theme.cardBackground.opacity(0.6))
                        .frame(height: sharedGridBoxHeight)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(theme.textMuted.opacity(0.5))
                        )
                }
                
                // Theme-based gradient overlay for text readability (no black)
                LinearGradient(
                    colors: [Color.clear, (theme.gradientColors.last ?? theme.accentColor).opacity(0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.name.isEmpty ? "Product" : product.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .shadow(radius: 1)
                        
                        HStack {
                            Text("$\(String(format: "%.2f", product.finalPrice))")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(product.stock == 0 ? .gray : .white)
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                Text("Stock:")
                                    .font(.caption2)
                                    .foregroundColor(product.stock == 0 ? .gray : .white.opacity(0.95))
                                Text("\(product.stock)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(product.stockColor)
                            }
                        }
                    }
                    .padding(4)
                }
            }
            .frame(height: sharedGridBoxHeight)
            .cornerRadius(10)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(product.stock == 0 && !product.isEmpty ? theme.textMuted : theme.accentColor, lineWidth: 1)
            )
            .opacity(product.stock == 0 && !product.isEmpty ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in onHold() }
        )
    }
}

// MARK: - Orders Flexible Section
struct OrdersFlexibleSection: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var authManager: AuthManager
    @Binding var selectedPlatform: String
    @Binding var selectedStatus: String
    @State private var orderToDelete: Order?
    @State private var showSwipeDeleteConfirmation = false
    @State private var editingOrder: Order?
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    private var filteredOrders: [Order] {
        var orders = viewModel.orders
        
        // Filter by platform
        if selectedPlatform != "All" {
            orders = orders.filter { $0.platform.name == selectedPlatform }
        }
        
        // Filter by status
        if selectedStatus == "Pending" {
            orders = orders.filter { !$0.isFulfilled }
        } else if selectedStatus == "Completed" {
            orders = orders.filter { $0.isFulfilled }
        }
        
        return orders
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(localization.localized(.orders))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                HStack(spacing: 7) {
                    Menu {
                        Button {
                            selectedPlatform = "All"
                            viewModel.filterPlatform = nil
                        } label: {
                            Text("All Platforms")
                        }
                        ForEach(viewModel.platforms) { platform in
                            Button {
                                selectedPlatform = platform.name
                                viewModel.filterPlatform = platform
                            } label: {
                                Text(platform.name)
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text(selectedPlatform == "All" ? localization.localized(.all) : selectedPlatform)
                                .font(.system(size: 10))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 7))
                        }
                        .foregroundColor(theme.textMuted)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(theme.cardBackground.opacity(0.5))
                        )
                    }
                    
                    Menu {
                        Button { selectedStatus = "All" } label: { Text("All") }
                        Button { selectedStatus = "Pending" } label: { Text("Pending") }
                        Button { selectedStatus = "Completed" } label: { Text("Completed") }
                    } label: {
                        HStack(spacing: 3) {
                            Text(selectedStatus)
                                .font(.system(size: 10))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 7))
                        }
                        .foregroundColor(theme.textMuted)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(theme.cardBackground.opacity(0.5))
                        )
                    }
                }
            }
            .padding(15)
            
            // Divider
            Rectangle()
                .fill(theme.cardBorder.opacity(0.3))
                .frame(height: 1)
            
            // Content - FILLS ALL AVAILABLE SPACE TO BOTTOM
            if filteredOrders.isEmpty {
                // Empty State - helpful copy
                VStack(spacing: 15) {
                    Spacer()
                    Text("🛍️")
                        .font(.system(size: 44))
                    Image(systemName: "basket.fill")
                        .font(.system(size: 42))
                        .foregroundColor(theme.textMuted.opacity(0.5))
                    Text(localization.localized(.noOrders))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(theme.textMuted)
                    Text("Tap a product below to add your first order!")
                        .font(.system(size: 13))
                        .foregroundColor(theme.textMuted.opacity(0.9))
                        .multilineTextAlignment(.center)
                    Text("Or tap [+] to add a product first.")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textMuted.opacity(0.7))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredOrders) { order in
                        OrderRowView(
                            order: order,
                            theme: theme,
                            localization: localization,
                            productImageData: (authManager.currentUser?.isPro == true) ? viewModel.products.first(where: { $0.id == order.productId })?.imageData : nil,
                            onEdit: { editingOrder = order }
                        )
                        .listRowInsets(EdgeInsets(top: 1, leading: 10, bottom: 1, trailing: 10))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                orderToDelete = order
                                showSwipeDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(maxHeight: .infinity)
            }
        }
        .confirmationDialog("Delete this order?", isPresented: $showSwipeDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let order = orderToDelete {
                    HapticManager.warning()
                    viewModel.deleteOrder(order)
                }
                orderToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                orderToDelete = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
        .sheet(item: $editingOrder) { order in
            EditOrderSheet(
                order: order,
                platforms: viewModel.platforms,
                onSave: { viewModel.updateOrder($0); editingOrder = nil },
                onCancel: { editingOrder = nil }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .background(
            RoundedRectangle(cornerRadius: 11)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(theme.cardBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Order Row View
struct OrderRowView: View {
    let order: Order
    let theme: AppTheme
    @ObservedObject var localization: LocalizationManager
    var productImageData: Data?
    var onEdit: (() -> Void)? = nil
    
    private let thumbSize: CGFloat = 28
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Rectangle()
                .fill(order.platform.swiftUIColor)
                .frame(width: 2)
            
            if let data = productImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: thumbSize, height: thumbSize)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .clipped()
            } else {
                Color.clear
                    .frame(width: thumbSize, height: thumbSize)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(order.buyerName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                Text(order.productName)
                    .font(.system(size: 10))
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)
                HStack(spacing: 2) {
                    Text("\(order.quantity) u")
                    Text("•")
                    Text("$\(order.pricePerUnit, specifier: "%.1f")")
                }
                .font(.system(size: 9))
                .foregroundColor(theme.textMuted)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 1) {
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.accentColor)
                Text(order.timestamp, style: .time)
                    .font(.system(size: 8))
                    .foregroundColor(theme.textMuted)
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(theme.cardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .strokeBorder(theme.cardBorder.opacity(0.3), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit?()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            HapticManager.lightImpact()
            onEdit?()
        }
    }
}

// MARK: - Add Platform Sheet Wrapper
struct AddPlatformSheetWrapper: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var platformName = ""
    @State private var platformColor = "orange"
    
    private let colorOptions = ["pink", "purple", "blue", "orange", "green", "red", "yellow", "cyan", "indigo", "mint", "teal", "brown"]
    
    var body: some View {
        AddPlatformSheet(
            platformName: $platformName,
            platformColor: $platformColor,
            colorOptions: colorOptions,
            existingPlatforms: viewModel.platforms,
            localization: localization,
            onAdd: { name in
                let trimmedName = name.trimmingCharacters(in: .whitespaces)
                if viewModel.platforms.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
                    return false
                }
                let newPlatform = Platform(name: trimmedName, icon: "star.fill", color: platformColor, isCustom: true)
                viewModel.platforms.append(newPlatform)
                platformName = ""
                dismiss()
                return true
            },
            onCancel: {
                platformName = ""
                dismiss()
            }
        )
        .presentationDetents([.height(320)])
    }
}

