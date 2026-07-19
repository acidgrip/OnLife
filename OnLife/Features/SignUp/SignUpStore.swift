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
    
    // MARK: - Verification Methods
    
    /// Send verification code to email or phone number
    func sendVerificationCode(to emailOrPhone: String) async {
        let trimmed = emailOrPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate input is not empty
        guard !trimmed.isEmpty else {
            showErrorMessage("Please enter an email address or phone number")
            return
        }
        
        // Validate input format
        guard isValidEmailOrPhone(trimmed) else {
            showErrorMessage("Please enter a valid email address or phone number")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await sendVerificationCodeToBackend(emailOrPhone: trimmed)
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Validation
    
    /// Validate if the input is a valid email or phone number
    private func isValidEmailOrPhone(_ input: String) -> Bool {
        // Check if it's a valid email
        if isValidEmail(input) {
            return true
        }
        
        // Check if it's a valid phone number
        if isValidPhoneNumber(input) {
            return true
        }
        
        return false
    }
    
    /// Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validate phone number format
    /// Accepts formats like: +1234567890, 123-456-7890, (123) 456-7890, 1234567890
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // Remove common phone formatting characters
        let digits = phone.filter { $0.isNumber }
        
        // Phone numbers should have at least 10 digits (can have more with country code)
        return digits.count >= 10 && digits.count <= 15
    }
    
    // MARK: - Backend Communication (Placeholder)
    
    private func sendVerificationCodeToBackend(emailOrPhone: String) async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        // Simulate sending verification code
        // In production, this would be an actual API call to your backend
        // Example:
        // let response = try await NetworkService.shared.sendVerificationCode(to: emailOrPhone)
        // if !response.success {
        //     throw SignUpError.verificationFailed
        // }
        
        print("✅ Verification code sent to: \(emailOrPhone)")
        
        // For demo purposes, always succeed
        // In production, you might throw errors for already registered users, rate limiting, etc.
    }
    
    // MARK: - Helpers
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
