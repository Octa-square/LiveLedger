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
    var phone: String
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
    
    func signUp(email: String, name: String, phone: String = "", password: String, companyName: String, currency: String, referralCode: String) {
        // In a real app, password would be hashed and sent to a server
        let user = AppUser(
            id: UUID().uuidString,
            email: email,
            name: name,
            phone: phone,
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
    
    func updateEmail(_ email: String) {
        currentUser?.email = email
        saveUser()
    }
    
    func updatePhone(_ phone: String) {
        currentUser?.phone = phone
        saveUser()
    }
    
    func updatePassword(_ password: String) {
        // In a real app, this would hash the password and update on server
        // For local storage, we just acknowledge the update
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

// MARK: - Auth View (Centered, Polished Design)
struct AuthView: View {
    @ObservedObject var authManager: AuthManager
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
    @State private var showPasswordTooltip = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, phone, password, confirmPassword, company, referral
    }
    
    // Password validation
    private var isPasswordValid: Bool {
        password.count >= 6 &&
        password.contains(where: { $0.isLetter }) &&
        password.contains(where: { $0.isNumber || "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) })
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
                
                // Vertically centered content
                VStack(spacing: 0) {
                    Spacer().frame(height: 8)
                    
                    // Logo Section (Compact)
                    VStack(spacing: 4) {
                        LiveLedgerLogo(size: 70)
                        
                        Text("LiveLedger")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Track Live Sales Like a Pro")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer().frame(height: 10)
                    
                    // Expanded Features Grid (10 features in 2 columns)
                    HStack(alignment: .top, spacing: 12) {
                        // Left Column
                        VStack(alignment: .leading, spacing: 4) {
                            FeatureRow(icon: "bolt.fill", text: "Real-time tracking", color: .yellow)
                            FeatureRow(icon: "square.grid.2x2.fill", text: "Multi-platform", color: .pink)
                            FeatureRow(icon: "timer", text: "Live session timer", color: .cyan)
                            FeatureRow(icon: "wifi", text: "Network analyzer", color: .blue)
                            FeatureRow(icon: "bell.badge.fill", text: "Stock alerts", color: .red)
                        }
                        
                        // Right Column
                        VStack(alignment: .leading, spacing: 4) {
                            FeatureRow(icon: "chart.bar.fill", text: "Analytics", color: .green)
                            FeatureRow(icon: "printer.fill", text: "Print & export", color: .orange)
                            FeatureRow(icon: "speaker.wave.2.fill", text: "Sound alerts", color: .purple)
                            FeatureRow(icon: "arrow.left.arrow.right", text: "Comparisons", color: .teal)
                            FeatureRow(icon: "photo.fill", text: "Image editing", color: .indigo)
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    Spacer().frame(height: 10)
                    
                    // Sign Up Form (Compact spacing)
                    VStack(spacing: 8) {
                        // Row 1: Name & Email
                        HStack(spacing: 6) {
                            AuthInputField(placeholder: "Full Name", text: $name, icon: "person.fill")
                                .focused($focusedField, equals: .name)
                            AuthInputField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboard: .emailAddress)
                                .focused($focusedField, equals: .email)
                        }
                        
                        // Row 2: Phone Number (full width)
                        AuthInputField(placeholder: "Phone Number", text: $phoneNumber, icon: "phone.fill", keyboard: .phonePad)
                            .focused($focusedField, equals: .phone)
                        
                        // Row 3: Password & Confirm (aligned, same size)
                        HStack(spacing: 6) {
                            // Password field
                            ZStack(alignment: .topTrailing) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    if showPassword {
                                        TextField("Password", text: $password)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .focused($focusedField, equals: .password)
                                    } else {
                                        SecureField("Password", text: $password)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .tint(.white)
                                            .focused($focusedField, equals: .password)
                                    }
                                    
                                    Button { showPassword.toggle() } label: {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                .onChange(of: focusedField) { _, newValue in
                                    if newValue == .password {
                                        showPasswordTooltip = true
                                        // Auto-dismiss after 3 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            showPasswordTooltip = false
                                        }
                                    }
                                }
                                .onChange(of: password) { _, _ in
                                    showPasswordTooltip = false
                                }
                                
                                // Auto-dismissing tooltip
                                if showPasswordTooltip {
                                    Text("Min 6 chars, 1 letter, 1 symbol")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.8))
                                        .cornerRadius(6)
                                        .offset(y: -35)
                                        .transition(.opacity.combined(with: .scale))
                                        .animation(.easeInOut(duration: 0.2), value: showPasswordTooltip)
                                }
                            }
                            
                            // Confirm Password field (same size)
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                if showConfirmPassword {
                                    TextField("Confirm", text: $confirmPassword)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .tint(.white)
                                        .focused($focusedField, equals: .confirmPassword)
                                } else {
                                    SecureField("Confirm", text: $confirmPassword)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .tint(.white)
                                        .focused($focusedField, equals: .confirmPassword)
                                }
                                
                                // Show eye toggle OR match indicator (not blocking input)
                                Button { showConfirmPassword.toggle() } label: {
                                    // Only show match status after user finishes typing (both fields have content)
                                    if !confirmPassword.isEmpty && !password.isEmpty && confirmPassword.count >= password.count {
                                        Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(password == confirmPassword ? .green : .red)
                                    } else {
                                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Row 4: Company & Referral
                        HStack(spacing: 6) {
                            AuthInputField(placeholder: "Company (optional)", text: $companyName, icon: "building.2.fill")
                                .focused($focusedField, equals: .company)
                            AuthInputField(placeholder: "Referral (optional)", text: $referralCode, icon: "gift.fill")
                                .focused($focusedField, equals: .referral)
                        }
                        
                        // Currency Picker (Compact)
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Currency:")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Picker("", selection: $selectedCurrency) {
                                ForEach(AppUser.currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Terms with clickable links (Compact)
                        HStack(spacing: 4) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .font(.system(size: 16))
                                .foregroundColor(agreedToTerms ? .green : .white.opacity(0.8))
                                .onTapGesture { agreedToTerms.toggle() }
                            
                            Text("I agree to ")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button {
                                if let url = URL(string: "https://liveledger.app/terms") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Terms")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                            
                            Text(" & ")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button {
                                if let url = URL(string: "https://liveledger.app/privacy") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Privacy")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Sign Up Button (Compact)
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
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    
                    Spacer()
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

// MARK: - Feature Pill (Compact)
struct FeaturePill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

// MARK: - Feature Row (For 2-column layout)
struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 14)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.95))
                .lineLimit(1)
        }
    }
}

// MARK: - Auth Input Field (Uniform size, readable placeholder)
struct AuthInputField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .tint(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
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
