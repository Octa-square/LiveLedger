//
//  MainTabView.swift
//  LiveLedger
//
//  STATIC SINGLE-SCREEN LAYOUT - NO BOTTOM NAVIGATION
//  All content fits on one iPhone screen without scrolling
//

import SwiftUI

// MARK: - Main View (Single Screen - No Bottom Nav)
struct MainTabView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @StateObject private var viewModel = SalesViewModel()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        // Single screen layout - NO tabs, NO bottom navigation
        HomeScreenView(
            viewModel: viewModel,
            themeManager: themeManager,
            authManager: authManager,
            localization: localization
        )
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
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    // Grid container styling - STATIC LAYOUT (BRIGHTER COLORS)
    private let containerCornerRadius: CGFloat = 12
    private var containerBorderColor: Color { theme.accentColor } // Uses theme's bright accent
    private let containerBorderWidth: CGFloat = 2
    private var containerBackground: Color { theme.isDarkTheme ? Color.black.opacity(0.75) : Color.white.opacity(0.85) }
    private let horizontalMargin: CGFloat = 11
    private let internalPadding: CGFloat = 10
    
    // FIXED CONTAINER HEIGHTS (Static layout - fits on iPhone screen)
    // Total available: ~667pt (iPhone 8) or ~844pt (iPhone 14)
    // Status bar: ~44pt, Safe area bottom: ~34pt
    // Available content height: ~589pt (iPhone 8) or ~766pt (iPhone 14)
    
    private let containerGap: CGFloat = 10  // Gap between containers (10pt each)
    
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
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeWidth = geometry.size.width - (horizontalMargin * 2)
            let safeHeight = geometry.size.height
            
            // Calculate dynamic heights based on screen size
            // Proportional layout that fits any iPhone
            let headerHeight: CGFloat = safeHeight * 0.20   // ~130pt on iPhone 8
            let platformHeight: CGFloat = safeHeight * 0.14  // ~90pt on iPhone 8
            let productsHeight: CGFloat = safeHeight * 0.18  // ~110pt on iPhone 8
            // Orders fills remaining space (no fixed height - uses Spacer)
            
            ZStack {
                // Wallpaper - STRETCHED HORIZONTALLY to fill screen width
                Image(theme.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Stretch to fill
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
                
                // STATIC LAYOUT - All containers fit on one screen
                // NO page scrolling - only Orders has internal scroll
                VStack(spacing: containerGap) {
                    // === CONTAINER 1: Header + Stats + Actions ===
                    // FIXED at top, proportional height - MOVED UP by 7pt
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
                    .offset(y: -7) // Move Header UP by 7pt ONLY
                    
                    // === CONTAINER 2: Platform Section ===
                    // FIXED position, proportional height
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
                    // FIXED position, proportional height (max 12 products)
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
                    .frame(width: safeWidth, height: productsHeight)
                    .padding(.horizontal, horizontalMargin)
                    .clipped()
                    
                    // === CONTAINER 4: Orders ===
                    // FILLS REMAINING SPACE - internal scroll only
                    // No fixed height - expands to fill available space to bottom
                    gridContainer {
                        OrdersListView(
                            viewModel: viewModel,
                            themeManager: themeManager,
                            localization: localization,
                            authManager: authManager
                        )
                    }
                    .frame(width: safeWidth)
                    .frame(maxHeight: .infinity) // Fill remaining space
                    .padding(.horizontal, horizontalMargin)
                    .clipped()
                }
                .padding(.top, 6) // Reduced - move header UP for equal gaps
                .padding(.bottom, 15) // 15pt from bottom (black area starts after Orders)
                
                // TikTok Overlay (floating widget - separate from layout)
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
        .sheet(isPresented: $showAnalytics) {
            NavigationStack {
                AnalyticsView(viewModel: viewModel, localization: localization)
            }
        }
        .alert("Upgrade Required", isPresented: $showLimitAlert) {
            Button("Upgrade to Pro") { showSubscription = true }
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
