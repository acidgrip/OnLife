//
//  AuthServiceTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/29/26.
//

import Testing
import Foundation
import AuthenticationServices
@testable import OnLife
internal import FirebaseAuth

// MARK: - Real AuthService Tests (Integration with Firebase)

@Suite("AuthService Integration Tests", .tags(.integration))
struct AuthServiceTests {

    init() {
        // Ensure test environment is set up before running tests
        ensureTestSetup()
    }

    @Test("AuthService is a singleton")
    @MainActor
    func singletonPattern() {
        let instance1 = AuthService.shared
        let instance2 = AuthService.shared

        #expect(instance1 === instance2, "Both references should point to same instance")
    }

    @Test("Authentication state properties are consistent")
    @MainActor
    func stateConsistency() {
        let service = AuthService.shared

        // isAuthenticated should match currentUser state
        #expect(service.isAuthenticated == (service.currentUser != nil))

        // currentUserId should match currentUser state
        if service.currentUser != nil {
            #expect(service.currentUserId != nil)
        } else {
            #expect(service.currentUserId == nil)
        }
    }

    @Test("Sign in anonymously creates authenticated session", .timeLimit(.minutes(1)), .enabled(if: TestEnvironment.isFirebaseConfigured))
    @MainActor
    func signInAnonymously() async throws {
        let service = AuthService.shared

        do {
            try await service.signInAnonymously()

            // Verify authenticated state
            #expect(service.isAuthenticated, "User should be authenticated")
            #expect(service.currentUser != nil, "currentUser should be set")
            #expect(service.currentUserId != nil, "currentUserId should be set")
            #expect(service.currentUserId?.isEmpty == false, "currentUserId should not be empty")

            // Clean up
            try? service.signOut()
        } catch {
            Issue.record("Firebase error: \(error)")
        }
    }

    @Test("Sign out clears authentication state", .timeLimit(.minutes(1)), .enabled(if: TestEnvironment.isFirebaseConfigured))
    @MainActor
    func signOut() async throws {
        let service = AuthService.shared

        do {
            // First sign in
            try await service.signInAnonymously()
            #expect(service.isAuthenticated, "User should be authenticated after sign in")

            // Sign out
            try service.signOut()

            // Verify clean state
            #expect(!service.isAuthenticated, "User should not be authenticated")
            #expect(service.currentUser == nil, "currentUser should be nil")
            #expect(service.currentUserId == nil, "currentUserId should be nil")
        } catch {
            Issue.record("Firebase error: \(error)")
        }
    }

    @Test("Sign out when not authenticated does not crash", .timeLimit(.minutes(1)), .enabled(if: TestEnvironment.isFirebaseConfigured))
    @MainActor
    func signOutWhenNotAuthenticated() throws {
        let service = AuthService.shared

        do {
            // Ensure clean state
            try? service.signOut()

            // Sign out again - should not crash
            try service.signOut()

            #expect(!service.isAuthenticated)
        } catch {
            // Some errors may be thrown, but shouldn't crash
            Issue.record("Sign out error (acceptable): \(error)")
        }
    }

    @Test("Multiple authentication cycles work correctly", .timeLimit(.minutes(2)), .enabled(if: TestEnvironment.isFirebaseConfigured))
    @MainActor
    func multipleAuthCycles() async throws {
        let service = AuthService.shared

        do {
            // Cycle 1: Sign in
            try await service.signInAnonymously()
            let firstUserId = service.currentUserId
            #expect(firstUserId != nil)

            // Cycle 1: Sign out
            try service.signOut()
            #expect(service.currentUserId == nil)

            // Cycle 2: Sign in again
            try await service.signInAnonymously()
            let secondUserId = service.currentUserId
            #expect(secondUserId != nil)

            // Anonymous auth creates new users, so IDs should differ
            #expect(firstUserId != secondUserId, "Anonymous sign ins should create different users")

            // Clean up
            try? service.signOut()
        } catch {
            Issue.record("Firebase not configured: \(error)")
        }
    }

    @Test("Sign out clears isOnboarding", .enabled(if: TestEnvironment.isFirebaseConfigured))
    @MainActor
    func signOutClearsIsOnboarding() throws {
        let service = AuthService.shared

        service.isOnboarding = true
        try? service.signOut()

        #expect(!service.isOnboarding)
    }
}

// MARK: - MockAuthService (Pure Unit Tests)

/// A testable mock of AuthService that doesn't depend on Firebase
@MainActor
@Observable
final class MockAuthService: AuthServiceProtocol {

    static let shared = MockAuthService()

    var mockUser: MockUser?
    var currentUser: MockUser? { mockUser }
    var isAuthenticated: Bool { mockUser != nil }
    var currentUserId: String? { mockUser?.uid }

    /// Verification ID returned from `sendPhoneVerificationCode` -
    /// customizable so tests can assert it round-trips into `verifyPhoneCode`.
    var mockVerificationID = "mock-verification-id"
    /// The last email/password credential passed to `linkEmailPassword`,
    /// for tests to assert on.
    var lastLinkedEmail: String?
    var lastLinkedPassword: String?

