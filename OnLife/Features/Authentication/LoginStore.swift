//
//  LoginStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI
import AuthenticationServices

@Observable
@MainActor
final class LoginStore {
    // MARK: - Published State
    
    var isLoading = false
    var showError = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private var authState: AuthenticationState?
    
    func configure(authState: AuthenticationState) {
        self.authState = authState
    }
    
    // MARK: - Authentication Methods
    
    /// Login with email and password
    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            showErrorMessage("Please enter both email and password")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorMessage("Please enter a valid email address")
            return
        }
        
        guard password.count >= 6 else {
            showErrorMessage("Password must be at least 6 characters")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: Replace with actual backend authentication
            try await authenticateWithBackend(email: email, password: password)
            authState?.login()
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    /// Sign in with Apple
    func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                showErrorMessage("Failed to get Apple credentials")
                return
            }
            
            isLoading = true
            defer { isLoading = false }
            
            do {
                // TODO: Send credential to backend for verification
                try await authenticateWithApple(credential: credential)
                authState?.login()
            } catch {
                showErrorMessage("Apple Sign In failed: \(error.localizedDescription)")
            }
            
        case .failure(let error):
            // User cancelled or error occurred
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                // User cancelled - don't show error
                return
            }
            showErrorMessage("Apple Sign In failed: \(error.localizedDescription)")
        }
    }
    
    /// Sign in with Google
    func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: Implement Google Sign In
            // This will require adding Google Sign-In SDK
            // For now, show a placeholder message
            try await Task.sleep(for: .seconds(1))
            showErrorMessage("Google Sign In coming soon")
        } catch {
            showErrorMessage("Google Sign In failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Backend Communication (Placeholder)
    
    private func authenticateWithBackend(email: String, password: String) async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        // Simulate authentication
        // In production, this would be an actual API call to your backend
        // Example:
        // let response = try await NetworkService.shared.login(email: email, password: password)
        // if response.success {
        //     // Store authentication token
        //     // Update user session
        // } else {
        //     throw AuthenticationError.invalidCredentials
        // }
        
        // For demo purposes, accept any valid email format
        if email.contains("@") && password.count >= 6 {
            // Success
            print("✅ Login successful for: \(email)")
        } else {
            throw AuthenticationError.invalidCredentials
        }
    }
    
    private func authenticateWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        // TODO: Send Apple credential to backend for verification
        // This is a placeholder
        
        try await Task.sleep(for: .seconds(1))
        
        let userIdentifier = credential.user
        let email = credential.email
        let fullName = credential.fullName
        
        print("✅ Apple Sign In successful")
        print("   User ID: \(userIdentifier)")
        if let email = email {
            print("   Email: \(email)")
        }
        if let fullName = fullName {
            print("   Name: \(fullName.givenName ?? "") \(fullName.familyName ?? "")")
        }
        
        // In production:
        // let response = try await NetworkService.shared.authenticateWithApple(
        //     userIdentifier: userIdentifier,
        //     identityToken: credential.identityToken,
        //     authorizationCode: credential.authorizationCode
        // )
    }
    
    // MARK: - Validation Helpers
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Authentication Error

enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case networkError
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection failed"
        case .serverError:
            return "Server error. Please try again later"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
