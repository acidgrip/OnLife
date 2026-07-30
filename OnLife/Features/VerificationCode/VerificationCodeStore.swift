//
//  VerificationCodeStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

@Observable
@MainActor
final class VerificationCodeStore {
    // MARK: - Published State

    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?
    var verificationCode: [String] = Array(repeating: "", count: 6)
    var resendCountdown: Int = 30
    var canResend: Bool = false

    // MARK: - Dependencies

    private let authService: any AuthServiceProtocol

    // MARK: - Private State

    private nonisolated(unsafe) var countdownTask: Task<Void, Never>?

    // MARK: - Initialization

    init(authService: any AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        startResendCountdown()
    }

    deinit {
        countdownTask?.cancel()
    }

    // MARK: - Verification Methods

    /// Verify the entered code against the real Firebase Phone Auth
    /// verification started for `session`.
    func verifyCode(session: SignUpSession) async {
        let code = verificationCode.joined()

        // Validate code is complete
        guard code.count == 6 else {
            showErrorMessage("Please enter the complete 6-digit code")
            return
        }

        // Validate code contains only digits
        guard code.allSatisfy({ $0.isNumber }) else {
            showErrorMessage("Verification code must contain only numbers")
            return
        }

        guard let verificationID = session.verificationID else {
            showErrorMessage("Verification session expired. Please request a new code.")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.verifyPhoneCode(verificationID: verificationID, code: code)
            showSuccess = true
        } catch {
            error.printDebugDetails(context: "VerificationCodeStore.verifyCode")
            showErrorMessage(error.localizedDescription)
        }
    }

    /// Resend a real verification code for `session.phoneNumber`
    func resendCode(session: SignUpSession) async {
        guard canResend else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let verificationID = try await authService.sendPhoneVerificationCode(phoneNumber: session.phoneNumber)
            session.verificationID = verificationID

            // Reset countdown
            resendCountdown = 30
            canResend = false
            startResendCountdown()

            // Clear existing code
            verificationCode = Array(repeating: "", count: 6)

        } catch {
            error.printDebugDetails(context: "VerificationCodeStore.resendCode")
            showErrorMessage(error.localizedDescription)
        }
    }

    /// Update a specific digit in the verification code
    func updateDigit(at index: Int, with value: String) {
        guard index >= 0 && index < verificationCode.count else { return }

        // Only allow single digit
        let filtered = value.filter { $0.isNumber }
        verificationCode[index] = String(filtered.prefix(1))
    }

    /// Clear a specific digit
    func clearDigit(at index: Int) {
        guard index >= 0 && index < verificationCode.count else { return }
        verificationCode[index] = ""
    }

    /// Check if the form is valid (all 6 digits entered)
    var isFormValid: Bool {
        verificationCode.allSatisfy { !$0.isEmpty }
    }

    // MARK: - Countdown Timer

    private func startResendCountdown() {
        countdownTask?.cancel()

        countdownTask = Task {
            while resendCountdown > 0 {
                try? await Task.sleep(for: .seconds(1))

                guard !Task.isCancelled else { return }

                resendCountdown -= 1

                if resendCountdown == 0 {
                    canResend = true
                }
            }
        }
    }

    // MARK: - Helpers

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    /// Format countdown time as MM:SS
    var formattedCountdown: String {
        let minutes = resendCountdown / 60
        let seconds = resendCountdown % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
