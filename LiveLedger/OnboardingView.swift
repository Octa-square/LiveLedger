//
//  OnboardingView.swift
//  LiveLedger
//
//  LiveLedger - Detailed Tutorial/Onboarding
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var localization: LocalizationManager
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @Environment(\.dismiss) var dismiss
    
    // Flag to check if it's being shown from settings (re-tutorial)
    var isReTutorial: Bool = false
    
    // DETAILED tutorial pages - How to use LiveLedger step by step
    let pages: [TutorialPage] = [
        // Page 1: Welcome & Overview
        TutorialPage(
            icon: "sparkles",
            color: .green,
            title: "Welcome to LiveLedger",
            description: "Your complete live selling companion! Track orders in real-time, manage multiple platforms, and grow your business with powerful insights. Let's show you how it works.",
            steps: []
        ),
        
        // Page 2: Adding Products
        TutorialPage(
            icon: "bag.fill.badge.plus",
            color: .blue,
            title: "Step 1: Add Your Products",
            description: "Start by adding products you'll be selling:",
            steps: [
                "1. Tap the + button in 'My Products' section",
                "2. Enter product name and price",
                "3. Add an image (optional but recommended)",
                "4. Tap 'Save' to add your product",
                "5. You can add up to 12 products"
            ]
        ),
        
        // Page 3: Recording Sales
        TutorialPage(
            icon: "hand.tap.fill",
            color: .orange,
            title: "Step 2: Record Sales",
            description: "Recording a sale takes just one tap:",
            steps: [
                "1. TAP a product once = Add 1 sale",
                "2. HOLD a product = Edit product details",
                "3. Enter buyer name when prompted",
                "4. Order appears instantly in your list",
                "5. Revenue updates in real-time"
            ]
        ),
        
        // Page 4: Using Timer
        TutorialPage(
            icon: "timer",
            color: .red,
            title: "Step 3: Start Your Live Session",
            description: "Track your live selling sessions:",
            steps: [
                "1. Tap ▶ (play button) to start timer",
                "2. Timer tracks your session duration",
                "3. Sound plays when timer starts",
                "4. Tap ⏸ to pause if needed",
                "5. Tap ■ to stop and save session"
            ]
        ),
        
        // Page 5: Platform Selection
        TutorialPage(
            icon: "apps.iphone",
            color: .pink,
            title: "Step 4: Select Your Platform",
            description: "Attribute sales to the right platform:",
            steps: [
                "1. Tap a platform (TikTok, Instagram, etc.)",
                "2. All new orders go to that platform",
                "3. Tap 'All' to see all orders",
                "4. Tap + Add to create custom platforms",
                "5. Each platform shows its own revenue"
            ]
        ),
        
        // Page 6: Managing Orders
        TutorialPage(
            icon: "shippingbox.fill",
            color: .purple,
            title: "Step 5: Manage Your Orders",
            description: "Keep track of all your sales:",
            steps: [
                "1. Orders appear in the Orders section",
                "2. Swipe left on an order to delete",
                "3. Filter orders by platform",
                "4. Filter by price type (full/discounted)",
                "5. Scroll to see all orders"
            ]
        ),
        
        // Page 7: Export & Print
        TutorialPage(
            icon: "square.and.arrow.up.fill",
            color: .cyan,
            title: "Step 6: Export Your Data",
            description: "Save and share your sales data:",
            steps: [
                "1. Tap 'Export' to save to Excel/CSV",
                "2. Tap 'Print' for sales reports",
                "3. Choose to export by platform",
                "4. Print individual receipts",
                "5. Great for record keeping!"
            ]
        ),
        
        // Page 8: Navigation
        TutorialPage(
            icon: "rectangle.grid.1x2.fill",
            color: .indigo,
            title: "Using the Bottom Navigation",
            description: "Quick access to all features:",
            steps: [
                "🏠 Home - Main sales dashboard",
                "📊 Analytics - Charts & insights",
                "⏱️ Timer - Session timer control",
                "📦 Orders - Full order history",
                "⋯ More - Settings & extras"
            ]
        ),
        
        // Page 9: Settings & Customization
        TutorialPage(
            icon: "gearshape.fill",
            color: .gray,
            title: "Customize Your Experience",
            description: "Make LiveLedger work for you:",
            steps: [
                "• Change themes & wallpapers",
                "• Customize timer & order sounds",
                "• Adjust display settings",
                "• Test your network connection",
                "• Update profile & store info"
            ]
        ),
        
        // Page 10: Pro Tips
        TutorialPage(
            icon: "star.fill",
            color: .yellow,
            title: "Pro Tips for Success",
            description: "Get the most out of LiveLedger:",
            steps: [
                "✓ Add product images for quick recognition",
                "✓ Start timer before going live",
                "✓ Use platform filter to track performance",
                "✓ Export data weekly for records",
                "✓ Check Analytics to find top sellers"
            ]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(colors: [
                    Color(red: 0.07, green: 0.5, blue: 0.46),
                    Color(red: 0.05, green: 0.35, blue: 0.35)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Skip button - top right
                    HStack {
                        // Progress indicator
                        Text("\(currentPage + 1) of \(pages.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        Button {
                            completeOnboarding()
                        } label: {
                            Text(localization.localized(.skip))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Logo - smaller for tutorial pages
                    LiveLedgerLogo(size: 60)
                        .padding(.top, 8)
                    
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            DetailedTutorialPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    Spacer()
                    
                    // Bottom Navigation
                    VStack(spacing: 12) {
                        // Pagination dots
                        HStack(spacing: 6) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: currentPage == index ? 8 : 6, height: currentPage == index ? 8 : 6)
                                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                            }
                        }
                        
                        // Navigation buttons
                        HStack(spacing: 12) {
                            // Back button (if not first page)
                            if currentPage > 0 {
                                Button {
                                    withAnimation {
                                        currentPage -= 1
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("Back")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 90)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                }
                            }
                            
                            // Next/Finish button
                            Button {
                                if currentPage < pages.count - 1 {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } else {
                                    completeOnboarding()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(currentPage < pages.count - 1 ? localization.localized(.next) : "Get Started!")
                                        .font(.system(size: 16, weight: .semibold))
                                    if currentPage < pages.count - 1 {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                    } else {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                }
                                .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: 300)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            hasCompletedOnboarding = true
        }
        // If shown from settings, also dismiss
        if isReTutorial {
            dismiss()
        }
    }
}

// MARK: - Tutorial Page Model (Enhanced with Steps)
struct TutorialPage {
    let icon: String
    let color: Color
    let title: String
    let description: String
    var steps: [String] = []
}

// MARK: - Detailed Tutorial Page View
struct DetailedTutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(page.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(page.color.opacity(0.3))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Title
                Text(page.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                
                // Description
                Text(page.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 10)
                    .padding(.horizontal, 30)
                
                // Steps (if any)
                if !page.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(page.steps, id: \.self) { step in
                            HStack(alignment: .top, spacing: 8) {
                                if step.hasPrefix("•") || step.hasPrefix("✓") {
                                    // Bullet points - no extra circle
                                    Text(step)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                } else if step.contains("🏠") || step.contains("📊") || step.contains("⏱️") || step.contains("📦") || step.contains("⋯") {
                                    // Navigation items with emoji
                                    Text(step)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                } else {
                                    // Numbered steps
                                    Circle()
                                        .fill(page.color.opacity(0.6))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    
                                    Text(step)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.25))
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                
                Spacer(minLength: 20)
            }
        }
    }
}

// MARK: - Legacy Tutorial Page View (kept for compatibility)
struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        DetailedTutorialPageView(page: page)
    }
}

// MARK: - Legacy Compact Page (kept for compatibility)
struct CompactOnboardingPage: View {
    let page: TutorialPage
    
    var body: some View {
        TutorialPageView(page: page)
    }
}

// Legacy support
struct OnboardingPage: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let localization: LocalizationManager
    
    var body: some View {
        CompactOnboardingPage(page: TutorialPage(icon: icon, color: color, title: title, description: description))
    }
}

// Tutorial button view for settings
struct TutorialButton: View {
    @Binding var showTutorial: Bool
    
    var body: some View {
        Button {
            showTutorial = true
        } label: {
            Label("Tutorial", systemImage: "play.circle.fill")
            }
    }
}

#Preview {
    OnboardingView(localization: LocalizationManager(), hasCompletedOnboarding: .constant(false))
}
