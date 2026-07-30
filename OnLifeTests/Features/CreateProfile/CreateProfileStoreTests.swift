//
//  CreateProfileStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("Create Profile Store Tests")
struct CreateProfileStoreTests {

    // MARK: - Initialization Tests

    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())

        #expect(store.username.isEmpty)
        #expect(store.name.isEmpty)
        #expect(store.bio.isEmpty)
        #expect(store.email.isEmpty)
        #expect(store.password.isEmpty)
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
    }

    // MARK: - Username Validation Tests

    @Test("Username is invalid when too short")
    @MainActor
    func testUsernameTooShort() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.updateUsername("ab")

        #expect(!store.isUsernameValid)
        #expect(store.usernameValidationMessage == "Username must be at least 3 characters")
    }

    @Test("Username is invalid with special characters")
    @MainActor
    func testUsernameInvalidFormat() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.updateUsername("abc!def")

        #expect(!store.isUsernameValid)
        #expect(store.usernameValidationMessage != nil)
    }

    @Test("Username is lowercased")
    @MainActor
    func testUsernameLowercased() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.updateUsername("JaneDoe99")

        #expect(store.username == "janedoe99")
        #expect(store.isUsernameValid)
    }

    // MARK: - Name / Bio Validation Tests

    @Test("Name is invalid when too short")
    @MainActor
    func testNameTooShort() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.updateName("J")

        #expect(!store.isNameValid)
    }

    @Test("Bio is valid when empty (optional field)")
    @MainActor
    func testBioOptional() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())

        #expect(store.isBioValid)
    }

    // MARK: - Email / Password Validation Tests

    @Test("Email is invalid without an @ symbol")
    @MainActor
    func testEmailInvalid() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.email = "not-an-email"

        #expect(!store.isEmailValid)
    }

    @Test("Email is valid with a proper format")
    @MainActor
    func testEmailValid() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.email = "jane@example.com"

        #expect(store.isEmailValid)
    }

    @Test("Password is invalid when under 6 characters")
    @MainActor
    func testPasswordTooShort() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.password = "12345"

        #expect(!store.isPasswordValid)
        #expect(store.passwordValidationMessage == "Password must be at least 6 characters")
    }

    @Test("Password is valid at 6 characters")
    @MainActor
    func testPasswordValid() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.password = "123456"

        #expect(store.isPasswordValid)
    }

    // MARK: - Form Validation Tests

    @Test("Form is valid only when every field passes")
    @MainActor
    func testFormValidWhenAllFieldsValid() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.updateUsername("jane_doe")
        store.updateName("Jane Doe")
        store.email = "jane@example.com"
        store.password = "password123"

        #expect(store.isFormValid)
    }

    @Test("Form is invalid when password is missing")
    @MainActor
    func testFormInvalidMissingPassword() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.updateUsername("jane_doe")
        store.updateName("Jane Doe")
        store.email = "jane@example.com"

        #expect(!store.isFormValid)
    }

    // MARK: - Create Profile Tests

    @Test("Create profile links credentials and writes a profile built from session + form fields")
    @MainActor
    func testCreateProfileSuccess() async throws {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        try await mockAuth.verifyPhoneCode(verificationID: "any-id", code: "123456")

        let session = SignUpSession()
        session.phoneNumber = "+15551234567"
        session.dateOfBirth = Date(timeIntervalSince1970: 0)
        session.profilePhotoURL = "https://mock-storage.example.com/users/1/profile.jpg"

        let store = CreateProfileStore(session: session, database: MockDatabaseService(), authService: mockAuth)
        store.updateUsername("jane_doe")
        store.updateName("Jane Doe")
        store.updateBio("Hello!")
        store.email = "jane@example.com"
        store.password = "password123"

        await store.createProfile()

        #expect(!store.showError)
        #expect(store.showSuccess)
        #expect(mockAuth.lastLinkedEmail == "jane@example.com")
        mockAuth.reset()
    }

    @Test("Create profile normalizes a mixed-case email before linking, so sign-in is case-insensitive")
    @MainActor
    func testCreateProfileNormalizesEmailCase() async throws {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        try await mockAuth.verifyPhoneCode(verificationID: "any-id", code: "123456")

        let session = SignUpSession()
        session.phoneNumber = "+15551234567"
        session.dateOfBirth = Date(timeIntervalSince1970: 0)
        session.profilePhotoURL = "https://mock-storage.example.com/users/1/profile.jpg"

        let store = CreateProfileStore(session: session, database: MockDatabaseService(), authService: mockAuth)
        store.updateUsername("jane_doe")
        store.updateName("Jane Doe")
        store.email = "JaNe@ExAmPlE.CoM"
        store.password = "password123"

        await store.createProfile()

        #expect(!store.showError)
        #expect(store.showSuccess)
        #expect(mockAuth.lastLinkedEmail == "jane@example.com", "The credential linked with Firebase Auth should be normalized")
        mockAuth.reset()
    }

    @Test("Create profile fails when the form is invalid")
    @MainActor
    func testCreateProfileFailsInvalidForm() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService(), authService: mockAuth)
        // Fields left empty/invalid

        await store.createProfile()

        #expect(store.showError)
        #expect(!store.showSuccess)
        mockAuth.reset()
    }

    @Test("Create profile fails when linking credentials fails (no authenticated user)")
    @MainActor
    func testCreateProfileFailsWhenLinkFails() async {
        let mockAuth = MockAuthService()
        mockAuth.reset() // no user signed in, so linkEmailPassword throws
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService(), authService: mockAuth)
        store.updateUsername("jane_doe")
        store.updateName("Jane Doe")
        store.email = "jane@example.com"
        store.password = "password123"

        await store.createProfile()

        #expect(store.showError)
        #expect(!store.showSuccess)
    }

    // MARK: - Reset Tests

    @Test("Reset clears all fields")
    @MainActor
    func testReset() async {
        let store = CreateProfileStore(session: SignUpSession(), database: MockDatabaseService())
        store.updateUsername("jane_doe")
        store.updateName("Jane Doe")
        store.updateBio("Hi")
        store.email = "jane@example.com"
        store.password = "password123"
        store.showError = true
        store.showSuccess = true

        store.reset()

        #expect(store.username.isEmpty)
        #expect(store.name.isEmpty)
        #expect(store.bio.isEmpty)
        #expect(store.email.isEmpty)
        #expect(store.password.isEmpty)
        #expect(!store.showError)
        #expect(!store.showSuccess)
    }
}
