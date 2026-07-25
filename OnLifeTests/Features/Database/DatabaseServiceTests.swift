//
//  DatabaseServiceTests.swift
//  OnlifeTests
//
//  Example tests demonstrating the database abstraction layer
//  Created by Daniel Lee on 6/29/26.
//

import Testing
import Foundation
import CoreLocation
@testable import OnLife

@Suite("Database Service Tests")
struct DatabaseServiceTests {

    // MARK: - Proximity Filtering Tests

    // Downtown LA, close to the coordinates MockDatabaseService seeds its
    // mock posts/event at (a few km away from each other).
    private let laOrigin = CLLocationCoordinate2D(latitude: 34.0407, longitude: -118.2468)
    // Far enough from LA that no reasonable "nearby" radius would include it.
    private let nycCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

    @Test("fetchFeed near a coordinate excludes items far outside the radius")
    @MainActor
    func testFetchFeedExcludesFarAwayItems() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0

        let farPost = try await db.createPost(Post(
            userId: "nyc-user",
            userName: "NYC User",
            latitude: nycCoordinate.latitude,
            longitude: nycCoordinate.longitude,
            content: "Posting from NYC"
        ))

        let feed = try await db.fetchFeed(
            filter: .all,
            limit: 50,
            lastItemId: nil,
            near: laOrigin,
            radiusInKm: 20
        )

        let containsFarPost = feed.contains { item in
            if case .post(let post) = item { return post.id == farPost.id }
            return false
        }
        #expect(!containsFarPost)
        // The seeded LA-area mock posts/event should still be included.
        #expect(feed.count > 0)
    }

    @Test("fetchFeed near a coordinate includes items within the radius")
    @MainActor
    func testFetchFeedIncludesNearbyItems() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0

        let nearbyCoordinate = CLLocationCoordinate2D(latitude: 34.0420, longitude: -118.2460)
        let nearbyPost = try await db.createPost(Post(
            userId: "la-user",
            userName: "LA User",
            latitude: nearbyCoordinate.latitude,
            longitude: nearbyCoordinate.longitude,
            content: "Posting from downtown LA"
        ))

        let feed = try await db.fetchFeed(
            filter: .all,
            limit: 50,
            lastItemId: nil,
            near: laOrigin,
            radiusInKm: 20
        )

        let containsNearbyPost = feed.contains { item in
            if case .post(let post) = item { return post.id == nearbyPost.id }
            return false
        }
        #expect(containsNearbyPost)
    }

    @Test("fetchFeed near a coordinate excludes items with no known location")
    @MainActor
    func testFetchFeedExcludesItemsWithoutCoordinates() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0

        let noLocationPost = try await db.createPost(Post(
            userId: "unknown-location-user",
            userName: "Unknown Location User",
            content: "No coordinates attached"
        ))

        let feed = try await db.fetchFeed(
            filter: .all,
            limit: 50,
            lastItemId: nil,
            near: laOrigin,
            radiusInKm: 20
        )

        let containsPost = feed.contains { item in
            if case .post(let post) = item { return post.id == noLocationPost.id }
            return false
        }
        #expect(!containsPost)
    }

    @Test("fetchFeed with no coordinate returns items regardless of location")
    @MainActor
    func testFetchFeedWithNoCoordinateIsUnfiltered() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0

        let farPost = try await db.createPost(Post(
            userId: "nyc-user",
            userName: "NYC User",
            latitude: nycCoordinate.latitude,
            longitude: nycCoordinate.longitude,
            content: "Posting from NYC"
        ))

        let feed = try await db.fetchFeed(
            filter: .all,
            limit: 50,
            lastItemId: nil,
            near: nil,
            radiusInKm: nil
        )

        let containsFarPost = feed.contains { item in
            if case .post(let post) = item { return post.id == farPost.id }
            return false
        }
        #expect(containsFarPost)
    }

    @Test("fetchNearbyEvents filters by real distance")
    @MainActor
    func testFetchNearbyEventsFiltersByRealDistance() async throws {
        let db = MockDatabaseService()
        db.simulatedDelay = 0

        let nearbyCoordinate = CLLocationCoordinate2D(latitude: 34.0420, longitude: -118.2460)
        let nearbyEvent = try await db.createEvent(Event(
            title: "Nearby Meetup",
            hostedBy: "Local Host",
            location: "Downtown LA",
            latitude: nearbyCoordinate.latitude,
            longitude: nearbyCoordinate.longitude,
            date: Date(),
            time: "6:00 PM"
        ))

        let farEvent = try await db.createEvent(Event(
            title: "NYC Meetup",
            hostedBy: "East Coast Host",
            location: "NYC",
            latitude: nycCoordinate.latitude,
            longitude: nycCoordinate.longitude,
            date: Date(),
            time: "6:00 PM"
        ))

        let nearby = try await db.fetchNearbyEvents(
            latitude: laOrigin.latitude,
            longitude: laOrigin.longitude,
            radiusInKm: 20
        )

        #expect(nearby.contains { $0.id == nearbyEvent.id })
        #expect(!nearby.contains { $0.id == farEvent.id })
    }
    
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

    @Test("Creating a user profile does not throw")
    func testCreateUserProfile() async throws {
        let db = MockDatabaseService()

        let profile = UserProfile(
            id: "user-1",
            phoneNumber: "+15551234567",
            email: "jane@example.com",
            username: "jane_doe",
            name: "Jane Doe",
            bio: "Hello!",
            dateOfBirth: Date(timeIntervalSince1970: 0),
            profilePhotoURL: "https://mock-storage.example.com/users/user-1/profile.jpg",
            publicPhotoURL: nil,
            privatePhotoURLs: []
        )

        // Should not throw
        try await db.createUserProfile(profile)
    }

    @Test("Creating a user profile twice overwrites the previous one")
    func testCreateUserProfileOverwrites() async throws {
        let db = MockDatabaseService()

        let original = UserProfile(id: "user-1", username: "original_name", name: "Original")
        try await db.createUserProfile(original)

        let updated = UserProfile(id: "user-1", username: "updated_name", name: "Updated")
        try await db.createUserProfile(updated)

        // No direct read API on the protocol for user profiles - this test
        // just documents that a second write for the same id doesn't throw,
        // matching Firestore's merge:true "last write wins" semantics.
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
