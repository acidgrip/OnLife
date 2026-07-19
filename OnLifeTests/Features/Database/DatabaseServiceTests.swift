//
//  DatabaseServiceTests.swift
//  OnlifeTests
//
//  Example tests demonstrating the database abstraction layer
//  Created by Daniel Lee on 6/29/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("Database Service Tests")
struct DatabaseServiceTests {
    
    // MARK: - Post Tests
    
    @Test("Creating a post returns a post with ID")
    @MainActor
    func testCreatePost() async throws {
        let db = MockDatabaseService()
        
        let post = Post(
            userId: "user123",
            userName: "Test User",
            content: "Hello, world!"
        )
        
        let created = try await db.createPost(post)
        
        #expect(created.id.isEmpty == false)
        #expect(created.userId == post.userId)
        #expect(created.content == post.content)
        #expect(created.likeCount == 0)
        #expect(created.commentCount == 0)
    }
    
    @Test("Liking a post increases like count")
    @MainActor
    func testLikePost() async throws {
        let db = MockDatabaseService()
        
        // Create a post
        let post = try await db.createPost(Post(
            userId: "user1",
            userName: "User One",
            content: "Test content"
        ))
        
        // Like the post
        try await db.togglePostLike(
            postId: post.id,
            userId: "user2",
            isLiked: true
        )
        
        // Verify like count increased
        let updated = try await db.fetchPost(id: post.id)
        #expect(updated?.likeCount == 1)
    }
    
    @Test("Unliking a post decreases like count")
    @MainActor
    func testUnlikePost() async throws {
        let db = MockDatabaseService()
        
        // Create and like a post
        let post = try await db.createPost(Post(
            userId: "user1",
            userName: "User One",
            content: "Test content"
        ))
        try await db.togglePostLike(postId: post.id, userId: "user2", isLiked: true)
        
        // Unlike the post
        try await db.togglePostLike(postId: post.id, userId: "user2", isLiked: false)
        
        // Verify like count decreased
        let updated = try await db.fetchPost(id: post.id)
        #expect(updated?.likeCount == 0)
    }
    
    @Test("Deleting a post removes it from database")
    @MainActor
    func testDeletePost() async throws {
        let db = MockDatabaseService()
        
        let post = try await db.createPost(Post(
            userId: "user1",
            userName: "User One",
            content: "To be deleted"
        ))
        
        try await db.deletePost(id: post.id)
        
        let fetched = try await db.fetchPost(id: post.id)
        #expect(fetched == nil)
    }
    
    // MARK: - Event Tests
    
    @Test("Creating an event returns an event with ID")
    @MainActor
    func testCreateEvent() async throws {
        let db = MockDatabaseService()
        
        let event = Event(
            title: "Test Event",
            hostedBy: "Test Host",
            location: "Test Location",
            date: Date(),
            time: "6:00 PM"
        )
        
        let created = try await db.createEvent(event)
        
        #expect(created.id.isEmpty == false)
        #expect(created.title == event.title)
        #expect(created.attendeeCount == 0)
    }
    
    @Test("Joining an event increases attendee count")
    @MainActor
    func testJoinEvent() async throws {
        let db = MockDatabaseService()
        
        let event = try await db.createEvent(Event(
            title: "Test Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "6:00 PM"
        ))
        
        try await db.toggleEventJoin(
            eventId: event.id,
            userId: "user1",
            isJoined: true
        )
        
        let updated = try await db.fetchEvent(id: event.id)
        #expect(updated?.attendeeCount == 1)
    }
    
    @Test("Bookmarking an event works")
    @MainActor
    func testBookmarkEvent() async throws {
        let db = MockDatabaseService()
        
        let event = try await db.createEvent(Event(
            title: "Test Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "6:00 PM"
        ))
        
        // Should not throw
        try await db.toggleEventBookmark(
            eventId: event.id,
            userId: "user1",
            isBookmarked: true
        )
    }
    
    // MARK: - Feed Tests
    
    @Test("Fetching feed returns items")
    func testFetchFeed() async throws {
        let db = MockDatabaseService()
        
        let feed = try await db.fetchFeed(
            filter: .all,
            limit: 50,
            lastItemId: nil
        )
        
        #expect(feed.count > 0)
    }
    
    @Test("Feed filter for posts only")
    func testFetchPostsOnly() async throws {
        let db = MockDatabaseService()
        
        let feed = try await db.fetchFeed(
            filter: .posts,
            limit: 50,
            lastItemId: nil
        )
        
        for item in feed {
            if case .event = item {
                Issue.record("Feed should only contain posts")
            }
        }
    }
    
    @Test("Feed filter for events only")
    func testFetchEventsOnly() async throws {
        let db = MockDatabaseService()
        
        let feed = try await db.fetchFeed(
            filter: .events,
            limit: 50,
            lastItemId: nil
        )
        
        for item in feed {
            if case .post = item {
                Issue.record("Feed should only contain events")
            }
        }
    }
    
    // MARK: - Comment Tests
    
