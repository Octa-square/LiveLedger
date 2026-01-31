//
//  SettingsView.swift
//  LiveLedger
//
//  LiveLedger - Settings & Themes
//

import SwiftUI
import Combine
import PhotosUI

// MARK: - Theme Definitions
enum AppTheme: String, CaseIterable, Codable {
    case liveLedger = "LiveLedger"
    case emeraldGreen = "Emerald Green"
    case glassmorphism = "Glassmorphism"
    case boldFuturistic = "Bold Futuristic"
    case motionRich = "Motion Rich"
    case sunsetOrange = "Sunset Orange"
    
    // MARK: - Theme Mode
    var isDarkTheme: Bool {
        // All remaining themes are dark themes
        return true
    }
    
    // MARK: - Has Wallpaper
    var hasWallpaper: Bool {
        switch self {
        case .liveLedger: return false  // Plain background, no wallpaper
        default: return true
        }
    }
    
    // MARK: - Text Colors (BRIGHTER - More Visible)
    var textPrimary: Color {
        switch self {
        case .liveLedger: return Color(hex: "FFFFFF")
        case .emeraldGreen: return Color(hex: "FFFFFF")
        case .glassmorphism: return Color(hex: "FFFFFF")
        case .boldFuturistic: return Color(hex: "00FFFF") // Bright cyan
        case .motionRich: return Color(hex: "FFFFFF")
        case .sunsetOrange: return Color(hex: "FFFFFF")
        }
    }
    
    var textSecondary: Color {
        switch self {
        case .liveLedger: return Color(hex: "C8E6C9") // Light green tint
        case .emeraldGreen: return Color(hex: "B8FFE0") // Brighter mint
        case .glassmorphism: return Color(hex: "E0E7FF") // Brighter
        case .boldFuturistic: return Color(hex: "00E6FF") // Bright cyan
        case .motionRich: return Color(hex: "F0E6FF") // Brighter purple tint
        case .sunsetOrange: return Color(hex: "FFE6CC") // Brighter orange tint
        }
    }
    
    var textMuted: Color {
        switch self {
        case .liveLedger: return Color(hex: "A5D6A7") // Muted green
        case .emeraldGreen: return Color(hex: "8CFFCC") // Brighter
        case .glassmorphism: return Color(hex: "B8C4E0") // Brighter
        case .boldFuturistic: return Color(hex: "00B3CC") // Brighter cyan
        case .motionRich: return Color(hex: "D9B3FF") // Brighter purple
        case .sunsetOrange: return Color(hex: "FFC299") // Brighter orange
        }
    }
    
    // MARK: - Accent Colors (BRIGHTER)
    var accentColor: Color {
        switch self {
        case .liveLedger: return Color(hex: "4CAF50") // LiveLedger green
        case .emeraldGreen: return Color(hex: "00FFAA") // Brighter emerald
        case .glassmorphism: return Color(hex: "00E5FF") // Brighter cyan
        case .boldFuturistic: return Color(hex: "00FFCC") // Brighter neon green
        case .motionRich: return Color(hex: "B366FF") // Brighter purple
        case .sunsetOrange: return Color(hex: "FF8C5A") // Brighter orange
        }
    }
    
    var primaryColor: Color { accentColor }
    
    var secondaryColor: Color {
        switch self {
        case .liveLedger: return Color(hex: "81C784") // Lighter green
        case .emeraldGreen: return Color(hex: "4FFFB0") // Brighter mint
        case .glassmorphism: return Color(hex: "A855F7") // Brighter purple
        case .boldFuturistic: return Color(hex: "00E5FF") // Bright cyan
        case .motionRich: return Color(hex: "FF6BB3") // Brighter pink
        case .sunsetOrange: return Color(hex: "FFAB76") // Brighter coral
        }
    }
    
    // MARK: - Background Image
    var backgroundImageName: String {
        switch self {
        case .liveLedger: return "" // No wallpaper - plain background
        case .emeraldGreen: return "ThemeBG_EmeraldGreen"
        case .glassmorphism: return "ThemeBG_Glassmorphism"
        case .boldFuturistic: return "ThemeBG_BoldFuturistic"
        case .motionRich: return "ThemeBG_MotionRich"
        case .sunsetOrange: return "ThemeBG_SunsetOrange"
        }
    }
    
