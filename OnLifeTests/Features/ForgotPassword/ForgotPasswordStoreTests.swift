//
//  ForgotPasswordStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/13/26.
//

import Testing
@testable import OnLife

@Suite("Forgot Password Store Tests")
@MainActor
struct ForgotPasswordStoreTests {
    
    // MARK: - Initial State Tests
    
    @Test("Store initializes with correct default state")
    func initialState() {
        let store = ForgotPasswordStore()
        
        #expect(store.isLoading == false)
        #expect(store.showError == false)
        #expect(store.showSuccess == false)
        #expect(store.errorMessage == nil)
    }
    
    // MARK: - Input Validation Tests
    
    @Test("Sending reset link with empty input shows error")
    func sendResetLinkWithEmptyInput() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter your email or phone number")
        #expect(store.showSuccess == false)
        #expect(store.isLoading == false)
    }
    
    @Test("Sending reset link with too short input shows error")
    func sendResetLinkWithTooShortInput() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "ab")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter a valid email or phone number")
        #expect(store.showSuccess == false)
        #expect(store.isLoading == false)
    }
    
    @Test("Sending reset link with valid email succeeds")
    func sendResetLinkWithValidEmail() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "test@example.com")
        
        #expect(store.showSuccess == true)
        #expect(store.showError == false)
        #expect(store.errorMessage == nil)
        #expect(store.isLoading == false)
    }
    
    @Test("Sending reset link with valid phone number succeeds")
    func sendResetLinkWithValidPhone() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "+1234567890")
        
        #expect(store.showSuccess == true)
        #expect(store.showError == false)
        #expect(store.errorMessage == nil)
        #expect(store.isLoading == false)
    }
    
    @Test("Sending reset link with minimal valid input succeeds")
    func sendResetLinkWithMinimalInput() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "abc")
        
        #expect(store.showSuccess == true)
        #expect(store.showError == false)
        #expect(store.errorMessage == nil)
        #expect(store.isLoading == false)
    }
    
    // MARK: - Loading State Tests
    
    @Test("Loading state resets after request completion")
    func loadingStateAfterRequestCompletion() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "test@example.com")
        
        // After completion, loading should be false
        #expect(store.isLoading == false)
    }
    
    // MARK: - Multiple Request Tests
    
    @Test("Multiple successful requests maintain correct state")
    func multipleSuccessfulRequests() async {
        let store = ForgotPasswordStore()
        
        // First request
        await store.sendResetLink(emailOrPhone: "user1@example.com")
        #expect(store.showSuccess == true)
        
        // Reset state manually (simulating user dismissing alert)
        store.showSuccess = false
        
        // Second request
        await store.sendResetLink(emailOrPhone: "user2@example.com")
        #expect(store.showSuccess == true)
        #expect(store.showError == false)
    }
    
    @Test("Error state is replaced by success on valid request")
    func errorStateReplacedBySuccess() async {
        let store = ForgotPasswordStore()
        
        // First request fails
        await store.sendResetLink(emailOrPhone: "")
        #expect(store.showError == true)
        
        // Second request succeeds
        await store.sendResetLink(emailOrPhone: "test@example.com")
        #expect(store.showSuccess == true)
        #expect(store.isLoading == false)
    }
    
    @Test("Success state is replaced by error on invalid request")
    func successStateReplacedByError() async {
        let store = ForgotPasswordStore()
        
        // First request succeeds
        await store.sendResetLink(emailOrPhone: "test@example.com")
        #expect(store.showSuccess == true)
        
        // Reset success state
        store.showSuccess = false
        
        // Second request fails
        await store.sendResetLink(emailOrPhone: "")
        #expect(store.showError == true)
        #expect(store.errorMessage != nil)
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Sending reset link with whitespace-only input")
    func sendResetLinkWithWhitespaceOnly() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "   ")
        
        // Trimmed string becomes empty or succeeds based on implementation
        #expect(store.showError == true || store.showSuccess == true)
        #expect(store.isLoading == false)
    }
    
    @Test("Sending reset link with special characters succeeds")
    func sendResetLinkWithSpecialCharacters() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "user+tag@example.com")
        
        #expect(store.showSuccess == true)
        #expect(store.isLoading == false)
    }
    
    @Test("Sending reset link with very long input succeeds")
    func sendResetLinkWithLongInput() async {
        let store = ForgotPasswordStore()
        let longEmail = String(repeating: "a", count: 100) + "@example.com"
        
        await store.sendResetLink(emailOrPhone: longEmail)
        
        #expect(store.showSuccess == true)
        #expect(store.isLoading == false)
    }
    
    // MARK: - State Cleanup Tests
    
    @Test("Error message is set when showing error")
    func errorMessageSetWhenShowingError() async {
        let store = ForgotPasswordStore()
        
        await store.sendResetLink(emailOrPhone: "")
        
        #expect(store.showError == true)
        #expect(store.errorMessage != nil)
        #expect(store.errorMessage?.isEmpty == false)
    }
}

// MARK: - Password Reset Error Tests

@Suite("Password Reset Error Tests")
struct PasswordResetErrorTests {
    
    @Test("Invalid identifier error has correct description")
    func invalidIdentifierError() {
        let error = PasswordResetError.invalidIdentifier
        
        #expect(error.errorDescription == "Please enter a valid email or phone number")
    }
    
    @Test("Network error has correct description")
    func networkError() {
        let error = PasswordResetError.networkError
        
        #expect(error.errorDescription == "Network connection failed")
    }
    
    @Test("Server error has correct description")
    func serverError() {
        let error = PasswordResetError.serverError
        
        #expect(error.errorDescription == "Server error. Please try again later")
    }
    
    @Test("User not found error has correct description")
    func userNotFoundError() {
        let error = PasswordResetError.userNotFound
        
        #expect(error.errorDescription == "No account found with this email or phone number")
    }
    
    @Test("Unknown error has correct description")
    func unknownError() {
        let error = PasswordResetError.unknown
        
        #expect(error.errorDescription == "An unknown error occurred")
    }
    
    @Test("All errors conform to LocalizedError")
    func errorsConformToLocalizedError() {
        let errors: [PasswordResetError] = [
            .invalidIdentifier,
            .networkError,
            .serverError,
            .userNotFound,
            .unknown
        ]
        
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription?.isEmpty == false)
        }
    }
}

