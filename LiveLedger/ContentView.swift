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
                // Background Image
                Image(theme.backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                // Semi-transparent overlay for readability
                LinearGradient(
                    colors: theme.gradientColors.map { $0.opacity(theme.backgroundOverlayOpacity) },
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                // FIXED HEADER - X style (~56px height feel)
                VStack(spacing: 6) {
                    HeaderView(viewModel: viewModel, themeManager: themeManager, authManager: authManager, localization: localization, showSettings: $showSettings, showSubscription: $showSubscription)
                    PlatformSelectorView(viewModel: viewModel, themeManager: themeManager, localization: localization)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    theme.cardBackground
                        .shadow(color: theme.shadowDark.opacity(0.1), radius: 2, y: 2)
                )
                
                // CONTENT - Products fixed, Orders stretches to bottom
                VStack(spacing: 8) {
                    // Free tier banner
                    if let user = authManager.currentUser, !user.isPro {
                        FreeTierBanner(user: user, theme: theme) {
                            showSubscription = true
                        }
                    }
                    
                    // Products card - fixed size
                    QuickAddView(viewModel: viewModel, themeManager: themeManager, authManager: authManager, localization: localization, onLimitReached: {
                        limitAlertMessage = "You've used all 20 free orders. Upgrade to Pro for unlimited orders!"
                        showLimitAlert = true
                    })
                    
                    // Orders - stretches all the way down
                    OrdersListView(viewModel: viewModel, themeManager: themeManager, localization: localization, authManager: authManager)
                        .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8) // Same as top
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
            SettingsView(viewModel: viewModel, themeManager: themeManager, authManager: authManager, localization: localization)
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(authManager: authManager)
        }
        } // GeometryReader
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
