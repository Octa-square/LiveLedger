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

// MARK: - Auth View
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
    @State private var showErrors = false
    @State private var showPasswordRequirementsAlert = false
    
    var body: some View {
        ZStack {
            // Background - Green theme matching logo
            LinearGradient(colors: [
                Color(red: 0.07, green: 0.5, blue: 0.46),
                Color(red: 0.05, green: 0.35, blue: 0.35)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 50)
                    
                    // Logo
                    VStack(spacing: 16) {
                        LiveLedgerLogo(size: 100)
                        
                        Text("LiveLedger")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Track sales in real-time during live streams")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(icon: "bolt.fill", color: .yellow, text: "Instant tap-to-add orders")
                        FeatureRow(icon: "printer.fill", color: .blue, text: "Print receipts & reports")
                        FeatureRow(icon: "chart.bar.fill", color: .green, text: "Real-time analytics")
                        FeatureRow(icon: "square.and.arrow.up", color: .purple, text: "Export to CSV")
                    }
                    .padding(.vertical, 10)
                    
                    // Sign Up Form
                    VStack(spacing: 14) {
                        Text("Create Your Account")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        CustomTextField(placeholder: "Full Name", text: $name, icon: "person.fill")
                        CustomTextField(placeholder: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                if showPassword {
                                    TextField("Password (min 6 characters)", text: $password)
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Password (min 6 characters)", text: $password)
                                        .foregroundColor(.white)
                                }
                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            
                        }
                        
                        // Confirm Password field
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                if showConfirmPassword {
                                    TextField("Confirm Password", text: $confirmPassword)
                                        .foregroundColor(.white)
                                        .onChange(of: confirmPassword) { _, newValue in
                                            // Show popup if password doesn't meet requirements
                                            if !newValue.isEmpty && !password.isEmpty {
                                                let hasLetter = password.contains(where: { $0.isLetter })
                                                let hasNumber = password.contains(where: { $0.isNumber })
                                                if password.count < 6 || !hasLetter || !hasNumber {
                                                    showPasswordRequirementsAlert = true
                                                }
                                            }
                                        }
                                } else {
                                    SecureField("Confirm Password", text: $confirmPassword)
                                        .foregroundColor(.white)
                                        .onChange(of: confirmPassword) { _, newValue in
                                            // Show popup if password doesn't meet requirements
                                            if !newValue.isEmpty && !password.isEmpty {
                                                let hasLetter = password.contains(where: { $0.isLetter })
                                                let hasNumber = password.contains(where: { $0.isNumber })
                                                if password.count < 6 || !hasLetter || !hasNumber {
                                                    showPasswordRequirementsAlert = true
                                                }
                                            }
                                        }
                                }
                                Button {
                                    showConfirmPassword.toggle()
                                } label: {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            
                            if showErrors && !confirmPassword.isEmpty && password != confirmPassword {
                                Text("⚠️ Passwords do not match")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if showErrors && !confirmPassword.isEmpty && password == confirmPassword {
                                Text("✓ Passwords match")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        CustomTextField(placeholder: "Company/Store Name (optional)", text: $companyName, icon: "building.2.fill")
                        CustomTextField(placeholder: "Referral Code (optional)", text: $referralCode, icon: "gift.fill")
                        
                        // Currency Picker
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("Currency", selection: $selectedCurrency) {
                                ForEach(AppUser.currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        // Terms
                        Toggle(isOn: $agreedToTerms) {
                            Text("I agree to the Terms of Service and Privacy Policy")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .toggleStyle(CheckboxToggleStyle())
                        
                        // Error Summary
                        if showErrors && !isFormValid {
                            VStack(alignment: .leading, spacing: 4) {
                                if name.isEmpty {
                                    Text("• Full name is required")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                if email.isEmpty || !email.contains("@") {
                                    Text("• Valid email is required")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                if password.count < 6 {
                                    Text("• Password must be at least 6 characters")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                if password != confirmPassword {
                                    Text("• Passwords must match")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                if !agreedToTerms {
                                    Text("• You must agree to the terms")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Sign Up Button
                        Button {
                            showErrors = true
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
                                .font(.headline)
                                .foregroundColor(Color(red: 0.07, green: 0.4, blue: 0.36))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        Text("First 20 orders FREE • No credit card required")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .alert("Password Requirements", isPresented: $showPasswordRequirementsAlert) {
            Button("OK", role: .cancel) {
                // Clear confirm password so user fixes the password first
                confirmPassword = ""
            }
        } message: {
            Text("Your password must have:\n• At least 6 characters\n• At least 1 letter (a-z)\n• At least 1 number (0-9)")
        }
    }
    
    var isFormValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && 
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword &&
        agreedToTerms
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
