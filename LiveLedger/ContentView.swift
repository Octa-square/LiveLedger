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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Layer - User's wallpaper/theme image (VISIBLE throughout app)
                ZStack {
                    // Theme background image - FULL VISIBILITY
                    Image(theme.backgroundImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    
                    // Very subtle gradient overlay for readability (optional)
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.1),
                            Color.clear,
                            Color.black.opacity(0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea()
                
                // Content Layer - Semi-transparent containers over visible wallpaper
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        // HEADER - Semi-transparent (80% opacity)
                        VStack(spacing: 6) {
                            HeaderView(viewModel: viewModel, themeManager: themeManager, authManager: authManager, localization: localization, showSettings: $showSettings, showSubscription: $showSubscription)
                            PlatformSelectorView(viewModel: viewModel, themeManager: themeManager, localization: localization)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.cardBackground.opacity(0.80))
                                .shadow(color: theme.shadowDark.opacity(0.15), radius: 4, y: 2)
                        )
                        .padding(.horizontal, 12)
                        
                        // Free tier banner (if applicable)
                        if let user = authManager.currentUser, !user.isPro {
                            FreeTierBanner(user: user, theme: theme) {
                                showSubscription = true
                            }
                            .padding(.horizontal, 12)
                        }
                        
                        // MY PRODUCTS - Semi-transparent (85% opacity)
                        QuickAddView(viewModel: viewModel, themeManager: themeManager, authManager: authManager, localization: localization, onLimitReached: {
                            limitAlertMessage = "You've used all 20 free orders. Upgrade to Pro for unlimited orders!"
                            showLimitAlert = true
                        })
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.cardBackground.opacity(0.85))
                                .shadow(color: theme.shadowDark.opacity(0.15), radius: 4, y: 2)
                        )
                        .padding(.horizontal, 12)
                        
                        // ORDERS - Semi-transparent (85% opacity) with wavy bottom
                        OrdersListView(viewModel: viewModel, themeManager: themeManager, localization: localization, authManager: authManager)
                            .background(
                                WavyBottomContainer(cornerRadius: 16, waveHeight: 12)
                                    .fill(theme.cardBackground.opacity(0.85))
                                    .shadow(color: theme.shadowDark.opacity(0.15), radius: 4, y: 2)
                            )
                            .padding(.horizontal, 12)
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .preferredColorScheme(theme.isDarkTheme ? .dark : .light)
        // Auto-save listener
        .onReceive(NotificationCenter.default.publisher(for: .autoSaveData)) { notification in
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
                // Check export limit
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
                    .foregroundColor(theme.warningColor)
                Text("\(user.remainingFreeOrders) orders • \(user.remainingFreeExports) exports left")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textSecondary)
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
                .background(theme.warningColor)
                .cornerRadius(6)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.warningColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(theme.warningColor.opacity(0.3), lineWidth: 1)
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
    var waveHeight: CGFloat = 12
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
        
        // Right edge
        path.addLine(to: CGPoint(x: width, y: height - waveHeight - cornerRadius))
        
        // Bottom-right corner transition to wave
        path.addQuadCurve(
            to: CGPoint(x: width - cornerRadius, y: height - waveHeight),
            control: CGPoint(x: width, y: height - waveHeight)
        )
        
        // Wavy bottom edge
        let waveWidth = (width - cornerRadius * 2) / CGFloat(waveCount)
        for i in 0..<waveCount {
            let startX = width - cornerRadius - waveWidth * CGFloat(i)
            let endX = startX - waveWidth
            let midX = (startX + endX) / 2
            
            if i % 2 == 0 {
                path.addQuadCurve(
                    to: CGPoint(x: endX, y: height - waveHeight),
                    control: CGPoint(x: midX, y: height)
                )
            } else {
                path.addQuadCurve(
                    to: CGPoint(x: endX, y: height - waveHeight),
                    control: CGPoint(x: midX, y: height - waveHeight * 2)
                )
            }
        }
        
        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height - waveHeight - cornerRadius),
            control: CGPoint(x: 0, y: height - waveHeight)
        )
        
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
    // Create a mock authenticated user to avoid StoreKit initialization issues
    let mockAuthManager = AuthManager()
    mockAuthManager.currentUser = AppUser(
        id: "preview-user",
        email: "preview@example.com",
        passwordHash: "preview",
        name: "Preview User",
        companyName: "My Shop",
        currency: "USD ($)",
        isPro: true, // Set to Pro to avoid subscription checks
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
