//
//  SimpleAuthView.swift
//  LiveLedger
//
//  New Simplified Authentication View
//

import SwiftUI

struct SimpleAuthView: View {
    @ObservedObject var authManager: AuthManager
    @State private var isSignUp = true
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var storeName = ""
    @State private var selectedCurrency = "USD"
    @State private var agreedToTerms = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var loginError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmError: String?
    @State private var showForgotPasswordSheet = false
    @State private var resetEmail = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    let currencies = ["USD", "EUR", "GBP", "NGN", "KES"]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 50)
                    
                    // Logo Section
                    VStack(spacing: 15) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#00ff88"), Color(hex: "#00cc6a")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color(hex: "#00ff88").opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            Image("app_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                        
                        Text("LiveLedger")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Complete sales and inventory management for social sellers")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#888888"))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                    }
                    
                    // Auth Toggle
                    HStack(spacing: 0) {
                        Button(action: { isSignUp = true }) {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isSignUp ? .white : Color(hex: "#888888"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    isSignUp ? Color(hex: "#00ff88") : Color.clear
                                )
                        }
                        
                        Button(action: { isSignUp = false }) {
                            Text("Log In")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(!isSignUp ? .white : Color(hex: "#888888"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    !isSignUp ? Color(hex: "#00ff88") : Color.clear
                                )
                        }
                    }
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    
                    // Form Fields
                    VStack(spacing: 15) {
                        if isSignUp {
                            // Sign Up Fields
                            AuthTextField(
                                icon: "person.fill",
                                placeholder: "Full Name",
                                text: $fullName
                            )
                            
                            AuthTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            .onChange(of: email) { _, newValue in
                                if !newValue.isEmpty && !AuthManager.isValidEmail(newValue) {
                                    emailError = "Please enter a valid email (e.g. name@example.com)"
                                } else {
                                    emailError = nil
                                }
                            }
                            if let error = emailError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            AuthTextField(
                                icon: "phone.fill",
                                placeholder: "Phone Number (optional)",
                                text: $phoneNumber,
                                keyboardType: .phonePad
                            )
                            
                            AuthPasswordField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                showPassword: $showPassword
                            )
                            .onSubmit {
                                if !password.isEmpty && !AuthManager.isValidPassword(password) {
                                    passwordError = "Password must be 8+ characters with uppercase, lowercase, and number"
                                } else {
                                    passwordError = nil
                                }
                            }
                            if let error = passwordError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            AuthPasswordField(
                                icon: "lock.fill",
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                showPassword: $showConfirmPassword
                            )
                            .onChange(of: confirmPassword) { _, newValue in
                                if !newValue.isEmpty && newValue != password {
                                    confirmError = "Passwords must match"
                                } else {
                                    confirmError = nil
                                }
                            }
                            if let error = confirmError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            HStack(spacing: 12) {
                                AuthTextField(
                                    icon: "storefront.fill",
                                    placeholder: "Store Name",
                                    text: $storeName
                                )
                                .frame(maxWidth: .infinity)
                                
                                Menu {
                                    ForEach(currencies, id: \.self) { currency in
                                        Button(currency) {
                                            selectedCurrency = currency
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedCurrency)
                                            .foregroundColor(.white)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color(hex: "#888888"))
                                    }
                                    .padding()
                                    .frame(width: 100)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            
                            // Terms Checkbox
                            HStack(alignment: .top, spacing: 4) {
                                Button(action: { agreedToTerms.toggle() }) {
                                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(agreedToTerms ? Color(hex: "#00ff88") : Color(hex: "#666666"))
                                        .font(.system(size: 20))
                                }
                                .padding(.top, 2)
                                
                                HStack(spacing: 0) {
                                    Text("I agree to the ")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#888888"))
                                    Text("Terms of Service")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(hex: "#00ff88"))
                                    Text(" and ")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#888888"))
                                    Text("Privacy Policy")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(hex: "#00ff88"))
                                }
                            }
                            .padding(.top, 5)
                            
                        } else {
                            // Log In Fields
                            AuthTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            AuthPasswordField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                showPassword: $showPassword
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Continue Button
                    Button(action: {
                        // Authenticate with authManager
                        if isSignUp {
                            // Sign up: validate email and password first
                            print("[Auth] Sign Up (Continue) tapped – email: \(email)")
                            loginError = nil
                            if !AuthManager.isValidEmail(email) {
                                loginError = "Please enter a valid email (e.g. name@domain.com)"
                                return
                            }
                            if !AuthManager.isValidPassword(password) {
                                loginError = "Password must be at least 8 characters with uppercase, lowercase, and number"
                                return
                            }
                            if password != confirmPassword {
                                loginError = "Passwords must match"
                                return
                            }
                            authManager.signUp(
                                email: email,
                                name: fullName,
                                password: password,
                                companyName: storeName,
                                currency: selectedCurrency,
                                referralCode: "", // Empty referral code for new signups
                                phoneNumber: phoneNumber
                            )
                            // Show sign-up error (e.g. "email already exists") so user sees why they weren't signed in
                            if let signUpErr = authManager.signUpError {
                                loginError = signUpErr
                            }
                            // Sign up sets isAuthenticated automatically when it succeeds
                            if authManager.isAuthenticated {
                                isLoggedIn = true
                            }
                        } else {
                            // Login logic
                            print("[Auth] Log In tapped – email: \(email), password length: \(password.count)")
                            loginError = nil
                            let result = authManager.signInWithResult(email: email, password: password)
                            switch result {
                            case .success:
                                print("[Auth] Log In success – isAuthenticated: \(authManager.isAuthenticated)")
                                if authManager.isAuthenticated { isLoggedIn = true }
                            case .error(let message):
                                print("[Auth] Log In error: \(message)")
                                loginError = message
                            case .requiresSecurityQuestions(let account):
                                print("[Auth] Log In – requires security questions for \(account.email)")
                                resetEmail = account.email
                                showForgotPasswordSheet = true
                            case .accountLocked:
                                print("[Auth] Log In – account locked")
                                loginError = "Account locked. Enter your email below to reset your password."
                                resetEmail = email
                                showForgotPasswordSheet = true
                            }
                        }
                    }) {
                        Text(isSignUp ? "Continue" : "Log In")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#00ff88"), Color(hex: "#00cc6a")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: Color(hex: "#00ff88").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .disabled(isSignUp ? (!agreedToTerms || fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) : email.isEmpty || password.isEmpty)
                    .opacity((isSignUp ? (!agreedToTerms || fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) : email.isEmpty || password.isEmpty) ? 0.5 : 1.0)
                    
                    if let error = loginError {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    if !isSignUp {
                        Button("Forgot Password?") {
                            resetEmail = email
                            showForgotPasswordSheet = true
                        }
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#00ff88"))
                    }
                    
                    if isSignUp {
                        Text("First 20 orders FREE • No credit card required")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#888888"))
                    }
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
        }
        .sheet(isPresented: $showForgotPasswordSheet) {
            ForgotPasswordSheet(
                authManager: authManager,
                resetEmail: $resetEmail,
                onClose: {
                    showForgotPasswordSheet = false
                    loginError = nil
                }
            )
        }
    }
}

// MARK: - Auth Text Field
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#888888"))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Auth Password Field
struct AuthPasswordField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#888888"))
                .frame(width: 20)
            
            if showPassword {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
            
            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(Color(hex: "#888888"))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
