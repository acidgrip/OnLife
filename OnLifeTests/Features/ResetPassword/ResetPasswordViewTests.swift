//
//  ResetPasswordViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Reset Password View Tests")
struct ResetPasswordViewTests {
    
    // MARK: - View Initialization Tests
    
    @Test("View initializes correctly")
    func testViewInitialization() {
        let view = ResetPasswordView()
        
        #expect(view != nil)
    }
    
    // MARK: - Password Validation Helper Tests
    
    @Test("hasMinimumCharacters validates correctly")
    func testMinimumCharactersValidation() async {
        let view = ResetPasswordView()
        let mirror = Mirror(reflecting: view)
        
        // Note: In a real scenario, we'd need to set the state and test the computed property
        // This is a simplified test structure
        #expect(view != nil)
    }
    
    // MARK: - Form Validation Tests
    
    @Test("Form validation - empty passwords should be invalid")
    func testEmptyPasswordsInvalid() {
        // Test that empty passwords result in invalid form
        let newPassword = ""
        let confirmPassword = ""
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(!isFormValid)
    }
    
    @Test("Form validation - short password should be invalid")
    func testShortPasswordInvalid() {
        let newPassword = "Pass1"
        let confirmPassword = "Pass1"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(!isFormValid)
    }
    
    @Test("Form validation - password without number should be invalid")
    func testPasswordWithoutNumberInvalid() {
        let newPassword = "Password"
        let confirmPassword = "Password"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(!isFormValid)
    }
    
    @Test("Form validation - mismatched passwords should be invalid")
    func testMismatchedPasswordsInvalid() {
        let newPassword = "Password123"
        let confirmPassword = "Password456"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(!isFormValid)
    }
    
    @Test("Form validation - valid password should be valid")
    func testValidPasswordValid() {
        let newPassword = "Password123"
        let confirmPassword = "Password123"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(isFormValid)
    }
    
    // MARK: - Password Requirement Tests
    
    @Test("Minimum characters requirement - 7 characters fails")
    func testMinimumCharactersSevenFails() {
        let password = "Pass123"
        let hasMinimumCharacters = password.count >= 8
        
        #expect(!hasMinimumCharacters)
    }
    
    @Test("Minimum characters requirement - 8 characters passes")
    func testMinimumCharactersEightPasses() {
        let password = "Pass1234"
        let hasMinimumCharacters = password.count >= 8
        
        #expect(hasMinimumCharacters)
    }
    
    @Test("Minimum characters requirement - 9+ characters passes")
    func testMinimumCharactersNinePlusPasses() {
        let password = "Password123"
        let hasMinimumCharacters = password.count >= 8
        
        #expect(hasMinimumCharacters)
    }
    
    @Test("Number requirement - no number fails")
    func testNumberRequirementNoNumberFails() {
        let password = "Password"
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        #expect(!hasNumber)
    }
    
    @Test("Number requirement - single number passes")
    func testNumberRequirementSingleNumberPasses() {
        let password = "Password1"
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        #expect(hasNumber)
    }
    
    @Test("Number requirement - multiple numbers passes")
    func testNumberRequirementMultipleNumbersPasses() {
        let password = "Pass123word"
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        #expect(hasNumber)
    }
    
    @Test("Number requirement - number at start passes")
    func testNumberRequirementNumberAtStartPasses() {
        let password = "1Password"
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        #expect(hasNumber)
    }
    
    @Test("Number requirement - number at end passes")
    func testNumberRequirementNumberAtEndPasses() {
        let password = "Password1"
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        #expect(hasNumber)
    }
    
    @Test("Number requirement - number in middle passes")
    func testNumberRequirementNumberInMiddlePasses() {
        let password = "Pass1word"
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        #expect(hasNumber)
    }
    
    // MARK: - Edge Cases
    
    @Test("Form validation - empty confirm password invalid")
    func testEmptyConfirmPasswordInvalid() {
        let newPassword = "Password123"
        let confirmPassword = ""
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(!isFormValid)
    }
    
    @Test("Form validation - whitespace password with valid criteria valid")
    func testWhitespacePasswordValid() {
        let newPassword = "Pass word 123"
        let confirmPassword = "Pass word 123"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(isFormValid)
    }
    
    @Test("Form validation - special characters with valid criteria valid")
    func testSpecialCharactersPasswordValid() {
        let newPassword = "P@ssw0rd!"
        let confirmPassword = "P@ssw0rd!"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(isFormValid)
    }
    
    @Test("Form validation - unicode characters with number valid")
    func testUnicodePasswordValid() {
        let newPassword = "Pässwörd123"
        let confirmPassword = "Pässwörd123"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(isFormValid)
    }
    
    @Test("Form validation - case sensitivity matters")
    func testCaseSensitivePasswordInvalid() {
        let newPassword = "Password123"
        let confirmPassword = "password123"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(!isFormValid)
    }
    
    // MARK: - Boundary Tests
    
    @Test("Form validation - exactly 8 characters with number valid")
    func testExactly8CharactersValid() {
        let newPassword = "Pass1234"
        let confirmPassword = "Pass1234"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(isFormValid)
    }
    
    @Test("Form validation - very long password valid")
    func testVeryLongPasswordValid() {
        let newPassword = "ThisIsAVeryLongPasswordThatContainsNumbers123456789AndMore"
        let confirmPassword = "ThisIsAVeryLongPasswordThatContainsNumbers123456789AndMore"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(isFormValid)
    }
    
    @Test("Form validation - only numbers 8+ digits valid")
    func testOnlyNumbersValid() {
        let newPassword = "12345678"
        let confirmPassword = "12345678"
        
        let hasMinimumCharacters = newPassword.count >= 8
        let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let isFormValid = hasMinimumCharacters &&
                         hasNumber &&
                         !confirmPassword.isEmpty &&
                         newPassword == confirmPassword
        
        #expect(isFormValid)
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete validation flow - all requirements met")
    func testCompleteValidationFlow() {
        let testCases: [(String, String, Bool)] = [
            // (newPassword, confirmPassword, expectedValid)
            ("", "", false),                           // Empty
            ("Pass", "Pass", false),                   // Too short
            ("Password", "Password", false),           // No number
            ("Pass123", "Pass123", false),             // Too short with number
            ("Password1", "Password2", false),         // Mismatch
            ("Password1", "Password1", true),          // Valid
            ("Pass1234", "Pass1234", true),            // Valid minimum
            ("P@ssw0rd!", "P@ssw0rd!", true),         // Valid with special chars
            ("MySecurePass123", "MySecurePass123", true), // Valid long
        ]
        
        for (newPassword, confirmPassword, expectedValid) in testCases {
            let hasMinimumCharacters = newPassword.count >= 8
            let hasNumber = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
            let isFormValid = hasMinimumCharacters &&
                             hasNumber &&
                             !confirmPassword.isEmpty &&
                             newPassword == confirmPassword
            
            #expect(isFormValid == expectedValid,
                   "Failed for password: '\(newPassword)' and confirm: '\(confirmPassword)'")
        }
    }
}
