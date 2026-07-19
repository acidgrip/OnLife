//
//  SignUpStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
@testable import OnLife

@Suite("Sign Up Store Tests")
struct SignUpStoreTests {
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = SignUpStore()
        
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
    }
    
    // MARK: - Email Validation Tests
    
    @Test("Send verification code succeeds with valid email")
    @MainActor
    func testValidEmail() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "user@example.com")
        
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
        #expect(store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Send verification code succeeds with complex email")
    @MainActor
    func testComplexEmail() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "user.name+tag@example.co.uk")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code fails with invalid email format")
    @MainActor
    func testInvalidEmail() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "invalid-email")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    @Test("Send verification code fails with email missing @")
    @MainActor
    func testEmailMissingAt() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "userexample.com")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    @Test("Send verification code fails with email missing domain")
    @MainActor
    func testEmailMissingDomain() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "user@")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    // MARK: - Phone Number Validation Tests
    
    @Test("Send verification code succeeds with 10-digit phone")
    @MainActor
    func testValidPhoneTenDigits() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "1234567890")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code succeeds with formatted phone")
    @MainActor
    func testValidPhoneFormatted() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "123-456-7890")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code succeeds with phone including parentheses")
    @MainActor
    func testValidPhoneWithParentheses() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "(123) 456-7890")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code succeeds with international phone")
    @MainActor
    func testValidInternationalPhone() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "+1234567890")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code succeeds with phone with spaces")
    @MainActor
    func testValidPhoneWithSpaces() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "+1 234 567 8900")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code fails with phone too short")
    @MainActor
    func testPhoneTooShort() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "123456")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    @Test("Send verification code fails with phone too long")
    @MainActor
    func testPhoneTooLong() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "1234567890123456")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    // MARK: - Empty Input Tests
    
    @Test("Send verification code fails with empty input")
    @MainActor
    func testEmptyInput() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter an email address or phone number")
        #expect(!store.showSuccess)
    }
    
    @Test("Send verification code fails with whitespace only")
    @MainActor
    func testWhitespaceOnly() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "   ")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter an email address or phone number")
        #expect(!store.showSuccess)
    }
    
    @Test("Send verification code trims whitespace from valid email")
    @MainActor
    func testTrimsWhitespace() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "  user@example.com  ")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    // MARK: - Loading State Tests
    
    @Test("isLoading is false after successful send")
    @MainActor
    func testLoadingStateFalseAfterSuccess() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "user@example.com")
        
        #expect(!store.isLoading)
    }
    
    @Test("isLoading is false after validation failure")
    @MainActor
    func testLoadingStateFalseAfterValidationFailure() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "invalid")
        
        #expect(!store.isLoading)
    }
    
    // MARK: - Edge Cases
    
    @Test("Send verification code with email containing numbers")
    @MainActor
    func testEmailWithNumbers() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "user123@example.com")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code with email containing dots")
    @MainActor
    func testEmailWithDots() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "first.last@example.com")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code with email containing plus")
    @MainActor
    func testEmailWithPlus() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "user+tag@example.com")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code fails with special characters only")
    @MainActor
    func testSpecialCharactersOnly() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "!@#$%^&*()")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    @Test("Send verification code with exactly 10 digits succeeds")
    @MainActor
    func testExactlyTenDigits() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "1234567890")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code with exactly 15 digits succeeds")
    @MainActor
    func testExactlyFifteenDigits() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "123456789012345")
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Send verification code with 9 digits fails")
    @MainActor
    func testNineDigitsFails() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "123456789")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    @Test("Send verification code with 16 digits fails")
    @MainActor
    func testSixteenDigitsFails() async {
        let store = SignUpStore()
        
        await store.sendVerificationCode(to: "1234567890123456")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid email address or phone number")
        #expect(!store.showSuccess)
    }
    
    // MARK: - State Management Tests
    
    @Test("Error message clears on new valid attempt")
    @MainActor
    func testErrorMessageClears() async {
        let store = SignUpStore()
        
        // First attempt with error
        await store.sendVerificationCode(to: "invalid")
        #expect(store.showError)
        #expect(store.errorMessage != nil)
        
        // Reset error state
        store.showError = false
        store.errorMessage = nil
        
        // Second attempt with valid input
        await store.sendVerificationCode(to: "user@example.com")
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
    }
    
    @Test("Multiple verification attempts work correctly")
    @MainActor
    func testMultipleVerificationAttempts() async {
        let store = SignUpStore()
        
        // First attempt - should fail
        await store.sendVerificationCode(to: "")
        #expect(store.showError)
        
        // Reset state
        store.showError = false
        store.errorMessage = nil
        
        // Second attempt - should succeed
        await store.sendVerificationCode(to: "user@example.com")
        #expect(store.showSuccess)
        #expect(!store.showError)
    }
    
    @Test("Can send verification to different contacts")
    @MainActor
    func testDifferentContacts() async {
        let store = SignUpStore()
        
        // Send to email
        await store.sendVerificationCode(to: "user@example.com")
        #expect(store.showSuccess)
        
        // Reset state
        store.showSuccess = false
        
        // Send to phone
        await store.sendVerificationCode(to: "1234567890")
        #expect(store.showSuccess)
    }
    
    // MARK: - Real-world Scenarios
    
    @Test("Common email providers work correctly")
    @MainActor
    func testCommonEmailProviders() async {
        let store = SignUpStore()
        let emails = [
            "user@gmail.com",
            "user@yahoo.com",
            "user@outlook.com",
            "user@icloud.com",
            "user@protonmail.com"
        ]
        
        for email in emails {
            await store.sendVerificationCode(to: email)
            #expect(store.showSuccess, "Should succeed for \(email)")
            store.showSuccess = false
        }
    }
    
    @Test("Various phone formats work correctly")
    @MainActor
    func testVariousPhoneFormats() async {
        let store = SignUpStore()
        let phones = [
            "1234567890",
            "123-456-7890",
            "(123) 456-7890",
            "+1 (123) 456-7890",
            "+12345678901",
            "123.456.7890"
        ]
        
        for phone in phones {
            await store.sendVerificationCode(to: phone)
            #expect(store.showSuccess, "Should succeed for \(phone)")
            store.showSuccess = false
        }
    }
    
    @Test("Invalid inputs fail correctly")
    @MainActor
    func testInvalidInputsFail() async {
        let store = SignUpStore()
        let invalidInputs = [
            "",
            "   ",
            "not-an-email",
            "@example.com",
            "user@",
            "123",
            "abc",
            "!@#$"
        ]
        
        for input in invalidInputs {
            await store.sendVerificationCode(to: input)
            #expect(store.showError, "Should fail for '\(input)'")
            store.showError = false
            store.errorMessage = nil
        }
    }
}
