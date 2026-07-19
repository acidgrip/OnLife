//
//  ResetPasswordView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var store = ResetPasswordStore()
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
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
                        .frame(height: Spacing.large)
                    
                    // Title and Description
                    headerSection
                    
                    Spacer()
                        .frame(height: Spacing.large)
                    
                    // Password Input Fields
                    passwordInputSection
                    
                    // Password Requirements
                    passwordRequirements
                    
                    Spacer()
                    
                    // Save Password Button
                    savePasswordButton
                    
                    // Contact Support Link
                    contactSupportLink
                    
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
            Text("Your password has been successfully reset.")
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
            
            // Onlife Icon
            Image.onlifeIcon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 32)
            
            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.medium)
        .padding(.bottom, Spacing.small)
    }
    
    // MARK: - Icon Section
    
    private var iconSection: some View {
        ZStack {
            // Large circular background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.2, blue: 0.2).opacity(0.5),
                            Color.black.opacity(0.2)
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 20)
            
            // Middle ring
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                .frame(width: 200, height: 200)
            
            // Inner ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.5, blue: 0.35).opacity(0.3),
                            Color(red: 0.8, green: 0.3, blue: 0.2).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: 130, height: 130)
            
            // Circular arrow with lock
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
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-100))
                
                // Arrow head
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: -19, y: 20)
                    .rotationEffect(.degrees(20))
                
                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            // Decorative dots
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 8, height: 8)
                .offset(x: 100, y: -60)
                .blur(radius: 1)
        }
        .frame(height: 250)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Spacing.small) {
            Text("Create new password")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Your new password must be different from previous\nused passwords for security.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }
    
    // MARK: - Password Input Section
    
    private var passwordInputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // New Password Field
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("NEW PASSWORD")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                HStack(spacing: Spacing.small) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 20)
                    
                    Group {
                        if showNewPassword {
                            TextField("", text: $newPassword)
                        } else {
                            SecureField("", text: $newPassword)
                        }
                    }
                    .foregroundColor(.white)
                    .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
                    
                    Button {
                        showNewPassword.toggle()
                    } label: {
                        Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
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
            
            // Confirm New Password Field
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("CONFIRM NEW PASSWORD")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                HStack(spacing: Spacing.small) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 20)
                    
                    Group {
                        if showConfirmPassword {
                            TextField("", text: $confirmPassword)
                        } else {
                            SecureField("", text: $confirmPassword)
                        }
                    }
                    .foregroundColor(.white)
                    .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
                    
                    Button {
                        showConfirmPassword.toggle()
                    } label: {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
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
    
    // MARK: - Password Requirements
    
    private var passwordRequirements: some View {
        HStack(spacing: Spacing.small) {
            // 8+ characters requirement
            HStack(spacing: Spacing.extraSmall) {
                Image(systemName: hasMinimumCharacters ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(hasMinimumCharacters ? .green : .gray)
                    .font(.system(size: 14))
                
                Text("8+ characters")
                    .font(.caption)
                    .foregroundColor(hasMinimumCharacters ? .green : .gray)
            }
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.extraSmall)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(hasMinimumCharacters ? Color.green.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                    }
            )
            
            // 1 Number requirement
            HStack(spacing: Spacing.extraSmall) {
                Image(systemName: hasNumber ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(hasNumber ? .green : .gray)
                    .font(.system(size: 14))
                
                Text("1 Number")
                    .font(.caption)
                    .foregroundColor(hasNumber ? .green : .gray)
            }
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.extraSmall)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(hasNumber ? Color.green.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                    }
            )
            
            Spacer()
        }
        .padding(.top, Spacing.extraSmall)
    }
    
    // MARK: - Save Password Button
    
    private var savePasswordButton: some View {
        Button {
            Task {
                await store.resetPassword(newPassword: newPassword, confirmPassword: confirmPassword)
            }
        } label: {
            HStack(spacing: Spacing.small) {
                Group {
                    if store.isLoading {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("Save Password")
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
    
    // MARK: - Contact Support Link
    
    private var contactSupportLink: some View {
        HStack(spacing: Spacing.extraSmall) {
            Text("Having trouble?")
                .foregroundColor(.gray)
            
            Button {
                // TODO: Navigate to support
                print("Contact support tapped")
            } label: {
                Text("Contact Support")
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
        .padding(.top, Spacing.small)
    }
    
    // MARK: - Helpers
    
    private var hasMinimumCharacters: Bool {
        newPassword.count >= 8
    }
    
    private var hasNumber: Bool {
        newPassword.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    private var isFormValid: Bool {
        hasMinimumCharacters &&
        hasNumber &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword
    }
}

// MARK: - Preview

#Preview {
    ResetPasswordView()
}
