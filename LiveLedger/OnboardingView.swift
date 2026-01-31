//
//  OnboardingView.swift
//  LiveLedger
//
//  Clean, Apple-style onboarding – 4 screens, centered, modern.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @Environment(\.dismiss) var dismiss
    
    var isReTutorial: Bool = false
    
    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("", "LiveLedger", "Complete sales and inventory management for social sellers"),
        ("chart.line.uptrend.xyaxis", "Track Sales", "Manage orders from TikTok, Instagram & Facebook"),
        ("shippingbox.fill", "Manage Inventory", "Keep track of stock and products"),
        ("checkmark.circle.fill", "You're All Set", "Tap Get Started to begin")
    ]
    
    var body: some View {
        ZStack {
            // Green gradient background (no white) – keeps text and icons readable
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.42, blue: 0.32),
                    Color(red: 0.04, green: 0.32, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button (top right) – hide on last page
                if currentPage < pages.count - 1 {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageContent(
                            icon: pages[index].icon,
                            title: pages[index].title,
                            subtitle: pages[index].subtitle,
                            isFirstPage: index == 0,
                            isLastPage: index == pages.count - 1,
                            onGetStarted: completeOnboarding
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.35))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.25)) {
            hasCompletedOnboarding = true
        }
        if isReTutorial {
            dismiss()
        }
    }
}

// MARK: - Single onboarding page (centered content)
private struct OnboardingPageContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let isFirstPage: Bool
    let isLastPage: Bool
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)
            
            // First screen: app logo (L²); others: SF Symbol
            if isFirstPage {
                LiveLedgerLogo(size: 90)
                    .padding(.bottom, 32)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 90, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.95, blue: 0.75),
                                Color(red: 0.35, green: 0.85, blue: 0.65)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 32)
            }
            
            // Title
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 12)
            
            // Subtitle
            Text(subtitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white.opacity(0.88))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            
            Spacer(minLength: 40)
            
            // Get Started button (last screen only)
            if isLastPage {
                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.04, green: 0.32, blue: 0.24))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.95, blue: 0.75),
                                    Color(red: 0.35, green: 0.85, blue: 0.65)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Tutorial button (for Settings)
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

// MARK: - Legacy types (minimal, for any existing references)
struct TutorialPage {
    let icon: String
    let color: Color
    let title: String
    let description: String
    var steps: [String] = []
}

struct DetailedTutorialPageView: View {
    let page: TutorialPage
    var body: some View {
        EmptyView()
    }
}

struct TutorialPageView: View {
    let page: TutorialPage
    var body: some View {
        DetailedTutorialPageView(page: page)
    }
}

struct CompactOnboardingPage: View {
    let page: TutorialPage
    var body: some View {
        TutorialPageView(page: page)
    }
}

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

#Preview {
    OnboardingView(authManager: AuthManager(), localization: LocalizationManager(), hasCompletedOnboarding: .constant(false))
}
