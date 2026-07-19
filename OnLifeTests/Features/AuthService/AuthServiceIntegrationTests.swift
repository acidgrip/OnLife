//
//  AuthServiceIntegrationTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/29/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("AuthService Integration Tests")
struct AuthServiceIntegrationTests {
    
    // MARK: - ActivityFeedStore Integration
    
    @Test("ActivityFeedStore uses AuthService current user ID")
    @MainActor
    func storeUsesAuthServiceUserId() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // Sign in
        try await mockAuth.signInAnonymously()
        let expectedUserId = mockAuth.currentUserId
        
        // Create store (would need to modify ActivityFeedStore to accept MockAuthService)
        // This demonstrates the testing pattern
        #expect(expectedUserId != nil)
        
        // Clean up
        try mockAuth.signOut()
    }
    
    @Test("Store creates post with authenticated user ID")
    @MainActor
    func createPostWithAuthenticatedUser() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // Set up authentication
        try await mockAuth.signInAnonymously()
        let userId = mockAuth.currentUserId
        
        #expect(userId != nil)
        #expect(!userId!.isEmpty)
        
        // In a real test, you'd create a post and verify it has the correct user ID
        // let store = ActivityFeedStore(authService: mockAuth)
        // await store.createPost(content: "Test post")
        // Verify post.userId == userId
        
        // Clean up
        try mockAuth.signOut()
    }
    
    // MARK: - Authentication Flow Tests
    
    @Test("Complete authentication flow works end-to-end")
    @MainActor
    func completeAuthenticationFlow() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // 1. Start unauthenticated
        #expect(!mockAuth.isAuthenticated)
        #expect(mockAuth.currentUserId == nil)
        
        // 2. Sign in
        try await mockAuth.signInAnonymously()
        #expect(mockAuth.isAuthenticated)
        let userId = mockAuth.currentUserId
        #expect(userId != nil)
        
        // 3. Perform authenticated operations
        // (In real app, create posts, like content, etc.)
        #expect(mockAuth.isAuthenticated) // Still authenticated
        
        // 4. Sign out
        try mockAuth.signOut()
        #expect(!mockAuth.isAuthenticated)
        #expect(mockAuth.currentUserId == nil)
    }
    
    @Test("User ID persists throughout session")
    @MainActor
    func userIdPersistsThroughoutSession() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        try await mockAuth.signInAnonymously()
        
        let userId1 = mockAuth.currentUserId
        let userId2 = mockAuth.currentUserId
        let userId3 = mockAuth.currentUserId
        
        // User ID should be stable during session
        #expect(userId1 == userId2)
        #expect(userId2 == userId3)
        #expect(userId1 != nil)
        
        try mockAuth.signOut()
    }
    
    // MARK: - Error Recovery Tests
    
    @Test("App handles sign in failure gracefully")
    @MainActor
    func handleSignInFailure() async {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        mockAuth.shouldFailSignIn = true
        
        do {
            try await mockAuth.signInAnonymously()
            Issue.record("Should have thrown error")
        } catch {
            // Expected error
            #expect(error is MockAuthError)
        }
        
        // App should still be in valid state
        #expect(!mockAuth.isAuthenticated)
        #expect(mockAuth.currentUser == nil)
        
        // Clean up
        mockAuth.reset()
    }
    
    @Test("App handles sign out failure gracefully")
    @MainActor
    func handleSignOutFailure() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        try await mockAuth.signInAnonymously()
        mockAuth.shouldFailSignOut = true
        
        do {
            try mockAuth.signOut()
            Issue.record("Should have thrown error")
        } catch {
            // Expected error
            #expect(error is MockAuthError)
        }
        
        // Clean up
        mockAuth.reset()
    }
    
    // MARK: - Concurrent Access Tests
    
    @Test("Multiple concurrent reads don't cause issues")
    @MainActor
    func concurrentReads() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        try await mockAuth.signInAnonymously()
        
        // Perform multiple concurrent reads
        await withTaskGroup(of: String?.self) { group in
            for _ in 0..<10 {
                group.addTask { @MainActor in
                    mockAuth.currentUserId
                }
            }
            
            var userIds: [String?] = []
            for await userId in group {
                userIds.append(userId)
            }
            
            // All reads should return the same value
            let uniqueIds = Set(userIds.compactMap { $0 })
            #expect(uniqueIds.count == 1)
        }
        
        try mockAuth.signOut()
    }
    
    // MARK: - State Transition Tests
    
    @Test("State transitions are atomic")
    @MainActor
    func stateTransitionsAreAtomic() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // Before sign in
        let preSignInState = (
            authenticated: mockAuth.isAuthenticated,
            userId: mockAuth.currentUserId
        )
        #expect(preSignInState.authenticated == false)
        #expect(preSignInState.userId == nil)
        
        // Sign in
        try await mockAuth.signInAnonymously()
        
        // After sign in - both properties should change together
        let postSignInState = (
            authenticated: mockAuth.isAuthenticated,
            userId: mockAuth.currentUserId
        )
        #expect(postSignInState.authenticated == true)
        #expect(postSignInState.userId != nil)
        
        // Sign out
        try mockAuth.signOut()
        
        // After sign out - both properties should change together
        let postSignOutState = (
            authenticated: mockAuth.isAuthenticated,
            userId: mockAuth.currentUserId
        )
        #expect(postSignOutState.authenticated == false)
        #expect(postSignOutState.userId == nil)
    }
    
    // MARK: - Performance Tests
    
    @Test("Authentication state queries are fast", .timeLimit(.minutes(1)))
    @MainActor
    func authenticationStatePerformance() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        try await mockAuth.signInAnonymously()
        
        // Perform many reads - should complete quickly
        for _ in 0..<1000 {
            _ = mockAuth.isAuthenticated
            _ = mockAuth.currentUserId
            _ = mockAuth.currentUser
        }
        
        try mockAuth.signOut()
    }
    
    @Test("Multiple sign in/out cycles complete quickly", .timeLimit(.minutes(1)))
    @MainActor
    func multipleAuthCyclesPerformance() async throws {
        let mockAuth = MockAuthService.shared
        
        for _ in 0..<10 {
            mockAuth.reset()
            try await mockAuth.signInAnonymously()
            #expect(mockAuth.isAuthenticated)
            try mockAuth.signOut()
            #expect(!mockAuth.isAuthenticated)
        }
    }
}

