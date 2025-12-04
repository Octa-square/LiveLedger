//
//  LiveLedgerApp.swift
//  LiveLedger
//
//  Live Sales Tracker App - Auto-save on background
//

import SwiftUI

@main
struct LiveLedgerApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var localization = LocalizationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootView(authManager: authManager, localization: localization)
                .environmentObject(localization)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .background || newPhase == .inactive {
                        // Auto-save when app goes to background
                        NotificationCenter.default.post(name: .autoSaveData, object: nil)
                    }
                }
        }
    }
}

// Root view that switches between Auth, Onboarding, and Main content
struct RootView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        if authManager.isAuthenticated {
            if hasCompletedOnboarding {
                MainContentView(authManager: authManager, localization: localization)
            } else {
                OnboardingView(localization: localization, hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        } else {
            AuthView(authManager: authManager)
        }
    }
}

// Notification for auto-save
extension Notification.Name {
    static let autoSaveData = Notification.Name("autoSaveData")
}