    var shouldFailSignIn = false
    var shouldFailSignOut = false

    /// Not `private` so tests can construct their own isolated instance
    /// instead of sharing `.shared`'s mutable state across
    /// the whole test target - Swift Testing runs `@Test`s in parallel by
    /// default (with no cross-suite serialization mechanism), so a shared
    /// singleton mutated by many tests is a real source of order-dependent
    /// flakiness/failures. `.shared` is kept for call sites that intentionally
    /// want the single conventional instance.
    init() {}

    func signInAnonymously() async throws {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        mockUser = MockUser(uid: UUID().uuidString)
    }

    // MARK: - Email/Password Authentication

    func signIn(email: String, password: String) async throws {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        mockUser = MockUser(uid: UUID().uuidString)
    }

    func createAccount(email: String, password: String) async throws {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        mockUser = MockUser(uid: UUID().uuidString)
    }

    // MARK: - Phone Authentication

    func sendPhoneVerificationCode(phoneNumber: String) async throws -> String {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        try await Task.sleep(nanoseconds: 100_000_000)

        return mockVerificationID
    }

    func verifyPhoneCode(verificationID: String, code: String) async throws {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        try await Task.sleep(nanoseconds: 100_000_000)

        mockUser = MockUser(uid: UUID().uuidString)
    }

    func linkEmailPassword(email: String, password: String) async throws {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        guard mockUser != nil else {
            throw MockAuthError.notAuthenticated
        }

        try await Task.sleep(nanoseconds: 100_000_000)

        lastLinkedEmail = email
        lastLinkedPassword = password
    }

    // MARK: - Social Authentication

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        mockUser = MockUser(uid: UUID().uuidString)
    }

    func signInWithGoogle() async throws {
        if shouldFailSignIn {
            throw MockAuthError.signInFailed
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        mockUser = MockUser(uid: UUID().uuidString)
    }

    func signOut() throws {
        if shouldFailSignOut {
            throw MockAuthError.signOutFailed
        }
        mockUser = nil
    }

    func reset() {
        mockUser = nil
        shouldFailSignIn = false
        shouldFailSignOut = false
        mockVerificationID = "mock-verification-id"
        lastLinkedEmail = nil
        lastLinkedPassword = nil
    }
}

struct MockUser: Equatable {
    let uid: String
}

enum MockAuthError: Error {
    case signInFailed
    case signOutFailed
    case notAuthenticated
}

// MARK: - MockAuthService Unit Tests

@Suite("MockAuthService Unit Tests", .tags(.unit))
struct MockAuthServiceTests {

    init() {
        // Ensure test environment is set up
        ensureTestSetup()
    }

    @Test("MockAuthService starts with no user")
    @MainActor
    func initialization() {
        let service = MockAuthService()
        service.reset()

        #expect(!service.isAuthenticated)
        #expect(service.currentUser == nil)
        #expect(service.currentUserId == nil)
    }

    @Test("Sign in creates authenticated user")
    @MainActor
    func signIn() async throws {
        let service = MockAuthService()
        service.reset()

        try await service.signInAnonymously()

        #expect(service.isAuthenticated)
        #expect(service.currentUser != nil)
        #expect(service.currentUserId != nil)
        #expect(service.currentUserId?.isEmpty == false)
    }

    @Test("Sign out clears user")
    @MainActor
    func signOut() async throws {
        let service = MockAuthService()
        service.reset()

        // Sign in first
        try await service.signInAnonymously()
        #expect(service.isAuthenticated)

        // Then sign out
        try service.signOut()

        #expect(!service.isAuthenticated)
        #expect(service.currentUser == nil)
        #expect(service.currentUserId == nil)
    }

    @Test("isAuthenticated reflects currentUser state")
    @MainActor
    func isAuthenticatedReflectsState() async throws {
        let service = MockAuthService()
        service.reset()

        // Not authenticated initially
        #expect(!service.isAuthenticated)

        // Authenticated after sign in
        try await service.signInAnonymously()
        #expect(service.isAuthenticated)

        // Not authenticated after sign out
        try service.signOut()
        #expect(!service.isAuthenticated)
    }

    @Test("currentUserId matches user uid")
    @MainActor
    func currentUserIdMatchesUid() async throws {
        let service = MockAuthService()
        service.reset()

        try await service.signInAnonymously()

        #expect(service.currentUserId == service.currentUser?.uid)
    }

    @Test("Multiple sign ins create different users")
    @MainActor
    func multipleSignIns() async throws {
        let service = MockAuthService()
        service.reset()

        // First sign in
        try await service.signInAnonymously()
        let firstUserId = service.currentUserId

        // Sign out and sign in again
        try service.signOut()
        try await service.signInAnonymously()
        let secondUserId = service.currentUserId

        #expect(firstUserId != nil)
        #expect(secondUserId != nil)
        #expect(firstUserId != secondUserId, "Each sign in should create a new user")
    }

    @Test("Sign in failure throws error")
    @MainActor
    func signInFailure() async {
        let service = MockAuthService()
        service.reset()
        service.shouldFailSignIn = true

        await #expect(throws: MockAuthError.self) {
            try await service.signInAnonymously()
        }

