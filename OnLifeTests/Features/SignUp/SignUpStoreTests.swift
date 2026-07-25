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
        let store = SignUpStore(authService: MockAuthService())

        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
    }

    // MARK: - Phone Number Validation Tests

    @Test("Send verification code succeeds with 10-digit phone")
    @MainActor
    func testValidPhoneTenDigits() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "1234567890", session: session)

        #expect(!store.showError)
        #expect(store.showSuccess)
        #expect(session.phoneNumber == "1234567890")
        #expect(session.verificationID != nil)
    }

    @Test("Send verification code succeeds with formatted phone")
    @MainActor
    func testValidPhoneFormatted() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "123-456-7890", session: session)

        #expect(!store.showError)
        #expect(store.showSuccess)
    }

    @Test("Send verification code succeeds with international phone")
    @MainActor
    func testValidInternationalPhone() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "+1234567890", session: session)

        #expect(!store.showError)
        #expect(store.showSuccess)
    }

    @Test("Send verification code fails with phone too short")
    @MainActor
    func testPhoneTooShort() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "123456", session: session)

        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a valid phone number")
        #expect(!store.showSuccess)
        #expect(session.verificationID == nil)
    }

    @Test("Send verification code fails with phone too long")
    @MainActor
    func testPhoneTooLong() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "1234567890123456", session: session)

        #expect(store.showError)
        #expect(!store.showSuccess)
    }

    // MARK: - Empty Input Tests

    @Test("Send verification code fails with empty input")
    @MainActor
    func testEmptyInput() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "", session: session)

        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a phone number")
        #expect(!store.showSuccess)
    }

    @Test("Send verification code fails with whitespace only")
    @MainActor
    func testWhitespaceOnly() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "   ", session: session)

        #expect(store.showError)
        #expect(store.errorMessage == "Please enter a phone number")
        #expect(!store.showSuccess)
    }

    @Test("Send verification code trims whitespace from valid phone")
    @MainActor
    func testTrimsWhitespace() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "  1234567890  ", session: session)

        #expect(!store.showError)
        #expect(store.showSuccess)
        #expect(session.phoneNumber == "1234567890")
    }

    // MARK: - Loading State Tests

    @Test("isLoading is false after successful send")
    @MainActor
    func testLoadingStateFalseAfterSuccess() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "1234567890", session: session)

        #expect(!store.isLoading)
    }

    @Test("isLoading is false after validation failure")
    @MainActor
    func testLoadingStateFalseAfterValidationFailure() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "invalid", session: session)

        #expect(!store.isLoading)
    }

    // MARK: - Backend Failure Tests

    @Test("Send verification code surfaces backend failure")
    @MainActor
    func testBackendFailure() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        mockAuth.shouldFailSignIn = true
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "1234567890", session: session)

        #expect(store.showError)
        #expect(!store.showSuccess)
        #expect(session.verificationID == nil)
        mockAuth.reset()
    }

    // MARK: - Session Round-Trip Tests

    @Test("Verification ID from backend is stored on session")
    @MainActor
    func testVerificationIDStoredOnSession() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        mockAuth.mockVerificationID = "abc-123"
        let store = SignUpStore(authService: mockAuth)
        let session = SignUpSession()

        await store.sendVerificationCode(to: "1234567890", session: session)

        #expect(session.verificationID == "abc-123")
        mockAuth.reset()
    }
}
