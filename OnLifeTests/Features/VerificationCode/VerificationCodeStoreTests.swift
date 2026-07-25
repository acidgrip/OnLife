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
        let store = VerificationCodeStore(authService: MockAuthService())

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
        let store = VerificationCodeStore(authService: MockAuthService())

        store.updateDigit(at: 0, with: "5")

        #expect(store.verificationCode[0] == "5")
    }

    @Test("Update digit only accepts single digit")
    @MainActor
    func testUpdateDigitSingleOnly() async {
        let store = VerificationCodeStore(authService: MockAuthService())

        store.updateDigit(at: 0, with: "123")

        #expect(store.verificationCode[0] == "1")
    }

    @Test("Update digit filters non-numeric characters")
    @MainActor
    func testUpdateDigitFiltersNonNumeric() async {
        let store = VerificationCodeStore(authService: MockAuthService())

        store.updateDigit(at: 0, with: "a5b")

        #expect(store.verificationCode[0] == "5")
    }

    @Test("Clear digit at valid index")
    @MainActor
    func testClearDigit() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.verificationCode[0] = "5"

        store.clearDigit(at: 0)

        #expect(store.verificationCode[0].isEmpty)
    }

    // MARK: - Form Validation Tests

    @Test("Form is invalid when not all digits entered")
    @MainActor
    func testFormInvalidIncomplete() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.verificationCode = ["1", "2", "3", "4", "5", ""]

        #expect(!store.isFormValid)
    }

    @Test("Form is valid when all digits entered")
    @MainActor
    func testFormValidComplete() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]

        #expect(store.isFormValid)
    }

    // MARK: - Verification Tests

    @Test("Verify code succeeds with valid 6-digit code and a pending verification ID")
    @MainActor
    func testVerifyCodeSuccess() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = VerificationCodeStore(authService: mockAuth)
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]

        let session = SignUpSession()
        session.verificationID = "mock-verification-id"

        await store.verifyCode(session: session)

        #expect(!store.showError)
        #expect(store.errorMessage == nil)
        #expect(store.showSuccess)
        #expect(!store.isLoading)
        #expect(mockAuth.isAuthenticated)
        mockAuth.reset()
    }

    @Test("Verify code fails with incomplete code")
    @MainActor
    func testVerifyCodeIncomplete() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.verificationCode = ["1", "2", "3", "", "", ""]

        let session = SignUpSession()
        session.verificationID = "mock-verification-id"

        await store.verifyCode(session: session)

        #expect(store.showError)
        #expect(store.errorMessage == "Please enter the complete 6-digit code")
        #expect(!store.showSuccess)
    }

    @Test("Verify code fails with non-numeric characters")
    @MainActor
    func testVerifyCodeNonNumeric() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.verificationCode = ["1", "2", "a", "4", "5", "6"]

        let session = SignUpSession()
        session.verificationID = "mock-verification-id"

        await store.verifyCode(session: session)

        #expect(store.showError)
        #expect(store.errorMessage == "Verification code must contain only numbers")
        #expect(!store.showSuccess)
    }

    @Test("Verify code fails when session has no verification ID")
    @MainActor
    func testVerifyCodeMissingVerificationID() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]

        let session = SignUpSession() // verificationID is nil

        await store.verifyCode(session: session)

        #expect(store.showError)
        #expect(!store.showSuccess)
    }

    @Test("Verify code surfaces backend failure")
    @MainActor
    func testVerifyCodeBackendFailure() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        mockAuth.shouldFailSignIn = true
        let store = VerificationCodeStore(authService: mockAuth)
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]

        let session = SignUpSession()
        session.verificationID = "mock-verification-id"

        await store.verifyCode(session: session)

        #expect(store.showError)
        #expect(!store.showSuccess)
        mockAuth.reset()
    }

    // MARK: - Resend Tests

    @Test("Cannot resend when countdown is active")
    @MainActor
    func testCannotResendDuringCountdown() async {
        let store = VerificationCodeStore(authService: MockAuthService())

        #expect(!store.canResend)
    }

    @Test("Resend code clears existing digits and stores a new verification ID")
    @MainActor
    func testResendCodeClearsDigits() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        mockAuth.mockVerificationID = "second-id"
        let store = VerificationCodeStore(authService: mockAuth)
        store.verificationCode = ["1", "2", "3", "4", "5", "6"]
        store.canResend = true

        let session = SignUpSession()
        session.phoneNumber = "1234567890"
        session.verificationID = "first-id"

        await store.resendCode(session: session)

        #expect(store.verificationCode.allSatisfy { $0.isEmpty })
        #expect(session.verificationID == "second-id")
        mockAuth.reset()
    }

    @Test("Resend code resets countdown")
    @MainActor
    func testResendCodeResetsCountdown() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = VerificationCodeStore(authService: mockAuth)
        store.resendCountdown = 0
        store.canResend = true

        let session = SignUpSession()
        session.phoneNumber = "1234567890"

        await store.resendCode(session: session)

        #expect(store.resendCountdown == 30)
        #expect(!store.canResend)
        mockAuth.reset()
    }

    @Test("Resend does nothing when not allowed")
    @MainActor
    func testResendDoesNothingWhenNotAllowed() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.canResend = false
        let originalCountdown = store.resendCountdown

        let session = SignUpSession()
        session.phoneNumber = "1234567890"

        await store.resendCode(session: session)

        #expect(store.resendCountdown == originalCountdown)
    }

    // MARK: - Countdown Formatting Tests

    @Test("Formatted countdown displays correctly for 30 seconds")
    @MainActor
    func testFormattedCountdown30Seconds() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.resendCountdown = 30

        #expect(store.formattedCountdown == "0:30")
    }

    @Test("Formatted countdown displays correctly for 90 seconds")
    @MainActor
    func testFormattedCountdown90Seconds() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.resendCountdown = 90

        #expect(store.formattedCountdown == "1:30")
    }

    // MARK: - Edge Cases

    @Test("Update digit replaces existing value")
    @MainActor
    func testUpdateDigitReplacesExisting() async {
        let store = VerificationCodeStore(authService: MockAuthService())
        store.verificationCode[0] = "5"

        store.updateDigit(at: 0, with: "9")

        #expect(store.verificationCode[0] == "9")
    }
}
