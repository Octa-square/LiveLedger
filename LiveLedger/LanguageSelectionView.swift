//
//  LanguageSelectionView.swift
//  LiveLedger
//
//  First-Launch Language Selection Screen
//

import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var localization: LocalizationManager
    @Binding var hasSelectedLanguage: Bool
    @State private var selectedLanguage: AppLanguage = .english
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.5, blue: 0.46),
                        Color(red: 0.05, green: 0.35, blue: 0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo at top
                    VStack(spacing: 16) {
                        LiveLedgerLogo(size: 80)
                        
                        Text("Welcome to LiveLedger")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Select Your Language")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    // Language selection list
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedLanguage = language
                                    }
                                } label: {
                                    HStack(spacing: 16) {
                                        // Flag
                                        Text(language.flag)
                                            .font(.system(size: 32))
                                        
                                        // Language name
                                        Text(language.displayName)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        // Selection indicator
                                        ZStack {
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                                .frame(width: 24, height: 24)
                                            
                                            if selectedLanguage == language {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 16, height: 16)
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(
                                                selectedLanguage == language
                                                    ? Color.white.opacity(0.25)
                                                    : Color.white.opacity(0.1)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                selectedLanguage == language
                                                    ? Color.white.opacity(0.5)
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                    
                    // Continue button
                    Button {
                        confirmLanguageSelection()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func confirmLanguageSelection() {
        // Save selected language
        localization.currentLanguage = selectedLanguage
        
        // Mark that language has been selected
        UserDefaults.standard.set(true, forKey: "hasSelectedLanguage")
        
        withAnimation {
            hasSelectedLanguage = true
        }
    }
}

#Preview {
    LanguageSelectionView(
        localization: LocalizationManager.shared,
        hasSelectedLanguage: .constant(false)
    )
}
