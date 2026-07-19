//
//  ResetPasswordStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

@Observable
@MainActor
final class ResetPasswordStore {
    // MARK: - Published State
    
    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?
    
    // MARK: - Password Reset Methods
    
    /// Reset password with new password and confirmation
    func resetPassword(newPassword: String, confirmPassword: String) async {
        // Validate passwords match
        guard newPassword == confirmPassword else {
            showErrorMessage("Passwords do not match")
            return
        }
        
        // Validate password requirements
        guard newPassword.count >= 8 else {
            showErrorMessage("Password must be at least 8 characters")
            return
        }
        
        guard newPassword.rangeOfCharacter(from: .decimalDigits) != nil else {
            showErrorMessage("Password must contain at least one number")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await resetPasswordOnBackend(newPassword: newPassword)
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Backend Communication (Placeholder)
    
    private func resetPasswordOnBackend(newPassword: String) async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        // Simulate password reset
        // In production, this would be an actual API call to your backend
        // Example:
        // let response = try await NetworkService.shared.resetPassword(token: resetToken, newPassword: newPassword)
        // if !response.success {
        //     throw CreatePasswordError.resetFailed
        // }
        
        print("✅ Password successfully reset")
        
        // For demo purposes, always succeed
        // In production, you might throw errors for invalid tokens, expired links, etc.
    }
    
    // MARK: - Helpers
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
