//
//  AuthView.swift
//  LiveLedger
//
//  LiveLedger - Authentication & Onboarding
//

import SwiftUI
import Combine

// MARK: - User Model
struct AppUser: Codable {
    var id: String
    var email: String
    var passwordHash: String  // Simple hash for local storage
    var name: String
    var phoneNumber: String?  // Optional for backwards compatibility
    var companyName: String
    var storeAddress: String?  // Store address for receipts
    var businessPhone: String?  // Business phone number
    var currency: String
    var isPro: Bool
    var ordersUsed: Int
    var exportsUsed: Int
    var referralCode: String
    var createdAt: Date
    var profileImageData: Data?  // Profile picture
    
    static let currencies = [
        "USD ($)", "EUR (€)", "GBP (£)", "NGN (₦)", "CAD ($)", "AUD ($)", 
        "INR (₹)", "JPY (¥)", "CNY (¥)", "KRW (₩)", "MXN ($)", "BRL (R$)",
        "ZAR (R)", "PHP (₱)", "SGD ($)", "HKD ($)", "CHF (Fr)", "SEK (kr)",
        "NZD ($)", "THB (฿)", "AED (د.إ)", "SAR (﷼)", "KES (KSh)", "GHS (₵)"
    ]
    
    var currencySymbol: String {
        switch currency {
        case "USD ($)", "CAD ($)", "AUD ($)", "MXN ($)", "SGD ($)", "HKD ($)", "NZD ($)": return "$"
        case "EUR (€)": return "€"
        case "GBP (£)": return "£"
        case "NGN (₦)": return "₦"
        case "INR (₹)": return "₹"
        case "JPY (¥)", "CNY (¥)": return "¥"
        case "KRW (₩)": return "₩"
        case "BRL (R$)": return "R$"
        case "ZAR (R)": return "R"
        case "PHP (₱)": return "₱"
        case "CHF (Fr)": return "Fr"
        case "SEK (kr)": return "kr"
        case "THB (฿)": return "฿"
        case "AED (د.إ)": return "د.إ"
        case "SAR (﷼)": return "﷼"
        case "KES (KSh)": return "KSh"
        case "GHS (₵)": return "₵"
        default: return "$"
        }
    }
    
    // Limits
    var maxFreeOrders: Int { 20 }
    var maxFreeExports: Int { 10 }
    var canCreateOrder: Bool { isPro || ordersUsed < maxFreeOrders }
    var canExport: Bool { isPro || exportsUsed < maxFreeExports }
    var remainingFreeOrders: Int { max(0, maxFreeOrders - ordersUsed) }
    var remainingFreeExports: Int { max(0, maxFreeExports - exportsUsed) }
}

