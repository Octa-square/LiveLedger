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
    
    // Semi-transparent container background - lets wallpaper show through
    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.65))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // LAYER 1: WALLPAPER - Full screen, visible throughout
                Image(theme.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all)
                
                // LAYER 2: Subtle dark overlay for text readability
                Color.black.opacity(0.15)
                    .ignoresSafeArea(.all)
                
                // LAYER 3: CONTENT - Semi-transparent containers
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        // HEADER SECTION
                        VStack(spacing: 8) {
                            HeaderView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                authManager: authManager,
                                localization: localization,
                                showSettings: $showSettings,
                                showSubscription: $showSubscription
                            )
                            
                            PlatformSelectorView(
                                viewModel: viewModel,
                                themeManager: themeManager,
                                localization: localization
                            )
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.6))
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                        )
                        .padding(.horizontal, 12)
                        
                        // FREE TIER BANNER (if applicable)
                        if let user = authManager.currentUser, !user.isPro {
                            FreeTierBanner(user: user, theme: theme) {
                                showSubscription = true
                            }
                            .padding(.horizontal, 12)
                        }
                        
                        // MY PRODUCTS SECTION
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
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.6))
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                        )
                        .padding(.horizontal, 12)
                        
                        // ORDERS SECTION - with wavy bottom
                        OrdersListView(
                            viewModel: viewModel,
                            themeManager: themeManager,
                            localization: localization,
                            authManager: authManager
                        )
                        .padding(12)
                        .background(
                            WavyBottomContainer(cornerRadius: 16, waveHeight: 15)
                                .fill(Color.black.opacity(0.6))
                                .background(
                                    WavyBottomContainer(cornerRadius: 16, waveHeight: 15)
                                        .fill(.ultraThinMaterial)
                                )
                        )
                        .padding(.horizontal, 12)
                        .padding(.bottom, 50) // Show wallpaper at bottom
                    }
                    .padding(.top, 8)
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

// Free tier banner
struct FreeTierBanner: View {
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
    var waveHeight: CGFloat = 20
    var waveCount: Int = 4
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Start at top-left with rounded corner
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        // Top edge
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        
        // Top-right corner
        path.addQuadCurve(
            to: CGPoint(x: width, y: cornerRadius),
            control: CGPoint(x: width, y: 0)
        )
        
        // Right edge - stop before wave starts
        path.addLine(to: CGPoint(x: width, y: height - waveHeight * 2))
        
        // Smooth organic wave at bottom - curved scallop pattern
        let segmentWidth = width / CGFloat(waveCount)
        
        for i in 0..<waveCount {
            let segmentStart = width - segmentWidth * CGFloat(i)
            let segmentEnd = segmentStart - segmentWidth
            let midPoint = (segmentStart + segmentEnd) / 2
            
            // Create scalloped curves
            path.addQuadCurve(
                to: CGPoint(x: midPoint, y: height - waveHeight),
                control: CGPoint(x: segmentStart - segmentWidth * 0.25, y: height - waveHeight * 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: segmentEnd, y: height - waveHeight * 2),
                control: CGPoint(x: midPoint - segmentWidth * 0.25, y: height)
            )
        }
        
        // Left edge back to start
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