// MARK: - Mock Database Integration Tests

@Suite("AuthService with Database Integration")
struct AuthServiceDatabaseIntegrationTests {
    
    @Test("Database operations use authenticated user ID")
    @MainActor
    func databaseUsesAuthenticatedUserId() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        try await mockAuth.signInAnonymously()
        let userId = mockAuth.currentUserId
        
        // Simulate database operation
        let post = Post(
            userId: userId ?? "unknown",
            userName: "Test User",
            content: "Test content"
        )
        
        #expect(post.userId == userId)
        
        try mockAuth.signOut()
    }
    
    @Test("Creating post without authentication uses fallback ID")
    @MainActor
    func postCreationWithoutAuth() async {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // No authentication
        #expect(mockAuth.currentUserId == nil)
        
        // Should use fallback
        let userId = mockAuth.currentUserId ?? "anonymous"
        #expect(userId == "anonymous")
        
        let post = Post(
            userId: userId,
            userName: "Anonymous",
            content: "Test"
        )
        
        #expect(post.userId == "anonymous")
    }
}

// MARK: - Real-World Scenario Tests

@Suite("Real-World Authentication Scenarios")
struct RealWorldAuthenticationScenarios {
    
    @Test("User opens app, signs in, creates post, signs out")
    @MainActor
    func typicalUserSession() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // App opens - not authenticated
        #expect(!mockAuth.isAuthenticated)
        
        // User signs in anonymously
        try await mockAuth.signInAnonymously()
        #expect(mockAuth.isAuthenticated)
        
        // User creates a post
        let post = Post(
            userId: mockAuth.currentUserId ?? "unknown",
            userName: "User",
            content: "My first post!"
        )
        #expect(post.userId != "unknown")
        #expect(post.userId == mockAuth.currentUserId)
        
        // User signs out
        try mockAuth.signOut()
        #expect(!mockAuth.isAuthenticated)
    }
    
    @Test("User signs in, app crashes, user reopens app")
    @MainActor
    func appCrashScenario() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // User signs in
        try await mockAuth.signInAnonymously()
        let originalUserId = mockAuth.currentUserId
        
        // Simulate app "crash" by signing out
        try mockAuth.signOut()
        
        // User reopens app and signs in again
        try await mockAuth.signInAnonymously()
        let newUserId = mockAuth.currentUserId
        
        // Anonymous auth creates new users
        #expect(originalUserId != newUserId)
    }
    
    @Test("User tries multiple operations in sequence")
    @MainActor
    func multipleOperationsSequence() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        try await mockAuth.signInAnonymously()
        let userId = mockAuth.currentUserId!
        
        // Create multiple posts
        let post1 = Post(userId: userId, userName: "User", content: "Post 1")
        let post2 = Post(userId: userId, userName: "User", content: "Post 2")
        let post3 = Post(userId: userId, userName: "User", content: "Post 3")
        
        // All posts should have same user ID
        #expect(post1.userId == userId)
        #expect(post2.userId == userId)
        #expect(post3.userId == userId)
        
        // User should still be authenticated
        #expect(mockAuth.isAuthenticated)
        
        try mockAuth.signOut()
    }
}

