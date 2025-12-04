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
    
    let pages: [(icon: String, color: Color, titleKey: String, descriptionKey: LocalizedKey)] = [
        ("bag.fill.badge.plus", .green, "Products & Orders", .tutorialProducts),
        ("list.clipboard.fill", .blue, "Track Everything", .tutorialOrders),
        ("apps.iphone", .pink, "Multi-Platform", .tutorialPlatforms),
        ("chart.bar.fill", .purple, "Analytics", .tutorialAnalytics),
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
            
            VStack(spacing: 0) {
                // Logo/Welcome Header
                VStack(spacing: 8) {
                    LiveLedgerLogoMini()
                        .scaleEffect(1.2)
                    
                    Text("\(localization.localized(.welcomeTo)) LiveLedger")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                .padding(.bottom, 10)
                
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        completeOnboarding()
                    } label: {
                        Text(localization.localized(.skip))
                            .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                
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
                        completeOnboarding()
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
    OnboardingView(localization: LocalizationManager(), hasCompletedOnboarding: .constant(false))
}
