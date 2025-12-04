//
//  OnboardingView.swift
//  LiveLedger
//
//  LiveLedger - Tutorial/Onboarding for first-time users
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var authManager: AuthManager
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var showSubscriptionChoice = false
    @Environment(\.dismiss) var dismiss
    
    // Flag to check if it's being shown from settings (re-tutorial)
    var isReTutorial: Bool = false
    
    let pages: [(icon: String, color: Color, titleKey: String, descriptionKey: LocalizedKey)] = [
        ("bag.fill.badge.plus", .green, "Products & Orders", .tutorialProducts),
        ("list.clipboard.fill", .blue, "Track Everything", .tutorialOrders),
        ("apps.iphone", .pink, "Multi-Platform", .tutorialPlatforms),
        ("square.and.arrow.up.fill", .orange, "Export & Print", .tutorialExport)
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [
                Color(red: 0.07, green: 0.5, blue: 0.46),
                Color(red: 0.05, green: 0.35, blue: 0.35)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            if showSubscriptionChoice && !isReTutorial {
                // Subscription Choice Screen
                subscriptionChoiceView
            } else {
                // Tutorial Pages
                VStack(spacing: 0) {
                    // Skip button at top-right (professional placement)
                    HStack {
                        Spacer()
                        Button {
                            if isReTutorial {
                                completeOnboarding()
                            } else {
                                showSubscriptionChoice = true
                            }
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
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                    
                    // Logo/Welcome Header (Larger)
                    VStack(spacing: 10) {
                        LiveLedgerLogoMini()
                            .scaleEffect(1.5)
                        
                        Text("\(localization.localized(.welcomeTo)) LiveLedger")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPage(
                                icon: pages[index].icon,
                                color: pages[index].color,
                                title: pages[index].titleKey,
                                description: localization.localized(pages[index].descriptionKey),
                                localization: localization
                            )
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Next/Get Started button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            if isReTutorial {
                                completeOnboarding()
                            } else {
                                withAnimation {
                                    showSubscriptionChoice = true
                                }
                            }
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? localization.localized(.next) : localization.localized(.letsGo))
                            .font(.headline)
                            .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Subscription Choice View
    private var subscriptionChoiceView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 12) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                Text("Choose Your Plan")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Start tracking your live sales today")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Plan Options
            VStack(spacing: 16) {
                // Free Plan
                Button {
                    // Stay on free plan
                    completeOnboarding()
                } label: {
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Free Plan")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text("20 orders • 10 exports • Basic features")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Text("$0")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Pro Plan
                Button {
                    // Upgrade to Pro
                    authManager.upgradeToPro()
                    completeOnboarding()
                } label: {
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text("Pro Plan")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("RECOMMENDED")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange)
                                        .cornerRadius(4)
                                }
                                Text("Unlimited orders • Unlimited exports • All features")
                                    .font(.system(size: 13))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("$4.99")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                Text("/month")
                                    .font(.system(size: 11))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Footer note
            Text("You can change your plan anytime in Settings")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 40)
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

struct OnboardingPage: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let localization: LocalizationManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // Title
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // Description
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
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
    OnboardingView(localization: LocalizationManager(), authManager: AuthManager(), hasCompletedOnboarding: .constant(false))
}

