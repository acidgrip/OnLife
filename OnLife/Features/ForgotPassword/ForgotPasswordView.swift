//
//  ForgotPasswordView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var store = ForgotPasswordStore()
    @State private var emailOrPhone = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                VStack(spacing: Spacing.medium) {
                    Spacer()
                        .frame(height: Spacing.small)
                    
                    // Icon
                    iconSection
                    
                    Spacer()
                        .frame(height: Spacing.medium)
                    
                    // Title and Description
                    headerSection
                    
                    Spacer()
                        .frame(height: Spacing.large)
                    
                    // Email/Phone Input
                    inputSection
                    
                    Spacer()
                        .frame(height: Spacing.medium)
                    
                    // Send Link Button
                    sendLinkButton
                    
                    Spacer()
                    
                    // Remember Password Link
                    rememberPasswordLink
                    
                    Spacer()
                        .frame(height: Spacing.medium)
                }
                .padding(.horizontal, Spacing.large)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .alert("Success", isPresented: $store.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("We've sent a password reset link to \(emailOrPhone)")
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
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.medium)
        .padding(.bottom, Spacing.small)
    }
    
    // MARK: - Icon Section
    
    private var iconSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.08))
                .frame(width: 120, height: 120)
            
            ZStack {
                // Circular arrow
                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 55, height: 55)
                    .rotationEffect(.degrees(-100))
                
                // Arrow head
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: -17, y: 18)
                    .rotationEffect(.degrees(20))
                
                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Spacing.small) {
            Text("Forgot access?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("No worries! Enter your credentials\nand we'll send a secure reset link to\nyour account.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("EMAIL OR PHONE NUMBER")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            HStack(spacing: Spacing.small) {
                Image(systemName: "at")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                #if os(iOS)
                TextField("hello@onlife.app", text: $emailOrPhone)
                    .foregroundColor(.white)
                    .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                #else
                TextField("hello@onlife.app", text: $emailOrPhone)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                #endif
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
    
    // MARK: - Send Link Button
    
    private var sendLinkButton: some View {
        Button {
            Task {
                await store.sendResetLink(emailOrPhone: emailOrPhone)
            }
        } label: {
            HStack(spacing: Spacing.small) {
                Group {
                    if store.isLoading {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("Send Link")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
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
            .cornerRadius(28)
        }
        .disabled(store.isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }
    
    // MARK: - Remember Password Link
    
    private var rememberPasswordLink: some View {
        HStack(spacing: Spacing.extraSmall) {
            Text("Remember your password?")
                .foregroundColor(.gray)
            
            Button {
                dismiss()
            } label: {
                Text("Log In")
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
        !emailOrPhone.isEmpty && emailOrPhone.count >= 3
    }
}

// MARK: - Preview

#Preview {
    ForgotPasswordView()
}
