//
//  VerificationCodeView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

struct VerificationCodeView: View {
    @State private var store = VerificationCodeStore()
    @FocusState private var focusedField: Int?
    @State private var navigateToBirthday = false

    let session: SignUpSession

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

                    // Code Input Fields
                    codeInputSection

                    Spacer()
                        .frame(height: Spacing.large)

                    // Resend Code Timer
                    resendSection

                    Spacer()
                        .frame(height: Spacing.large)

                    // Verify Button
                    verifyButton

                    Spacer()
                }
                .padding(.horizontal, Spacing.large)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .navigationDestination(isPresented: $navigateToBirthday) {
            VerificationBirthdayView(session: session)
        }
        .onAppear {
            // Auto-focus first field
            focusedField = 0
        }
        .onChange(of: store.showSuccess) { oldValue, newValue in
            if newValue {
                navigateToBirthday = true
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
                    .foregroundColor(.gray)
            }

            Spacer()

            Spacer()
                .frame(width: 44) // Balance the back button
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.medium)
        .padding(.bottom, Spacing.small)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Verify Code")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            Text("Enter the verification code.")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, Spacing.extraSmall)

            Text("Sent to \(maskedPhoneNumber)")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Code Input Section

    private var codeInputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("ENTER VERIFICATION CODE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray.opacity(0.7))

            HStack(spacing: Spacing.small) {
                ForEach(0..<6, id: \.self) { index in
                    codeDigitField(at: index)
                }
            }
        }
    }

    private func codeDigitField(at index: Int) -> some View {
        let isFocused = focusedField == index

        return ZStack {
            // Background and border
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? primaryGradient : LinearGradient(
                                colors: [Color.white.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: isFocused ? 2 : 1
                        )
                }

            // Text field
            TextField("", text: Binding(
                get: { store.verificationCode[index] },
                set: { newValue in
                    handleDigitInput(at: index, newValue: newValue)
                }
            ))
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: index)
            #if os(iOS)
            .keyboardType(.numberPad)
            #endif
            .frame(height: 56)
            .onChange(of: store.verificationCode[index]) { oldValue, newValue in
                handleDigitChange(at: index, oldValue: oldValue, newValue: newValue)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
    }

    // MARK: - Resend Section

    private var resendSection: some View {
        HStack {
            Spacer()

            if store.canResend {
                Button {
                    Task {
                        await store.resendCode(session: session)
                    }
                } label: {
                    Text("Resend code")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .underline()
                }
                .disabled(store.isLoading)
            } else {
                Text("Resend code in \(store.formattedCountdown)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.vertical, Spacing.small)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Verify Button

    private var verifyButton: some View {
        Button {
            Task {
                await store.verifyCode(session: session)
            }
        } label: {
            buttonLabel
        }
        .disabled(store.isLoading || !store.isFormValid)
        .opacity(store.isFormValid ? 1.0 : 0.6)
    }

    private var buttonLabel: some View {
        HStack(spacing: Spacing.small) {
            if store.isLoading {
                ProgressView()
                    .tint(.black)
            } else {
                Text("Verify")
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

    // MARK: - Input Handling

    private func handleDigitInput(at index: Int, newValue: String) {
        // Filter to only numbers and take first character
        let filtered = newValue.filter { $0.isNumber }
        let finalValue = String(filtered.prefix(1))

        store.updateDigit(at: index, with: finalValue)
    }

    private func handleDigitChange(at index: Int, oldValue: String, newValue: String) {
        // Move to next field when a digit is entered
        if !newValue.isEmpty && oldValue.isEmpty {
            if index < 5 {
                focusedField = index + 1
            } else {
                // Last field - remove focus
                focusedField = nil
            }
        }

        // Move to previous field when digit is deleted
        if newValue.isEmpty && !oldValue.isEmpty {
            if index > 0 {
                focusedField = index - 1
            }
        }
    }

    // MARK: - Helpers

    private var maskedPhoneNumber: String {
        let digits = session.phoneNumber.filter { $0.isNumber }
        guard digits.count >= 4 else { return session.phoneNumber }
        let lastFour = String(digits.suffix(4))
        return "(***) ***-\(lastFour)"
    }
}

// MARK: - Preview

#Preview {
    VerificationCodeView(session: SignUpSession())
}
