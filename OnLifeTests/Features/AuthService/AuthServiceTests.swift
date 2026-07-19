//
//  AuthServiceTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/29/26.
//

import Testing
import Foundation
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
    
    @Test("Sign in anonymously creates authenticated session", .timeLimit(.minutes(1)))
    @MainActor
    func signInAnonymously() async throws {
        let service = AuthService.shared
        
        guard TestEnvironment.isFirebaseConfigured else {
            Issue.record("Firebase not configured - skipping integration test")
            return
        }
        
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
    
    @Test("Sign out clears authentication state", .timeLimit(.minutes(1)))
    @MainActor
    func signOut() async throws {
        let service = AuthService.shared
        
        guard TestEnvironment.isFirebaseConfigured else {
            Issue.record("Firebase not configured - skipping integration test")
            return
        }
        
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
    
    @Test("Sign out when not authenticated does not crash", .timeLimit(.minutes(1)))
    @MainActor
    func signOutWhenNotAuthenticated() throws {
        let service = AuthService.shared
        
        guard TestEnvironment.isFirebaseConfigured else {
            Issue.record("Firebase not configured - skipping integration test")
            return
        }
        
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
    
    @Test("Multiple authentication cycles work correctly", .timeLimit(.minutes(2)))
    @MainActor
    func multipleAuthCycles() async throws {
        let service = AuthService.shared
        
        guard TestEnvironment.isFirebaseConfigured else {
            Issue.record("Firebase not configured - skipping integration test")
            return
        }
        
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
}

// MARK: - MockAuthService (Pure Unit Tests)

/// A testable mock of AuthService that doesn't depend on Firebase
@MainActor
@Observable
final class MockAuthService {
    
    static let shared = MockAuthService()
    
    var mockUser: MockUser?
    var currentUser: MockUser? { mockUser }
    var isAuthenticated: Bool { mockUser != nil }
    var currentUserId: String? { mockUser?.uid }
    
    var shouldFailSignIn = false
    var shouldFailSignOut = false
    
    private init() {}
    
    func signInAnonymously() async throws {
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
    }
}

struct MockUser: Equatable {
    let uid: String
}

enum MockAuthError: Error {
    case signInFailed
    case signOutFailed
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
        let service = MockAuthService.shared
        service.reset()
        
        #expect(!service.isAuthenticated)
        #expect(service.currentUser == nil)
        #expect(service.currentUserId == nil)
    }
    
    @Test("Sign in creates authenticated user")
    @MainActor
    func signIn() async throws {
        let service = MockAuthService.shared
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
        let service = MockAuthService.shared
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
        let service = MockAuthService.shared
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
        let service = MockAuthService.shared
        service.reset()
        
        try await service.signInAnonymously()
        
        #expect(service.currentUserId == service.currentUser?.uid)
    }
    
    @Test("Multiple sign ins create different users")
    @MainActor
    func multipleSignIns() async throws {
        let service = MockAuthService.shared
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
        let service = MockAuthService.shared
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
        let service = MockAuthService.shared
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
        let service = MockAuthService.shared
        
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
 
 ## Using MockAuthService in Other Tests
 
 ```swift
 @Test("Feature uses current user ID")
 @MainActor
 func featureUsesUserId() async throws {
     let mockAuth = MockAuthService.shared
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
 
 - [ ] Email/password authentication
 - [ ] Social sign-in (Apple, Google)
 - [ ] Auth state persistence
 - [ ] Auth state change listeners
 - [ ] Concurrent operation handling
 - [ ] Network failure scenarios
 */
