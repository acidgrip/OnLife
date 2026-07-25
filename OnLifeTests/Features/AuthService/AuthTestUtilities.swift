//
//  AuthTestUtilities.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/29/26.
//

import Foundation
import Testing
@testable import OnLife

// MARK: - Test Utilities

/// Utilities for testing authentication-related functionality
enum AuthTestUtilities {
    
    /// Creates a test user with predictable data
    static func createTestUser(id: String = "test-user-123") -> MockUser {
        return MockUser(uid: id)
    }
    
    /// Creates multiple test users for batch testing
    static func createTestUsers(count: Int) -> [MockUser] {
        return (0..<count).map { MockUser(uid: "test-user-\($0)") }
    }
    
    /// Ensures clean authentication state before tests
    @MainActor
    static func cleanAuthState() async {
        let mockAuth = MockAuthService()
        mockAuth.reset()
    }
    
    /// Signs in with a predictable test user
    @MainActor
    static func signInTestUser(userId: String = "test-user") async throws -> MockUser {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        try await mockAuth.signInAnonymously()
        return MockUser(uid: userId)
    }
}

// MARK: - Test Data Builders

/// Builder pattern for creating test posts with authentication context
struct TestPostBuilder {
    private var userId: String = "test-user"
    private var userName: String = "Test User"
    private var content: String = "Test content"
    private var location: String? = nil
    private var likeCount: Int = 0
    private var commentCount: Int = 0
    private var isLiked: Bool = false
    
    func withUserId(_ id: String) -> Self {
        var copy = self
        copy.userId = id
        return copy
    }
    
    func withUserName(_ name: String) -> Self {
        var copy = self
        copy.userName = name
        return copy
    }
    
    func withContent(_ text: String) -> Self {
        var copy = self
        copy.content = text
        return copy
    }
    
    func withLocation(_ loc: String) -> Self {
        var copy = self
        copy.location = loc
        return copy
    }
    
    func withLikes(_ count: Int) -> Self {
        var copy = self
        copy.likeCount = count
        return copy
    }
    
    func liked() -> Self {
        var copy = self
        copy.isLiked = true
        return copy
    }
    
    func build() -> Post {
        return Post(
            userId: userId,
            userName: userName,
            userLocation: location,
            content: content,
            likeCount: likeCount,
            commentCount: commentCount,
            isLiked: isLiked
        )
    }
}

// MARK: - Authentication Assertions

/// Custom assertions for authentication testing
enum AuthAssertions {
    
    /// Asserts that a user is authenticated
    @MainActor
    static func assertAuthenticated(
        _ mockAuth: MockAuthService,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockAuth.isAuthenticated, "Expected user to be authenticated", sourceLocation: sourceLocation)
        #expect(mockAuth.currentUser != nil, "Expected currentUser to be set", sourceLocation: sourceLocation)
        #expect(mockAuth.currentUserId != nil, "Expected currentUserId to be set", sourceLocation: sourceLocation)
    }
    
    /// Asserts that no user is authenticated
    @MainActor
    static func assertNotAuthenticated(
        _ mockAuth: MockAuthService,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(!mockAuth.isAuthenticated, "Expected user to NOT be authenticated", sourceLocation: sourceLocation)
        #expect(mockAuth.currentUser == nil, "Expected currentUser to be nil", sourceLocation: sourceLocation)
        #expect(mockAuth.currentUserId == nil, "Expected currentUserId to be nil", sourceLocation: sourceLocation)
    }
    
    /// Asserts that a user ID is valid (not empty, not default values)
    static func assertValidUserId(
        _ userId: String?,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(userId != nil, "Expected userId to be non-nil", sourceLocation: sourceLocation)
        #expect(userId?.isEmpty == false, "Expected userId to be non-empty", sourceLocation: sourceLocation)
        #expect(userId != "anonymous", "Expected userId to not be default value", sourceLocation: sourceLocation)
        #expect(userId != "unknown", "Expected userId to not be default value", sourceLocation: sourceLocation)
    }
}

// MARK: - Test Fixtures

/// Provides consistent test data for authentication tests
enum AuthTestFixtures {
    
    /// Sample user IDs for testing
    static let sampleUserIds = [
        "user-1",
        "user-2",
        "user-3",
        "user-abc-123",
        "user-xyz-789"
    ]
    
