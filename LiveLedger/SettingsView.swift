//
//  SettingsView.swift
//  LiveLedger
//
//  LiveLedger - Settings & Themes
//

import SwiftUI
import Combine

// MARK: - Theme Definitions
enum AppTheme: String, CaseIterable, Codable {
    case minimalistLight = "Minimalist Light"
    case minimalistDark = "Minimalist Dark"
    case emeraldGreen = "Emerald Green"
    case glassmorphism = "Glassmorphism"
    case boldFuturistic = "Bold Futuristic"
    case motionRich = "Motion Rich"
    case sunsetOrange = "Sunset Orange"
    
    // MARK: - Theme Mode
    var isDarkTheme: Bool {
        switch self {
        case .minimalistLight:
            return false
        case .minimalistDark, .emeraldGreen, .glassmorphism, .boldFuturistic, .motionRich, .sunsetOrange:
            return true
        }
    }
    
    // MARK: - Text Colors (BRIGHTER)
    var textPrimary: Color {
        switch self {
        case .minimalistLight: return Color(hex: "111111")
        case .minimalistDark: return Color(hex: "FFFFFF")
        case .emeraldGreen: return Color(hex: "FFFFFF")
        case .glassmorphism: return Color(hex: "FFFFFF")
        case .boldFuturistic: return Color(hex: "FFFFFF")
        case .motionRich: return Color(hex: "FFFFFF")
        case .sunsetOrange: return Color(hex: "FFFFFF")
        }
    }
    
    var textSecondary: Color {
        switch self {
        case .minimalistLight: return Color(hex: "4B5563")
        case .minimalistDark: return Color(hex: "D1D5DB")
        case .emeraldGreen: return Color(hex: "A7F3D0")
        case .glassmorphism: return Color(hex: "CBD5E1")
        case .boldFuturistic: return Color(hex: "6EE7B7")
        case .motionRich: return Color(hex: "DDD6FE")
        case .sunsetOrange: return Color(hex: "FED7AA")
        }
    }
    
    var textMuted: Color {
        switch self {
        case .minimalistLight: return Color(hex: "6B7280")
        case .minimalistDark: return Color(hex: "9CA3AF")
        case .emeraldGreen: return Color(hex: "6EE7B7")
        case .glassmorphism: return Color(hex: "94A3B8")
        case .boldFuturistic: return Color(hex: "34D399")
        case .motionRich: return Color(hex: "C4B5FD")
        case .sunsetOrange: return Color(hex: "FDBA74")
        }
    }
    
    // MARK: - Accent Colors
    var accentColor: Color {
        switch self {
        case .minimalistLight: return Color(hex: "3B82F6")
        case .minimalistDark: return Color(hex: "60A5FA")
        case .emeraldGreen: return Color(hex: "10B981")
        case .glassmorphism: return Color(hex: "00D4FF")
        case .boldFuturistic: return Color(hex: "00F5A0")
        case .motionRich: return Color(hex: "A78BFA")
        case .sunsetOrange: return Color(hex: "FF6A00")
        }
    }
    
    var primaryColor: Color { accentColor }
    
    var secondaryColor: Color {
        switch self {
        case .minimalistLight: return Color(hex: "10B981")
        case .minimalistDark: return Color(hex: "34D399")
        case .emeraldGreen: return Color(hex: "34D399")
        case .glassmorphism: return Color(hex: "7C3AED")
        case .boldFuturistic: return Color(hex: "00D1FF")
        case .motionRich: return Color(hex: "EC4899")
        case .sunsetOrange: return Color(hex: "F97316")
        }
    }
    
    // MARK: - Background Image
    var backgroundImageName: String {
        switch self {
        case .minimalistLight: return "ThemeBG_MinimalistLight"
        case .minimalistDark: return "ThemeBG_MinimalistDark"
        case .emeraldGreen: return "ThemeBG_EmeraldGreen"
        case .glassmorphism: return "ThemeBG_Glassmorphism"
        case .boldFuturistic: return "ThemeBG_BoldFuturistic"
        case .motionRich: return "ThemeBG_MotionRich"
        case .sunsetOrange: return "ThemeBG_SunsetOrange"
        }
    }
    
