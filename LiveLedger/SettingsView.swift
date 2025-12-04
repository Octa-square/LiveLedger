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
    case boldFuturistic = "Bold Futuristic"
    case motionRich = "Motion Rich"
    case sunsetOrange = "Sunset Orange"
    case grayscale = "Grayscale"
    
    // MARK: - Theme Mode
    var isDarkTheme: Bool {
        switch self {
        case .minimalistLight:
            return false
        case .minimalistDark, .emeraldGreen, .boldFuturistic, .motionRich, .sunsetOrange, .grayscale:
            return true
        }
    }
    
    var isGrayscale: Bool {
        self == .grayscale
    }
    
    // MARK: - Text Colors (BRIGHTER)
    var textPrimary: Color {
        switch self {
        case .minimalistLight: return Color(hex: "111111")
        case .minimalistDark: return Color(hex: "FFFFFF")
        case .emeraldGreen: return Color(hex: "FFFFFF")
        case .boldFuturistic: return Color(hex: "FFFFFF")
        case .motionRich: return Color(hex: "FFFFFF")
        case .sunsetOrange: return Color(hex: "FFFFFF")
        case .grayscale: return Color(hex: "FFFFFF")
        }
    }
    
    var textSecondary: Color {
        switch self {
        case .minimalistLight: return Color(hex: "4B5563")
        case .minimalistDark: return Color(hex: "D1D5DB")
        case .emeraldGreen: return Color(hex: "A7F3D0")
        case .boldFuturistic: return Color(hex: "6EE7B7")
        case .motionRich: return Color(hex: "DDD6FE")
        case .sunsetOrange: return Color(hex: "FED7AA")
        case .grayscale: return Color(hex: "B0B0B0")
        }
    }
    
    var textMuted: Color {
        switch self {
        case .minimalistLight: return Color(hex: "6B7280")
        case .minimalistDark: return Color(hex: "9CA3AF")
        case .emeraldGreen: return Color(hex: "6EE7B7")
        case .boldFuturistic: return Color(hex: "34D399")
        case .motionRich: return Color(hex: "C4B5FD")
        case .sunsetOrange: return Color(hex: "FDBA74")
        case .grayscale: return Color(hex: "808080")
        }
    }
    
    // MARK: - Accent Colors
    var accentColor: Color {
        switch self {
        case .minimalistLight: return Color(hex: "3B82F6")
        case .minimalistDark: return Color(hex: "60A5FA")
        case .emeraldGreen: return Color(hex: "10B981")
        case .boldFuturistic: return Color(hex: "00F5A0")
        case .motionRich: return Color(hex: "A78BFA")
        case .sunsetOrange: return Color(hex: "FF6A00")
        case .grayscale: return Color(hex: "666666")
        }
    }
    
    var primaryColor: Color { accentColor }
    
    var secondaryColor: Color {
        switch self {
        case .minimalistLight: return Color(hex: "10B981")
        case .minimalistDark: return Color(hex: "34D399")
        case .emeraldGreen: return Color(hex: "34D399")
        case .boldFuturistic: return Color(hex: "00D1FF")
        case .motionRich: return Color(hex: "EC4899")
        case .sunsetOrange: return Color(hex: "F97316")
        case .grayscale: return Color(hex: "999999")
        }
    }
    
    // MARK: - Background Image
    var backgroundImageName: String {
        switch self {
        case .minimalistLight: return "ThemeBG_MinimalistLight"
        case .minimalistDark: return "ThemeBG_MinimalistDark"
        case .emeraldGreen: return "ThemeBG_EmeraldGreen"
        case .boldFuturistic: return "ThemeBG_BoldFuturistic"
        case .motionRich: return "ThemeBG_MotionRich"
        case .sunsetOrange: return "ThemeBG_SunsetOrange"
        case .grayscale: return "ThemeBG_MinimalistDark" // Will be filtered to grayscale
        }
    }
    
    // Overlay opacity - lower = more visible background image
    var backgroundOverlayOpacity: Double {
        switch self {
        case .minimalistLight: return 0.55
        case .minimalistDark: return 0.40
        case .emeraldGreen: return 0.40
        case .boldFuturistic: return 0.40
        case .motionRich: return 0.35
        case .sunsetOrange: return 0.40
        case .grayscale: return 0.45
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
        case .boldFuturistic: 
            return [Color(hex: "000000"), Color(hex: "0A0A0A"), Color(hex: "050505")]
        case .motionRich: 
            return [Color(hex: "1E1B4B"), Color(hex: "2E1065"), Color(hex: "1E1B4B")]
        case .sunsetOrange: 
            return [Color(hex: "1C1917"), Color(hex: "292524"), Color(hex: "44403C")]
        case .grayscale:
            return [Color(hex: "1A1A1A"), Color(hex: "2C2C2C"), Color(hex: "3D3D3D")]
        }
    }
    
    // MARK: - Card/Surface Colors (Semi-transparent for background visibility)
    var cardBackground: Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF").opacity(0.82)
        case .minimalistDark: return Color(hex: "262626").opacity(0.80)
        case .emeraldGreen: return Color(hex: "064E3B").opacity(0.78)
        case .boldFuturistic: return Color(hex: "111111").opacity(0.78)
        case .motionRich: return Color(hex: "312E81").opacity(0.70)
        case .sunsetOrange: return Color(hex: "292524").opacity(0.78)
        case .grayscale: return Color(hex: "2C2C2C").opacity(0.80)
        }
    }
    
    // More transparent card for larger areas (product grid, orders)
    var cardBackgroundSubtle: Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF").opacity(0.75)
        case .minimalistDark: return Color(hex: "262626").opacity(0.72)
        case .emeraldGreen: return Color(hex: "064E3B").opacity(0.70)
        case .boldFuturistic: return Color(hex: "111111").opacity(0.70)
        case .motionRich: return Color(hex: "312E81").opacity(0.60)
        case .sunsetOrange: return Color(hex: "292524").opacity(0.70)
        case .grayscale: return Color(hex: "2C2C2C").opacity(0.72)
        }
    }
    
    // Higher opacity for input fields and critical elements
    var cardBackgroundSolid: Color {
        switch self {
        case .minimalistLight: return Color(hex: "FFFFFF").opacity(0.92)
        case .minimalistDark: return Color(hex: "262626").opacity(0.90)
        case .emeraldGreen: return Color(hex: "064E3B").opacity(0.88)
        case .boldFuturistic: return Color(hex: "111111").opacity(0.88)
        case .motionRich: return Color(hex: "312E81").opacity(0.82)
        case .sunsetOrange: return Color(hex: "292524").opacity(0.88)
        case .grayscale: return Color(hex: "2C2C2C").opacity(0.90)
        }
    }
    
    var cardBorder: Color {
        switch self {
        case .minimalistLight: return Color(hex: "D1D5DB")
        case .minimalistDark: return Color(hex: "525252")
        case .emeraldGreen: return Color(hex: "10B981").opacity(0.4)
        case .boldFuturistic: return Color(hex: "00F5A0").opacity(0.4)
        case .motionRich: return Color(hex: "A78BFA").opacity(0.4)
        case .sunsetOrange: return Color(hex: "FF6A00").opacity(0.4)
        case .grayscale: return Color(hex: "666666").opacity(0.5)
        }
    }
    
    // MARK: - Shadows (for neumorphic effects)
    var shadowLight: Color {
        switch self {
        case .minimalistLight: return Color.white
        case .minimalistDark: return Color(hex: "404040")
        case .emeraldGreen: return Color(hex: "065F46")
        case .boldFuturistic: return Color(hex: "00F5A0").opacity(0.1)
        case .motionRich: return Color(hex: "A78BFA").opacity(0.1)
        case .sunsetOrange: return Color(hex: "57534E")
        case .grayscale: return Color(hex: "4A4A4A")
        }
    }
    
    var shadowDark: Color {
        switch self {
        case .minimalistLight: return Color(hex: "D1D5DB")
        case .minimalistDark: return Color.black
        case .emeraldGreen: return Color.black.opacity(0.4)
        case .boldFuturistic: return Color(hex: "00F5A0").opacity(0.2)
        case .motionRich: return Color(hex: "8B5CF6").opacity(0.3)
        case .sunsetOrange: return Color.black.opacity(0.5)
        case .grayscale: return Color.black.opacity(0.6)
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
        case .boldFuturistic: return "bolt.fill"
        case .motionRich: return "waveform.path"
        case .sunsetOrange: return "sun.horizon.fill"
        case .grayscale: return "circle.lefthalf.filled"
        }
    }
    
    // MARK: - Text Readability & Contrast (for transparent backgrounds)
    
    // Text shadow for depth and separation
    var textShadowColor: Color {
        switch self {
        case .minimalistLight: return Color.white.opacity(0.4)  // Light glow for dark text
        case .minimalistDark: return Color.black.opacity(0.6)
        case .emeraldGreen: return Color.black.opacity(0.5)
        case .boldFuturistic: return Color.black.opacity(0.7)
        case .motionRich: return Color.black.opacity(0.6)
        case .sunsetOrange: return Color.black.opacity(0.5)
        case .grayscale: return Color.black.opacity(0.6)
        }
    }
    
    var textShadowRadius: CGFloat {
        switch self {
        case .minimalistLight: return 2
        case .minimalistDark, .emeraldGreen, .sunsetOrange: return 3
        case .boldFuturistic, .motionRich: return 4
        case .grayscale: return 3
        }
    }
    
    var textShadowOffset: CGSize {
        switch self {
        case .minimalistLight: return CGSize(width: 0, height: 1)
        default: return CGSize(width: 0, height: 2)
        }
    }
    
    // Check if theme is light (for dynamic text contrast)
    var isLightTheme: Bool {
        switch self {
        case .minimalistLight: return true
        default: return false
        }
    }
    
    // MARK: - Adaptive Text Styling
    
    // Bold heading text with high contrast
    var headingTextColor: Color {
        isLightTheme ? Color(hex: "1A1A1A") : Color.white
    }
    
    // Standard text weights for hierarchy
    var headingWeight: Font.Weight { .bold }
    var labelWeight: Font.Weight { .semibold }
    var bodyWeight: Font.Weight { .medium }
    
    // Container background with optimal opacity for text readability
    var readableContainerBg: Color {
        switch self {
        case .minimalistLight: return Color.white.opacity(0.88)
        case .minimalistDark: return Color.black.opacity(0.80)
        case .emeraldGreen: return Color(hex: "022C22").opacity(0.82)
        case .boldFuturistic: return Color.black.opacity(0.82)
        case .motionRich: return Color(hex: "1E1B4B").opacity(0.80)
        case .sunsetOrange: return Color(hex: "1C1917").opacity(0.82)
        case .grayscale: return Color(hex: "1A1A1A").opacity(0.85)
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
    @State private var showChangePassword = false
    @State private var showImagePicker = false
    @State private var showEditStore = false
    @State private var showNetworkTest = false
    @State private var editedCompanyName = ""
    @State private var editedUserName = ""
    @State private var editedEmail = ""
    @State private var editedPhone = ""
    @State private var editedStoreAddress = ""
    @State private var editedStorePhone = ""
    @State private var editedStoreDescription = ""
    @State private var selectedCurrency = "USD"
    @State private var profileImage: UIImage? = nil
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Section (Personal Information)
                if let user = authManager.currentUser {
                    Section {
                        // Profile Picture
                        HStack {
                            Button {
                                showImagePicker = true
                            } label: {
                                ZStack {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(.blue)
                                            )
                                    }
                                    
                                    // Camera badge
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.white)
                                        )
                                        .offset(x: 20, y: 20)
                                }
                            }
                            
                            Spacer()
                            
                            // Pro Badge
                            if user.isPro {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 12))
                                    Text("PRO")
                                        .font(.system(size: 12, weight: .black))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 6)
                        
                        // Full Name
                        HStack {
                            Label("Full Name", systemImage: "person.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.name)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                        
                        // Email
                        HStack {
                            Label("Email", systemImage: "envelope.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.email)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                        
                        // Phone Number
                        HStack {
                            Label("Phone", systemImage: "phone.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.phone.isEmpty ? "Not set" : user.phone)
                                .font(.system(size: 14))
                                .foregroundColor(user.phone.isEmpty ? .gray : .primary)
                        }
                        
                        // Edit Profile Button
                        Button {
                            editedUserName = user.name
                            editedEmail = user.email
                            editedPhone = user.phone
                            showEditProfile = true
                        } label: {
                            HStack {
                                Label("Edit Profile", systemImage: "pencil")
                                    .font(.system(size: 14))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        // Change Password Button
                        Button {
                            showChangePassword = true
                        } label: {
                            HStack {
                                Label("Change Password", systemImage: "lock.fill")
                                    .font(.system(size: 14))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.blue)
                        }
                    } header: {
                        Text("Profile")
                            .font(.system(size: 11))
                    }
                    
                    // MARK: - My Store Section (Business Information)
                    Section {
                        // Store Name
                        HStack {
                            Label("Store Name", systemImage: "storefront.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.companyName.isEmpty ? "Not set" : user.companyName)
                                .font(.system(size: 14))
                                .foregroundColor(user.companyName.isEmpty ? .gray : .primary)
                        }
                        
                        // Business Address
                        HStack {
                            Label("Address", systemImage: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(editedStoreAddress.isEmpty ? "Not set" : editedStoreAddress)
                                .font(.system(size: 14))
                                .foregroundColor(editedStoreAddress.isEmpty ? .gray : .primary)
                                .lineLimit(1)
                        }
                        
                        // Business Phone
                        HStack {
                            Label("Business Phone", systemImage: "phone.badge.checkmark")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(editedStorePhone.isEmpty ? "Not set" : editedStorePhone)
                                .font(.system(size: 14))
                                .foregroundColor(editedStorePhone.isEmpty ? .gray : .primary)
                        }
                        
                        // Currency
                        HStack {
                            Label("Currency", systemImage: "dollarsign.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(selectedCurrency)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                        
                        // Edit Store Button
                        Button {
                            editedCompanyName = user.companyName
                            showEditStore = true
                        } label: {
                            HStack {
                                Label("Edit Store Info", systemImage: "pencil")
                                    .font(.system(size: 14))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.blue)
                        }
                    } header: {
                        Text("My Store")
                            .font(.system(size: 11))
                    }
                    
                    // Subscription Section
                    Section {
                        if !user.isPro {
                            Button {
                                showSubscription = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                        .foregroundColor(.orange)
                                    Text("Upgrade to Pro")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.orange)
                                    Spacer()
                                    Text("$49.99/mo")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        } else {
                            Button {
                                showManageSubscription = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
                                    Text("Manage Subscription")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    } header: {
                        Text("Subscription")
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
                
                // Network Section
                Section {
                    NavigationLink {
                        NetworkTestView()
                    } label: {
                        HStack {
                            Label("Network", systemImage: "wifi")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("Check Connection")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Network")
                } footer: {
                    Text("Test your internet connection for live streaming")
                }
                
                // Display Settings Section
                Section {
                    NavigationLink {
                        DisplaySettingsView(themeManager: themeManager)
                    } label: {
                        HStack {
                            Label("Display & Appearance", systemImage: "paintbrush.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("Customize")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Display")
                } footer: {
                    Text("Adjust brightness, contrast, and background visibility")
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
                    userName: $editedUserName,
                    email: $editedEmail,
                    phone: $editedPhone,
                    onSave: {
                        authManager.updateUserName(editedUserName)
                        authManager.updateEmail(editedEmail)
                        authManager.updatePhone(editedPhone)
                    }
                )
            }
            .sheet(isPresented: $showEditStore) {
                EditStoreView(
                    companyName: $editedCompanyName,
                    storeAddress: $editedStoreAddress,
                    storePhone: $editedStorePhone,
                    storeDescription: $editedStoreDescription,
                    currency: $selectedCurrency,
                    onSave: {
                        authManager.updateCompanyName(editedCompanyName)
                    }
                )
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView(authManager: authManager)
            }
            .sheet(isPresented: $showManageSubscription) {
                ManageSubscriptionView(authManager: authManager)
            }
            .sheet(isPresented: $showImagePicker) {
                ProfileImagePicker(image: $profileImage)
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
        case .boldFuturistic: return "Neon cyber vibes"
        case .motionRich: return "Smooth purple flow"
        case .sunsetOrange: return "Warm sunset glow"
        case .grayscale: return "Black & white focus"
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

// MARK: - Manage Subscription View
struct ManageSubscriptionView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showCancelConfirm = false
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
                        showFinalCancel = true
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
            // Cancellation confirmation
            .alert("Cancel Subscription?", isPresented: $showFinalCancel) {
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

// MARK: - Edit Profile View (Personal Information)
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    @Binding var email: String
    @Binding var phone: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Full Name", text: $userName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                } header: {
                    Text("Personal Information")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Edit Store View (Business Information)
struct EditStoreView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var companyName: String
    @Binding var storeAddress: String
    @Binding var storePhone: String
    @Binding var storeDescription: String
    @Binding var currency: String
    let onSave: () -> Void
    
    let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "CNY", "INR", "NGN", "ZAR", "BRL", "MXN"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Store/Company Name", text: $companyName)
                    TextField("Business Address", text: $storeAddress)
                    TextField("Business Phone", text: $storePhone)
                        .keyboardType(.phonePad)
                } header: {
                    Text("Business Details")
                }
                
                Section {
                    TextEditor(text: $storeDescription)
                        .frame(minHeight: 80)
                } header: {
                    Text("Store Description (Optional)")
                }
                
                Section {
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { curr in
                            Text(curr).tag(curr)
                        }
                    }
                } header: {
                    Text("Currency Preference")
                }
            }
            .navigationTitle("Edit Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authManager: AuthManager
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isCurrentPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var isPasswordValid: Bool {
        newPassword.count >= 6 &&
        newPassword.contains(where: { $0.isLetter }) &&
        newPassword.contains(where: { "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) })
    }
    
    var passwordsMatch: Bool {
        newPassword == confirmPassword && !newPassword.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if isCurrentPasswordVisible {
                            TextField("Current Password", text: $currentPassword)
                        } else {
                            SecureField("Current Password", text: $currentPassword)
                        }
                        Button {
                            isCurrentPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isCurrentPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Verify Identity")
                }
                
                Section {
                    HStack {
                        if isNewPasswordVisible {
                            TextField("New Password", text: $newPassword)
                        } else {
                            SecureField("New Password", text: $newPassword)
                        }
                        Button {
                            isNewPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        if isConfirmPasswordVisible {
                            TextField("Confirm Password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                        }
                        Button {
                            isConfirmPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Password requirements
                    VStack(alignment: .leading, spacing: 4) {
                        PasswordRequirementRow(
                            met: newPassword.count >= 6,
                            text: "At least 6 characters"
                        )
                        PasswordRequirementRow(
                            met: newPassword.contains(where: { $0.isLetter }),
                            text: "At least one letter"
                        )
                        PasswordRequirementRow(
                            met: newPassword.contains(where: { "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) }),
                            text: "At least one symbol"
                        )
                        if !confirmPassword.isEmpty {
                            PasswordRequirementRow(
                                met: passwordsMatch,
                                text: "Passwords match"
                            )
                        }
                    }
                    .font(.system(size: 12))
                    .padding(.vertical, 4)
                } header: {
                    Text("New Password")
                } footer: {
                    Text("Password must be at least 6 characters with at least one letter and one symbol")
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
                        if currentPassword.isEmpty {
                            errorMessage = "Please enter your current password"
                            showError = true
                        } else if !isPasswordValid {
                            errorMessage = "New password doesn't meet requirements"
                            showError = true
                        } else if !passwordsMatch {
                            errorMessage = "Passwords don't match"
                            showError = true
                        } else {
                            // Save password
                            authManager.updatePassword(newPassword)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!isPasswordValid || !passwordsMatch || currentPassword.isEmpty)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - Password Requirement Row
struct PasswordRequirementRow: View {
    let met: Bool
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundColor(met ? .green : .gray)
                .font(.system(size: 12))
            Text(text)
                .foregroundColor(met ? .primary : .gray)
        }
    }
}

// MARK: - Network Test View
struct NetworkTestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isTestingNetwork = false
    @State private var testComplete = false
    @State private var connectionStatus = "Unknown"
    @State private var connectionType = "Unknown"
    @State private var downloadSpeed = 0.0
    @State private var uploadSpeed = 0.0
    @State private var latency = 0
    @State private var signalStrength = "Unknown"
    
    var connectionQuality: (text: String, color: Color, icon: String) {
        if downloadSpeed >= 50 && uploadSpeed >= 10 && latency < 50 {
            return ("Excellent - Great for live streaming", .green, "checkmark.circle.fill")
        } else if downloadSpeed >= 25 && uploadSpeed >= 5 && latency < 100 {
            return ("Good - Suitable for live streaming", .green, "checkmark.circle")
        } else if downloadSpeed >= 10 && uploadSpeed >= 2 {
            return ("Fair - May experience occasional lag", .orange, "exclamationmark.triangle.fill")
        } else {
            return ("Poor - Not recommended for live streaming", .red, "xmark.circle.fill")
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Current Status
                Section {
                    HStack {
                        Label("Status", systemImage: "wifi")
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(connectionStatus == "Connected" ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(connectionStatus)
                                .foregroundColor(connectionStatus == "Connected" ? .green : .red)
                        }
                        .font(.system(size: 14))
                    }
                    
                    HStack {
                        Label("Connection Type", systemImage: "antenna.radiowaves.left.and.right")
                        Spacer()
                        Text(connectionType)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Signal Strength", systemImage: "cellularbars")
                        Spacer()
                        Text(signalStrength)
                            .font(.system(size: 14))
                            .foregroundColor(signalStrengthColor)
                    }
                } header: {
                    Text("Connection Status")
                }
                
                // Test Results
                if testComplete {
                    Section {
                        HStack {
                            Label("Download", systemImage: "arrow.down.circle.fill")
                                .foregroundColor(.blue)
                            Spacer()
                            Text("\(String(format: "%.1f", downloadSpeed)) Mbps")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        HStack {
                            Label("Upload", systemImage: "arrow.up.circle.fill")
                                .foregroundColor(.green)
                            Spacer()
                            Text("\(String(format: "%.1f", uploadSpeed)) Mbps")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        HStack {
                            Label("Latency", systemImage: "timer")
                                .foregroundColor(.orange)
                            Spacer()
                            Text("\(latency) ms")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    } header: {
                        Text("Speed Test Results")
                    }
                    
                    // Quality Assessment
                    Section {
                        HStack(spacing: 10) {
                            Image(systemName: connectionQuality.icon)
                                .font(.system(size: 24))
                                .foregroundColor(connectionQuality.color)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(connectionQuality.text)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(connectionQuality.color)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Streaming Readiness")
                    }
                    
                    // Recommendations
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            recommendationRow(icon: "arrow.up", text: "Upload: Minimum 5 Mbps for HD streaming")
                            recommendationRow(icon: "timer", text: "Latency: Under 100ms for smooth experience")
                            recommendationRow(icon: "wifi", text: "Use WiFi when possible for stability")
                        }
                        .font(.system(size: 13))
                        .padding(.vertical, 4)
                    } header: {
                        Text("Recommended for Live Streaming")
                    }
                }
                
                // Test Button
                Section {
                    Button {
                        runNetworkTest()
                    } label: {
                        HStack {
                            Spacer()
                            if isTestingNetwork {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Testing...")
                            } else {
                                Image(systemName: "speedometer")
                                Text(testComplete ? "Test Again" : "Test Network Speed")
                            }
                            Spacer()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Network")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                checkConnectionStatus()
            }
        }
    }
    
    private var signalStrengthColor: Color {
        switch signalStrength {
        case "Excellent": return .green
        case "Good": return .green
        case "Fair": return .orange
        case "Poor": return .red
        default: return .gray
        }
    }
    
    private func recommendationRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
    
    private func checkConnectionStatus() {
        // Simple check - in real app would use NWPathMonitor
        connectionStatus = "Connected"
        connectionType = "WiFi"
        signalStrength = "Good"
    }
    
    private func runNetworkTest() {
        isTestingNetwork = true
        testComplete = false
        
        // Simulate network test (in real app would actually measure)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // Simulated results - in production would use actual network measurement
            downloadSpeed = Double.random(in: 25...120)
            uploadSpeed = Double.random(in: 5...50)
            latency = Int.random(in: 15...80)
            signalStrength = downloadSpeed > 50 ? "Excellent" : (downloadSpeed > 25 ? "Good" : "Fair")
            
            isTestingNetwork = false
            testComplete = true
        }
    }
}

// MARK: - Profile Image Picker
struct ProfileImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ProfileImagePicker
        
        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Display Settings View
struct DisplaySettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("app_brightness") private var brightness: Double = 1.0
    @AppStorage("app_contrast") private var contrast: Double = 1.0
    @AppStorage("app_bg_opacity") private var bgOpacity: Double = 0.80
    @AppStorage("app_font_size") private var fontSize: String = "Medium"
    @AppStorage("app_font_type") private var fontType: String = "System"
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    var body: some View {
        NavigationStack {
            List {
                // Theme Selection
                Section {
                    ForEach(AppTheme.allCases, id: \.self) { selectedTheme in
                        Button {
                            withAnimation {
                                themeManager.currentTheme = selectedTheme
                            }
                        } label: {
                            HStack(spacing: 12) {
                                // Theme preview circle
                                ZStack {
                                    Circle()
                                        .fill(selectedTheme.gradientColors.first ?? .gray)
                                        .frame(width: 36, height: 36)
                                    
                                    if selectedTheme.isGrayscale {
                                        // Grayscale indicator
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 18, height: 18)
                                    }
                                    
                                    Image(systemName: selectedTheme.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(selectedTheme.isLightTheme ? .black : .white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedTheme.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text(themeDescription(selectedTheme))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if themeManager.currentTheme == selectedTheme {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Theme")
                } footer: {
                    if theme.isGrayscale {
                        Text("Grayscale mode converts all colors to black, white, and gray tones")
                    }
                }
                
                // Brightness Control
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Brightness", systemImage: "sun.max.fill")
                                .font(.system(size: 14))
                            Spacer()
                            Text("\(Int(brightness * 100))%")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $brightness, in: 0.5...1.5, step: 0.05)
                            .tint(.yellow)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Contrast", systemImage: "circle.lefthalf.filled")
                                .font(.system(size: 14))
                            Spacer()
                            Text("\(Int(contrast * 100))%")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $contrast, in: 0.5...2.0, step: 0.05)
                            .tint(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Background Visibility", systemImage: "square.stack.3d.up")
                                .font(.system(size: 14))
                            Spacer()
                            Text("\(Int((1.0 - bgOpacity) * 100))%")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $bgOpacity, in: 0.50...0.95, step: 0.05)
                            .tint(.purple)
                        
                        Text("Lower = more background visible")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Display Adjustments")
                } footer: {
                    Text("Adjust visual settings for comfortable viewing")
                }
                
                // Font Size
                Section {
                    Picker("Font Size", selection: $fontSize) {
                        Text("Small").tag("Small")
                        Text("Medium").tag("Medium")
                        Text("Large").tag("Large")
                        Text("Extra Large").tag("Extra Large")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Font Size")
                }
                
                // Text Weight
                Section {
                    Picker("Text Style", selection: $textWeight) {
                        Text("Regular").tag("Regular")
                        Text("Semi-Bold").tag("Semi-Bold")
                        Text("Bold").tag("Bold")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Text Style")
                } footer: {
                    Text("Bolder text improves readability on transparent backgrounds")
                }
                
                // Reset Button
                Section {
                    Button {
                        withAnimation {
                            brightness = 1.0
                            contrast = 1.0
                            bgOpacity = 0.80
                            fontSize = "Medium"
                            textWeight = "Semi-Bold"
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Display & Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func themeDescription(_ theme: AppTheme) -> String {
        switch theme {
        case .minimalistLight: return "Clean & airy whites"
        case .minimalistDark: return "Smooth dark contrast"
        case .emeraldGreen: return "Rich forest vibes"
        case .boldFuturistic: return "Neon cyber vibes"
        case .motionRich: return "Smooth purple flow"
        case .sunsetOrange: return "Warm sunset glow"
        case .grayscale: return "Black & white focus"
        }
    }
}

#Preview {
    SettingsView(viewModel: SalesViewModel(), themeManager: ThemeManager(), authManager: AuthManager(), localization: LocalizationManager.shared)
}
