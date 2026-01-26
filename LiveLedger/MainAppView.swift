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
    @StateObject private var viewModel = SalesViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedPlatform = "All"
    @State private var selectedStatus = "All"
    @State private var selectedProductForOrder: Product?
    @State private var buyerName: String = ""
    @State private var orderQuantity: Int = 1
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    
    private var limitAlertTitle: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Subscription Expired" : "Upgrade Required"
    }
    
    private var limitAlertButtonText: String {
        authManager.currentUser?.isLapsedSubscriber == true ? "Resubscribe to Pro" : "Upgrade to Pro"
    }
    
    var body: some View {
        ZStack {
                VStack(spacing: 0) {
                    // FIXED HEADER - WITH TIMER INTEGRATED (centered in header)
                    FixedHeaderView(
                        authManager: authManager,
                        viewModel: viewModel,
                        themeManager: themeManager,
                        localization: localization
                    )
                    
                    // MAIN CONTENT - NO GAPS, ORDERS FILLS TO BOTTOM
                VStack(spacing: 0) {
                    // Scrollable sections - Stats, Platform, Products
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 15) {  // CRITICAL: 15px spacing between ALL sections
                            StatsAndActionsSection(
                                viewModel: viewModel,
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
                                }
                            )
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 15)
                        .padding(.bottom, 0)  // CRITICAL: No bottom padding - eliminates gap
                    }
                    .layoutPriority(1)  // CRITICAL: Allows this to shrink
                    
                    // Orders Section - FILLS REMAINING SPACE TO BOTTOM
                    OrdersFlexibleSection(
                        viewModel: viewModel,
                        themeManager: themeManager,
                        localization: localization,
                        authManager: authManager,
                        selectedPlatform: $selectedPlatform,
                        selectedStatus: $selectedStatus
                    )
                    .frame(maxHeight: .infinity)  // CRITICAL: Expands to fill all remaining space
                    .padding(.horizontal, 15)
                    .padding(.top, 15)  // CRITICAL: Only 15px gap from Products
                    .padding(.bottom, 0)  // CRITICAL: Extends to bottom edge - no padding
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
                
                // Buyer Popup - Overlay on top
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
        }
        .onAppear {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.sizeRestrictions?.minimumSize = CGSize(width: 660, height: 1000)
                }
            }
            #endif
        }
        .alert(limitAlertTitle, isPresented: $showLimitAlert) {
            Button(limitAlertButtonText) {
                // Show subscription
            }
            Button("Later", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
    }
}

// MARK: - Fixed Header Component
struct FixedHeaderView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @State private var showSettings = false
    @State private var showSubscription = false
    
    private var isPro: Bool {
        authManager.currentUser?.isPro ?? false
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // LEFT: Logo and App Info
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#00ff88"), Color(hex: "#00cc6a")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color(hex: "#00ff88").opacity(0.4), radius: 7, x: 0, y: 3)
                    
                    // Try to use app_logo asset, fallback to "L" if not available
                    if UIImage(named: "app_logo") != nil {
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    } else {
                        Text("L")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("LiveLedger")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)  // CRITICAL: Prevents wrapping to second line
                        .minimumScaleFactor(0.7)  // CRITICAL: Shrinks text instead of wrapping
                    
                    Text("My Store")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#888888"))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // CENTER: Timer with Controls
            HStack(spacing: 8) {
                Text(viewModel.formattedSessionTime)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .frame(minWidth: 80)
                
                Button(action: {
                    if !viewModel.isTimerRunning {
                        viewModel.startTimer()
                    }
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                        .foregroundColor(viewModel.isTimerRunning ? Color(hex: "#444444") : Color(hex: "#00ff88"))
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                .disabled(viewModel.isTimerRunning)
                
                Button(action: {
                    if viewModel.isTimerRunning {
                        viewModel.pauseTimer()
                    }
                }) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 10))
                        .foregroundColor(viewModel.isTimerRunning ? Color(hex: "#ffd700") : Color(hex: "#444444"))
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                .disabled(!viewModel.isTimerRunning)
                
                Button(action: {
                    viewModel.resetTimer()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#ff6b6b"))
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color(hex: "#00ff88").opacity(0.2), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // RIGHT: Badges and Menu
            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 3) {
                    // PRO/FREE Badge
                    Text(isPro ? "PRO" : "FREE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(isPro ? Color(hex: "#ffd700") : Color(hex: "#888888"))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(isPro ? Color(hex: "#ffd700") : Color(hex: "#888888"), lineWidth: 1)
                                .background(Color.white.opacity(0.1).cornerRadius(5))
                        )
                    
                    // Auto-saving Badge
                    HStack(spacing: 3) {
                        Circle()
                            .fill(Color(hex: "#00ff88"))
                            .frame(width: 7, height: 7)
                        
                        Text("Auto-saving")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color(hex: "#00ff88"))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                
                // Menu Button
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(7)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [Color(hex: "#1a1a1a"), Color(hex: "#2a2a2a")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color(hex: "#00ff88"))
                .shadow(color: Color(hex: "#00ff88").opacity(0.3), radius: 9, x: 0, y: 3),
            alignment: .bottom
        )
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization)
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
        }
    }
}