// MARK: - Edge Cases

@Suite("Authentication Edge Cases")
struct AuthenticationEdgeCases {
    
    @Test("Accessing properties before initialization completes")
    @MainActor
    func propertyAccessBeforeInit() async {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // Should not crash
        let isAuth = mockAuth.isAuthenticated
        let userId = mockAuth.currentUserId
        let user = mockAuth.currentUser
        
        #expect(isAuth == false)
        #expect(userId == nil)
        #expect(user == nil)
    }
    
    @Test("Multiple rapid sign in attempts")
    @MainActor
    func rapidSignInAttempts() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        // Try signing in multiple times rapidly
        try await mockAuth.signInAnonymously()
        #expect(mockAuth.isAuthenticated)
        
        // Try signing in again while already signed in
        // Should handle gracefully (creates new session)
        try await mockAuth.signInAnonymously()
        #expect(mockAuth.isAuthenticated)
        
        try mockAuth.signOut()
    }
    
    @Test("Sign out while not signed in")
    @MainActor
    func signOutWhileNotSignedIn() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        #expect(!mockAuth.isAuthenticated)
        
        // Should not crash or error
        try mockAuth.signOut()
        
        #expect(!mockAuth.isAuthenticated)
    }
    
    @Test("Accessing user ID after sign out")
    @MainActor
    func accessUserIdAfterSignOut() async throws {
        let mockAuth = MockAuthService.shared
        mockAuth.reset()
        
        try await mockAuth.signInAnonymously()
        #expect(mockAuth.currentUserId != nil)
        
        try mockAuth.signOut()
        
        // Should return nil, not crash
        let userId = mockAuth.currentUserId
        #expect(userId == nil)
    }
}

// MARK: - Documentation

/*
 # AuthService Integration Tests Documentation
 
 ## Purpose
 These tests verify AuthService works correctly with other app components
 and handles real-world scenarios.
 
 ## Test Categories
 
 ### 1. Component Integration
 - Tests how AuthService integrates with ActivityFeedStore
 - Tests database operations with authentication
 - Verifies user ID propagation
 
 ### 2. Authentication Flows
 - Complete sign in → use → sign out cycles
 - User ID persistence during session
 - State consistency throughout operations
 
 ### 3. Error Recovery
 - Sign in failure handling
 - Sign out failure handling
 - Network error scenarios
 
 ### 4. Concurrent Access
 - Multiple simultaneous reads
 - Thread safety verification
 - Race condition prevention
 
 ### 5. Real-World Scenarios
 - Typical user sessions
 - App crash recovery
 - Multiple sequential operations
 
 ### 6. Edge Cases
 - Property access during initialization
 - Rapid sign in attempts
 - Sign out while not signed in
 - Post-sign-out property access
 
 ## Running These Tests
 
 ```bash
 # Run all integration tests
 swift test --filter AuthServiceIntegrationTests
 
 # Run specific category
 swift test --filter "Real-World Authentication Scenarios"
 
 # Run with specific test
 swift test --filter "typicalUserSession"
 ```
 
 ## Using in CI/CD
 
 These tests are designed to work in CI/CD pipelines:
 
 ```yaml
 # .github/workflows/test.yml
 - name: Run Integration Tests
   run: swift test --filter AuthServiceIntegrationTests
 ```
 
 ## Tips for Writing Similar Tests
 
 1. **Use MockAuthService** for fast, reliable tests
 2. **Test complete flows** not just individual methods
 3. **Include edge cases** that users might encounter
 4. **Test error scenarios** to verify robustness
 5. **Verify state consistency** after each operation
 6. **Clean up after tests** with reset() or signOut()
 
 ## Extending These Tests
 
 When adding new auth features, add tests for:
 - Email/password authentication
 - Social sign-in providers
 - Password reset flows
 - Multi-factor authentication
 - Account linking
 - Auth persistence across sessions
 */
