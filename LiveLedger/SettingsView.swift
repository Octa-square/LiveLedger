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
        case .minimalistLight: return 0.7
        case .minimalistDark: return 0.5
        case .emeraldGreen: return 0.5
        case .glassmorphism: return 0.4
        case .boldFuturistic: return 0.5
        case .motionRich: return 0.4
        case .sunsetOrange: return 0.5
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
    
    // MARK: - Card/Surface Colors
    var cardBackground: Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF")
        case .minimalistDark: return Color(hex: "262626")
        case .emeraldGreen: return Color(hex: "064E3B")
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.1)
        case .boldFuturistic: return Color(hex: "111111")
        case .motionRich: return Color(hex: "312E81").opacity(0.6)
        case .sunsetOrange: return Color(hex: "292524")
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
    @State private var editedCompanyName = ""
    @State private var editedUserName = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                if let user = authManager.currentUser {
                    Section {
                        HStack(spacing: 12) {
                            // Account Icon
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.companyName)
                                    .font(.headline)
                                Text(user.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 4) {
                                    if user.isPro {
                                        Label("PRO", systemImage: "crown.fill")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.orange)
                                    } else {
                                        Text("Free Plan")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                editedCompanyName = user.companyName
                                editedUserName = user.name
                                showEditProfile = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if !user.isPro {
                            Button {
                                showSubscription = true
                            } label: {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.orange)
                                    Text("Upgrade to Pro")
                                        .foregroundColor(.orange)
                                    Spacer()
                                    Text("$49.99/mo")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    } header: {
                        Text(localization.localized(.profile))
                    }
                }
                
                // Themes Section
                Section {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button {
                            withAnimation {
                                themeManager.currentTheme = theme
                            }
                        } label: {
                            HStack(spacing: 12) {
                                // Theme color preview
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(colors: [theme.primaryColor, theme.secondaryColor],
                                                          startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: theme.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(theme.rawValue)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text(themeDescription(theme))
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if themeManager.currentTheme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(theme.primaryColor)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text(localization.localized(.themes))
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
                    HStack {
                        Text(localization.localized(.version))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink {
                        IconExportView()
                    } label: {
                        Label("Export App Icons", systemImage: "square.and.arrow.down")
                    }
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

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @ObservedObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button {
                        withAnimation {
                            localization.currentLanguage = language
                        }
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Text(language.flag)
                                .font(.system(size: 28))
                            
                            Text(language.displayName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if localization.currentLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
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

#Preview {
    SettingsView(viewModel: SalesViewModel(), themeManager: ThemeManager(), authManager: AuthManager(), localization: LocalizationManager.shared)
}
