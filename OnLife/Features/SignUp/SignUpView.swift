//
//  SignUpView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

struct SignUpView: View {
    @State private var store = SignUpStore()
    @State private var emailOrPhone = ""
    @State private var navigateToVerification = false
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Gradient Definitions
    
    private var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                VStack(spacing: Spacing.large) {
                    Spacer()
                        .frame(height: Spacing.medium)
                    
                    // Title and Description
                    headerSection
                    
                    Spacer()
                        .frame(height: Spacing.extraLarge)
                    
                    // Email or Phone Input
                    inputSection
                    
                    Spacer()
                        .frame(height: Spacing.large)
                    
                    // Send Verification Code Button
                    sendVerificationButton
                    
                    Spacer()
                    
                    // Login Link
                    loginLink
                    
                    Spacer()
                        .frame(height: Spacing.medium)
                }
                .padding(.horizontal, Spacing.large)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .navigationDestination(isPresented: $navigateToVerification) {
            VerificationCodeView(emailOrPhone: emailOrPhone)
        }
        .onChange(of: store.showSuccess) { oldValue, newValue in
            if newValue {
                navigateToVerification = true
            }
        }
        .alert("Error", isPresented: $store.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        HStack(spacing: Spacing.medium) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(primaryGradient)
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.medium)
        .padding(.bottom, Spacing.small)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Sign Up")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("Let's get started by verifying your contact\ninfo.")
                .font(.body)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("EMAIL OR PHONE NUMBER")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(primaryGradient)
            
            inputField
        }
    }
    
    private var inputField: some View {
        let textField = TextField("", text: $emailOrPhone, prompt: Text("name@example.com or phone")
            .foregroundColor(.gray.opacity(0.5)))
            .foregroundColor(.gray)
            .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
            .font(.body)
        
        #if os(iOS)
        return textField
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.medium + Spacing.extraSmall)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        #else
        return textField
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.medium + Spacing.extraSmall)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        #endif
    }
    
    // MARK: - Send Verification Button
    
    private var sendVerificationButton: some View {
        Button {
            Task {
                await store.sendVerificationCode(to: emailOrPhone)
            }
        } label: {
            buttonLabel
        }
        .disabled(store.isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }
    
    private var buttonLabel: some View {
        HStack(spacing: Spacing.small) {
            if store.isLoading {
                ProgressView()
                    .tint(.black)
            } else {
                Text("Send Verification Code")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(primaryGradient)
        .foregroundColor(.black)
        .cornerRadius(28)
    }
    
    // MARK: - Login Link
    
    private var loginLink: some View {
        HStack(spacing: Spacing.extraSmall) {
            Text("Already have an account?")
                .foregroundColor(.gray)
            
            Button {
                // TODO: Navigate to login
                dismiss()
            } label: {
                Text("Log In")
                    .fontWeight(.semibold)
                    .foregroundStyle(primaryGradient)
            }
        }
        .font(.subheadline)
    }
    
    // MARK: - Helpers
    
    private var isFormValid: Bool {
        !emailOrPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Preview

#Preview {
    SignUpView()
}