        #expect(!service.isAuthenticated)

        // Clean up: reset the failure flag so it doesn't affect other tests
        service.reset()
    }

    @Test("Sign out failure throws error")
    @MainActor
    func signOutFailure() async throws {
        let service = MockAuthService()
        service.reset()

        try await service.signInAnonymously()
        service.shouldFailSignOut = true

        #expect(throws: MockAuthError.self) {
            try service.signOut()
        }

        // Clean up: reset the failure flag so it doesn't affect other tests
        service.reset()
    }

    @Test("Reset clears all state")
    @MainActor
    func reset() async throws {
        let service = MockAuthService()
        service.reset()

        // Set up some state
        try await service.signInAnonymously()
        service.shouldFailSignIn = true
        service.shouldFailSignOut = true

        // Reset
        service.reset()

        // Verify everything is clean
        #expect(!service.isAuthenticated)
        #expect(service.currentUser == nil)
        #expect(service.shouldFailSignIn == false)
        #expect(service.shouldFailSignOut == false)
    }

    @Test("Sending a phone verification code returns the mock verification ID")
    @MainActor
    func sendPhoneVerificationCodeReturnsID() async throws {
        let service = MockAuthService()
        service.reset()
        service.mockVerificationID = "test-id-123"

        let id = try await service.sendPhoneVerificationCode(phoneNumber: "+15551234567")

        #expect(id == "test-id-123")
        service.reset()
    }

    @Test("Verifying a phone code authenticates the user")
    @MainActor
    func verifyPhoneCodeAuthenticates() async throws {
        let service = MockAuthService()
        service.reset()

        #expect(!service.isAuthenticated)

        try await service.verifyPhoneCode(verificationID: "any-id", code: "123456")

        #expect(service.isAuthenticated)
        service.reset()
    }

    @Test("Linking email/password requires an authenticated user")
    @MainActor
    func linkEmailPasswordRequiresAuth() async {
        let service = MockAuthService()
        service.reset()

        await #expect(throws: MockAuthError.self) {
            try await service.linkEmailPassword(email: "jane@example.com", password: "password123")
        }

        service.reset()
    }

    @Test("Linking email/password records the credential once authenticated")
    @MainActor
    func linkEmailPasswordRecordsCredential() async throws {
        let service = MockAuthService()
        service.reset()

        try await service.verifyPhoneCode(verificationID: "any-id", code: "123456")
        try await service.linkEmailPassword(email: "jane@example.com", password: "password123")

        #expect(service.lastLinkedEmail == "jane@example.com")
        #expect(service.lastLinkedPassword == "password123")
        service.reset()
    }
}

// MARK: - Test Tags

extension Tag {
    @Tag static var integration: Self
    @Tag static var unit: Self
}

// MARK: - Documentation

/*
 # AuthService Test Suite

 ## Overview
 This test suite validates authentication functionality with two complementary approaches:

 ### 1. Integration Tests (`AuthServiceTests`)
 - Tests real `AuthService` with Firebase Auth
 - Tagged with `.integration`
 - May fail if Firebase is not configured
 - Run with Firebase Emulator in CI/CD

 ### 2. Unit Tests (`MockAuthServiceTests`)
 - Tests business logic with `MockAuthService`
 - Tagged with `.unit`
 - Fast, reliable, no external dependencies
 - Ideal for TDD and rapid feedback

 ## Running Tests

 ### All Tests
 ```
 ⌘U in Xcode
 ```

 ### Unit Tests Only
 ```bash
 swift test --filter MockAuthServiceTests
 ```

 ### Integration Tests Only (requires Firebase)
 ```bash
 swift test --filter AuthServiceTests
 ```

 ## Test Coverage

 ✅ Singleton pattern
 ✅ Authentication state consistency
 ✅ Anonymous sign in
 ✅ Sign out
 ✅ Error handling
 ✅ Multiple auth cycles
 ✅ Edge cases (sign out when not authenticated)
 ✅ Phone verification (send code / verify code)
 ✅ Email/password credential linking

 ## Using MockAuthService in Other Tests

 ```swift
 @Test("Feature uses current user ID")
 @MainActor
 func featureUsesUserId() async throws {
     let mockAuth = MockAuthService()
     mockAuth.reset()

     try await mockAuth.signInAnonymously()
     let userId = mockAuth.currentUserId

     // Test your feature with the user ID
     let feature = MyFeature(authService: mockAuth)
     // ... assertions

     // Clean up
     try mockAuth.signOut()
 }
 ```

 ## Best Practices

 1. **Always call `reset()`** before tests to ensure clean state
 2. **Use MockAuthService for unit tests** - fast and reliable
 3. **Use real AuthService for integration tests** - validates Firebase integration
 4. **Clean up after tests** with `signOut()` or `reset()`
 5. **Test error cases** to ensure robust error handling

 ## Future Enhancements

 - [ ] Auth state persistence
 - [ ] Auth state change listeners
 - [ ] Concurrent operation handling
 - [ ] Network failure scenarios
 */
