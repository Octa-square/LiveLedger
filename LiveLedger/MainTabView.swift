//
//  MainTabView.swift
//  LiveLedger
//
//  Bottom Navigation Bar with 5 Tabs
//

import SwiftUI

// MARK: - Tab Enum
enum AppTab: Int, CaseIterable {
    case home = 0
    case analytics = 1
    case timer = 2
    case orders = 3
    case more = 4
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .analytics: return "Analytics"
        case .timer: return "Timer"
        case .orders: return "Orders"
        case .more: return "More"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .analytics: return "chart.bar.fill"
        case .timer: return "timer"
        case .orders: return "shippingbox.fill"
        case .more: return "ellipsis"
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @StateObject private var viewModel = SalesViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab: AppTab = .home
    
    private var theme: AppTheme { themeManager.currentTheme }
    private let accentGreen = Color(red: 0, green: 0.8, blue: 0.53) // #00cc88
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Area
            TabContent(
                selectedTab: selectedTab,
                viewModel: viewModel,
                themeManager: themeManager,
                authManager: authManager,
                localization: localization
            )
            
            // Bottom Navigation Bar
            BottomNavBar(
                selectedTab: $selectedTab,
                isTimerRunning: viewModel.isTimerRunning,
                accentColor: accentGreen
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Tab Content Switcher
struct TabContent: View {
    let selectedTab: AppTab
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    
    var body: some View {
        switch selectedTab {
        case .home:
            HomeTabView(
                viewModel: viewModel,
                themeManager: themeManager,
                authManager: authManager,
                localization: localization
            )
        case .analytics:
            AnalyticsTabView(
                viewModel: viewModel,
                themeManager: themeManager,
                localization: localization
            )
        case .timer:
            TimerTabView(
                viewModel: viewModel,
                themeManager: themeManager
            )
        case .orders:
            OrdersTabView(
                viewModel: viewModel,
                themeManager: themeManager,
                authManager: authManager,
                localization: localization
            )
        case .more:
            MoreTabView(
                viewModel: viewModel,
                themeManager: themeManager,
                authManager: authManager,
                localization: localization
            )
        }
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavBar: View {
    @Binding var selectedTab: AppTab
    let isTimerRunning: Bool
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                BottomNavItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    isTimerRunning: tab == .timer && isTimerRunning,
                    accentColor: accentColor
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20) // Safe area for home indicator
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.95))
                .overlay(
                    Rectangle()
                        .fill(accentColor)
                        .frame(height: 2),
                    alignment: .top
                )
        )
    }
}

// MARK: - Individual Nav Item
struct BottomNavItem: View {
    let tab: AppTab
    let isSelected: Bool
    let isTimerRunning: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: .medium))
                    
                    // Red dot indicator when timer is running
                    if isTimerRunning {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 12, y: -8)
                    }
                }
                
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isTimerRunning ? .red : (isSelected ? accentColor : .gray))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .overlay(
                Rectangle()
                    .fill(isSelected ? accentColor : .clear)
                    .frame(height: 3)
                    .offset(y: -20),
                alignment: .top
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Home Tab (Existing Main Content)
struct HomeTabView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    // Grid container styling
    private let containerCornerRadius: CGFloat = 12
    private let containerBorderColor: Color = Color(red: 0, green: 0.8, blue: 0.53)
    private let containerBorderWidth: CGFloat = 2
    private let containerBackground: Color = Color.black.opacity(0.75)
    private let horizontalMargin: CGFloat = 11
    private let internalPadding: CGFloat = 10
    private let containerSpacing: CGFloat = 8
    
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
            .padding(.horizontal, horizontalMargin)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Wallpaper
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                    )
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .ignoresSafeArea(.all, edges: .all)
                
                Color.black.opacity(0.15)
                    .ignoresSafeArea(.all, edges: .all)
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: containerSpacing) {
                        // Header + Stats + Actions
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
                        
                        // Platform Section
                        gridContainer {
                            PlatformSelectorView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization
                            )
                        }
                        
                        // Free Tier Banner
                        if let user = authManager.currentUser, !user.isPro {
                            gridContainer {
                                FreeTierBannerContent(user: user, theme: theme) {
                                    showSubscription = true
                                }
                            }
                        }
                        
                        // My Products
                        gridContainer {
                            QuickAddView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                authManager: authManager,
                                localization: localization,
                                onLimitReached: {
                                    limitAlertMessage = "You've used all 20 free orders. Upgrade to Pro for unlimited orders!"
                                    showLimitAlert = true
                                }
                            )
                        }
                        
                        // Orders Container - FULL 270pt HEIGHT (NEVER SHORTENED)
                        // Bottom nav overlays this area, orders scroll above nav with internal padding
                        gridContainer {
                            OrdersListView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization,
                                authManager: authManager
                            )
                            .frame(minHeight: max(270, geometry.size.height * 0.38))
                        }
                        .padding(.bottom, 80) // Internal padding so orders scroll above bottom nav
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 0) // No extra bottom padding - Orders extends full height
                }
                
                // TikTok Overlay
                TikTokLiveOverlayView(viewModel: viewModel, themeManager: themeManager)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization)
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
        }
        .alert("Upgrade Required", isPresented: $showLimitAlert) {
            Button("Upgrade to Pro") { showSubscription = true }
            Button("Later", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
    }
}