// MARK: - Auth Manager
class AuthManager: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated: Bool = false
    
    private let userKey = "liveledger_user"
    
    init() {
        loadUser()
        setupSubscriptionObserver()
    }
    
    // Listen for subscription status changes from StoreKit
    private func setupSubscriptionObserver() {
        NotificationCenter.default.addObserver(
            forName: .subscriptionStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let isPro = notification.userInfo?["isPro"] as? Bool {
                self?.currentUser?.isPro = isPro
                self?.saveUser()
            }
        }
    }
    
    func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(AppUser.self, from: data) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    func saveUser() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
    
    func signUp(email: String, name: String, password: String, companyName: String, currency: String, referralCode: String, phoneNumber: String = "") {
        let user = AppUser(
            id: UUID().uuidString,
            email: email.lowercased().trimmingCharacters(in: .whitespaces),
            passwordHash: simpleHash(password),
            name: name,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            companyName: companyName,
            storeAddress: nil,
            businessPhone: nil,
            currency: currency,
            isPro: false,
            ordersUsed: 0,
            exportsUsed: 0,
            referralCode: referralCode,
            createdAt: Date(),
            profileImageData: nil
        )
        currentUser = user
        isAuthenticated = true
        saveUser()
    }
    
    /// Sign in with email and password - returns error message if failed
    func signIn(email: String, password: String) -> String? {
        // Load saved user
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let savedUser = try? JSONDecoder().decode(AppUser.self, from: data) else {
            return "No account found. Please sign up first."
        }
        
        // Check email matches
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard savedUser.email == normalizedEmail else {
            return "Email not found. Please check your email or sign up."
        }
        
        // Check password matches
        guard savedUser.passwordHash == simpleHash(password) else {
            return "Incorrect password. Please try again."
        }
        
        // Success - log in
        currentUser = savedUser
        isAuthenticated = true
        return nil
    }
    
    /// Simple hash for local password storage (not cryptographically secure, but fine for local-only auth)
    private func simpleHash(_ string: String) -> String {
        var hash = 5381
        for char in string.utf8 {
            hash = ((hash << 5) &+ hash) &+ Int(char)
        }
        return String(format: "%llx", hash)
    }
    
    func incrementOrderCount() {
        currentUser?.ordersUsed += 1
        saveUser()
    }
    
    func incrementExportCount() {
        currentUser?.exportsUsed += 1
        saveUser()
    }
    
    func upgradeToPro() {
        currentUser?.isPro = true
        saveUser()
    }
    
    func updateCompanyName(_ name: String) {
        currentUser?.companyName = name
        saveUser()
    }
    
    func updateUserName(_ name: String) {
        currentUser?.name = name
        saveUser()
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func deleteAccount() {
        // Clear all user data
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: "livesales_products")
        UserDefaults.standard.removeObject(forKey: "livesales_orders")
        UserDefaults.standard.removeObject(forKey: "livesales_platforms")
    }
    
    func updatePassword(newPassword: String) {
        currentUser?.passwordHash = simpleHash(newPassword)
        saveUser()
    }
    
    /// Demo mode for App Store review - creates a pre-configured account with sample data
    func startDemoMode() {
        // Create demo user with Pro access
        let demoUser = AppUser(
            id: "demo-user-\(UUID().uuidString)",
            email: "demo@liveledger.app",
            passwordHash: simpleHash("demo123"),
            name: "Demo User",
            phoneNumber: nil,
            companyName: "Demo Store",
            storeAddress: "123 Demo Street",
            businessPhone: nil,
            currency: "USD ($)",
            isPro: true, // Pro access to test all features
            ordersUsed: 0,
            exportsUsed: 0,
            referralCode: "DEMO2024",
            createdAt: Date(),
            profileImageData: nil
        )
        
        currentUser = demoUser
        isAuthenticated = true
        saveUser()
        
        // Skip onboarding for demo
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Trigger demo data population
        NotificationCenter.default.post(name: .populateDemoData, object: nil)
    }
}

// Notification for demo data population
extension Notification.Name {
    static let populateDemoData = Notification.Name("populateDemoData")
}

// MARK: - Logo View (Simplified for better rendering)
struct LiveLedgerLogo: View {
    var size: CGFloat = 90
    
