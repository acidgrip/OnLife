//
//  ForgotPasswordStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI

@Observable
@MainActor
final class ForgotPasswordStore {
    // MARK: - Published State
    
    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?
    
    // MARK: - Password Reset Methods
    
    /// Send password reset link to the provided email or phone number
    func sendResetLink(emailOrPhone: String) async {
        guard !emailOrPhone.isEmpty else {
            showErrorMessage("Please enter your email or phone number")
            return
        }
        
        guard emailOrPhone.count >= 3 else {
            showErrorMessage("Please enter a valid email or phone number")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await sendResetLinkToBackend(emailOrPhone: emailOrPhone)
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Backend Communication (Placeholder)
    
    private func sendResetLinkToBackend(emailOrPhone: String) async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        // Simulate sending reset link
        // In production, this would be an actual API call to your backend
        // Example:
        // let response = try await NetworkService.shared.requestPasswordReset(identifier: emailOrPhone)
        // if !response.success {
        //     throw PasswordResetError.requestFailed
        // }
        
        print("✅ Password reset link sent to: \(emailOrPhone)")
        
        // For demo purposes, always succeed
        // In production, you might throw errors for invalid emails, etc.
    }
    
    // MARK: - Helpers
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Password Reset Error

enum PasswordResetError: LocalizedError {
    case invalidIdentifier
    case networkError
    case serverError
    case userNotFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidIdentifier:
            return "Please enter a valid email or phone number"
        case .networkError:
            return "Network connection failed"
        case .serverError:
            return "Server error. Please try again later"
        case .userNotFound:
            return "No account found with this email or phone number"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