// MARK: - Analytics Tab
struct AnalyticsTabView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Wallpaper - FULL SCREEN (no black cutoff)
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                    )
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .ignoresSafeArea(.all, edges: .all)
                
                Color.black.opacity(0.15)
                    .ignoresSafeArea(.all, edges: .all)
                
                // Analytics Content - DYNAMIC with real viewModel data
                NavigationStack {
                    AnalyticsView(viewModel: viewModel, localization: localization)
                        .padding(.bottom, 80) // Space for bottom nav
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Timer Tab
struct TimerTabView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    
    private var theme: AppTheme { themeManager.currentTheme }
    private let accentGreen = Color(red: 0, green: 0.8, blue: 0.53)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Wallpaper - FULL SCREEN (no black cutoff)
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                    )
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .ignoresSafeArea(.all, edges: .all)
                
                Color.black.opacity(0.3)
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Timer Status
                    Text(viewModel.isTimerRunning ? "SESSION ACTIVE" : (viewModel.isTimerPaused ? "PAUSED" : "READY"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.isTimerRunning ? .green : (viewModel.isTimerPaused ? .orange : .gray))
                        .tracking(3)
                    
                    // Large Timer Display
                    Text(viewModel.formattedSessionTime)
                        .font(.system(size: 72, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: accentGreen.opacity(0.5), radius: 10)
                    
                    // Session Stats
                    HStack(spacing: 40) {
                        VStack(spacing: 4) {
                            Text("\(viewModel.orderCount)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Orders")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            Text("$\(viewModel.totalRevenue, specifier: "%.2f")")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(accentGreen)
                            Text("Revenue")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Timer Controls
                    HStack(spacing: 20) {
                        // Start/Resume Button
                        if !viewModel.isTimerRunning {
                            Button {
                                if viewModel.isTimerPaused {
                                    viewModel.resumeTimer()
                                } else {
                                    viewModel.startTimer()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 20))
                                    Text(viewModel.isTimerPaused ? "Resume" : "Start")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(width: 130, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.green)
                                )
                            }
                        }
                        
                        // Pause Button
                        if viewModel.isTimerRunning {
                            Button {
                                viewModel.pauseTimer()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "pause.fill")
                                        .font(.system(size: 20))
                                    Text("Pause")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(width: 130, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.orange)
                                )
                            }
                        }
                        
                        // Stop/Reset Button
                        if viewModel.isTimerRunning || viewModel.isTimerPaused || viewModel.sessionElapsedTime > 0 {
                            Button {
                                viewModel.resetTimer()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 20))
                                    Text("Stop")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(width: 130, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.red)
                                )
                            }
                        }
                    }
                    
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Space for bottom nav
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Orders Tab (Full History)
struct OrdersTabView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    
    private var theme: AppTheme { themeManager.currentTheme }
    private let accentGreen = Color(red: 0, green: 0.8, blue: 0.53)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Wallpaper - FULL SCREEN (no black cutoff)
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                    )
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .ignoresSafeArea(.all, edges: .all)
                
                Color.black.opacity(0.2)
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("All Orders")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(viewModel.orders.count) total")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(accentGreen)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                    
                    // Orders List
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.orders.sorted(by: { $0.timestamp > $1.timestamp })) { order in
                                OrderRowCard(order: order, theme: theme)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // Space for bottom nav
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Order Row Card for Orders Tab
struct OrderRowCard: View {
    let order: Order
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Platform indicator
            Circle()
                .fill(order.platform.swiftUIColor)
                .frame(width: 8, height: 8)
            
            // Product & Buyer
            VStack(alignment: .leading, spacing: 2) {
                Text(order.productName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(order.buyerName)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Quantity & Price
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0, green: 0.8, blue: 0.53))
                Text("×\(order.quantity)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - More Tab
struct MoreTabView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var showSettings = false
    @State private var showTutorial = false
    @State private var tutorialBinding = true // Dummy binding for re-tutorial
    
    private var theme: AppTheme { themeManager.currentTheme }
    private let accentGreen = Color(red: 0, green: 0.8, blue: 0.53)
    
    let menuItems: [(icon: String, title: String, color: Color)] = [
        ("clock.arrow.circlepath", "Recent Sessions", .blue),
        ("square.and.arrow.up", "Export Data", .orange),
        ("questionmark.circle", "Help & Tutorial", .purple),
        ("wifi", "Network Test", .cyan),
        ("person.2", "Team Management", .pink),
        ("externaldrive", "Backup & Restore", .green),
        ("info.circle", "About LiveLedger", .gray),
        ("rectangle.portrait.and.arrow.right", "Sign Out", .red)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Wallpaper - FULL SCREEN (no black cutoff)
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
                    )
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .ignoresSafeArea(.all, edges: .all)
                
                Color.black.opacity(0.3)
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack(spacing: 0) {
                    // Header
                    Text("More")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 15)
                    
                    // Menu Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(menuItems, id: \.title) { item in
                                MoreMenuItem(
                                    icon: item.icon,
                                    title: item.title,
                                    color: item.color
                                ) {
                                    handleMenuTap(item.title)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // Space for bottom nav
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization)
        }
        .sheet(isPresented: $showTutorial) {
            OnboardingView(localization: localization, hasCompletedOnboarding: $tutorialBinding, isReTutorial: true)
        }
    }
    
    private func handleMenuTap(_ title: String) {
        switch title {
        case "Help & Tutorial":
            showTutorial = true
        case "Sign Out":
            authManager.signOut()
        default:
            break
        }
    }
}

// More Menu Item
struct MoreMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    MainTabView(
        authManager: AuthManager(),
        localization: LocalizationManager.shared
    )
}

