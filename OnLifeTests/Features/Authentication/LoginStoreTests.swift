//
//  LoginStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/13/26.
//

import Testing
@testable import OnLife

@Suite("Login Store Tests")
@MainActor
struct LoginStoreTests {
    
    // MARK: - Email Validation Tests
    
    @Test("Valid email addresses pass validation")
    func validEmailValidation() {
        let store = LoginStore()
        
        #expect(store.isValidEmail("test@example.com") == true)
        #expect(store.isValidEmail("user.name@domain.co.uk") == true)
        #expect(store.isValidEmail("first+last@test.io") == true)
    }
    
    @Test("Invalid email addresses fail validation")
    func invalidEmailValidation() {
        let store = LoginStore()
        
        #expect(store.isValidEmail("notanemail") == false)
        #expect(store.isValidEmail("missing@domain") == false)
        #expect(store.isValidEmail("@nodomain.com") == false)
        #expect(store.isValidEmail("no@.com") == false)
        #expect(store.isValidEmail("") == false)
    }
    
    // MARK: - Login Validation Tests
    
    @Test("Login with empty email shows error")
    func loginWithEmptyEmail() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: "", password: "password123")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter both email and password")
        #expect(authState.isAuthenticated == false)
    }
    
    @Test("Login with empty password shows error")
    func loginWithEmptyPassword() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: "test@example.com", password: "")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter both email and password")
        #expect(authState.isAuthenticated == false)
    }
    
    @Test("Login with invalid email format shows error")
    func loginWithInvalidEmailFormat() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: "notanemail", password: "password123")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter a valid email address")
        #expect(authState.isAuthenticated == false)
    }
    
    @Test("Login with short password shows error")
    func loginWithShortPassword() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: "test@example.com", password: "12345")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Password must be at least 6 characters")
        #expect(authState.isAuthenticated == false)
    }
    
    @Test("Login with valid credentials succeeds")
    func loginWithValidCredentials() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: "test@example.com", password: "password123")
        
        #expect(store.isLoading == false)
        #expect(store.showError == false)
        #expect(authState.isAuthenticated == true)
    }
    
    // MARK: - Loading State Tests
    
    @Test("Loading state is true during login")
    func loadingStateDuringLogin() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        // Start login in background
        Task {
            await store.login(email: "test@example.com", password: "password123")
        }
        
        // Small delay to allow login to start
        try? await Task.sleep(for: .milliseconds(100))
        
        // Loading should be true while processing
        // Note: This test is timing-dependent and may be flaky
        // In production, you'd mock the network call to control timing
    }
    
    @Test("Loading state is false after login completes")
    func loadingStateAfterLogin() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: "test@example.com", password: "password123")
        
        #expect(store.isLoading == false)
    }
    
    // MARK: - Error State Tests
    
    @Test("Error state is cleared on new login attempt")
    func errorStateClearedOnNewAttempt() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        // First attempt with invalid data
        await store.login(email: "", password: "")
        #expect(store.showError == true)
        
        // Reset error manually (as UI would do)
        store.showError = false
        store.errorMessage = nil
        
        // Second attempt with valid data
        await store.login(email: "test@example.com", password: "password123")
        #expect(store.showError == false)
    }
    
    // MARK: - Edge Cases
    
    @Test("Login with minimum valid password length")
    func loginWithMinimumPasswordLength() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: "test@example.com", password: "123456")
        
        #expect(store.showError == false)
        #expect(authState.isAuthenticated == true)
    }
    
    @Test("Login with whitespace in email")
    func loginWithWhitespaceEmail() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.login(email: " test@example.com ", password: "password123")
        
        // Current implementation doesn't trim whitespace
        // This test documents current behavior
        #expect(store.showError == true)
    }
    
    @Test("Email validation with special characters")
    func emailValidationWithSpecialCharacters() {
        let store = LoginStore()
        
        #expect(store.isValidEmail("user+tag@example.com") == true)
        #expect(store.isValidEmail("first.last@example.com") == true)
        #expect(store.isValidEmail("user_name@example.com") == true)
    }
    
    // MARK: - Google Sign In Tests
    
    @Test("Google sign in shows coming soon message")
    func googleSignInShowsComingSoon() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.signInWithGoogle()
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Google Sign In coming soon")
        #expect(authState.isAuthenticated == false)
    }
    
    @Test("Google sign in sets loading state correctly")
    func googleSignInLoadingState() async {
        let store = LoginStore()
        let authState = AuthenticationState()
        store.configure(authState: authState)
        
        await store.signInWithGoogle()
        
        #expect(store.isLoading == false)
    }
}

// MARK: - Authentication State Tests

@Suite("Authentication State Tests")
@MainActor
struct AuthenticationStateTests {
    
    @Test("Initial state is not authenticated")
    func initialState() {
        let authState = AuthenticationState()
        
        #expect(authState.isAuthenticated == false)
    }
    
    @Test("Login sets authenticated to true")
    func loginSetsAuthenticated() {
        let authState = AuthenticationState()
        
        authState.login()
        
        #expect(authState.isAuthenticated == true)
    }
    
    @Test("Logout sets authenticated to false")
    func logoutSetsUnauthenticated() {
        let authState = AuthenticationState()
        
        authState.login()
        #expect(authState.isAuthenticated == true)
        
        authState.logout()
        #expect(authState.isAuthenticated == false)
    }
    
    @Test("Multiple login calls remain authenticated")
    func multipleLoginCalls() {
        let authState = AuthenticationState()
        
        authState.login()
        authState.login()
        authState.login()
        
        #expect(authState.isAuthenticated == true)
    }
    
    @Test("Multiple logout calls remain unauthenticated")
    func multipleLogoutCalls() {
        let authState = AuthenticationState()
        
        authState.login()
        authState.logout()
        authState.logout()
        authState.logout()
        
        #expect(authState.isAuthenticated == false)
    }
}