    var body: some View {
        ZStack {
            // Green rounded background
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.05, green: 0.59, blue: 0.41), Color(red: 0.04, green: 0.47, blue: 0.34)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // L² - L with superscript 2 (represents "Live Ledger" - two L's)
            HStack(alignment: .top, spacing: -size * 0.02) {  // Negative spacing to bring 2 closer
                Text("L")
                    .font(.system(size: size * 0.48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("²")
                    .font(.system(size: size * 0.28, weight: .medium, design: .rounded))  // Larger, same visual weight
                    .foregroundColor(.white)
                    .offset(y: size * 0.02)  // Tighter to top of L
            }
            
            // LIVE badge
            Text("LIVE")
                .font(.system(size: size * 0.11, weight: .heavy))
                .foregroundColor(.white)
                .padding(.horizontal, size * 0.05)
                .padding(.vertical, size * 0.025)
                .background(Color.red)
                .cornerRadius(size * 0.05)
                .offset(x: -size * 0.26, y: -size * 0.32)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Auth View
struct AuthView: View {
    @ObservedObject var authManager: AuthManager
    @State private var isLoginMode = false  // Toggle between Login and Sign Up
    @State private var email = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var companyName = ""
    @State private var referralCode = ""
    @State private var selectedCurrency = "USD ($)"
    @State private var agreedToTerms = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showErrors = false
    @State private var loginError: String?
    @State private var passwordFieldTouched = false  // Track if user left password field
    @State private var showPasswordRequirements = false
    
    // Password validation
    private var isPasswordValid: Bool {
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasSymbol = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil
        let hasMinLength = password.count >= 6
        return hasLetter && hasSymbol && hasMinLength
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - Green gradient with transparency effect
                LinearGradient(colors: [
                    Color(red: 0.07, green: 0.5, blue: 0.46),
                    Color(red: 0.05, green: 0.35, blue: 0.35)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                // Decorative circles for depth
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: -200)
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 250, height: 250)
                    .offset(x: 150, y: 400)
                
                // Main Content - No ScrollView, fit to screen
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer(minLength: 8)
                    
                    // Logo (30-40% larger)
                    VStack(spacing: 6) {
                        LiveLedgerLogo(size: isLoginMode ? 85 : 80)
                        
                        Text("LiveLedger")
                            .font(.system(size: isLoginMode ? 28 : 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        if isLoginMode {
                            Text("Track sales in real-time")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.bottom, isLoginMode ? 16 : 8)
                    
                    // Form Card - Glassmorphism effect
                    VStack(spacing: 8) {
                        // Mode Toggle - Compact
                        HStack(spacing: 0) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isLoginMode = false
                                    clearForm()
                                }
                            } label: {
                                Text("Sign Up")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(isLoginMode ? .white.opacity(0.6) : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(isLoginMode ? Color.clear : Color.white.opacity(0.25))
                                    .cornerRadius(6)
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isLoginMode = true
                                    clearForm()
                                }
                            } label: {
                                Text("Log In")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(isLoginMode ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(isLoginMode ? Color.white.opacity(0.25) : Color.clear)
                                    .cornerRadius(6)
                            }
                        }
                        .padding(3)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        
                        if isLoginMode {
                            loginFormContent
                        } else {
                            signUpFormContent
                        }
                        
                        // Compact Divider
                        HStack {
                            Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
                            Text("or").font(.caption2).foregroundColor(.white.opacity(0.5))
                            Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
                        }
                        .padding(.vertical, 4)
                        
                        // Demo Mode Button - Compact
                        Button {
                            authManager.startDemoMode()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "play.circle.fill")
                                    .font(.caption)
                                Text("Try Demo Mode")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        Text("Explore all features with sample data")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        // Glassmorphism card
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial.opacity(0.3))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    
                    // Features List - Compact 2-column grid
                    if !isLoginMode {
                        VStack(spacing: 4) {
                            Text("Why LiveLedger?")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 4),
                                GridItem(.flexible(), spacing: 4)
                            ], spacing: 3) {
                                CompactFeatureItem(icon: "chart.line.uptrend.xyaxis", text: "Real-time tracking")
                                CompactFeatureItem(icon: "apps.iphone", text: "Multi-platform")
                                CompactFeatureItem(icon: "timer", text: "Live timer")
                                CompactFeatureItem(icon: "network", text: "Network analyzer")
                                CompactFeatureItem(icon: "bell.badge", text: "Smart alerts")
                                CompactFeatureItem(icon: "chart.pie", text: "Analytics")
                                CompactFeatureItem(icon: "printer", text: "Print & export")
                                CompactFeatureItem(icon: "speaker.wave.2", text: "Sound notifications")
                                CompactFeatureItem(icon: "chart.bar.xaxis", text: "Comparisons")
                                CompactFeatureItem(icon: "photo", text: "Image editing")
                                CompactFeatureItem(icon: "plus.circle", text: "Custom platforms")
                                CompactFeatureItem(icon: "line.3.horizontal.decrease", text: "Order filtering")
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                    }
                    
                    // Bottom spacing
                    Spacer(minLength: 8)
                }
            }
        }
    }
    
    // MARK: - Login Form (Compact)
    private var loginFormContent: some View {
        VStack(spacing: 8) {
            Text("Welcome Back")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            
            CompactTextField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
            
            // Password field
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 16)
                if showPassword {
                    TextField("Password", text: $password)
                        .font(.caption)
                        .foregroundColor(.white)
                } else {
                    SecureField("Password", text: $password)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.15))
            .cornerRadius(8)
            
            if let error = loginError {
                Text(error)
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(6)
            }
            
            Button {
                loginError = nil
                if let error = authManager.signIn(email: email, password: password) {
                    loginError = error
                }
            } label: {
                Text("Log In")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .disabled(email.isEmpty || password.isEmpty)
            .opacity(email.isEmpty || password.isEmpty ? 0.7 : 1)
            
            Text("Don't have an account? Tap Sign Up above")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Sign Up Form (Compact)
    private var signUpFormContent: some View {
        VStack(spacing: 6) {
            // Row 1: Name & Email side by side
            HStack(spacing: 8) {
                CompactTextField(placeholder: "Full Name", text: $name, icon: "person.fill")
                CompactTextField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
            }
            
            // Row 1.5: Phone number
            CompactTextField(placeholder: "Phone Number (optional)", text: $phoneNumber, icon: "phone.fill", keyboardType: .phonePad)
            
            // Row 2: Password with validation
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 16)
                    if showPassword {
                        TextField("Password", text: $password)
                            .font(.caption)
                            .foregroundColor(.white)
                            .onChange(of: password) { _, _ in
                                if !password.isEmpty { showPasswordRequirements = true }
                            }
                    } else {
                        SecureField("Password", text: $password)
                            .font(.caption)
                            .foregroundColor(.white)
                            .onChange(of: password) { _, _ in
                                if !password.isEmpty { showPasswordRequirements = true }
                            }
                    }
                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            passwordFieldTouched && !isPasswordValid && !password.isEmpty ? Color.red : Color.clear,
                            lineWidth: 1.5
                        )
                )
                
                // Password requirements popup
                if showPasswordRequirements && !password.isEmpty && !isPasswordValid {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 9))
                        Text("Must contain at least one letter and one symbol (!@#$%...)")
                            .font(.system(size: 9))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 4)
                }
            }
            
            // Row 3: Confirm Password
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 16)
                    if showConfirmPassword {
                        TextField("Confirm Password", text: $confirmPassword)
                            .font(.caption)
                            .foregroundColor(.white)
                            .onTapGesture { passwordFieldTouched = true }
                    } else {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .font(.caption)
                            .foregroundColor(.white)
                            .onTapGesture { passwordFieldTouched = true }
                    }
                    Button { showConfirmPassword.toggle() } label: {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
                
                if !confirmPassword.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 9))
                        Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                            .font(.system(size: 9))
                    }
                    .foregroundColor(password == confirmPassword ? .green : .red)
                    .padding(.horizontal, 4)
                }
            }
            
            // Row 4: Company & Currency side by side
            HStack(spacing: 8) {
                CompactTextField(placeholder: "Store Name (optional)", text: $companyName, icon: "building.2.fill")
                
                // Compact Currency Picker
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Picker("", selection: $selectedCurrency) {
                        ForEach(AppUser.currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    .scaleEffect(0.85)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
            }
            
            // Terms with clickable links
            HStack(spacing: 4) {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .font(.caption)
                    .foregroundColor(agreedToTerms ? .green : .white.opacity(0.7))
                    .onTapGesture { agreedToTerms.toggle() }
                
                Text("I agree to the ")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
                
                Button {
                    if let url = URL(string: "https://octa-square.github.io/LiveLedger/terms-of-service.html") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Terms of Service")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .underline()
                }
                
                Text(" and ")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
                
                Button {
                    if let url = URL(string: "https://octa-square.github.io/LiveLedger/privacy-policy.html") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .underline()
                }
            }
            .padding(.vertical, 4)
            
            // Error Summary - Compact
            if showErrors && !isFormValid {
                VStack(alignment: .leading, spacing: 2) {
                    if name.isEmpty { errorText("Full name required") }
                    if email.isEmpty || !email.contains("@") { errorText("Valid email required") }
                    if !isPasswordValid { errorText("Password needs letter + symbol") }
                    if password != confirmPassword { errorText("Passwords must match") }
                    if !agreedToTerms { errorText("Accept terms to continue") }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.2))
                .cornerRadius(6)
            }
            
            // Sign Up Button
            Button {
                showErrors = true
                passwordFieldTouched = true
                if isFormValid {
                    authManager.signUp(
                        email: email,
                        name: name,
                        password: password,
                        companyName: companyName.isEmpty ? "My Store" : companyName,
                        currency: selectedCurrency,
                        referralCode: referralCode,
                        phoneNumber: phoneNumber
                    )
                }
            } label: {
                Text("Create Free Account")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            
            Text("First 20 orders FREE • No credit card required")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private func errorText(_ text: String) -> some View {
        Text("• \(text)")
            .font(.system(size: 9))
            .foregroundColor(.orange)
    }
    
    private func clearForm() {
        email = ""
        name = ""
        password = ""
        confirmPassword = ""
        companyName = ""
        referralCode = ""
        showErrors = false
        loginError = nil
        showPassword = false
        showConfirmPassword = false
        passwordFieldTouched = false
        showPasswordRequirements = false
    }
    
    var isFormValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && 
        email.contains("@") &&
        isPasswordValid &&
        password == confirmPassword &&
        agreedToTerms
    }
}

// MARK: - Compact Text Field
struct CompactTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 16)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                .font(.caption)
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.2))
                .cornerRadius(8)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}

// Compact feature item for signup page grid
struct CompactFeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(.green)
            Text(text)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .green : .white.opacity(0.7))
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

#Preview {
    AuthView(authManager: AuthManager())
}
