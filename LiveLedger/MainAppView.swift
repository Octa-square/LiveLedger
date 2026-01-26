//
//  MainAppView.swift
//  LiveLedger
//
//  Main App View - Simple wrapper for MainTabView
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct MainAppView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    
    var body: some View {
        MainTabView(authManager: authManager, localization: localization)
    }
}
