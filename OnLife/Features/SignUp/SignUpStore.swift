//
//  SignUpStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

@Observable
@MainActor
final class SignUpStore {
    // MARK: - Published State

    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let authService: any AuthServiceProtocol

    // MARK: - Initialization

    init(authService: any AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    // MARK: - Verification Methods

    /// Sends a real Firebase Phone Auth SMS code to `phoneNumber`, storing
    /// both the number and the resulting verification ID on `session` for
    /// the next screen to use.
    func sendVerificationCode(to phoneNumber: String, session: SignUpSession) async {
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            showErrorMessage("Please enter a phone number")
            return
        }

        guard isValidPhoneNumber(trimmed) else {
            showErrorMessage("Please enter a valid phone number")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let verificationID = try await authService.sendPhoneVerificationCode(phoneNumber: trimmed)
            session.phoneNumber = trimmed
            session.verificationID = verificationID
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }

    // MARK: - Validation

    /// Validate phone number format
    /// Accepts formats like: +1234567890, 123-456-7890, (123) 456-7890, 1234567890
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // Remove common phone formatting characters
        let digits = phone.filter { $0.isNumber }

        // Phone numbers should have at least 10 digits (can have more with country code)
        return digits.count >= 10 && digits.count <= 15
    }

    // MARK: - Helpers

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
