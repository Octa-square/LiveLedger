//
//  ContentView.swift
//  LiveLedger
//
//  LiveLedger - Main View with Auto-Save
//

import SwiftUI

struct MainContentView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @StateObject private var viewModel = SalesViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    // GRID CONTAINER STYLE - Green border, rounded corners, semi-transparent
    // All containers use IDENTICAL styling
    private let containerCornerRadius: CGFloat = 12
    private let containerBorderColor: Color = Color(red: 0, green: 0.8, blue: 0.53) // #00cc88 green
    private let containerBorderWidth: CGFloat = 2
    private let containerBackground: Color = Color.black.opacity(0.75)
    private let horizontalMargin: CGFloat = 11 // 22pt total from edge (11 + 11 padding)
    private let internalPadding: CGFloat = 10 // Reduced from 12 for compactness
    private let containerSpacing: CGFloat = 8  // Reduced from 12 - compact 8pt gaps between containers
    
    // Reusable container modifier
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
                // LAYER 1: WALLPAPER - Full screen from TOP to BOTTOM (no black cutoff)
                // Maintains aspect ratio (scaledToFill) - may crop sides but won't stretch
                // Frame includes extra height to cover bottom safe area
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
                
                // LAYER 2: Subtle dark overlay for text readability (also full screen)
                Color.black.opacity(0.15)
                    .ignoresSafeArea(.all, edges: .all)
                
                // LAYER 3: CONTENT - Grid containers with green borders
                // All containers have IDENTICAL styling: green border, 12px rounded corners ALL FOUR SIDES
                // UI dimensions are INDEPENDENT of wallpaper - fixed measurements
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: containerSpacing) {
                        // CONTAINER 1: Header + Stats + Action Buttons
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
                        
                        // CONTAINER 2: Platform Section
                        gridContainer {
                            PlatformSelectorView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization
                            )
                        }
                        
                        // FREE TIER BANNER (if applicable) - same styling
                        if let user = authManager.currentUser, !user.isPro {
                            gridContainer {
                                FreeTierBannerContent(user: user, theme: theme) {
                                    showSubscription = true
                                }
                            }
                        }
                        
                        // CONTAINER 3: My Products Section
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
                        
                        // CONTAINER 4: Orders Section - EXTENDED to show 8-10 orders
                        // Height: ~270pt (fills remaining screen space)
                        gridContainer {
                            OrdersListView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization,
                                authManager: authManager
                            )
                            .frame(minHeight: max(270, geometry.size.height * 0.38))
                        }
                    }
                    .padding(.top, 4)  // Minimal top padding - start near status bar
                    .padding(.bottom, 12) // Small gap at bottom for wallpaper peek
                }
                
                // TikTok Live Overlay (floats above everything)
                TikTokLiveOverlayView(viewModel: viewModel, themeManager: themeManager)
            }
        }
        .preferredColorScheme(.dark) // Force dark for better contrast
        // Auto-save listener
        .onReceive(NotificationCenter.default.publisher(for: .autoSaveData)) { _ in
            viewModel.saveData()
        }
        .confirmationDialog("Clear All Data?", isPresented: $viewModel.showingClearConfirmation, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) {
                viewModel.clearAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all orders and reset products. This cannot be undone.")
        }
        .alert("Upgrade Required", isPresented: $showLimitAlert) {
            Button("Upgrade to Pro") { showSubscription = true }
            Button("Later", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
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
                        }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(themeManager: themeManager, authManager: authManager, localization: localization)
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
        }
    }
}

// Free tier banner content (without container - container applied by gridContainer)
struct FreeTierBannerContent: View {
    let user: AppUser
    let theme: AppTheme
    let onUpgrade: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Free Plan")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                Text("\(user.remainingFreeOrders) orders • \(user.remainingFreeExports) exports left")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: onUpgrade) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                    Text("Upgrade")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange)
                .cornerRadius(6)
            }
        }
    }
}

// Legacy FreeTierBanner for backwards compatibility
struct FreeTierBanner: View {
    let user: AppUser
    let theme: AppTheme
    let onUpgrade: () -> Void
    
    var body: some View {
        FreeTierBannerContent(user: user, theme: theme, onUpgrade: onUpgrade)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Wavy Bottom Container Shape
struct WavyBottomContainer: Shape {
    var cornerRadius: CGFloat = 16
    var waveHeight: CGFloat = 25
    var waveCount: Int = 5
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let waveBaseY = height - waveHeight
        
        // Start at top-left corner
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top-left rounded corner
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        // Top edge
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        
        // Top-right rounded corner
        path.addQuadCurve(
            to: CGPoint(x: width, y: cornerRadius),
            control: CGPoint(x: width, y: 0)
        )
        
        // Right edge down to wave start
        path.addLine(to: CGPoint(x: width, y: waveBaseY))
        
        // Create smooth wave pattern at bottom
        // Using sine-wave-like curves for organic flow
        let waveSegmentWidth = width / CGFloat(waveCount)
        
        for i in 0..<waveCount {
            let segmentStartX = width - (waveSegmentWidth * CGFloat(i))
            let segmentEndX = segmentStartX - waveSegmentWidth
            let controlY = (i % 2 == 0) ? height : waveBaseY - waveHeight * 0.5
            
            path.addQuadCurve(
                to: CGPoint(x: segmentEndX, y: waveBaseY),
                control: CGPoint(x: (segmentStartX + segmentEndX) / 2, y: controlY)
            )
        }
        
        // Left edge back up
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        path.closeSubpath()
        return path
    }
}

// Keep ContentView for previews
struct ContentView: View {
    var body: some View {
        MainContentView(authManager: AuthManager(), localization: LocalizationManager.shared)
    }
}

#Preview {
    let mockAuthManager = AuthManager()
    mockAuthManager.currentUser = AppUser(
        id: "preview-user",
        email: "preview@example.com",
        passwordHash: "preview",
        name: "Preview User",
        companyName: "My Shop",
        currency: "USD ($)",
        isPro: true,
        ordersUsed: 5,
        exportsUsed: 2,
        referralCode: "PREVIEW123",
        createdAt: Date()
    )
    mockAuthManager.isAuthenticated = true
    
    return MainContentView(
        authManager: mockAuthManager,
        localization: LocalizationManager.shared
    )
}
