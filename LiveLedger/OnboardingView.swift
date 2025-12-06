//
//  OnboardingView.swift
//  LiveLedger
//
//  LiveLedger - Tutorial/Onboarding for first-time users
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var localization: LocalizationManager
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @Environment(\.dismiss) var dismiss
    
    // Flag to check if it's being shown from settings (re-tutorial)
    var isReTutorial: Bool = false
    
    // Enhanced tutorial pages with detailed descriptions
    let pages: [TutorialPage] = [
        TutorialPage(
            icon: "bag.fill.badge.plus",
            color: .green,
            title: "Products & Orders",
            description: "Add your products with images and prices. Tap to record a sale instantly, or hold to edit product details. Track every order with timestamps and platform attribution."
        ),
        TutorialPage(
            icon: "apps.iphone",
            color: .pink,
            title: "Multi-Platform Sales",
            description: "Sell across TikTok, Instagram, Facebook, and custom platforms. Filter orders by platform to see which channels perform best. Add unlimited custom platforms for your business."
        ),
        TutorialPage(
            icon: "timer",
            color: .orange,
            title: "Live Timer & Sounds",
            description: "Track your live sessions with the built-in timer. Customize sounds for timer start and order notifications. Stay focused while the app handles the tracking."
        ),
        TutorialPage(
            icon: "network",
            color: .cyan,
            title: "Network Analyzer",
            description: "Monitor your connection quality before going live. Test bandwidth, latency, and get quality assessments. Ensure smooth streaming with real-time network status."
        ),
        TutorialPage(
            icon: "chart.bar.fill",
            color: .purple,
            title: "Analytics & Comparisons",
            description: "View detailed sales analytics with beautiful charts. Compare monthly performance, track top-selling products, and analyze platform breakdowns to grow your business."
        ),
        TutorialPage(
            icon: "square.and.arrow.up.fill",
            color: .blue,
            title: "Export & Print",
            description: "Export orders to Excel/CSV for record keeping. Print daily sales reports or individual receipts. Filter exports by platform and date range."
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
                    
                    // === LOGO RECTANGLE: 280pt × 100pt, 20pt from top ===
                    LiveLedgerLogo(size: 70)
                        .frame(width: 280, height: 100)
                        .padding(.top, 12)
                    
                    // === "Welcome to LiveLedger": 15pt below logo, 20pt bold ===
                    Text("\(localization.localized(.welcomeTo)) LiveLedger")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 15)
                    
                    // === Page Content ===
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            TutorialPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    Spacer()
                    
                    // === BOTTOM NAVIGATION: 280pt × 60pt, 30pt from bottom ===
                    VStack(spacing: 12) {
                        // Pagination dots: 6pt diameter, 8pt spacing
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        
                        // Next button: 16pt font
                        Button {
                            if currentPage < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                completeOnboarding()
                            }
                        } label: {
                            Text(currentPage < pages.count - 1 ? localization.localized(.next) : localization.localized(.letsGo))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                                .frame(width: 280)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    .frame(width: 280, height: 60)
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

// MARK: - Tutorial Page Model
struct TutorialPage {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

// MARK: - Tutorial Page View (iPhone measurements)
struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 0) {
            // === ICON CIRCLE: 160pt diameter, 30pt below "Welcome" ===
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .padding(.top, 30)
            
            // === HEADING: 20pt below circle, 22pt bold ===
            Text(page.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // === DESCRIPTION: 12pt below heading, 320pt width, 14pt font, 20pt line height ===
            Text(page.description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(6)  // 14pt font + 6pt = ~20pt line height
                .frame(width: 320)
                .padding(.top, 12)
            
            Spacer()
        }
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