    // Overlay opacity - lower = more visible background image
    var backgroundOverlayOpacity: Double {
        switch self {
        case .minimalistLight: return 0.55
        case .minimalistDark: return 0.40
        case .emeraldGreen: return 0.40
        case .glassmorphism: return 0.30
        case .boldFuturistic: return 0.40
        case .motionRich: return 0.35
        case .sunsetOrange: return 0.40
        }
    }
    
    // MARK: - Background Colors
    var gradientColors: [Color] {
        switch self {
        case .minimalistLight: 
            return [Color(hex: "FFFFFF"), Color(hex: "F8FAFC"), Color(hex: "F1F5F9")]
        case .minimalistDark: 
            return [Color(hex: "0F0F0F"), Color(hex: "171717"), Color(hex: "1F1F1F")]
        case .emeraldGreen: 
            return [Color(hex: "022C22"), Color(hex: "064E3B"), Color(hex: "065F46")]
        case .glassmorphism: 
            return [Color(hex: "0F172A"), Color(hex: "1E293B"), Color(hex: "0F172A")]
        case .boldFuturistic: 
            return [Color(hex: "000000"), Color(hex: "0A0A0A"), Color(hex: "050505")]
        case .motionRich: 
            return [Color(hex: "1E1B4B"), Color(hex: "2E1065"), Color(hex: "1E1B4B")]
        case .sunsetOrange: 
            return [Color(hex: "1C1917"), Color(hex: "292524"), Color(hex: "44403C")]
        }
    }
    