// MARK: - Stats and Actions Section
struct StatsAndActionsSection: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    
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
            // Stats Cards - 4 in a row
            HStack(spacing: 11) {
                MainAppStatCard(
                    icon: "dollarsign.circle.fill",
                    value: "\(currencySymbol)\(String(format: "%.0f", viewModel.totalRevenue))",
                    label: localization.localized(.totalSales),
                    color: Color(hex: "#00ff88")
                )
                MainAppStatCard(
                    icon: "flame.fill",
                    value: topSellerName,
                    label: localization.localized(.topSeller),
                    color: Color(hex: "#ff9500")
                )
                MainAppStatCard(
                    icon: "cube.fill",
                    value: "\(totalStockLeft)",
                    label: localization.localized(.stockLeft),
                    color: Color(hex: "#007aff")
                )
                MainAppStatCard(
                    icon: "bag.fill",
                    value: "\(viewModel.orderCount)",
                    label: localization.localized(.totalOrders),
                    color: Color(hex: "#00ff88")
                )
            }
            
            // Action Buttons - 3 in a row
            HStack(spacing: 11) {
                MainAppActionButton(
                    title: localization.localized(.clear),
                    icon: "trash.fill",
                    color: Color(hex: "#ff6b6b"),
                    viewModel: viewModel,
                    localization: localization
                )
                MainAppActionButton(
                    title: localization.localized(.export),
                    icon: "square.and.arrow.up.fill",
                    color: Color(hex: "#4ecdc4"),
                    viewModel: viewModel,
                    localization: localization
                )
                MainAppActionButton(
                    title: localization.localized(.print),
                    icon: "printer.fill",
                    color: Color(hex: "#4ecdc4"),
                    viewModel: viewModel,
                    authManager: authManager,
                    localization: localization
                )
            }
            .padding(.top, 11)
        }
        .padding(15)  // Reduced from 16px
        .background(
            RoundedRectangle(cornerRadius: 11)  // Reduced from 12px
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(Color(hex: "#00ff88").opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct MainAppStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {  // Reduced from 6px
            Image(systemName: icon)
                .font(.system(size: 19))  // Reduced from 20px
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 17, weight: .bold))  // Reduced from 18px
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 9))  // Reduced from 10px
                .foregroundColor(Color(hex: "#888888"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)  // Reduced from 10px
        .padding(.horizontal, 5)  // Reduced from 6px
        .background(
            RoundedRectangle(cornerRadius: 7)  // Reduced from 8px
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
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

// MARK: - Platform Section
struct PlatformSection: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @Binding var selectedPlatform: String
    @State private var showingAddPlatform = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {  // Reduced from 12px
            // Header
            HStack {
                Text(localization.localized(.platform))
                    .font(.system(size: 15, weight: .bold))  // Reduced from 16px
                    .foregroundColor(.white)
                
                Spacer()
                
                // Add Button
                Button(action: {
                    showingAddPlatform = true
                }) {
                    Text("+ Add")
                        .font(.system(size: 10, weight: .semibold))  // Reduced from 11px
                        .foregroundColor(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(hex: "#00ff88"))
                        )
                }
            }
            
            // Platform Buttons - 4 in a row
            HStack(spacing: 7) {  // Reduced from 8px
                PlatformButton(
                    icon: "square.grid.2x2",
                    title: localization.localized(.all),
                    isSelected: selectedPlatform == "All" || viewModel.selectedPlatform == nil,
                    iconColor: .white
                ) {
                    selectedPlatform = "All"
                    viewModel.selectedPlatform = nil
                }
                
                ForEach(viewModel.platforms.prefix(3)) { platform in
                    PlatformButton(
                        icon: platform.icon,
                        title: platform.name,
                        isSelected: selectedPlatform == platform.name || viewModel.selectedPlatform?.id == platform.id,
                        iconColor: platform.swiftUIColor  // CRITICAL: Always uses full color, never grayed
                    ) {
                        selectedPlatform = platform.name
                        viewModel.selectedPlatform = platform
                    }
                }
            }
        }
        .padding(15)  // Reduced from 16px
        .background(
            RoundedRectangle(cornerRadius: 11)  // Reduced from 12px
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(Color(hex: "#00ff88").opacity(0.2), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showingAddPlatform) {
            AddPlatformSheetWrapper(viewModel: viewModel, localization: localization, themeManager: themeManager)
        }
    }
}

