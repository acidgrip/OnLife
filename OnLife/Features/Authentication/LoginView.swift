//
//  LoginView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI
import AuthenticationServices

#if canImport(UIKit)
import UIKit
#endif

struct LoginView: View {
    @State private var store = LoginStore()
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showForgotPassword = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthenticationState.self) private var authState
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    Spacer()
                        .frame(height: Spacing.small)
                    
                    // Logo and Title Section
                    logoSection
                    
                    Spacer()
                        .frame(height: Spacing.large)
                    
                    // Social Login Buttons
                    socialLoginSection
                    
                    // Email and Password Fields
                    credentialsSection
                    
                    // Forgot Password Link
                    forgotPasswordLink
                    
                    // Login Button
                    loginButton
                    
                    Spacer()
                        .frame(height: Spacing.small)
                    
                    // Sign Up Link
                    signUpLink
                    
                    Spacer()
                        .frame(minHeight: Spacing.small)
                }
                .padding(.horizontal, Spacing.large)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .alert("Error", isPresented: $store.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            store.configure(authState: authState)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        VStack(spacing: Spacing.small) {
            // Placeholder for logo - replace with actual logo image later
            Text("ONLIFE")
                .font(.system(size: 48, weight: .bold, design: .default))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Connect with people around you in\nreal life.")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }
    
    // MARK: - Social Login Section
    
    private var socialLoginSection: some View {
        VStack(spacing: Spacing.medium) {
            // Apple Sign In
            appleSignInButton
            
            // Google Sign In Button
            googleSignInButton
        }
    }
    
    private var appleSignInButton: some View {
        SignInWithAppleButton { request in
            store.handleAppleSignInRequest(request)
        } onCompletion: { result in
            Task {
                await store.handleAppleSignInCompletion(result)
            }
        }
        .frame(height: 56)
        .cornerRadius(12)
    }
    
    private var googleSignInButton: some View {
        Button {
            Task {
                await store.signInWithGoogle()
            }
        } label: {
            HStack(spacing: Spacing.small) {
                // Google Icon Placeholder
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Text("G")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                
                Text("Log in with Google")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        }
    }
    
    // MARK: - Credentials Section
    
    private var credentialsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // Email Field
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("EMAIL ADDRESS OR PHONE NUMBER")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                HStack(spacing: Spacing.small) {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    
                    TextField("name@example.com", text: $email)
                        .foregroundColor(.white)
                        .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.medium)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("PASSWORD")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                HStack(spacing: Spacing.small) {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    
                    Group {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                    }
                    .foregroundColor(.white)
                    .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
                    
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.medium)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
            }
        }
    }
    
    // MARK: - Forgot Password Link
    
    private var forgotPasswordLink: some View {
        HStack {
            Spacer()
            Button {
                showForgotPassword = true
            } label: {
                Text("Forgot password?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Login Button
    
    private var loginButton: some View {
        Button {
            Task {
                await store.login(email: email, password: password)
            }
        } label: {
            Group {
                if store.isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("Log In")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .disabled(store.isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }
    
    // MARK: - Sign Up Link
    
    private var signUpLink: some View {
        HStack(spacing: Spacing.extraSmall) {
            Text("Don't have an account?")
                .foregroundColor(.gray)
            
            Button {
                // TODO: Navigate to Sign Up screen
                print("Sign up tapped")
            } label: {
                Text("Sign up")
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .font(.subheadline)
    }
    
    // MARK: - Helpers
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environment(AuthenticationState())
}
