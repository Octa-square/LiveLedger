//
//  AuthView.swift
//  LiveLedger
//
//  LiveLedger - Authentication & Onboarding with Security Questions
//

import SwiftUI
import Combine

// MARK: - Security Question Model
struct SecurityQuestion: Codable, Identifiable {
    let id: String
    let question: String
    var answer: String
    
    static let availableQuestions = [
        "What city were you born in?",
        "What is the name of your first pet?",
        "What is your mother's maiden name?",
        "What was the name of your first school?",
        "What is your favorite movie?",
        "What street did you grow up on?"
    ]
}

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
    
    // Security Questions (3 required)
    var securityQuestions: [SecurityQuestion]?
    
    // Account security
    var loginAttempts: Int
    var accountLocked: Bool
    var resetToken: String?
    var resetTokenExpiry: Date?
    var lastLogin: Date?
    
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
    
    // Migration initializer for backwards compatibility
    init(id: String, email: String, passwordHash: String, name: String, phoneNumber: String? = nil,
         companyName: String, storeAddress: String? = nil, businessPhone: String? = nil,
         currency: String, isPro: Bool, ordersUsed: Int, exportsUsed: Int, referralCode: String,
         createdAt: Date, profileImageData: Data? = nil, securityQuestions: [SecurityQuestion]? = nil,
         loginAttempts: Int = 0, accountLocked: Bool = false, resetToken: String? = nil,
         resetTokenExpiry: Date? = nil, lastLogin: Date? = nil) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.name = name
        self.phoneNumber = phoneNumber
        self.companyName = companyName
        self.storeAddress = storeAddress
        self.businessPhone = businessPhone
        self.currency = currency
        self.isPro = isPro
        self.ordersUsed = ordersUsed
        self.exportsUsed = exportsUsed
        self.referralCode = referralCode
        self.createdAt = createdAt
        self.profileImageData = profileImageData
        self.securityQuestions = securityQuestions
        self.loginAttempts = loginAttempts
        self.accountLocked = accountLocked
        self.resetToken = resetToken
        self.resetTokenExpiry = resetTokenExpiry
        self.lastLogin = lastLogin
    }
}