    @Test("Creating a comment increases comment count")
    @MainActor
    func testCreateComment() async throws {
        let db = MockDatabaseService()
        
        let post = try await db.createPost(Post(
            userId: "user1",
            userName: "User One",
            content: "Original post"
        ))
        
        let comment = Comment(
            postId: post.id,
            userId: "user2",
            userName: "User Two",
            content: "Great post!"
        )
        
        let created = try await db.createComment(for: post.id, comment: comment)
        
        #expect(created.id.isEmpty == false)
        #expect(created.content == comment.content)
        
        let updatedPost = try await db.fetchPost(id: post.id)
        #expect(updatedPost?.commentCount == 1)
    }
    
    @Test("Fetching comments for a post")
    @MainActor
    func testFetchComments() async throws {
        let db = MockDatabaseService()
        
        let post = try await db.createPost(Post(
            userId: "user1",
            userName: "User One",
            content: "Post with comments"
        ))
        
        // Add comments
        _ = try await db.createComment(for: post.id, comment: Comment(
            postId: post.id,
            userId: "user2",
            userName: "User Two",
            content: "Comment 1"
        ))
        
        _ = try await db.createComment(for: post.id, comment: Comment(
            postId: post.id,
            userId: "user3",
            userName: "User Three",
            content: "Comment 2"
        ))
        
        let comments = try await db.fetchComments(for: post.id)
        #expect(comments.count == 2)
    }
    
    // MARK: - User Operations Tests
    
    @Test("Updating user online status")
    func testUpdateOnlineStatus() async throws {
        let db = MockDatabaseService()
        
        // Should not throw
        try await db.updateUserOnlineStatus(userId: "user1", isOnline: true)
        try await db.updateUserOnlineStatus(userId: "user1", isOnline: false)
    }
    
    // MARK: - Image Upload Tests
    
    @Test("Uploading an image returns URL")
    func testImageUpload() async throws {
        let db = MockDatabaseService()
        
        let imageData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header
        let url = try await db.uploadImage(imageData: imageData, path: "test/image.png")
        
        #expect(url.isEmpty == false)
        #expect(url.contains("test/image.png"))
    }
    
    // MARK: - Performance Tests
    
    @Test("Mock database simulates delay")
    func testSimulatedDelay() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0.1
        
        let start = Date()
        _ = try await db.fetchFeed(filter: .all, limit: 10, lastItemId: nil)
        let duration = Date().timeIntervalSince(start)
        
        #expect(duration >= 0.1)
    }
    
    @Test("Zero delay for fast testing", .timeLimit(.minutes(1)))
    func testZeroDelay() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0
        
        let start = Date()
        _ = try await db.fetchFeed(filter: .all, limit: 10, lastItemId: nil)
        let duration = Date().timeIntervalSince(start)
        
        #expect(duration < 0.1)
    }
}

// MARK: - Integration Tests with ActivityFeedStore

@Suite("Activity Feed Store Integration")
struct ActivityFeedStoreIntegrationTests {
    
    @Test("Store can load feed from database")
    @MainActor
    func testStoreLoadsFeed() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0
        
        let store = ActivityFeedStore(database: db, autoLoad: false)
        
        await store.loadFeed()
        
        #expect(store.feedItems.count > 0)
        #expect(store.isLoading == false)
    }
    
    @Test("Store handles like post")
    @MainActor
    func testStoreLikePost() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0
        
        let store = ActivityFeedStore(database: db, autoLoad: false)
        await store.loadFeed()
        
        guard case .post(let post) = store.feedItems.first else {
            Issue.record("First item should be a post")
            return
        }
        
        let initialLikeCount = post.likeCount
        
        await store.likePost(post)
        
        guard case .post(let updatedPost) = store.feedItems.first else {
            Issue.record("First item should still be a post")
            return
        }
        
        #expect(updatedPost.likeCount != initialLikeCount)
    }
    
    @Test("Store handles join event")
    @MainActor
    func testStoreJoinEvent() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0
        
        let store = ActivityFeedStore(database: db, autoLoad: false)
        await store.loadFeed()
        
        // Find an event in the feed
        guard let eventItem = store.feedItems.first(where: {
            if case .event = $0 { return true }
            return false
        }), case .event(let event) = eventItem else {
            Issue.record("No event found in feed")
            return
        }
        
        let initialCount = event.attendeeCount
        
        await store.joinEvent(event)
        
        // Find the updated event
        guard let updatedItem = store.feedItems.first(where: {
            if case .event(let e) = $0, e.id == event.id { return true }
            return false
        }), case .event(let updatedEvent) = updatedItem else {
            Issue.record("Updated event not found")
            return
        }
        
        #expect(updatedEvent.attendeeCount != initialCount)
    }
    
    @Test("Store can create new post")
    @MainActor
    func testStoreCreatePost() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0
        
        let store = ActivityFeedStore(database: db, autoLoad: false)
        await store.loadFeed()
        
        let initialCount = store.feedItems.count
        
        await store.createPost(content: "Test post", location: "Test Location")
        
        #expect(store.feedItems.count == initialCount + 1)
        
        guard case .post(let newPost) = store.feedItems.first else {
            Issue.record("First item should be the new post")
            return
        }
        
        #expect(newPost.content == "Test post")
        #expect(newPost.userLocation == "Test Location")
    }
}
