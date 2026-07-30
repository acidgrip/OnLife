//
//  SignUpView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

struct SignUpView: View {
    @State private var store = SignUpStore()
    @State private var session = SignUpSession()
    @State private var phoneNumber = ""
    @State private var navigateToVerification = false
    @State private var navigateToBirthdaySkippingVerification = false
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

                    // Phone Number Input
                    inputSection

                    Spacer()
                        .frame(height: Spacing.large)

                    // Send Verification Code Button
                    sendVerificationButton

                    #if DEBUG
                    // Temporary testing affordance - see
                    // SignUpStore.skipPhoneVerification for why this exists
                    // and is DEBUG-only.
                    skipVerificationButton
                    #endif

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
            VerificationCodeView(session: session)
        }
        .navigationDestination(isPresented: $navigateToBirthdaySkippingVerification) {
            VerificationBirthdayView(session: session)
        }
        .onChange(of: store.showSuccess) { oldValue, newValue in
            if newValue {
                navigateToVerification = true
            }
        }
        .onChange(of: store.showSkipSuccess) { oldValue, newValue in
            if newValue {
                navigateToBirthdaySkippingVerification = true
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

            Text("Let's get started by verifying your phone\nnumber.")
                .font(.body)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("PHONE NUMBER")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(primaryGradient)

            inputField
        }
    }

    private var inputField: some View {
        let textField = TextField("", text: $phoneNumber, prompt: Text("+1 (555) 123-4567")
            .foregroundColor(.gray.opacity(0.5)))
            .foregroundColor(.gray)
            .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
            .font(.body)

        #if os(iOS)
        return textField
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
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
                await store.sendVerificationCode(to: phoneNumber, session: session)
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

    // MARK: - Skip Verification Button (DEBUG-only testing affordance)

    #if DEBUG
    private var skipVerificationButton: some View {
        Button {
            Task {
                await store.skipPhoneVerification(session: session)
            }
        } label: {
            Text("Skip phone verification (testing only)")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .underline()
        }
        .disabled(store.isLoading)
        .padding(.top, Spacing.extraSmall)
    }
    #endif

    // MARK: - Login Link

    private var loginLink: some View {
        HStack(spacing: Spacing.extraSmall) {
            Text("Already have an account?")
                .foregroundColor(.gray)

            Button {
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
        !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Preview

#Preview {
    SignUpView()
}
