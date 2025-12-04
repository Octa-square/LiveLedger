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
    var name: String
    var companyName: String
    var currency: String
    var isPro: Bool
    var ordersUsed: Int
    var exportsUsed: Int
    var referralCode: String
    var createdAt: Date
    
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
    
    func signUp(email: String, name: String, password: String, companyName: String, currency: String, referralCode: String) {
        // In a real app, password would be hashed and sent to a server
        let user = AppUser(
            id: UUID().uuidString,
            email: email,
            name: name,
            companyName: companyName,
            currency: currency,
            isPro: false,
            ordersUsed: 0,
            exportsUsed: 0,
            referralCode: referralCode,
            createdAt: Date()
        )
        currentUser = user
        isAuthenticated = true
        saveUser()
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
    
    func downgradeToFree() {
        currentUser?.isPro = false
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
            
            // Big L
            Text("L")
                .font(.system(size: size * 0.55, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            // LIVE badge
            Text("LIVE")
                .font(.system(size: size * 0.12, weight: .heavy))
                .foregroundColor(.white)
                .padding(.horizontal, size * 0.06)
                .padding(.vertical, size * 0.03)
                .background(Color.red)
                .cornerRadius(size * 0.05)
                .offset(x: -size * 0.22, y: -size * 0.32)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Auth View (Compact Single-Screen Design)
struct AuthView: View {
    @ObservedObject var authManager: AuthManager
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var companyName = ""
    @State private var referralCode = ""
    @State private var selectedCurrency = "USD ($)"
    @State private var agreedToTerms = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var passwordFieldFocused = false
    @State private var showPasswordTooltip = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password, confirmPassword, company, referral
    }
    
    // Password validation
    private var isPasswordValid: Bool {
        password.count >= 6 &&
        password.contains(where: { $0.isLetter }) &&
        password.contains(where: { $0.isNumber || "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) })
    }
    
    private var showPasswordError: Bool {
        !password.isEmpty && !isPasswordValid && focusedField == .confirmPassword
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image("AuthBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                // Semi-transparent overlay
                LinearGradient(colors: [
                    Color(red: 0.07, green: 0.5, blue: 0.46).opacity(0.75),
                    Color(red: 0.05, green: 0.35, blue: 0.35).opacity(0.85)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                // Content - NO SCROLLING, fits on screen
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer().frame(height: 20)
                    
                    // Logo Section (Compact)
                    VStack(spacing: 6) {
                        LiveLedgerLogo(size: 60)
                        
                        Text("LiveLedger")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Track sales in real-time during live streams")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer().frame(height: 12)
                    
                    // Features (Compact horizontal)
                    HStack(spacing: 16) {
                        CompactFeature(icon: "bolt.fill", color: .yellow, text: "Instant orders")
                        CompactFeature(icon: "printer.fill", color: .blue, text: "Print receipts")
                        CompactFeature(icon: "chart.bar.fill", color: .green, text: "Analytics")
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer().frame(height: 16)
                    
                    // Sign Up Form (Compact)
                    VStack(spacing: 8) {
                        // Row 1: Name & Email
                        HStack(spacing: 8) {
                            CompactField(placeholder: "Full Name", text: $name, icon: "person.fill")
                                .focused($focusedField, equals: .name)
                            CompactField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboard: .emailAddress)
                                .focused($focusedField, equals: .email)
                        }
                        
                        // Row 2: Password & Confirm
                        HStack(spacing: 8) {
                            // Password field with validation
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    if showPassword {
                                        TextField("Password", text: $password)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .focused($focusedField, equals: .password)
                                    } else {
                                        SecureField("Password", text: $password)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .focused($focusedField, equals: .password)
                                    }
                                    
                                    Button { showPassword.toggle() } label: {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(showPasswordError ? Color.red.opacity(0.3) : Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(showPasswordError ? Color.red : Color.clear, lineWidth: 1.5)
                                )
                                
                                Text("Min 6 chars, 1 letter, 1 number/symbol")
                                    .font(.system(size: 9))
                                    .foregroundColor(showPasswordError ? .red : .white.opacity(0.5))
                            }
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    if showConfirmPassword {
                                        TextField("Confirm", text: $confirmPassword)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .focused($focusedField, equals: .confirmPassword)
                                    } else {
                                        SecureField("Confirm", text: $confirmPassword)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .focused($focusedField, equals: .confirmPassword)
                                    }
                                    
                                    Button { showConfirmPassword.toggle() } label: {
                                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                
                                // Match indicator
                                if !confirmPassword.isEmpty {
                                    Text(password == confirmPassword ? "✓ Match" : "✗ No match")
                                        .font(.system(size: 9))
                                        .foregroundColor(password == confirmPassword ? .green : .red)
                                } else {
                                    Text(" ")
                                        .font(.system(size: 9))
                                }
                            }
                        }
                        
                        // Row 3: Company & Referral
                        HStack(spacing: 8) {
                            CompactField(placeholder: "Company (optional)", text: $companyName, icon: "building.2.fill")
                                .focused($focusedField, equals: .company)
                            CompactField(placeholder: "Referral (optional)", text: $referralCode, icon: "gift.fill")
                                .focused($focusedField, equals: .referral)
                        }
                        
                        // Currency Picker (Compact)
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("Currency:")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("", selection: $selectedCurrency) {
                                ForEach(AppUser.currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .scaleEffect(0.9)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)
                        
                        // Terms with clickable links
                        HStack(spacing: 4) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .font(.system(size: 16))
                                .foregroundColor(agreedToTerms ? .green : .white.opacity(0.7))
                                .onTapGesture { agreedToTerms.toggle() }
                            
                            Text("I agree to ")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button {
                                // Open Terms URL
                                if let url = URL(string: "https://example.com/terms") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Terms of Service")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                            
                            Text(" and ")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button {
                                // Open Privacy URL
                                if let url = URL(string: "https://example.com/privacy") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Privacy Policy")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Sign Up Button
                        Button {
                            if isFormValid {
                                authManager.signUp(
                                    email: email,
                                    name: name,
                                    password: password,
                                    companyName: companyName.isEmpty ? "My Store" : companyName,
                                    currency: selectedCurrency,
                                    referralCode: referralCode
                                )
                            }
                        } label: {
                            Text("Create Free Account")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isFormValid ? Color.white : Color.white.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                        
                        Text("First 20 orders FREE • No credit card required")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Bottom spacing
                    Spacer().frame(height: 20)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
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

// MARK: - Compact Feature
struct CompactFeature: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.2))
                .cornerRadius(6)
            
            Text(text)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Compact Field
struct CompactField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            TextField(placeholder, text: $text)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .tint(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Legacy Support
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
                .tint(.white)
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
