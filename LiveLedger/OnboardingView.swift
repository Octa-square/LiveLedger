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
        ZStack {
            // Background
            LinearGradient(colors: [
                Color(red: 0.07, green: 0.5, blue: 0.46),
                Color(red: 0.05, green: 0.35, blue: 0.35)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with Skip button
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
                
                // Logo/Welcome Header (larger logo, smaller text)
                VStack(spacing: 4) {
                    LiveLedgerLogoMini()
                        .scaleEffect(2.0)  // Much larger logo
                    
                    Text("\(localization.localized(.welcomeTo)) LiveLedger")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 8)
                .padding(.bottom, 0)  // Remove bottom padding - let content flow closer
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        CompactOnboardingPage(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicators
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .scaleEffect(currentPage == index ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 16)
                
                // Next/Get Started button
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
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
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

// MARK: - Compact Onboarding Page (tight spacing)
struct CompactOnboardingPage: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 10) {  // Tight spacing
            Spacer(minLength: 10)  // Small top spacer instead of flexible
            
            // Icon - compact size
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 75, height: 75)
                
                Image(systemName: page.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            // Title - closer to icon
            Text(page.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)
            
            // Description - compact
            Text(page.description)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 24)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()  // Push content up, let bottom have more space
        }
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

