//
//  LoginStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

@Observable
@MainActor
final class LoginStore {
    // MARK: - Published State
    
    var isLoading = false
    var showError = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let authService: any AuthServiceProtocol
    
    // MARK: - Initialization
    
    init(authService: any AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
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
            // Use Firebase Auth via AuthService
            try await authService.signIn(email: email, password: password)
            print("✅ Login successful for: \(email)")
        } catch {
            error.printDebugDetails(context: "LoginStore.login")
            showErrorMessage(error.localizedDescription)
        }
    }
    
    /// Create new account with email and password
    func createAccount(email: String, password: String) async {
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
            // Use Firebase Auth via AuthService
            try await authService.createAccount(email: email, password: password)
            print("✅ Account created for: \(email)")
        } catch {
            error.printDebugDetails(context: "LoginStore.createAccount")
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
                // Use Firebase Auth via AuthService
                try await authService.signInWithApple(credential: credential)
                print("✅ Apple Sign In successful")
            } catch {
                error.printDebugDetails(context: "LoginStore.handleAppleSignInCompletion")
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
            // Use Firebase Auth via AuthService
            try await authService.signInWithGoogle()
            print("✅ Google Sign In successful")
        } catch {
            error.printDebugDetails(context: "LoginStore.signInWithGoogle")
            showErrorMessage("Google Sign In failed: \(error.localizedDescription)")
        }
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