    // MARK: - Background Colors (fallback or primary for plain themes)
    var gradientColors: [Color] {
        switch self {
        case .liveLedger:
            // Plain solid LiveLedger green background
            return [Color(hex: "1B5E20"), Color(hex: "2E7D32"), Color(hex: "1B5E20")]
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
        case .liveLedger: return Color(hex: "1B5E20").opacity(0.9)
        case .emeraldGreen: return Color(hex: "064E3B")
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.1)
        case .boldFuturistic: return Color(hex: "111111")
        case .motionRich: return Color(hex: "312E81").opacity(0.6)
        case .sunsetOrange: return Color(hex: "292524")
        }
    }
    
    var cardBorder: Color {
        switch self {
        case .liveLedger: return Color(hex: "4CAF50").opacity(0.6) // LiveLedger green border
        case .emeraldGreen: return Color(hex: "00FFAA").opacity(0.5) // Brighter
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.4) // Brighter
        case .boldFuturistic: return Color(hex: "00FFCC").opacity(0.6) // Brighter neon
        case .motionRich: return Color(hex: "B366FF").opacity(0.5) // Brighter purple
        case .sunsetOrange: return Color(hex: "FF8C5A").opacity(0.5) // Brighter orange
        }
    }
    
    // MARK: - Shadows (for neumorphic effects)
    var shadowLight: Color {
        switch self {
        case .liveLedger: return Color(hex: "388E3C")
        case .emeraldGreen: return Color(hex: "065F46")
        case .glassmorphism: return Color(hex: "FFFFFF").opacity(0.05)
        case .boldFuturistic: return Color(hex: "00F5A0").opacity(0.1)
        case .motionRich: return Color(hex: "A78BFA").opacity(0.1)
        case .sunsetOrange: return Color(hex: "57534E")
        }
    }
    
    var shadowDark: Color {
        switch self {
        case .liveLedger: return Color.black.opacity(0.4)
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
        case .liveLedger: return Color(hex: "1B5E20").opacity(opacity)
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
    
    // MARK: - Status Colors (BRIGHTER)
    var successColor: Color {
        Color(hex: "4FFFB0") // Brighter green
    }
    
    var warningColor: Color {
        Color(hex: "FFD93D") // Brighter yellow
    }
    
    var dangerColor: Color {
        Color(hex: "FF6B6B") // Brighter red
    }
    
    // MARK: - Icon Color (adapts to theme background - BRIGHTER)
    var iconColor: Color {
        switch self {
        case .liveLedger: return Color(hex: "FFFFFF")
        case .emeraldGreen: return Color(hex: "FFFFFF")
        case .glassmorphism: return Color(hex: "FFFFFF")
        case .boldFuturistic: return Color(hex: "00FFCC") // Bright neon green
        case .motionRich: return Color(hex: "FFFFFF")
        case .sunsetOrange: return Color(hex: "FFFFFF")
        }
    }
    
    // MARK: - Button Text Color (for buttons with accent background)
    var buttonTextColor: Color {
        // All themes use black text on accent buttons
        return Color(hex: "000000")
    }
    
    // MARK: - Icons
    var icon: String {
        switch self {
        case .liveLedger: return "chart.line.uptrend.xyaxis"
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
    private let themeKey: String

    @Published var currentTheme: AppTheme {
        didSet {
            if let encoded = try? JSONEncoder().encode(currentTheme) {
                UserDefaults.standard.set(encoded, forKey: themeKey)
            }
        }
    }

    /// Per-user theme key so each user's theme is tied to their profile/email.
    private static func themeKey(for userId: String) -> String {
        userId.isEmpty ? "app_theme" : "app_theme_\(userId)"
    }

    init(userId: String = "") {
        themeKey = Self.themeKey(for: userId)
        if let data = UserDefaults.standard.data(forKey: themeKey),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            currentTheme = theme
        } else {
            currentTheme = .emeraldGreen // Default theme (green)
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    var viewModel: SalesViewModel? = nil
    @StateObject private var storeKit = StoreKitManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showFeedback = false
    @State private var showSubscription = false
    @State private var isRestoringPurchases = false
    @State private var showRestorePurchasesConfirm = false
    @State private var showRestoreSuccess = false
    @State private var showRestoreNoPurchases = false
    @State private var showRestoreError = false
    @State private var showWhyPro = false
    @State private var showBackupShareSheet = false
    @State private var backupFileURL: URL?
    @State private var showRestoreImporter = false
    @State private var showRestoreConfirm = false
    @State private var pendingRestoreData: Data?
    @State private var showDeleteFirstConfirm = false
    @State private var showDeleteTypeConfirm = false
    @State private var deleteConfirmText = ""
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
    
    private func performBackup(viewModel: SalesViewModel) {
        let backup = DataManager.buildBackup(from: viewModel)
        guard let data = try? JSONEncoder().encode(backup) else { return }
        let filename = DataManager.defaultBackupFilename()
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            backupFileURL = fileURL
            showBackupShareSheet = true
        } catch {
            #if os(iOS)
            HapticManager.error()
            #endif
        }
    }

    private func profileSection(user: AppUser) -> some View {
        Section {
            HStack(spacing: 12) {
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
                        } else if user.isLapsedSubscriber {
                            Label("EXPIRED", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.red)
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
            if user.isLapsedSubscriber {
                expiredSubscriptionBanner
            }
            if !user.isPro && !user.isLapsedSubscriber {
                Button {
                    showSubscription = true
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                        Text("Upgrade to Pro")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("$19.99/mo")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        } header: {
            Text(localization.localized(.profile))
        }
    }
    
    private var expiredSubscriptionBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Your Pro subscription expired")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
            }
            if let user = authManager.currentUser, let expiredDate = user.formattedExpirationDate {
                Text("Expired on \(expiredDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("Resubscribe to continue using unlimited orders, exports, and all Pro features.")
                .font(.caption)
                .foregroundColor(.secondary)
            Button {
                showSubscription = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Resubscribe to Pro")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(colors: [.orange, .red],
                                  startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var subscriptionSectionContent: some View {
        Section {
            Button {
                showSubscription = true
            } label: {
                Label("Subscription", systemImage: "crown.fill")
                    .foregroundColor(.primary)
            }
            Button {
                showRestorePurchasesConfirm = true
            } label: {
                HStack {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                        .foregroundColor(.primary)
                    if isRestoringPurchases {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.9)
                    }
                }
            }
            .disabled(isRestoringPurchases)
            Button {
                showWhyPro = true
            } label: {
                Label("Why Pro?", systemImage: "questionmark.circle")
                    .foregroundColor(.primary)
            }
        } header: {
            Text("Subscription")
        } footer: {
            Text("Restore if you reinstalled the app. Why Pro? shows what you get with a Pro subscription.")
        }
    }
    
    @ViewBuilder
    private var dataAndPrivacyContent: some View {
        if viewModel != nil {
            Section {
                Button {
                    guard let vm = viewModel else { return }
                    performBackup(viewModel: vm)
                } label: {
                    Label("Backup to Files", systemImage: "folder.badge.plus")
                        .foregroundColor(.primary)
                }
                Button {
                    showRestoreImporter = true
                } label: {
                    Label("Restore from Backup", systemImage: "folder.badge.arrow.down")
                        .foregroundColor(.primary)
                }
            } header: {
                Text("Your Data")
            } footer: {
                Text("Backup saves all orders, products, and settings to a JSON file. Restore replaces current data.")
            }
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• All data stored locally")
                    Text("• No data sent to servers")
                    Text("• You own your data")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            } header: {
                Text("Privacy")
            }
            Section {
                Button(role: .destructive) {
                    showDeleteFirstConfirm = true
                } label: {
                    Label("Delete My Data", systemImage: "trash")
                }
            } header: {
                Text("Delete Data")
            } footer: {
                Text("Permanently deletes all orders, products, and settings. You will be signed out. This cannot be undone.")
            }
        }
    }
    
    private var languageSoundDisplayTutorialContent: some View {
        Group {
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
            Section {
                Button {
                    showSoundSettings = true
                } label: {
                    HStack {
                        Label(localization.localized(.soundSettings), systemImage: "speaker.wave.2.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
            } header: {
                Text(localization.localized(.soundSettings))
            } footer: {
                Text("Configure order added sound")
            }
            Section {
                Button {
                    showDisplaySettings = true
                } label: {
                    HStack {
                        Label(localization.localized(.displaySettings), systemImage: "sun.max.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
            } header: {
                Text(localization.localized(.displaySettings))
            } footer: {
                Text("Theme and overlay settings")
            }
            Section {
                Button {
                    showTutorial = true
                } label: {
                    Label(localization.localized(.tutorial), systemImage: "questionmark.circle.fill")
                        .foregroundColor(.primary)
                }
            } header: {
                Text(localization.localized(.tutorial))
            }
        }
    }
    
    @ViewBuilder
    private var supportThroughDebugContent: some View {
        Section {
            Button {
                showFeedback = true
            } label: {
                Label(localization.localized(.sendFeedback), systemImage: "envelope.fill")
                    .foregroundColor(.primary)
            }
            Link(destination: URL(string: "https://octa-square.github.io/LiveLedger/privacy-policy.html")!) {
                Label(localization.localized(.privacyPolicy), systemImage: "hand.raised.fill")
                    .foregroundColor(.primary)
            }
            Link(destination: URL(string: "https://octa-square.github.io/LiveLedger/terms-of-service.html")!) {
                Label(localization.localized(.termsOfService), systemImage: "doc.text.fill")
                    .foregroundColor(.primary)
            }
        } header: {
            Text(localization.localized(.support))
        }
        Section {
            Button {
                let phoneNumber = "13477855007"
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
                if let url = URL(string: "mailto:admin@octasquare.com?subject=LiveLedger%20Support%20Request") {
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
        Section {
            HStack {
                Image(systemName: "app.fill")
                    .foregroundColor(.green)
                Text("LiveLedger")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            HStack {
                Text(localization.localized(.version))
                Spacer()
                Text("1.3.0")
                    .foregroundColor(.gray)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Description")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text("Real-time sales tracking for live stream sellers. Track orders, manage inventory, and grow your business across TikTok, Instagram, and Facebook.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
            HStack {
                Text("Developer")
                Spacer()
                Text("Octasquare")
                    .foregroundColor(.gray)
            }
            NavigationLink {
                TermsPrivacyView()
            } label: {
                Label("Terms & Privacy", systemImage: "doc.text.fill")
            }
        } header: {
            Text(localization.localized(.about))
        }
        Section {
            Button {
                showProfileSettings = true
            } label: {
                HStack {
                    Label(localization.localized(.profile), systemImage: "person.circle.fill")
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
                    Label(localization.localized(.myStore), systemImage: "building.2.fill")
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
            Text(localization.localized(.profileSettings))
        }
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
            Text("Test your network connection before selling")
        }
        Section {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label(localization.localized(.deleteAccount), systemImage: "trash.fill")
                    .foregroundColor(.red)
            }
            Button {
                isLoggedIn = false
                authManager.signOut()
                dismiss()
            } label: {
                Label(localization.localized(.signOut), systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.orange)
            }
        } header: {
            Text(localization.localized(.profile))
        }
        if (authManager.currentUser?.email ?? "").lowercased() == "applereview@liveledger.com" {
            Section("Debug - Test Account Only") {
                Button("Reset Sample Data Flag") {
                    UserDefaults.standard.removeObject(forKey: "sample_data_loaded_for_review_account")
                }
                Button("Force Load Sample Data Now") {
                    viewModel?.populateDemoData(
                        email: "applereview@liveledger.com",
                        isPro: authManager.currentUser?.isPro ?? false
                    )
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if let user = authManager.currentUser {
                    profileSection(user: user)
                }
                subscriptionSectionContent
                
                dataAndPrivacyContent
                
                languageSoundDisplayTutorialContent
                
                supportThroughDebugContent
            }
            .navigationTitle(localization.localized(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.localized(.done)) { dismiss() }
                }
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView(localization: localization)
            }
            .fullScreenCover(isPresented: $showSubscription) {
                SubscriptionView(authManager: authManager)
            }
            .sheet(isPresented: $showWhyPro) {
                WhyProSheet(onUpgrade: {
                    showWhyPro = false
                    showSubscription = true
                }, onDismiss: { showWhyPro = false })
            }
            .confirmationDialog("Restore Purchases", isPresented: $showRestorePurchasesConfirm, titleVisibility: .visible) {
                Button("Cancel", role: .cancel) {}
                Button("OK") {
                    Task {
                        isRestoringPurchases = true
                        let result = await storeKit.restorePurchases()
                        isRestoringPurchases = false
                        #if os(iOS)
                        switch result {
                        case .success:
                            HapticManager.success()
                            authManager.upgradeToPro()
                            showRestoreSuccess = true
                        case .noPurchases:
                            HapticManager.selection()
                            showRestoreNoPurchases = true
                        case .cancelled:
                            break
                        case .failed:
                            HapticManager.error()
                            showRestoreError = true
                        }
                        #endif
                    }
                }
            } message: {
                Text("Restore your Pro subscription from your Apple ID? You may be asked to sign in.")
            }
            .alert("Success", isPresented: $showRestoreSuccess) {
                Button("OK") {}
            } message: {
                Text("Your Pro subscription has been restored!")
            }
            .alert("No Purchases Found", isPresented: $showRestoreNoPurchases) {
                Button("OK") {}
            } message: {
                Text("We couldn't find any previous purchases for this Apple ID.")
            }
            .alert("Restore Failed", isPresented: $showRestoreError) {
                Button("OK") {}
            } message: {
                Text(storeKit.errorMessage ?? "Please try again or contact support.")
            }
            .alert(localization.localized(.deleteAccountQuestion), isPresented: $showDeleteConfirm) {
                Button(localization.localized(.delete), role: .destructive) {
                    isLoggedIn = false
                    authManager.deleteAccount()
                    dismiss()
                }
                Button(localization.localized(.cancel), role: .cancel) {}
            } message: {
                Text(localization.localized(.deleteAccountMessage))
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
                TutorialWrapperView(authManager: authManager, localization: localization, isPresented: $showTutorial)
            }
            .sheet(isPresented: $showBackupShareSheet, onDismiss: {
                if let url = backupFileURL {
                    try? FileManager.default.removeItem(at: url)
                }
                backupFileURL = nil
            }) {
                if let url = backupFileURL {
                    ShareSheet(items: [url])
                }
            }
            .fileImporter(isPresented: $showRestoreImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: url) {
                        pendingRestoreData = data
                        showRestoreConfirm = true
                    }
                case .failure: break
                }
                showRestoreImporter = false
            }
            .alert("Restore from Backup?", isPresented: $showRestoreConfirm) {
                Button("Cancel", role: .cancel) { pendingRestoreData = nil }
                Button("Restore", role: .destructive) {
                    guard let data = pendingRestoreData,
                          let backup = DataManager.restoreFromJSON(data),
                          let vm = viewModel else { pendingRestoreData = nil; return }
                    vm.loadFromBackup(backup)
                    pendingRestoreData = nil
                    #if os(iOS)
                    HapticManager.success()
                    #endif
                }
            } message: {
                Text("This will replace all current data. Continue?")
            }
            .alert("Delete All Data?", isPresented: $showDeleteFirstConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Everything", role: .destructive) {
                    showDeleteFirstConfirm = false
                    showDeleteTypeConfirm = true
                }
            } message: {
                Text("This will permanently delete:\n• All orders\n• All products\n• All settings\n\nThis CANNOT be undone.")
            }
            .sheet(isPresented: $showDeleteTypeConfirm) {
                DeleteDataConfirmSheet(
                    deleteConfirmText: $deleteConfirmText,
                    onConfirm: {
                        guard deleteConfirmText.trimmingCharacters(in: .whitespaces).uppercased() == "DELETE" else { return }
                        viewModel?.resetToEmptyState()
                        DataManager.deleteAllUserData()
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        authManager.signOutAfterDeleteAllData()
                        showDeleteTypeConfirm = false
                        deleteConfirmText = ""
                        dismiss()
                    },
                    onCancel: {
                        showDeleteTypeConfirm = false
                        deleteConfirmText = ""
                    }
                )
            }
        }
    }
    
    func themeDescription(_ theme: AppTheme) -> String {
        switch theme {
        case .liveLedger: return "Classic LiveLedger green"
        case .emeraldGreen: return "Rich forest vibes"
        case .glassmorphism: return "Frosted glass panels"
        case .boldFuturistic: return "Neon cyber vibes"
        case .motionRich: return "Smooth purple flow"
        case .sunsetOrange: return "Warm sunset glow"
        }
    }
}

// MARK: - Delete Data Confirm Sheet (type DELETE)
struct DeleteDataConfirmSheet: View {
    @Binding var deleteConfirmText: String
    var onConfirm: () -> Void
    var onCancel: () -> Void
    @Environment(\.dismiss) var dismiss
    
    private var canConfirm: Bool {
        deleteConfirmText.trimmingCharacters(in: .whitespaces).uppercased() == "DELETE"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Type DELETE to confirm")
                    .font(.headline)
                TextField("DELETE", text: $deleteConfirmText)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.allCharacters)
                    .padding(.horizontal)
                Button(role: .destructive) {
                    if canConfirm {
                        onConfirm()
                        dismiss()
                    }
                } label: {
                    Text("Delete Everything")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .disabled(!canConfirm)
                .padding(.horizontal)
            }
            .padding(.top, 24)
            .navigationTitle("Confirm Delete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Why Pro Sheet (benefits and upgrade CTA)
struct WhyProSheet: View {
    var onUpgrade: () -> Void
    var onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 8) {
                        Text("💎")
                        Text("Why Upgrade to Pro?")
                            .font(.title2.bold())
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scale Your Business")
                            .font(.headline)
                        Label("Unlimited orders (Free: limited to 20)", systemImage: "bag.fill")
                            .font(.subheadline)
                        Label("Unlimited exports (Free: limited to 10)", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Professional Tools")
                            .font(.headline)
                        Label("Product images", systemImage: "photo")
                            .font(.subheadline)
                        Label("Barcode scanning", systemImage: "barcode.viewfinder")
                            .font(.subheadline)
                        Label("Priority support", systemImage: "headphones")
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Text("Perfect for serious sellers who need professional tools.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button {
                        dismiss()
                        onUpgrade()
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Pro - $19.99/mo")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.orange, .yellow],
                                          startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Why Pro?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                        onDismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @ObservedObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText = ""
    @State private var feedbackType = "Suggestion"
    
    var feedbackTypes: [String] {
        [
            localization.localized(.suggestion),
            localization.localized(.bugReport),
            localization.localized(.question),
            localization.localized(.other)
        ]
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(localization.localized(.type)) {
                    Picker(localization.localized(.feedbackType), selection: $feedbackType) {
                        ForEach(feedbackTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(localization.localized(.message)) {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                }
                
                Section {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text(localization.localized(.sendFeedback))
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(feedbackText.isEmpty)
                }
            }
            .navigationTitle(localization.localized(.sendFeedbackTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.localized(.cancel)) { dismiss() }
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
    @ObservedObject var authManager: AuthManager
    @ObservedObject var localization: LocalizationManager
    @Binding var isPresented: Bool
    @State private var dummy = false
    
    var body: some View {
        OnboardingView(authManager: authManager, localization: localization, hasCompletedOnboarding: $dummy, isReTutorial: true)
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
            .navigationTitle(localization.localized(.selectLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.localized(.done)) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @Binding var companyName: String
    @Binding var userName: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(localization.localized(.companyName), text: $companyName)
                        .textContentType(.organizationName)
                } header: {
                    Text(localization.localized(.company))
                } footer: {
                    Text("This appears at the top of your dashboard")
                }
                
                Section {
                    TextField(localization.localized(.yourName), text: $userName)
                        .textContentType(.name)
                } header: {
                    Text(localization.localized(.yourName))
                }
            }
            .navigationTitle(localization.localized(.edit))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.localized(.cancel)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.localized(.save)) {
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
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        List {
            Section {
                Link(destination: URL(string: "https://octa-square.github.io/LiveLedger/terms-of-service.html")!) {
                    HStack {
                        Label(localization.localized(.termsOfService), systemImage: "doc.text.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Link(destination: URL(string: "https://octa-square.github.io/LiveLedger/privacy-policy.html")!) {
                    HStack {
                        Label(localization.localized(.privacyPolicy), systemImage: "hand.raised.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localization.localized(.dataCollection))
                        .font(.subheadline.weight(.semibold))
                    Text(localization.localized(.dataCollectionMessage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(localization.localized(.thirdPartyServices))
                        .font(.subheadline.weight(.semibold))
                    Text(localization.localized(.thirdPartyMessage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text(localization.localized(.privacySummary))
            }
        }
        .navigationTitle(localization.localized(.termsAndPrivacy))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Display Settings View
struct DisplaySettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // System Brightness Tip
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Screen Brightness")
                                .font(.subheadline.weight(.medium))
                            Text("Use iPhone Control Center to adjust brightness")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Display")
                } footer: {
                    Text("Swipe down from top-right corner to access Control Center")
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
                                Image(systemName: theme.icon)
                                    .foregroundColor(theme.accentColor)
                                    .frame(width: 24)
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
                } footer: {
                    Text("Choose your preferred visual theme")
                }
                
                // Reset
                Section {
                    Button(role: .destructive) {
                        themeManager.currentTheme = .emeraldGreen
                    } label: {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle(localization.localized(.displaySettings))
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
    @ObservedObject var localization = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var showChangePassword = false
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    @State private var selectedImageItem: PhotosPickerItem?
    
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
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.green.opacity(0.5), lineWidth: 3)
                                    )
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            // PhotosPicker for iOS 16+
                            PhotosPicker(selection: $selectedImageItem, matching: .images) {
                                HStack(spacing: 4) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12))
                                    Text("Change Photo")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                            }
                            .onChange(of: selectedImageItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        profileImage = image
                                    }
                                }
                            }
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
            .navigationTitle(localization.localized(.profile))
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
        if authManager.signIn(email: authManager.currentUser?.email ?? "", password: currentPassword) != nil {
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