struct PlatformButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var iconColor: Color = .white
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {  // Reduced from 6px
                Image(systemName: icon)
                    .font(.system(size: 19))  // Reduced from 20px
                    .foregroundColor(iconColor)  // CRITICAL: Always uses full color, never grayed
                
                Text(title)
                    .font(.system(size: 9, weight: .medium))  // Reduced from 10px
                    .foregroundColor(isSelected ? .white : Color(hex: "#666666"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 65)  // Reduced from 70px
            .background(
                RoundedRectangle(cornerRadius: 7)  // Reduced from 8px
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(
                                isSelected ? Color(hex: "#00ff88") : Color.white.opacity(0.1),
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
    @State private var showingAddProduct = false
    @State private var editingProduct: Product?
    @State private var newProductToAdd: Product?
    @State private var showMaxProductsAlert = false
    
    private var activeProductCount: Int {
        viewModel.products.filter { !$0.isEmpty }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {  // Reduced from 12px
            // Header
            HStack {
                Text("\(localization.localized(.myProducts)) (\(activeProductCount)/12)")
                    .font(.system(size: 15, weight: .bold))  // Reduced from 16px
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(localization.localized(.tapSellHoldEdit))
                    .font(.system(size: 9))  // Reduced from 10px
                    .foregroundColor(Color(hex: "#888888"))
                
                Button(action: {
                    if activeProductCount >= 12 {
                        showMaxProductsAlert = true
                    } else {
                        newProductToAdd = Product(name: "", price: 0, stock: 0)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 19))  // Reduced from 20px
                        .foregroundColor(Color(hex: "#00ff88"))
                }
            }
            
            // Products Grid - 4 in a row
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 4), spacing: 7) {  // Reduced from 8px
                ForEach(viewModel.products.prefix(12)) { product in
                    if product.isEmpty {
                        ProductPlaceholder {
                            newProductToAdd = Product(name: "", price: 0, stock: 0)
                        }
                    } else {
                        ProductCard(
                            product: product,
                            onTap: {
                                onProductSelected(product)
                            },
                            onHold: {
                                editingProduct = product
                            }
                        )
                    }
                }
            }
        }
        .padding(15)  // Reduced from 16px
        .background(
            RoundedRectangle(cornerRadius: 11)  // Reduced from 12px
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(Color(hex: "#00ff88").opacity(0.2), lineWidth: 1)
                )
        )
        .sheet(item: $editingProduct) { product in
            EditProductSheet(
                product: product,
                onSave: { updated in
                    viewModel.updateProduct(updated)
                    editingProduct = nil
                },
                onDelete: {
                    if let index = viewModel.products.firstIndex(where: { $0.id == product.id }) {
                        viewModel.products.remove(at: index)
                    }
                    editingProduct = nil
                },
                onCancel: {
                    editingProduct = nil
                },
                isPro: authManager.currentUser?.isPro ?? false
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
                    newProductToAdd = nil
                },
                onDelete: {
                    newProductToAdd = nil
                },
                onCancel: {
                    newProductToAdd = nil
                },
                isPro: authManager.currentUser?.isPro ?? false
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
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 7) {  // Reduced from 8px
                Image(systemName: "plus.circle")
                    .font(.system(size: 23))  // Reduced from 24px
                    .foregroundColor(Color(hex: "#666666"))
                
                Text("Hold to\nadd product")
                    .font(.system(size: 8))  // Reduced from 9px
                    .foregroundColor(Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 85)  // Reduced from 90px
            .background(
                RoundedRectangle(cornerRadius: 7)  // Reduced from 8px
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    let onHold: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name.isEmpty ? "Product" : product.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#00ff88"))
                
                HStack(spacing: 4) {
                    Image(systemName: "cube.fill")
                        .font(.system(size: 8))
                    Text("\(product.stock)")
                        .font(.system(size: 9))
                }
                .foregroundColor(Color(hex: "#888888"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(7)  // Reduced from 8px
            .frame(height: 85)  // Reduced from 90px
            .background(
                RoundedRectangle(cornerRadius: 7)  // Reduced from 8px
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
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
                    .font(.system(size: 15, weight: .bold))  // Reduced from 16px
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 7) {  // Reduced from 8px
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
                                .font(.system(size: 10))  // Reduced from 11px
                            Image(systemName: "chevron.down")
                                .font(.system(size: 7))  // Reduced from 8px
                        }
                        .foregroundColor(Color(hex: "#888888"))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.1))
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
                        .foregroundColor(Color(hex: "#888888"))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
            }
            .padding(15)  // Reduced from 16px
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
            
            // Content - FILLS ALL AVAILABLE SPACE TO BOTTOM
            if filteredOrders.isEmpty {
                // Empty State - Fills remaining space with centered content
                VStack(spacing: 15) {  // Reduced from 16px
                    Spacer()  // Centers content vertically
                    
                    Image(systemName: "basket.fill")
                        .font(.system(size: 48))  // Reduced from 50px
                        .foregroundColor(Color(hex: "#444444"))
                    
                    Text(localization.localized(.noOrders))
                        .font(.system(size: 15, weight: .medium))  // Reduced from 16px
                        .foregroundColor(Color(hex: "#888888"))
                    
                    Text("Tap a product to add orders")
                        .font(.system(size: 12))  // Reduced from 13px
                        .foregroundColor(Color(hex: "#666666"))
                    
                    Spacer()  // Centers content vertically
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)  // CRITICAL: Fills all space
            } else {
                ScrollView {
                    LazyVStack(spacing: 7) {  // Reduced from 8px
                        ForEach(filteredOrders) { order in
                            OrderRowView(order: order, theme: themeManager.currentTheme, localization: localization)
                        }
                    }
                    .padding(15)  // Reduced from 16px
                }
                .frame(maxHeight: .infinity)  // CRITICAL: Fills all space
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 11)  // Reduced from 12px
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(Color(hex: "#00ff88").opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Order Row View
struct OrderRowView: View {
    let order: Order
    let theme: AppTheme
    @ObservedObject var localization: LocalizationManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Platform color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(order.platform.swiftUIColor)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.buyerName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(order.productName)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#888888"))
                
                HStack(spacing: 8) {
                    Text("\(order.quantity) units")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#666666"))
                    
                    Text("•")
                        .foregroundColor(Color(hex: "#666666"))
                    
                    Text("$\(order.pricePerUnit, specifier: "%.2f")/unit")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#666666"))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#00ff88"))
                
                Text(order.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#666666"))
            }
        }
        .padding(11)  // Reduced from 12px
        .background(
            RoundedRectangle(cornerRadius: 7)  // Reduced from 8px
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
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