    // MARK: - Card/Surface Colors (Semi-transparent for background visibility)
    var cardBackground: Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF").opacity(0.82)
        case .minimalistDark: return Color(hex: "262626").opacity(0.80)
        case .emeraldGreen: return Color(hex: "064E3B").opacity(0.78)
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.12)
        case .boldFuturistic: return Color(hex: "111111").opacity(0.78)
        case .motionRich: return Color(hex: "312E81").opacity(0.70)
        case .sunsetOrange: return Color(hex: "292524").opacity(0.78)
        }
    }
    
    // More transparent card for larger areas (product grid, orders)
    var cardBackgroundSubtle: Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF").opacity(0.75)
        case .minimalistDark: return Color(hex: "262626").opacity(0.72)
        case .emeraldGreen: return Color(hex: "064E3B").opacity(0.70)
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.08)
        case .boldFuturistic: return Color(hex: "111111").opacity(0.70)
        case .motionRich: return Color(hex: "312E81").opacity(0.60)
        case .sunsetOrange: return Color(hex: "292524").opacity(0.70)
        }
    }
    
    // Higher opacity for input fields and critical elements
    var cardBackgroundSolid: Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF").opacity(0.92)
        case .minimalistDark: return Color(hex: "262626").opacity(0.90)
        case .emeraldGreen: return Color(hex: "064E3B").opacity(0.88)
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.18)
        case .boldFuturistic: return Color(hex: "111111").opacity(0.88)
        case .motionRich: return Color(hex: "312E81").opacity(0.82)
        case .sunsetOrange: return Color(hex: "292524").opacity(0.88)
        }
    }
    
    var cardBorder: Color {
        switch self {
        case .minimalistLight: return Color(hex: "D1D5DB")
        case .minimalistDark: return Color(hex: "525252")
        case .emeraldGreen: return Color(hex: "10B981").opacity(0.4)
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.2)
        case .boldFuturistic: return Color(hex: "00F5A0").opacity(0.4)
        case .motionRich: return Color(hex: "A78BFA").opacity(0.4)
        case .sunsetOrange: return Color(hex: "FF6A00").opacity(0.4)
        }
    }
    
    // MARK: - Shadows (for neumorphic effects)
    var shadowLight: Color {
        switch self {
        case .minimalistLight: return Color.white
        case .minimalistDark: return Color(hex: "404040")
        case .emeraldGreen: return Color(hex: "065F46")
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.05)
        case .boldFuturistic: return Color(hex: "00F5A0").opacity(0.1)
        case .motionRich: return Color(hex: "A78BFA").opacity(0.1)
        case .sunsetOrange: return Color(hex: "57534E")
        }
    }
    
    var shadowDark: Color {
        switch self {
        case .minimalistLight: return Color(hex: "D1D5DB")
        case .minimalistDark: return Color.black
        case .emeraldGreen: return Color.black.opacity(0.4)
        case .glassmorphism: return Color.black.opacity(0.4)
        case .boldFuturistic: return Color(hex: "00F5A0").opacity(0.2)
        case .motionRich: return Color(hex: "8B5CF6").opacity(0.3)
        case .sunsetOrange: return Color.black.opacity(0.5)
        }
    }
    
    // MARK: - Status Colors
    var successColor: Color {
        Color(hex: "34D399")
    }
    
    var warningColor: Color {
        Color(hex: "FBBF24")
    }
    
    var dangerColor: Color {
        Color(hex: "F87171")
    }
    
    // MARK: - Icons
    var icon: String {
        switch self {
        case .minimalistLight: return "sun.max.fill"
        case .minimalistDark: return "moon.fill"
        case .emeraldGreen: return "leaf.fill"
        case .glassmorphism: return "cube.transparent.fill"
        case .boldFuturistic: return "bolt.fill"
        case .motionRich: return "waveform.path"
        case .sunsetOrange: return "sun.horizon.fill"
        }
    }
    
    // MARK: - Text Readability (for transparent backgrounds)
    var textShadowColor: Color {
        switch self {
        case .minimalistLight: return Color.black.opacity(0.08)
        case .minimalistDark: return Color.black.opacity(0.4)
        case .emeraldGreen: return Color.black.opacity(0.35)
        case .glassmorphism: return Color.black.opacity(0.5)
        case .boldFuturistic: return Color.black.opacity(0.5)
        case .motionRich: return Color.black.opacity(0.4)
        case .sunsetOrange: return Color.black.opacity(0.35)
        }
    }
    
    var textShadowRadius: CGFloat {
        switch self {
        case .minimalistLight: return 1
        case .minimalistDark, .emeraldGreen, .sunsetOrange: return 2
        case .glassmorphism, .boldFuturistic, .motionRich: return 3
        }
    }
    
    // Check if theme is light (for dynamic text contrast)
    var isLightTheme: Bool {
        switch self {
        case .minimalistLight: return true
        default: return false
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Neumorphic View Modifiers
struct NeumorphicStyle: ViewModifier {
    let theme: AppTheme
    let isPressed: Bool
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if isPressed {
                        // Pressed/Inset effect
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(theme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(theme.shadowDark.opacity(0.1), lineWidth: 2)
                                    .blur(radius: 2)
                                    .offset(x: 2, y: 2)
                                    .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(colors: [.black, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(theme.shadowLight.opacity(0.5), lineWidth: 2)
                                    .blur(radius: 2)
                                    .offset(x: -2, y: -2)
                                    .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(colors: [.clear, .black], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                    } else {
                        // Raised effect
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(theme.cardBackground)
                            .shadow(color: theme.shadowDark.opacity(0.2), radius: 10, x: 5, y: 5)
                            .shadow(color: theme.shadowLight.opacity(0.7), radius: 10, x: -5, y: -5)
                    }
                }
            )
    }
}

struct NeumorphicCircleStyle: ViewModifier {
    let theme: AppTheme
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if isPressed {
                        Circle()
                            .fill(theme.cardBackground)
                            .overlay(
                                Circle()
                                    .stroke(theme.shadowDark.opacity(0.15), lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(colors: [.black, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(theme.shadowLight.opacity(0.5), lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(colors: [.clear, .black], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                    } else {
                        Circle()
                            .fill(theme.cardBackground)
                            .shadow(color: theme.shadowDark.opacity(0.25), radius: 8, x: 6, y: 6)
                            .shadow(color: theme.shadowLight.opacity(0.8), radius: 8, x: -6, y: -6)
                    }
                }
            )
    }
}

// Convex (raised) neumorphic button
struct NeumorphicButtonStyle: ButtonStyle {
    let theme: AppTheme
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(theme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(theme.shadowDark.opacity(0.2), lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(colors: [.black, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(theme.shadowLight.opacity(0.6), lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(colors: [.clear, .black], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(theme.cardBackground)
                            .shadow(color: theme.shadowDark.opacity(0.2), radius: 10, x: 5, y: 5)
                            .shadow(color: theme.shadowLight.opacity(0.7), radius: 10, x: -5, y: -5)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Circle neumorphic button (like play/pause buttons)
struct NeumorphicCircleButtonStyle: ButtonStyle {
    let theme: AppTheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(theme.cardBackground)
                            .overlay(
                                Circle()
                                    .stroke(theme.shadowDark.opacity(0.2), lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(colors: [.black, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(theme.shadowLight.opacity(0.6), lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(colors: [.clear, .black], startPoint: .topLeading, endPoint: .bottomTrailing)))
                            )
                    } else {
                        Circle()
                            .fill(theme.cardBackground)
                            .shadow(color: theme.shadowDark.opacity(0.25), radius: 8, x: 6, y: 6)
                            .shadow(color: theme.shadowLight.opacity(0.8), radius: 8, x: -6, y: -6)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func neumorphic(theme: AppTheme, isPressed: Bool = false, cornerRadius: CGFloat = 16) -> some View {
        self.modifier(NeumorphicStyle(theme: theme, isPressed: isPressed, cornerRadius: cornerRadius))
    }
    
    func neumorphicCircle(theme: AppTheme, isPressed: Bool = false) -> some View {
        self.modifier(NeumorphicCircleStyle(theme: theme, isPressed: isPressed))
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            if let encoded = try? JSONEncoder().encode(currentTheme) {
                UserDefaults.standard.set(encoded, forKey: "app_theme")
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "app_theme"),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            currentTheme = theme
        } else {
            currentTheme = .minimalistDark
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @State private var showFeedback = false
    @State private var showSubscription = false
    @State private var showDeleteConfirm = false
    @State private var showTutorial = false
    @State private var showLanguagePicker = false
    @State private var showEditProfile = false
    @State private var showManageSubscription = false
    @State private var editedCompanyName = ""
    @State private var editedUserName = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section - Compact
                if let user = authManager.currentUser {
                    Section {
                        HStack(spacing: 10) {
                            // Account Icon
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(user.companyName)
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    // Pro Badge - Sleek inline design
                                    if user.isPro {
                                        HStack(spacing: 2) {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 8))
                                            Text("PRO")
                                                .font(.system(size: 8, weight: .black))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(
                                            LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .cornerRadius(4)
                                    }
                                }
                                
                                Text(user.name)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text(user.email)
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button {
                                editedCompanyName = user.companyName
                                editedUserName = user.name
                                showEditProfile = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 2)
                        
                        if !user.isPro {
                            Button {
                                showSubscription = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                    Text("Upgrade to Pro")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.orange)
                                    Spacer()
                                    Text("$49.99/mo")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        } else {
                            // Manage Subscription for Pro users
                            Button {
                                showManageSubscription = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                    Text("Manage Subscription")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    } header: {
                        Text(localization.localized(.profile))
                            .font(.system(size: 11))
                    }
                }
                
                // Themes Section - Compact with Visual Previews
                Section {
                    ForEach(AppTheme.allCases, id: \.self) { selectedTheme in
                        Button {
                            withAnimation {
                                themeManager.currentTheme = selectedTheme
                            }
                        } label: {
                            ThemeRowView(
                                appTheme: selectedTheme,
                                isSelected: themeManager.currentTheme == selectedTheme
                            )
                        }
                    }
                } header: {
                    Text(localization.localized(.themes))
                        .font(.system(size: 11))
                }
                
                // Language Section
                Section {
                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack {
                            Label(localization.localized(.language), systemImage: "globe")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(localization.currentLanguage.flag) \(localization.currentLanguage.displayName)")
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text(localization.localized(.language))
                }
                
                // Sound Settings Section
                Section {
                    NavigationLink {
                        SoundSettingsView(soundManager: SoundManager.shared)
                    } label: {
                        HStack {
                            Label("Sound Settings", systemImage: "speaker.wave.2.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(SoundManager.shared.soundsEnabled ? "On" : "Off")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Sounds")
                } footer: {
                    Text("Configure audio feedback for timer and orders")
                }
                
                // Analytics & Tutorial Section
                Section {
                    NavigationLink {
                        AnalyticsView(viewModel: viewModel, authManager: authManager, localization: localization, themeManager: themeManager)
                    } label: {
                        Label(localization.localized(.salesAnalytics), systemImage: "chart.bar.fill")
                    }
                    
                    Button {
                        showTutorial = true
                    } label: {
                        Label(localization.localized(.tutorial), systemImage: "questionmark.circle.fill")
                            .foregroundColor(.primary)
                    }
                } header: {
                    Text(localization.localized(.tutorial))
                }
                
                // Support Section
                Section {
                    Button {
                        showFeedback = true
                    } label: {
                        Label(localization.localized(.sendFeedback), systemImage: "envelope.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label(localization.localized(.privacyPolicy), systemImage: "hand.raised.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label(localization.localized(.termsOfService), systemImage: "doc.text.fill")
                            .foregroundColor(.primary)
                    }
                } header: {
                    Text(localization.localized(.support))
                }
                
                // Having Issues Section
                Section {
                    Button {
                        // Open WhatsApp with pre-filled message
                        let phoneNumber = "+1234567890" // Replace with your WhatsApp business number
                        let message = "Hi, I need help with LiveLedger app"
                        let urlString = "https://wa.me/\(phoneNumber)?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "message.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 18))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localization.localized(.liveSupport))
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                Text(localization.localized(.chatOnWhatsApp))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // WhatsApp icon
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button {
                        // Send email for support
                        if let url = URL(string: "mailto:support@liveledger.app?subject=LiveLedger%20Support%20Request") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.badge.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 18))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localization.localized(.emailSupport))
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                Text(localization.localized(.sendUsEmail))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(localization.localized(.havingIssues))
                    }
                } footer: {
                    Text(localization.localized(.supportResponseTime))
                }
                
                // About Section
                Section {
                    // App Name & Logo
                    HStack(spacing: 12) {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.system(size: 32))
                            .foregroundColor(theme.accentColor)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(theme.accentColor.opacity(0.15))
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LiveLedger")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(theme.textPrimary)
                            
                            Text("Sales Tracking for Live Sellers")
                                .font(.system(size: 12))
                                .foregroundColor(theme.textMuted)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    // Version
                    HStack {
                        Label(localization.localized(.version), systemImage: "info.circle")
                            .foregroundColor(theme.textSecondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(theme.textMuted)
                            .font(.system(size: 14, weight: .medium))
                    }
                    
                    // App Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("About LiveLedger")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.textPrimary)
                        
                        Text("LiveLedger is a powerful sales tracking application designed for live stream sellers. Manage orders across multiple platforms, track inventory in real-time, and gain insights with comprehensive analytics.")
                            .font(.system(size: 12))
                            .foregroundColor(theme.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.vertical, 4)
                    
                    // Developer Info
                    HStack {
                        Label("Developer", systemImage: "person.fill")
                            .foregroundColor(theme.textSecondary)
                        Spacer()
                        Text("OctaSquare")
                            .foregroundColor(theme.textMuted)
                            .font(.system(size: 14))
                    }
                    
                    // Copyright
                    HStack {
                        Label("Copyright", systemImage: "c.circle")
                            .foregroundColor(theme.textSecondary)
                        Spacer()
                        Text("© 2024 OctaSquare")
                            .foregroundColor(theme.textMuted)
                            .font(.system(size: 14))
                    }
                    
                    // Terms & Privacy Links
                    HStack {
                        Link(destination: URL(string: "https://liveledger.app/terms")!) {
                            Label("Terms of Service", systemImage: "doc.text")
                                .font(.system(size: 14))
                                .foregroundColor(theme.accentColor)
                        }
                        
                        Spacer()
                        
                        Link(destination: URL(string: "https://liveledger.app/privacy")!) {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                    
                } header: {
                    Text(localization.localized(.about))
                }
                
                // Account Actions
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label(localization.localized(.deleteAccount), systemImage: "trash.fill")
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        authManager.signOut()
                        dismiss()
                    } label: {
                        Label(localization.localized(.signOut), systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.orange)
                    }
                } header: {
                    Text(localization.localized(.profile))
                }
            }
            .navigationTitle(localization.localized(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.localized(.done)) { dismiss() }
                }
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView(authManager: authManager)
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    authManager.deleteAccount()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all data. This cannot be undone.")
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView(localization: localization)
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    companyName: $editedCompanyName,
                    userName: $editedUserName,
                    onSave: {
                        authManager.updateCompanyName(editedCompanyName)
                        authManager.updateUserName(editedUserName)
                    }
                )
            }
            .sheet(isPresented: $showManageSubscription) {
                ManageSubscriptionView(authManager: authManager)
            }
            .fullScreenCover(isPresented: $showTutorial) {
                TutorialWrapperView(localization: localization, isPresented: $showTutorial)
            }
        }
    }
    
    func themeDescription(_ theme: AppTheme) -> String {
        switch theme {
        case .minimalistLight: return "Clean & airy whites"
        case .minimalistDark: return "Smooth dark contrast"
        case .emeraldGreen: return "Rich forest vibes"
        case .glassmorphism: return "Frosted glass panels"
        case .boldFuturistic: return "Neon cyber vibes"
        case .motionRich: return "Smooth purple flow"
        case .sunsetOrange: return "Warm sunset glow"
        }
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText = ""
    @State private var feedbackType = "Suggestion"
    let feedbackTypes = ["Suggestion", "Bug Report", "Question", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Feedback Type", selection: $feedbackType) {
                        ForEach(feedbackTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Message") {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                }
                
                Section {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Send Feedback")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(feedbackText.isEmpty)
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Theme Row View
struct ThemeRowView: View {
    let appTheme: AppTheme
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            // Visual Theme Preview - Shows actual theme appearance
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(colors: appTheme.gradientColors, startPoint: .top, endPoint: .bottom))
                    .frame(width: 32, height: 32)
                
                // Mini preview of theme elements
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(appTheme.primaryColor)
                        .frame(width: 16, height: 4)
                    HStack(spacing: 2) {
                        Circle().fill(appTheme.successColor).frame(width: 4, height: 4)
                        Circle().fill(appTheme.warningColor).frame(width: 4, height: 4)
                        Circle().fill(appTheme.accentColor).frame(width: 4, height: 4)
                    }
                    RoundedRectangle(cornerRadius: 1)
                        .fill(appTheme.cardBackground)
                        .frame(width: 14, height: 6)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(appTheme.primaryColor.opacity(0.5), lineWidth: 1)
            )
            
            Text(appTheme.rawValue)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(appTheme.primaryColor)
                    .font(.system(size: 16))
            }
        }
        .padding(.vertical, 1)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.image = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.image = original
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Tutorial Wrapper for Settings
struct TutorialWrapperView: View {
    @ObservedObject var localization: LocalizationManager
    @Binding var isPresented: Bool
    @State private var dummy = false
    
    var body: some View {
        OnboardingView(localization: localization, hasCompletedOnboarding: $dummy, isReTutorial: true)
            .onChange(of: dummy) { _, newValue in
                if newValue {
                    isPresented = false
                }
            }
    }
}

// MARK: - Language Picker View - Compact Grid
struct LanguagePickerView: View {
    @ObservedObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    // Create 2-column grid for compact display
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button {
                            withAnimation {
                                localization.currentLanguage = language
                            }
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Text(language.flag)
                                    .font(.system(size: 18))
                                
                                Text(language.displayName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                if localization.currentLanguage == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(localization.currentLanguage == language ? 
                                          Color.green.opacity(0.1) : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(localization.currentLanguage == language ? 
                                            Color.green.opacity(0.5) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var companyName: String
    @Binding var userName: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Company Name", text: $companyName)
                        .textContentType(.organizationName)
                } header: {
                    Text("Company")
                } footer: {
                    Text("This appears at the top of your dashboard")
                }
                
                Section {
                    TextField("Your Name", text: $userName)
                        .textContentType(.name)
                } header: {
                    Text("Your Name")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(companyName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Manage Subscription View
struct ManageSubscriptionView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showCancelConfirm = false
    @State private var showRetentionOffer = false
    @State private var showFinalCancel = false
    
    var body: some View {
        NavigationStack {
            List {
                // Current Plan Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                Text("Pro Plan")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            Text("$49.99/month")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Active")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                } header: {
                    Text("Current Plan")
                }
                
                // Plan Benefits
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        benefitRow(icon: "infinity", text: "Unlimited orders")
                        benefitRow(icon: "photo.fill", text: "Product images")
                        benefitRow(icon: "barcode", text: "Barcode scanning")
                        benefitRow(icon: "chart.bar.fill", text: "Advanced analytics")
                        benefitRow(icon: "printer.fill", text: "Receipt printing")
                        benefitRow(icon: "square.and.arrow.up", text: "Export to Excel")
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Your Benefits")
                }
                
                // Billing History (placeholder)
                Section {
                    HStack {
                        Text("Next billing date")
                            .font(.system(size: 14))
                        Spacer()
                        Text(nextBillingDate)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("Billing")
                }
                
                // Cancel Section
                Section {
                    Button {
                        showRetentionOffer = true
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                            Text("Cancel Subscription")
                                .foregroundColor(.red)
                        }
                        .font(.system(size: 14))
                    }
                } footer: {
                    Text("You'll keep Pro access until the end of your billing period")
                }
            }
            .navigationTitle("Manage Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            // Retention offer - $5 off
            .alert("Wait! We have an offer for you", isPresented: $showRetentionOffer) {
                Button("Accept $5 Off") {
                    // Apply discount and keep subscription
                    dismiss()
                }
                Button("Still Cancel", role: .destructive) {
                    showFinalCancel = true
                }
                Button("Keep My Plan", role: .cancel) {}
            } message: {
                Text("Stay with us and get $5 off your next month! Your new price will be $44.99/month.")
            }
            // Final cancellation confirmation
            .alert("Are you sure?", isPresented: $showFinalCancel) {
                Button("Yes, Cancel", role: .destructive) {
                    // Cancel subscription
                    authManager.downgradeToFree()
                    dismiss()
                }
                Button("Keep Pro", role: .cancel) {}
            } message: {
                Text("You'll lose access to all Pro features at the end of your billing period. You can always re-subscribe later.")
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var nextBillingDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        // Calculate 30 days from now as placeholder
        let nextDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return formatter.string(from: nextDate)
    }
    
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.orange)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SettingsView(viewModel: SalesViewModel(), themeManager: ThemeManager(), authManager: AuthManager(), localization: LocalizationManager.shared)
}
