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
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        #expect(store.isValidEmail("test@example.com") == true)
        #expect(store.isValidEmail("user.name@domain.co.uk") == true)
        #expect(store.isValidEmail("first+last@test.io") == true)
    }
    
    @Test("Invalid email addresses fail validation")
    func invalidEmailValidation() {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        #expect(store.isValidEmail("notanemail") == false)
        #expect(store.isValidEmail("missing@domain") == false)
        #expect(store.isValidEmail("@nodomain.com") == false)
        #expect(store.isValidEmail("no@.com") == false)
        #expect(store.isValidEmail("") == false)
    }
    
    // MARK: - Login Validation Tests
    
    @Test("Login with empty email shows error")
    func loginWithEmptyEmail() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: "", password: "password123")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter both email and password")
        #expect(mockAuth.isAuthenticated == false)
    }
    
    @Test("Login with empty password shows error")
    func loginWithEmptyPassword() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: "test@example.com", password: "")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter both email and password")
        #expect(mockAuth.isAuthenticated == false)
    }
    
    @Test("Login with invalid email format shows error")
    func loginWithInvalidEmailFormat() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: "notanemail", password: "password123")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter a valid email address")
        #expect(mockAuth.isAuthenticated == false)
    }
    
    @Test("Login with short password shows error")
    func loginWithShortPassword() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: "test@example.com", password: "12345")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Password must be at least 6 characters")
        #expect(mockAuth.isAuthenticated == false)
    }
    
    @Test("Login with valid credentials succeeds")
    func loginWithValidCredentials() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: "test@example.com", password: "password123")
        
        #expect(store.isLoading == false)
        #expect(store.showError == false)
        #expect(mockAuth.isAuthenticated == true)
    }
    
    // MARK: - Loading State Tests
    
    @Test("Loading state is true during login")
    func loadingStateDuringLogin() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)

        // Start login in background
        let loginTask = Task {
            await store.login(email: "test@example.com", password: "password123")
        }

        // Small delay to allow login to start
        try? await Task.sleep(for: .milliseconds(50))

        // Loading should be true while processing
        // Note: This test is timing-dependent and may be flaky
        // In production, you'd mock the network call to control timing
        #expect(store.isLoading == true)

        // Wait for the login to actually finish before the test function
        // returns, so the background Task doesn't keep running/mutating
        // `store`/`mockAuth` after this test has already been reported done.
        await loginTask.value
        #expect(store.isLoading == false)
    }
    
    @Test("Loading state is false after login completes")
    func loadingStateAfterLogin() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: "test@example.com", password: "password123")
        
        #expect(store.isLoading == false)
    }
    
    // MARK: - Error State Tests
    
    @Test("Error state is cleared on new login attempt")
    func errorStateClearedOnNewAttempt() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
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
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: "test@example.com", password: "123456")
        
        #expect(store.showError == false)
        #expect(mockAuth.isAuthenticated == true)
    }
    
    @Test("Login with whitespace in email")
    func loginWithWhitespaceEmail() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.login(email: " test@example.com ", password: "password123")
        
        // Current implementation doesn't trim whitespace
        // This test documents current behavior
        #expect(store.showError == true)
    }
    
    @Test("Email validation with special characters")
    func emailValidationWithSpecialCharacters() {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        #expect(store.isValidEmail("user+tag@example.com") == true)
        #expect(store.isValidEmail("first.last@example.com") == true)
        #expect(store.isValidEmail("user_name@example.com") == true)
    }
    
    // MARK: - Google Sign In Tests
    
    @Test("Google sign in attempts authentication")
    func googleSignInAttemptsAuthentication() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.signInWithGoogle()
        
        // With mock auth service, Google sign in should succeed
        #expect(store.isLoading == false)
        #expect(mockAuth.isAuthenticated == true)
    }
    
    @Test("Google sign in handles failure gracefully")
    func googleSignInHandlesFailure() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        mockAuth.shouldFailSignIn = true
        let store = LoginStore(authService: mockAuth)
        
        await store.signInWithGoogle()
        
        #expect(store.isLoading == false)
        #expect(store.showError == true)
        #expect(mockAuth.isAuthenticated == false)
        
        // Clean up
        mockAuth.reset()
    }
}

// MARK: - Account Creation Tests

@Suite("Account Creation Tests")
@MainActor
struct AccountCreationTests {
    
    @Test("Create account with valid credentials succeeds")
    func createAccountWithValidCredentials() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.createAccount(email: "newuser@example.com", password: "password123")
        
        #expect(store.showError == false)
        #expect(mockAuth.isAuthenticated == true)
    }
    
    @Test("Create account with empty email shows error")
    func createAccountWithEmptyEmail() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.createAccount(email: "", password: "password123")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter both email and password")
        #expect(mockAuth.isAuthenticated == false)
    }
    
    @Test("Create account with invalid email shows error")
    func createAccountWithInvalidEmail() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.createAccount(email: "notanemail", password: "password123")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Please enter a valid email address")
        #expect(mockAuth.isAuthenticated == false)
    }
    
    @Test("Create account with short password shows error")
    func createAccountWithShortPassword() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = LoginStore(authService: mockAuth)
        
        await store.createAccount(email: "newuser@example.com", password: "12345")
        
        #expect(store.showError == true)
        #expect(store.errorMessage == "Password must be at least 6 characters")
        #expect(mockAuth.isAuthenticated == false)
    }
    
    @Test("Create account handles failure gracefully")
    func createAccountHandlesFailure() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        mockAuth.shouldFailSignIn = true
        let store = LoginStore(authService: mockAuth)
        
        await store.createAccount(email: "newuser@example.com", password: "password123")
        
        #expect(store.showError == true)
        #expect(mockAuth.isAuthenticated == false)
        
        // Clean up
        mockAuth.reset()
    }
}