    /// Sample user names
    static let sampleUserNames = [
        "Alice Johnson",
        "Bob Smith",
        "Carol Williams",
        "David Brown",
        "Eve Davis"
    ]
    
    /// Creates a sample post with authenticated user
    static func samplePost(userId: String) -> Post {
        return Post(
            userId: userId,
            userName: sampleUserNames.randomElement() ?? "Test User",
            userLocation: "Test Location",
            content: "This is a test post",
            likeCount: Int.random(in: 0...100),
            commentCount: Int.random(in: 0...50),
            isLiked: Bool.random()
        )
    }
    
    /// Creates multiple sample posts for a user
    static func samplePosts(userId: String, count: Int) -> [Post] {
        return (0..<count).map { index in
            Post(
                userId: userId,
                userName: sampleUserNames[index % sampleUserNames.count],
                userLocation: "Location \(index)",
                content: "Test post \(index)",
                likeCount: index * 5,
                commentCount: index * 2,
                isLiked: index % 2 == 0
            )
        }
    }
}

// MARK: - Mock Auth State Manager

/// Manages mock authentication state for complex test scenarios
@MainActor
class AuthTestStateManager {
    
    private let mockAuth = MockAuthService()
    
    /// Signs in and returns the user ID
    func signIn() async throws -> String {
        mockAuth.reset()
        try await mockAuth.signInAnonymously()
        return mockAuth.currentUserId ?? "unknown"
    }
    
    /// Signs out and verifies clean state
    func signOut() throws {
        try mockAuth.signOut()
        assert(!mockAuth.isAuthenticated)
        assert(mockAuth.currentUserId == nil)
    }
    
    /// Performs an operation within an authenticated context
    func withAuthenticatedUser<T>(_ operation: (String) async throws -> T) async throws -> T {
        let userId = try await signIn()
        defer { try? signOut() }
        return try await operation(userId)
    }
    
    /// Simulates a sign in failure
    func simulateSignInFailure() {
        mockAuth.shouldFailSignIn = true
    }
    
    /// Simulates a sign out failure
    func simulateSignOutFailure() {
        mockAuth.shouldFailSignOut = true
    }
    
    /// Resets all mock state
    func reset() {
        mockAuth.reset()
    }
}

// MARK: - Example Usage Tests

@Suite("Test Utilities Usage Examples")
struct TestUtilitiesExamples {
    
    @Test("Using TestPostBuilder")
    func testPostBuilder() async {
        let post = TestPostBuilder()
            .withUserId("user-123")
            .withUserName("Alice")
            .withContent("Hello world!")
            .withLocation("San Francisco")
            .withLikes(42)
            .liked()
            .build()
        
        #expect(post.userId == "user-123")
        #expect(post.userName == "Alice")
        #expect(post.content == "Hello world!")
        #expect(post.userLocation == "San Francisco")
        #expect(post.likeCount == 42)
        #expect(post.isLiked == true)
    }
    
    @Test("Using AuthAssertions")
    @MainActor
    func testAuthAssertions() async throws {
        // Run directly on MainActor rather than wrapping in a detached
        // `Task` inside `MainActor.run` - the previous version's inner
        // `Task { @MainActor in ... }` was never awaited, so this test
        // function could return (and be reported as passed) before its own
        // assertions had even run, and any thrown error inside that Task
        // was silently discarded instead of failing the test.
        let mockAuth = MockAuthService()

        await AuthTestUtilities.cleanAuthState()

        // Assert not authenticated
        AuthAssertions.assertNotAuthenticated(mockAuth)

        // Sign in
        try await mockAuth.signInAnonymously()

        // Assert authenticated
        AuthAssertions.assertAuthenticated(mockAuth)

        // Validate user ID
        AuthAssertions.assertValidUserId(mockAuth.currentUserId)

        // Clean up
        try mockAuth.signOut()
    }

    @Test("Using AuthTestStateManager")
    @MainActor
    func testAuthStateManager() async throws {
        // Run directly on MainActor - see `testAuthAssertions` above for why
        // the previous detached-`Task`-inside-`MainActor.run` pattern was
        // unsafe (assertions could run after the test already finished, and
        // thrown errors were silently swallowed).
        let stateManager = AuthTestStateManager()

        // Perform operation with authenticated user
        let result = try await stateManager.withAuthenticatedUser { userId in
            // Inside this block, user is authenticated
            return "Operation completed for \(userId)"
        }

        // After block, user is automatically signed out
        #expect(result.contains("Operation completed"))
    }
    