// MARK: - Auth Manager
class AuthManager: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated: Bool = false
    
    private let userKey = "liveledger_user"
    private let accountsKey = "liveledger_accounts"
    
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
            // Also update in accounts array
            updateAccountInStorage(user)
        }
    }
    
    // MARK: - Multi-account Storage
    
    private func getAllAccounts() -> [AppUser] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let accounts = try? JSONDecoder().decode([AppUser].self, from: data) else {
            return []
        }
        return accounts
    }
    
    private func saveAllAccounts(_ accounts: [AppUser]) {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: accountsKey)
        }
    }
    
    private func updateAccountInStorage(_ user: AppUser) {
        var accounts = getAllAccounts()
        if let index = accounts.firstIndex(where: { $0.email == user.email }) {
            accounts[index] = user
        } else {
            accounts.append(user)
        }
        saveAllAccounts(accounts)
    }
    
    private func getAccountByEmail(_ email: String) -> AppUser? {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        return getAllAccounts().first(where: { $0.email == normalizedEmail })
    }
    
    // MARK: - Sign Up with Security Questions
    
    func signUp(email: String, name: String, password: String, companyName: String, currency: String, referralCode: String, phoneNumber: String = "", securityQuestions: [SecurityQuestion]) {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        
        let user = AppUser(
            id: UUID().uuidString,
            email: normalizedEmail,
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
            profileImageData: nil,
            securityQuestions: securityQuestions,
            loginAttempts: 0,
            accountLocked: false,
            resetToken: nil,
            resetTokenExpiry: nil,
            lastLogin: Date()
        )
        
        currentUser = user
        isAuthenticated = true
        saveUser()
    }
    
    // Legacy signup without security questions (for backwards compatibility)
    func signUp(email: String, name: String, password: String, companyName: String, currency: String, referralCode: String, phoneNumber: String = "") {
        let defaultQuestions = [
            SecurityQuestion(id: "q1", question: "What city were you born in?", answer: ""),
            SecurityQuestion(id: "q2", question: "What is the name of your first pet?", answer: ""),
            SecurityQuestion(id: "q3", question: "What is your mother's maiden name?", answer: "")
        ]
        signUp(email: email, name: name, password: password, companyName: companyName, currency: currency, referralCode: referralCode, phoneNumber: phoneNumber, securityQuestions: defaultQuestions)
    }
    
    // MARK: - Sign In with Attempt Tracking
    
    enum SignInResult {
        case success
        case error(String)
        case requiresSecurityQuestions(AppUser)
        case accountLocked
    }
    
    func signIn(email: String, password: String) -> String? {
        let result = signInWithResult(email: email, password: password)
        switch result {
        case .success:
            return nil
        case .error(let message):
            return message
        case .requiresSecurityQuestions:
            return "Too many failed attempts. Please verify your identity."
        case .accountLocked:
            return "Your account is locked. Please check your email for password reset instructions."
        }
    }
    
    func signInWithResult(email: String, password: String) -> SignInResult {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        
        // First check accounts storage
        guard var account = getAccountByEmail(normalizedEmail) else {
            // Fallback to legacy single-user storage
            if let data = UserDefaults.standard.data(forKey: userKey),
               let savedUser = try? JSONDecoder().decode(AppUser.self, from: data),
               savedUser.email == normalizedEmail {
                // Migrate to multi-account storage
                var accounts = getAllAccounts()
                accounts.append(savedUser)
                saveAllAccounts(accounts)
                return signInWithResult(email: email, password: password) // Retry
            }
            return .error("No account found with this email. Please sign up first.")
        }
        
        // Check if account is locked
        if account.accountLocked {
            return .accountLocked
        }
        
        // Check password
        if account.passwordHash == simpleHash(password) {
            // SUCCESS - Correct password
            account.loginAttempts = 0
            account.lastLogin = Date()
            updateAccountInStorage(account)
            
            currentUser = account
            isAuthenticated = true
            saveUser()
            return .success
            
        } else {
            // WRONG PASSWORD - Increment attempts
            account.loginAttempts += 1
            
            if account.loginAttempts >= 4 {
                // 4th+ failed attempt - Require security questions
                updateAccountInStorage(account)
                return .requiresSecurityQuestions(account)
            } else {
                updateAccountInStorage(account)
                let attemptsLeft = 4 - account.loginAttempts
                return .error("Incorrect password. \(attemptsLeft) attempt(s) remaining.")
            }
        }
    }
    
    // MARK: - Security Questions Verification
    
    func verifySecurityQuestions(email: String, answers: [String]) -> Bool {
        guard var account = getAccountByEmail(email),
              let questions = account.securityQuestions,
              questions.count >= 3 else {
            return false
        }
        
        var correctCount = 0
        for (index, question) in questions.prefix(3).enumerated() {
            if index < answers.count {
                let userAnswer = answers[index].lowercased().trimmingCharacters(in: .whitespaces)
                let storedAnswer = question.answer.lowercased().trimmingCharacters(in: .whitespaces)
                if userAnswer == storedAnswer && !storedAnswer.isEmpty {
                    correctCount += 1
                }
            }
        }
        
        // Need 2 out of 3 correct
        if correctCount >= 2 {
            // Reset login attempts
            account.loginAttempts = 0
            account.accountLocked = false
            updateAccountInStorage(account)
            return true
        } else {
            // Lock account
            account.accountLocked = true
            updateAccountInStorage(account)
            return false
        }
    }
    
    // MARK: - Password Reset
    
    func initiatePasswordReset(email: String) -> String {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard var account = getAccountByEmail(normalizedEmail) else {
            return "No account found with this email."
        }
        
        // Generate reset token
        let resetToken = "reset_\(Date().timeIntervalSince1970)_\(UUID().uuidString.prefix(8))"
        account.resetToken = resetToken
        account.resetTokenExpiry = Date().addingTimeInterval(3600) // 1 hour expiry
        updateAccountInStorage(account)
        
        // In production, send actual email here
        // For demo, we'll return the token
        return resetToken
    }
    
    func resetPassword(token: String, newPassword: String) -> Bool {
        let accounts = getAllAccounts()
        
        guard var account = accounts.first(where: { $0.resetToken == token }) else {
            return false
        }
        
        // Check token expiry
        if let expiry = account.resetTokenExpiry, Date() > expiry {
            return false
        }
        
        // Update password
        account.passwordHash = simpleHash(newPassword)
        account.resetToken = nil
        account.resetTokenExpiry = nil
        account.loginAttempts = 0
        account.accountLocked = false
        updateAccountInStorage(account)
        
        return true
    }
    
    func resetPasswordWithSecurityQuestions(email: String, newPassword: String) {
        guard var account = getAccountByEmail(email) else { return }
        
        account.passwordHash = simpleHash(newPassword)
        account.loginAttempts = 0
        account.accountLocked = false
        updateAccountInStorage(account)
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
        if let email = currentUser?.email {
            var accounts = getAllAccounts()
            accounts.removeAll(where: { $0.email == email })
            saveAllAccounts(accounts)
        }
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
    
    func updateSecurityQuestions(_ questions: [SecurityQuestion]) {
        currentUser?.securityQuestions = questions
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
            profileImageData: nil,
            securityQuestions: [
                SecurityQuestion(id: "q1", question: "What city were you born in?", answer: "demo"),
                SecurityQuestion(id: "q2", question: "What is the name of your first pet?", answer: "demo"),
                SecurityQuestion(id: "q3", question: "What is your mother's maiden name?", answer: "demo")
            ],
            loginAttempts: 0,
            accountLocked: false
        )
        
        currentUser = demoUser
        isAuthenticated = true
        saveUser()
        
        // Skip onboarding for demo
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Skip plan selection for demo (already Pro)
        UserDefaults.standard.set(true, forKey: "hasSelectedPlan")
        
        // Trigger demo data population
        NotificationCenter.default.post(name: .populateDemoData, object: nil)
    }
    
    // MARK: - Check if email exists
    func emailExists(_ email: String) -> Bool {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        return getAccountByEmail(normalizedEmail) != nil
    }
    
    func getSecurityQuestions(for email: String) -> [SecurityQuestion]? {
        guard let account = getAccountByEmail(email) else { return nil }
        return account.securityQuestions
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
            
            // L² - Official LiveLedger Logo
            // Large L with superscript 2, close together, larger "2" font
            HStack(alignment: .top, spacing: -size * 0.04) {
                Text("L")
                    .font(.system(size: size * 0.52, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("²")
                    .font(.system(size: size * 0.28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .baselineOffset(size * 0.26) // Superscript positioning
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
    @State private var passwordFieldTouched = false
    @State private var showPasswordRequirements = false
    
    // Security Questions State
    @State private var securityAnswer1 = ""
    @State private var securityAnswer2 = ""
    @State private var securityAnswer3 = ""
    @State private var showSecurityQuestionsModal = false
    @State private var pendingAccount: AppUser?
    @State private var verifyAnswer1 = ""
    @State private var verifyAnswer2 = ""
    @State private var verifyAnswer3 = ""
    
    // Password Reset State
    @State private var showPasswordResetModal = false
    @State private var resetEmail = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var showForgotPasswordSheet = false
    
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 8)
                        
                        // Logo
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
                        
                        // Form Card
                        VStack(spacing: 8) {
                            // Mode Toggle
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
                            
                            // Demo Mode Button
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
                        
                        // Features List
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
                        
                        Spacer(minLength: 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showSecurityQuestionsModal) {
            SecurityQuestionsVerificationSheet(
                email: email,
                questions: pendingAccount?.securityQuestions ?? [],
                verifyAnswer1: $verifyAnswer1,
                verifyAnswer2: $verifyAnswer2,
                verifyAnswer3: $verifyAnswer3,
                onVerify: {
                    let answers = [verifyAnswer1, verifyAnswer2, verifyAnswer3]
                    if authManager.verifySecurityQuestions(email: email, answers: answers) {
                        showSecurityQuestionsModal = false
                        showPasswordResetModal = true
                    } else {
                        loginError = "Security verification failed. Account locked. Please contact support."
                        showSecurityQuestionsModal = false
                    }
                },
                onCancel: {
                    showSecurityQuestionsModal = false
                }
            )
        }
        .sheet(isPresented: $showPasswordResetModal) {
            PasswordResetSheet(
                email: email,
                newPassword: $newPassword,
                confirmNewPassword: $confirmNewPassword,
                onReset: {
                    if newPassword == confirmNewPassword && isNewPasswordValid {
                        authManager.resetPasswordWithSecurityQuestions(email: email, newPassword: newPassword)
                        showPasswordResetModal = false
                        loginError = nil
                        // Clear fields
                        password = ""
                        newPassword = ""
                        confirmNewPassword = ""
                    }
                },
                onCancel: {
                    showPasswordResetModal = false
                }
            )
        }
        .sheet(isPresented: $showForgotPasswordSheet) {
            ForgotPasswordSheet(
                authManager: authManager,
                resetEmail: $resetEmail,
                onClose: {
                    showForgotPasswordSheet = false
                }
            )
        }
    }
    
    private var isNewPasswordValid: Bool {
        let hasLetter = newPassword.rangeOfCharacter(from: .letters) != nil
        let hasSymbol = newPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil
        let hasMinLength = newPassword.count >= 6
        return hasLetter && hasSymbol && hasMinLength
    }
    
    // MARK: - Login Form
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
            
            // Forgot Password Link
            Button {
                resetEmail = email
                showForgotPasswordSheet = true
            } label: {
                Text("Forgot Password?")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .underline()
            }
            
            Button {
                loginError = nil
                let result = authManager.signInWithResult(email: email, password: password)
                
                switch result {
                case .success:
                    break // Will navigate automatically
                case .error(let message):
                    loginError = message
                case .requiresSecurityQuestions(let account):
                    pendingAccount = account
                    verifyAnswer1 = ""
                    verifyAnswer2 = ""
                    verifyAnswer3 = ""
                    showSecurityQuestionsModal = true
                case .accountLocked:
                    loginError = "Account locked. Use 'Forgot Password?' to reset."
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
    
    // MARK: - Sign Up Form with Security Questions
    private var signUpFormContent: some View {
        VStack(spacing: 6) {
            // Row 1: Name & Email
            HStack(spacing: 8) {
                CompactTextField(placeholder: "Full Name", text: $name, icon: "person.fill")
                CompactTextField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
            }
            
            // Phone number
            CompactTextField(placeholder: "Phone Number (optional)", text: $phoneNumber, icon: "phone.fill", keyboardType: .phonePad)
            
            // Password
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
            
            // Confirm Password
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
            
            // Company & Currency
            HStack(spacing: 8) {
                CompactTextField(placeholder: "Store Name (optional)", text: $companyName, icon: "building.2.fill")
                
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
            
            // Security Questions Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.green)
                    Text("Security Questions")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("Answer these to recover your account")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.6))
                
                SecurityQuestionField(
                    question: "What city were you born in?",
                    answer: $securityAnswer1
                )
                
                SecurityQuestionField(
                    question: "What is the name of your first pet?",
                    answer: $securityAnswer2
                )
                
                SecurityQuestionField(
                    question: "What is your mother's maiden name?",
                    answer: $securityAnswer3
                )
            }
            .padding(10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            
            // Terms
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
            
            // Error Summary
            if showErrors && !isFormValid {
                VStack(alignment: .leading, spacing: 2) {
                    if name.isEmpty { errorText("Full name required") }
                    if email.isEmpty || !email.contains("@") { errorText("Valid email required") }
                    if authManager.emailExists(email) { errorText("Email already registered") }
                    if !isPasswordValid { errorText("Password needs letter + symbol") }
                    if password != confirmPassword { errorText("Passwords must match") }
                    if !areSecurityQuestionsAnswered { errorText("Answer all security questions") }
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
                    let questions = [
                        SecurityQuestion(id: "q1", question: "What city were you born in?", answer: securityAnswer1.lowercased().trimmingCharacters(in: .whitespaces)),
                        SecurityQuestion(id: "q2", question: "What is the name of your first pet?", answer: securityAnswer2.lowercased().trimmingCharacters(in: .whitespaces)),
                        SecurityQuestion(id: "q3", question: "What is your mother's maiden name?", answer: securityAnswer3.lowercased().trimmingCharacters(in: .whitespaces))
                    ]
                    
                    authManager.signUp(
                        email: email,
                        name: name,
                        password: password,
                        companyName: companyName.isEmpty ? "My Store" : companyName,
                        currency: selectedCurrency,
                        referralCode: referralCode,
                        phoneNumber: phoneNumber,
                        securityQuestions: questions
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
    
    private var areSecurityQuestionsAnswered: Bool {
        !securityAnswer1.trimmingCharacters(in: .whitespaces).isEmpty &&
        !securityAnswer2.trimmingCharacters(in: .whitespaces).isEmpty &&
        !securityAnswer3.trimmingCharacters(in: .whitespaces).isEmpty
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
        phoneNumber = ""
        securityAnswer1 = ""
        securityAnswer2 = ""
        securityAnswer3 = ""
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
        !authManager.emailExists(email) &&
        isPasswordValid &&
        password == confirmPassword &&
        areSecurityQuestionsAnswered &&
        agreedToTerms
    }
}

// MARK: - Security Question Field
struct SecurityQuestionField: View {
    let question: String
    @Binding var answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            TextField("Your answer", text: $answer)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(6)
        }
    }
}

// MARK: - Security Questions Verification Sheet
struct SecurityQuestionsVerificationSheet: View {
    let email: String
    let questions: [SecurityQuestion]
    @Binding var verifyAnswer1: String
    @Binding var verifyAnswer2: String
    @Binding var verifyAnswer3: String
    let onVerify: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Verify Your Identity")
                        .font(.title2.bold())
                    
                    Text("You've entered the wrong password 4 times.\nPlease answer your security questions.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("You must answer at least 2 out of 3 correctly.")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                }
                
                VStack(spacing: 16) {
                    if questions.count > 0 {
                        SecurityQuestionVerifyField(
                            question: questions[0].question,
                            answer: $verifyAnswer1
                        )
                    }
                    
                    if questions.count > 1 {
                        SecurityQuestionVerifyField(
                            question: questions[1].question,
                            answer: $verifyAnswer2
                        )
                    }
                    
                    if questions.count > 2 {
                        SecurityQuestionVerifyField(
                            question: questions[2].question,
                            answer: $verifyAnswer3
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        onVerify()
                    } label: {
                        Text("Verify Answers")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 30)
            .navigationBarHidden(true)
        }
    }
}

struct SecurityQuestionVerifyField: View {
    let question: String
    @Binding var answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question)
                .font(.subheadline.weight(.medium))
            
            TextField("Your answer", text: $answer)
                .textFieldStyle(.roundedBorder)
        }
    }
}

// MARK: - Password Reset Sheet
struct PasswordResetSheet: View {
    let email: String
    @Binding var newPassword: String
    @Binding var confirmNewPassword: String
    let onReset: () -> Void
    let onCancel: () -> Void
    
    @State private var showPassword = false
    
    var isPasswordValid: Bool {
        let hasLetter = newPassword.rangeOfCharacter(from: .letters) != nil
        let hasSymbol = newPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil
        let hasMinLength = newPassword.count >= 6
        return hasLetter && hasSymbol && hasMinLength
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("Reset Your Password")
                        .font(.title2.bold())
                    
                    Text("Security verified! Create a new password.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("New Password")
                            .font(.subheadline.weight(.medium))
                        
                        HStack {
                            if showPassword {
                                TextField("New Password", text: $newPassword)
                            } else {
                                SecureField("New Password", text: $newPassword)
                            }
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        
                        if !newPassword.isEmpty && !isPasswordValid {
                            Text("Must contain at least one letter and one symbol")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password")
                            .font(.subheadline.weight(.medium))
                        
                        SecureField("Confirm Password", text: $confirmNewPassword)
                            .textFieldStyle(.roundedBorder)
                        
                        if !confirmNewPassword.isEmpty && newPassword != confirmNewPassword {
                            Text("Passwords don't match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        onReset()
                    } label: {
                        Text("Reset Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isPasswordValid && newPassword == confirmNewPassword ? Color.green : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isPasswordValid || newPassword != confirmNewPassword)
                    
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 30)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Forgot Password Sheet
struct ForgotPasswordSheet: View {
    @ObservedObject var authManager: AuthManager
    @Binding var resetEmail: String
    let onClose: () -> Void
    
    @State private var step = 1 // 1: Enter email, 2: Answer questions, 3: Reset password
    @State private var errorMessage: String?
    @State private var questions: [SecurityQuestion] = []
    @State private var answer1 = ""
    @State private var answer2 = ""
    @State private var answer3 = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: step == 1 ? "envelope.badge.fill" : step == 2 ? "shield.checkered" : "key.fill")
                        .font(.system(size: 40))
                        .foregroundColor(step == 3 ? .green : .blue)
                    
                    Text(step == 1 ? "Forgot Password?" : step == 2 ? "Security Questions" : "New Password")
                        .font(.title2.bold())
                    
                    Text(step == 1 ? "Enter your email to recover your account" : 
                         step == 2 ? "Answer 2 of 3 questions correctly" : "Create your new password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Content based on step
                if step == 1 {
                    emailStepView
                } else if step == 2 {
                    securityQuestionsStepView
                } else {
                    newPasswordStepView
                }
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onClose() }
                }
            }
        }
    }
    
    private var emailStepView: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $resetEmail)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button {
                errorMessage = nil
                if let foundQuestions = authManager.getSecurityQuestions(for: resetEmail), !foundQuestions.isEmpty {
                    questions = foundQuestions
                    step = 2
                } else {
                    errorMessage = "No account found with this email or no security questions set."
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(resetEmail.contains("@") ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!resetEmail.contains("@"))
        }
    }
    
    private var securityQuestionsStepView: some View {
        VStack(spacing: 16) {
            if questions.count > 0 {
                SecurityQuestionVerifyField(question: questions[0].question, answer: $answer1)
            }
            if questions.count > 1 {
                SecurityQuestionVerifyField(question: questions[1].question, answer: $answer2)
            }
            if questions.count > 2 {
                SecurityQuestionVerifyField(question: questions[2].question, answer: $answer3)
            }
            
            Button {
                errorMessage = nil
                let answers = [answer1, answer2, answer3]
                if authManager.verifySecurityQuestions(email: resetEmail, answers: answers) {
                    step = 3
                } else {
                    errorMessage = "Verification failed. Your account may be locked."
                }
            } label: {
                Text("Verify")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
    
    private var newPasswordStepView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("New Password")
                    .font(.subheadline.weight(.medium))
                
                HStack {
                    if showPassword {
                        TextField("New Password", text: $newPassword)
                    } else {
                        SecureField("New Password", text: $newPassword)
                    }
                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
                .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.subheadline.weight(.medium))
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                if newPassword == confirmPassword && isNewPasswordValid {
                    authManager.resetPasswordWithSecurityQuestions(email: resetEmail, newPassword: newPassword)
                    onClose()
                }
            } label: {
                Text("Reset Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isNewPasswordValid && newPassword == confirmPassword ? Color.green : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isNewPasswordValid || newPassword != confirmPassword)
        }
    }
    
    private var isNewPasswordValid: Bool {
        let hasLetter = newPassword.rangeOfCharacter(from: .letters) != nil
        let hasSymbol = newPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil
        let hasMinLength = newPassword.count >= 6
        return hasLetter && hasSymbol && hasMinLength
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
