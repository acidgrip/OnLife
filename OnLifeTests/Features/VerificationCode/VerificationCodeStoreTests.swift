//
//  VerificationCodeStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
@testable import OnLife

@Suite("Verification Code Store Tests")
struct VerificationCodeStoreTests {
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = VerificationCodeStore()
        
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
        #expect(store.verificationCode.count == 6)
        #expect(store.verificationCode.allSatisfy { $0.isEmpty })
        #expect(store.resendCountdown == 30)
        #expect(!store.canResend)
    }
    
    // MARK: - Digit Update Tests
    
    @Test("Update digit at valid index")
    @MainActor
    func testUpdateDigitAtValidIndex() async {
        let store = VerificationCodeStore()
        
        store.updateDigit(at: 0, with: "5")
        
        #expect(store.verificationCode[0] == "5")
    }
    
    @Test("Update digit only accepts single digit")
    @MainActor
    func testUpdateDigitSingleOnly() async {
        let store = VerificationCodeStore()
        
        store.updateDigit(at: 0, with: "123")
        
        #expect(store.verificationCode[0] == "1")
    }
    
    @Test("Update digit filters non-numeric characters")
    @MainActor
    func testUpdateDigitFiltersNonNumeric() async {
        let store = VerificationCodeStore()
        
        store.updateDigit(at: 0, with: "a5b")
        
        #expect(store.verificationCode[0] == "5")
    }
    
    @Test("Update digit at invalid index does nothing")
    @MainActor
    func testUpdateDigitAtInvalidIndex() async {
        let store = VerificationCodeStore()
        
        store.updateDigit(at: 10, with: "5")
        
        #expect(store.verificationCode.allSatisfy { $0.isEmpty })
    }
    
    @Test("Clear digit at valid index")
    @MainActor
    func testClearDigit() async {
        let store = VerificationCodeStore()
        store.verificationCode[0] = "5"
        
        store.clearDigit(at: 0)
        
        #expect(store.verificationCode[0].isEmpty)
    }
    
    // MARK: - Form Validation Tests
    
    @Test("Form is invalid when not all digits entered")
    @MainActor
    func testFormInvalidIncomplete() async {
        let store = VerificationCodeStore()
        store.verificationCode = ["1", "2", "3", "4", "5", ""]
        
        #expect(!store.isFormValid)
    }
    
    @Test("Form is valid when all digits entered")
    @MainActor
    func testFormValidComplete() async {
        let store = VerificationCodeStore()
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]
        
        #expect(store.isFormValid)
    }
    
    // MARK: - Verification Tests
    
    @Test("Verify code succeeds with valid 6-digit code")
    @MainActor
    func testVerifyCodeSuccess() async {
        let store = VerificationCodeStore()
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]
        
        await store.verifyCode(emailOrPhone: "test@example.com")
        
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
        #expect(store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Verify code fails with incomplete code")
    @MainActor
    func testVerifyCodeIncomplete() async {
        let store = VerificationCodeStore()
        store.verificationCode = ["1", "2", "3", "", "", ""]
        
        await store.verifyCode(emailOrPhone: "test@example.com")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please enter the complete 6-digit code")
        #expect(!store.showSuccess)
    }
    
    @Test("Verify code fails with non-numeric characters")
    @MainActor
    func testVerifyCodeNonNumeric() async {
        let store = VerificationCodeStore()
        store.verificationCode = ["1", "2", "a", "4", "5", "6"]
        
        await store.verifyCode(emailOrPhone: "test@example.com")
        
        #expect(store.showError)
        #expect(store.errorMessage == "Verification code must contain only numbers")
        #expect(!store.showSuccess)
    }
    
    // MARK: - Resend Tests
    
    @Test("Cannot resend when countdown is active")
    @MainActor
    func testCannotResendDuringCountdown() async {
        let store = VerificationCodeStore()
        
        #expect(!store.canResend)
    }
    
    @Test("Resend code clears existing digits")
    @MainActor
    func testResendCodeClearsDigits() async {
        let store = VerificationCodeStore()
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]
        store.canResend = true
        
        await store.resendCode(to: "test@example.com")
        
        #expect(store.verificationCode.allSatisfy { $0.isEmpty })
    }
    
    @Test("Resend code resets countdown")
    @MainActor
    func testResendCodeResetsCountdown() async {
        let store = VerificationCodeStore()
        store.resendCountdown = 0
        store.canResend = true
        
        await store.resendCode(to: "test@example.com")
        
        #expect(store.resendCountdown == 30)
        #expect(!store.canResend)
    }
    
    @Test("Resend does nothing when not allowed")
    @MainActor
    func testResendDoesNothingWhenNotAllowed() async {
        let store = VerificationCodeStore()
        store.canResend = false
        let originalCountdown = store.resendCountdown
        
        await store.resendCode(to: "test@example.com")
        
        #expect(store.resendCountdown == originalCountdown)
    }
    
    // MARK: - Countdown Formatting Tests
    
    @Test("Formatted countdown displays correctly for 30 seconds")
    @MainActor
    func testFormattedCountdown30Seconds() async {
        let store = VerificationCodeStore()
        store.resendCountdown = 30
        
        #expect(store.formattedCountdown == "0:30")
    }
    
    @Test("Formatted countdown displays correctly for 90 seconds")
    @MainActor
    func testFormattedCountdown90Seconds() async {
        let store = VerificationCodeStore()
        store.resendCountdown = 90
        
        #expect(store.formattedCountdown == "1:30")
    }
    
    @Test("Formatted countdown displays correctly for 5 seconds")
    @MainActor
    func testFormattedCountdown5Seconds() async {
        let store = VerificationCodeStore()
        store.resendCountdown = 5
        
        #expect(store.formattedCountdown == "0:05")
    }
    
    @Test("Formatted countdown displays correctly for 0 seconds")
    @MainActor
    func testFormattedCountdown0Seconds() async {
        let store = VerificationCodeStore()
        store.resendCountdown = 0
        
        #expect(store.formattedCountdown == "0:00")
    }
    
    // MARK: - Multiple Digit Updates
    
    @Test("Can update all digits sequentially")
    @MainActor
    func testUpdateAllDigits() async {
        let store = VerificationCodeStore()
        
        for i in 0..<6 {
            store.updateDigit(at: i, with: "\(i + 1)")
        }
        
        #expect(store.verificationCode == ["1", "2", "3", "4", "5", "6"])
        #expect(store.isFormValid)
    }
    
    @Test("Can clear all digits")
    @MainActor
    func testClearAllDigits() async {
        let store = VerificationCodeStore()
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]
        
        for i in 0..<6 {
            store.clearDigit(at: i)
        }
        
        #expect(store.verificationCode.allSatisfy { $0.isEmpty })
        #expect(!store.isFormValid)
    }
    
    // MARK: - Edge Cases
    
    @Test("Verify code with empty string digits")
    @MainActor
    func testVerifyCodeWithEmptyDigits() async {
        let store = VerificationCodeStore()
        // All digits are empty by default
        
        await store.verifyCode(emailOrPhone: "test@example.com")
        
        #expect(store.showError)
        #expect(!store.showSuccess)
    }
    
    @Test("Update digit replaces existing value")
    @MainActor
    func testUpdateDigitReplacesExisting() async {
        let store = VerificationCodeStore()
        store.verificationCode[0] = "5"
        
        store.updateDigit(at: 0, with: "9")
        
        #expect(store.verificationCode[0] == "9")
    }
}
