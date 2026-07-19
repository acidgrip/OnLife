//
//  ResetPasswordStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
@testable import OnLife

@Suite("Reset Password Store Tests")
struct ResetPasswordStoreTests {
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = ResetPasswordStore()
        
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
    }
    
    // MARK: - Password Validation Tests
    
    @Test("Reset password fails when passwords don't match")
    @MainActor
    func testPasswordsDoNotMatch() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Password123", confirmPassword: "Password456")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Passwords do not match")
        #expect(!store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Reset password fails when password is too short")
    @MainActor
    func testPasswordTooShort() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Pass1", confirmPassword: "Pass1")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Password must be at least 8 characters")
        #expect(!store.showSuccess)
    }
    
    @Test("Reset password fails when password missing number")
    @MainActor
    func testPasswordMissingNumber() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Password", confirmPassword: "Password")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Password must contain at least one number")
        #expect(!store.showSuccess)
    }
    
    @Test("Reset password succeeds with valid password")
    @MainActor
    func testValidPasswordReset() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Password123", confirmPassword: "Password123")
        
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
        #expect(store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Reset password with exactly 8 characters and 1 number succeeds")
    @MainActor
    func testMinimumValidPassword() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Pass1234", confirmPassword: "Pass1234")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Reset password with multiple numbers succeeds")
    @MainActor
    func testPasswordWithMultipleNumbers() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "MyPass123456", confirmPassword: "MyPass123456")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Reset password with special characters and numbers succeeds")
    @MainActor
    func testPasswordWithSpecialCharacters() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "P@ssw0rd!", confirmPassword: "P@ssw0rd!")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    // MARK: - Loading State Tests
    
    @Test("isLoading is false after successful reset")
    @MainActor
    func testLoadingStateFalseAfterSuccess() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Password123", confirmPassword: "Password123")
        
        #expect(!store.isLoading)
    }
    
    @Test("isLoading is false after failed validation")
    @MainActor
    func testLoadingStateFalseAfterValidationFailure() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "short", confirmPassword: "short")
        
        #expect(!store.isLoading)
    }
    
    // MARK: - Edge Cases
    
    @Test("Reset password with empty passwords fails")
    @MainActor
    func testEmptyPasswords() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "", confirmPassword: "")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Password must be at least 8 characters")
        #expect(!store.showSuccess)
    }
    
    @Test("Reset password with only numbers (8+ digits) succeeds")
    @MainActor
    func testPasswordOnlyNumbers() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "12345678", confirmPassword: "12345678")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Reset password with whitespace and valid criteria succeeds")
    @MainActor
    func testPasswordWithWhitespace() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Pass word123", confirmPassword: "Pass word123")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Reset password with unicode characters and number succeeds")
    @MainActor
    func testPasswordWithUnicode() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Pässwörd123", confirmPassword: "Pässwörd123")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Reset password case sensitive - different cases don't match")
    @MainActor
    func testPasswordCaseSensitive() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Password123", confirmPassword: "password123")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Passwords do not match")
    }
    
    // MARK: - State Management Tests
    
    @Test("Error message clears on new valid attempt")
    @MainActor
    func testErrorMessageClears() async {
        let store = ResetPasswordStore()
        
        // First attempt with error
        await store.resetPassword(newPassword: "short", confirmPassword: "short")
        #expect(store.showError)
        #expect(store.errorMessage != nil)
        
        // Reset error state
        store.showError = false
        store.errorMessage = nil
        
        // Second attempt with valid password
        await store.resetPassword(newPassword: "Password123", confirmPassword: "Password123")
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
    }
    
    @Test("Multiple reset attempts work correctly")
    @MainActor
    func testMultipleResetAttempts() async {
        let store = ResetPasswordStore()
        
        // First attempt - should fail
        await store.resetPassword(newPassword: "Pass1", confirmPassword: "Pass1")
        #expect(store.showError)
        
        // Reset state
        store.showError = false
        store.errorMessage = nil
        
        // Second attempt - should succeed
        await store.resetPassword(newPassword: "Password123", confirmPassword: "Password123")
        #expect(store.showSuccess)
        #expect(!store.showError)
    }
    
    // MARK: - Boundary Tests
    
    @Test("Reset password with exactly 7 characters fails")
    @MainActor
    func testPasswordExactly7Characters() async {
        let store = ResetPasswordStore()
        
        await store.resetPassword(newPassword: "Pass123", confirmPassword: "Pass123")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Password must be at least 8 characters")
    }
    
    @Test("Reset password with very long password succeeds")
    @MainActor
    func testVeryLongPassword() async {
        let store = ResetPasswordStore()
        let longPassword = "ThisIsAVeryLongPasswordThatContainsNumbers123456789"
        
        await store.resetPassword(newPassword: longPassword, confirmPassword: longPassword)
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Reset password with number at different positions succeeds")
    @MainActor
    func testNumberAtDifferentPositions() async {
        let store = ResetPasswordStore()
        
        // Number at start
        await store.resetPassword(newPassword: "1Password", confirmPassword: "1Password")
        #expect(store.showSuccess)
        
        // Reset state
        store.showSuccess = false
        
        // Number in middle
        await store.resetPassword(newPassword: "Pass1word", confirmPassword: "Pass1word")
        #expect(store.showSuccess)
        
        // Reset state
        store.showSuccess = false
        
        // Number at end
        await store.resetPassword(newPassword: "Password1", confirmPassword: "Password1")
        #expect(store.showSuccess)
    }
}