    @Test("Using test fixtures")
    func testFixtures() async {
        let userId = "test-user"
        
        // Create sample posts
        let posts = AuthTestFixtures.samplePosts(userId: userId, count: 5)
        
        #expect(posts.count == 5)
        #expect(posts.allSatisfy { $0.userId == userId })
    }
    
    @Test("Creating test users")
    func testUserCreation() async {
        // Single user
        let user = AuthTestUtilities.createTestUser()
        #expect(user.uid == "test-user-123")
        
        // Multiple users
        let users = AuthTestUtilities.createTestUsers(count: 3)
        #expect(users.count == 3)
        #expect(users[0].uid == "test-user-0")
        #expect(users[1].uid == "test-user-1")
        #expect(users[2].uid == "test-user-2")
    }
}

// MARK: - Performance Test Helpers

/// Helpers for measuring authentication performance
enum AuthPerformanceHelpers {
    
    /// Measures time for a sign in operation
    @MainActor
    static func measureSignIn() async throws -> TimeInterval {
        let start = Date()
        
        let mockAuth = MockAuthService()
        mockAuth.reset()
        try await mockAuth.signInAnonymously()
        try mockAuth.signOut()
        
        return Date().timeIntervalSince(start)
    }
    
    /// Measures time for multiple sign in/out cycles
    @MainActor
    static func measureMultipleAuthCycles(count: Int) async throws -> TimeInterval {
        let start = Date()
        
        let mockAuth = MockAuthService()
        
        for _ in 0..<count {
            mockAuth.reset()
            try await mockAuth.signInAnonymously()
            try mockAuth.signOut()
        }
        
        return Date().timeIntervalSince(start)
    }
}

// MARK: - Debug Helpers

#if DEBUG
/// Helpers for debugging authentication tests
enum AuthDebugHelpers {
    
    /// Prints current authentication state
    @MainActor
    static func printAuthState(_ mockAuth: MockAuthService) {
        print("""
        🔐 Authentication State:
        - Authenticated: \(mockAuth.isAuthenticated)
        - User ID: \(mockAuth.currentUserId ?? "nil")
        - User: \(mockAuth.currentUser != nil ? "exists" : "nil")
        """)
    }
    
    /// Prints a post's authentication context
    static func printPostAuthContext(_ post: Post) {
        print("""
        📝 Post Authentication Context:
        - User ID: \(post.userId)
        - User Name: \(post.userName)
        - Content: \(post.content.prefix(50))...
        """)
    }
}
#endif

// MARK: - Documentation

/*
 # Authentication Test Utilities Documentation
 
 ## Overview
 This file provides utilities to make authentication testing easier and more consistent.
 
 ## Components
 
 ### AuthTestUtilities
 Basic utilities for common test operations:
 - Clean state management
 - Test user creation
 - Batch operations
 
 ### TestPostBuilder
 Fluent API for building test posts:
 ```swift
 let post = TestPostBuilder()
     .withUserId("123")
     .withContent("Test")
     .liked()
     .build()
 ```
 
 ### AuthAssertions
 Semantic assertions for authentication state:
 ```swift
 AuthAssertions.assertAuthenticated(mockAuth)
 AuthAssertions.assertValidUserId(userId)
 ```
 
 ### AuthTestFixtures
 Consistent test data:
 ```swift
 let posts = AuthTestFixtures.samplePosts(userId: "123", count: 10)
 ```
 
 ### AuthTestStateManager
 High-level auth state management:
 ```swift
 try await stateManager.withAuthenticatedUser { userId in
     // Your test code with authenticated user
 }
 ```
 
 ## Usage Examples
 
 See the `TestUtilitiesExamples` suite for complete examples.
 
 ## Best Practices
 
 1. **Always clean state** before tests with `AuthTestUtilities.cleanAuthState()`
 2. **Use builders** for complex object creation
 3. **Use semantic assertions** instead of raw expects
 4. **Use fixtures** for consistent test data
 5. **Clean up after tests** with sign out or reset
 
 ## Extending
 
 When adding new auth features:
 1. Add utilities to `AuthTestUtilities`
 2. Add assertions to `AuthAssertions`
 3. Add fixtures to `AuthTestFixtures`
 4. Update examples in `TestUtilitiesExamples`
 */
