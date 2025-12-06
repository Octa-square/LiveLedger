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
    
    // MARK: - Card/Surface Colors (with transparency support)
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
    
    // MARK: - Container Backgrounds with Transparency
    func cardBackgroundWithOpacity(_ opacity: Double = 0.85) -> Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF").opacity(opacity)
        case .minimalistDark: return Color(hex: "262626").opacity(opacity)
        case .emeraldGreen: return Color(hex: "064E3B").opacity(opacity)
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.08)
        case .boldFuturistic: return Color(hex: "111111").opacity(opacity)
        case .motionRich: return Color(hex: "312E81").opacity(opacity * 0.7)
        case .sunsetOrange: return Color(hex: "292524").opacity(opacity)
        }
    }
    
    var productGridOpacity: Double { 0.80 }  // 80% opacity for product grid
    var ordersOpacity: Double { 0.82 }  // 82% opacity for orders
    var formOpacity: Double { 0.92 }  // 92% opacity for forms (readability)
    
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
    @State private var showSoundSettings = false
    @State private var showDisplaySettings = false
    @State private var showProfileSettings = false
    @State private var showStoreSettings = false
    @State private var showNetworkTest = false
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
                
                // Sound Settings Section
                Section {
                    Button {
                        showSoundSettings = true
                    } label: {
                        HStack {
                            Label("Sound Settings", systemImage: "speaker.wave.2.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Sounds")
                } footer: {
                    Text("Configure timer start and order added sounds")
                }
                
                // Display Settings Section
                Section {
                    Button {
                        showDisplaySettings = true
                    } label: {
                        HStack {
                            Label("Display Settings", systemImage: "sun.max.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Display")
                } footer: {
                    Text("Adjust brightness, contrast, and text size")
                }
                
                // Analytics & Tutorial Section
                Section {
                    NavigationLink {
                        AnalyticsView(localization: localization)
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
                    // App Name
                    HStack {
                        Image(systemName: "app.fill")
                            .foregroundColor(.green)
                        Text("LiveLedger")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                    }
                    
                    // Version
                    HStack {
                        Text(localization.localized(.version))
                        Spacer()
                        Text("1.2.0")
                            .foregroundColor(.gray)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("Real-time sales tracking for live stream sellers. Track orders, manage inventory, and grow your business across TikTok, Instagram, and Facebook.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                    
                    // Developer
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Octasquare")
                            .foregroundColor(.gray)
                    }
                    
                    // Terms & Privacy
                    NavigationLink {
                        TermsPrivacyView()
                    } label: {
                        Label("Terms & Privacy", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text(localization.localized(.about))
                }
                
                // Profile Section
                Section {
                    Button {
                        showProfileSettings = true
                    } label: {
                        HStack {
                            Label("Profile", systemImage: "person.circle.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(authManager.currentUser?.name ?? "")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button {
                        showStoreSettings = true
                    } label: {
                        HStack {
                            Label("My Store", systemImage: "building.2.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(authManager.currentUser?.companyName ?? "")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Profile & Store")
                }
                
                // Network Section
                Section {
                    Button {
                        showNetworkTest = true
                    } label: {
                        HStack {
                            Label("Network", systemImage: "network")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Connection")
                } footer: {
                    Text("Test your network before going live")
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
            .sheet(isPresented: $showSoundSettings) {
                SoundSettingsView()
            }
            .sheet(isPresented: $showDisplaySettings) {
                DisplaySettingsView(themeManager: themeManager)
            }
            .sheet(isPresented: $showProfileSettings) {
                ProfileSettingsView(authManager: authManager)
            }
            .sheet(isPresented: $showStoreSettings) {
                MyStoreSettingsView(authManager: authManager)
            }
            .sheet(isPresented: $showNetworkTest) {
                NetworkTestView()
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

// MARK: - Terms & Privacy View
struct TermsPrivacyView: View {
    var body: some View {
        List {
            Section {
                Link(destination: URL(string: "https://octa-square.github.io/LiveLedger/terms-of-service.html")!) {
                    HStack {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Link(destination: URL(string: "https://octa-square.github.io/LiveLedger/privacy-policy.html")!) {
                    HStack {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Collection")
                        .font(.subheadline.weight(.semibold))
                    Text("LiveLedger stores all your data locally on your device. We do not collect, transmit, or store your sales data on any external servers.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Third-Party Services")
                        .font(.subheadline.weight(.semibold))
                    Text("We use Apple's StoreKit for in-app purchases. No personal data is shared with third parties.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Privacy Summary")
            }
        }
        .navigationTitle("Terms & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Display Settings View
struct DisplaySettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @AppStorage("display_brightness") private var brightness: Double = 1.0
    @AppStorage("display_contrast") private var contrast: Double = 1.0
    @AppStorage("display_bgOpacity") private var bgOpacity: Double = 0.85
    @AppStorage("display_fontSize") private var fontSize: String = "Medium"
    @AppStorage("display_textWeight") private var textWeight: String = "Regular"
    @Environment(\.dismiss) var dismiss
    
    let fontSizes = ["Small", "Medium", "Large", "XL"]
    let textWeights = ["Regular", "Semi-Bold", "Bold"]
    
    var body: some View {
        NavigationStack {
            List {
                // Visual Adjustments
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Brightness")
                            Spacer()
                            Text("\(Int(brightness * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $brightness, in: 0.5...1.0)
                            .tint(.yellow)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Contrast")
                            Spacer()
                            Text("\(Int(contrast * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $contrast, in: 0.5...2.0)
                            .tint(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Background Visibility")
                            Spacer()
                            Text("\(Int(bgOpacity * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $bgOpacity, in: 0.5...0.95)
                            .tint(.green)
                    }
                } header: {
                    Text("Visual Adjustments")
                }
                
                // Text Settings
                Section {
                    Picker("Font Size", selection: $fontSize) {
                        ForEach(fontSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    
                    Picker("Text Style", selection: $textWeight) {
                        ForEach(textWeights, id: \.self) { weight in
                            Text(weight).tag(weight)
                        }
                    }
                } header: {
                    Text("Text Settings")
                }
                
                // Theme Selection
                Section {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button {
                            withAnimation {
                                themeManager.currentTheme = theme
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(theme.accentColor)
                                    .frame(width: 24, height: 24)
                                Text(theme.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if themeManager.currentTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Theme")
                }
                
                // Reset
                Section {
                    Button(role: .destructive) {
                        brightness = 1.0
                        contrast = 1.0
                        bgOpacity = 0.85
                        fontSize = "Medium"
                        textWeight = "Regular"
                    } label: {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Display Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Profile Settings View
struct ProfileSettingsView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var showChangePassword = false
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Picture
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            Button("Change Photo") {
                                showImagePicker = true
                            }
                            .font(.caption)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Personal Info
                Section {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                } header: {
                    Text("Personal Information")
                }
                
                // Security
                Section {
                    Button {
                        showChangePassword = true
                    } label: {
                        HStack {
                            Label("Change Password", systemImage: "lock.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Security")
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView(authManager: authManager)
            }
        }
    }
    
    private func loadProfile() {
        if let user = authManager.currentUser {
            name = user.name
            email = user.email
            phoneNumber = user.phoneNumber ?? ""
            if let imageData = user.profileImageData {
                profileImage = UIImage(data: imageData)
            }
        }
    }
    
    private func saveProfile() {
        authManager.currentUser?.name = name
        authManager.currentUser?.email = email.lowercased()
        authManager.currentUser?.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
        if let image = profileImage, let data = image.jpegData(compressionQuality: 0.8) {
            authManager.currentUser?.profileImageData = data
        }
        authManager.saveUser()
    }
}

// MARK: - My Store Settings View
struct MyStoreSettingsView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var storeName: String = ""
    @State private var storeAddress: String = ""
    @State private var businessPhone: String = ""
    @State private var selectedCurrency: String = "USD ($)"
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Store Name", text: $storeName)
                        .textContentType(.organizationName)
                    
                    TextField("Address", text: $storeAddress)
                        .textContentType(.fullStreetAddress)
                    
                    TextField("Business Phone", text: $businessPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                } header: {
                    Text("Store Information")
                } footer: {
                    Text("This information appears on receipts and reports")
                }
                
                Section {
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(AppUser.currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                } header: {
                    Text("Currency")
                }
            }
            .navigationTitle("My Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStore()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadStore()
            }
        }
    }
    
    private func loadStore() {
        if let user = authManager.currentUser {
            storeName = user.companyName
            storeAddress = user.storeAddress ?? ""
            businessPhone = user.businessPhone ?? ""
            selectedCurrency = user.currency
        }
    }
    
    private func saveStore() {
        authManager.currentUser?.companyName = storeName
        authManager.currentUser?.storeAddress = storeAddress.isEmpty ? nil : storeAddress
        authManager.currentUser?.businessPhone = businessPhone.isEmpty ? nil : businessPhone
        authManager.currentUser?.currency = selectedCurrency
        authManager.saveUser()
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    
    private var isNewPasswordValid: Bool {
        let hasLetter = newPassword.rangeOfCharacter(from: .letters) != nil
        let hasSymbol = newPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil
        let hasMinLength = newPassword.count >= 6
        return hasLetter && hasSymbol && hasMinLength
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showCurrentPassword {
                            TextField("Current Password", text: $currentPassword)
                        } else {
                            SecureField("Current Password", text: $currentPassword)
                        }
                        Button {
                            showCurrentPassword.toggle()
                        } label: {
                            Image(systemName: showCurrentPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Current Password")
                }
                
                Section {
                    HStack {
                        if showNewPassword {
                            TextField("New Password", text: $newPassword)
                        } else {
                            SecureField("New Password", text: $newPassword)
                        }
                        Button {
                            showNewPassword.toggle()
                        } label: {
                            Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                !newPassword.isEmpty && !isNewPasswordValid ? Color.red : Color.clear,
                                lineWidth: 1
                            )
                    )
                    
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    !confirmPassword.isEmpty && confirmPassword != newPassword ? Color.red : Color.clear,
                                    lineWidth: 1
                                )
                        )
                } header: {
                    Text("New Password")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password must contain:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("• At least 6 characters")
                            .font(.caption)
                            .foregroundColor(newPassword.count >= 6 ? .green : .secondary)
                        Text("• At least one letter")
                            .font(.caption)
                            .foregroundColor(newPassword.rangeOfCharacter(from: .letters) != nil ? .green : .secondary)
                        Text("• At least one symbol (!@#$%...)")
                            .font(.caption)
                            .foregroundColor(newPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil ? .green : .secondary)
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        changePassword()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !currentPassword.isEmpty && isNewPasswordValid && newPassword == confirmPassword
    }
    
    private func changePassword() {
        // Verify current password
        if let error = authManager.signIn(email: authManager.currentUser?.email ?? "", password: currentPassword) {
            errorMessage = "Current password is incorrect"
            return
        }
        
        // Update password
        authManager.updatePassword(newPassword: newPassword)
        dismiss()
    }
}

// MARK: - Network Test View
struct NetworkTestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isTestingDownload = false
    @State private var isTestingUpload = false
    @State private var isTestingLatency = false
    @State private var downloadSpeed: Double?
    @State private var uploadSpeed: Double?
    @State private var latency: Double?
    @State private var testStartTime: Date?
    
    var qualityAssessment: (text: String, color: Color) {
        guard let download = downloadSpeed, let upload = uploadSpeed, let ping = latency else {
            return ("Not Tested", .gray)
        }
        
        if download >= 50 && upload >= 10 && ping < 50 {
            return ("Excellent", .green)
        } else if download >= 25 && upload >= 5 && ping < 100 {
            return ("Good", .blue)
        } else if download >= 10 && upload >= 2 && ping < 200 {
            return ("Fair", .orange)
        } else {
            return ("Poor", .red)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Connection Status
                Section {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.green)
                        Text("Connected")
                            .foregroundColor(.green)
                        Spacer()
                        Text("Wi-Fi")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Connection Status")
                }
                
                // Speed Test Results
                Section {
                    HStack {
                        Label("Download", systemImage: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                        Spacer()
                        if isTestingDownload {
                            ProgressView()
                        } else if let speed = downloadSpeed {
                            Text("\(String(format: "%.1f", speed)) Mbps")
                                .font(.system(.body, design: .monospaced))
                        } else {
                            Text("—")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Label("Upload", systemImage: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Spacer()
                        if isTestingUpload {
                            ProgressView()
                        } else if let speed = uploadSpeed {
                            Text("\(String(format: "%.1f", speed)) Mbps")
                                .font(.system(.body, design: .monospaced))
                        } else {
                            Text("—")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Label("Latency", systemImage: "clock.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        if isTestingLatency {
                            ProgressView()
                        } else if let ping = latency {
                            Text("\(Int(ping)) ms")
                                .font(.system(.body, design: .monospaced))
                        } else {
                            Text("—")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Speed Test Results")
                }
                
                // Quality Assessment
                Section {
                    HStack {
                        Text("Stream Quality")
                        Spacer()
                        Text(qualityAssessment.text)
                            .foregroundColor(qualityAssessment.color)
                            .font(.system(size: 14, weight: .semibold))
                    }
                } header: {
                    Text("Assessment")
                } footer: {
                    Text("For best streaming: Download > 50 Mbps, Upload > 10 Mbps, Latency < 50ms")
                }
                
                // Test Button
                Section {
                    Button {
                        runNetworkTest()
                    } label: {
                        HStack {
                            Spacer()
                            if isTestingDownload || isTestingUpload || isTestingLatency {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Testing...")
                            } else {
                                Image(systemName: "speedometer")
                                Text("Test Network Bandwidth")
                            }
                            Spacer()
                        }
                    }
                    .disabled(isTestingDownload || isTestingUpload || isTestingLatency)
                }
            }
            .navigationTitle("Network")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func runNetworkTest() {
        // Reset
        downloadSpeed = nil
        uploadSpeed = nil
        latency = nil
        
        // Simulate latency test
        isTestingLatency = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            latency = Double.random(in: 15...80)
            isTestingLatency = false
            
            // Simulate download test
            isTestingDownload = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                downloadSpeed = Double.random(in: 30...120)
                isTestingDownload = false
                
                // Simulate upload test
                isTestingUpload = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    uploadSpeed = Double.random(in: 8...50)
                    isTestingUpload = false
                }
            }
        }
    }
}

#Preview {
    SettingsView(themeManager: ThemeManager(), authManager: AuthManager(), localization: LocalizationManager.shared)
}
