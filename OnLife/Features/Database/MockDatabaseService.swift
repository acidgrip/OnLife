//
//  MockDatabaseService.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import Foundation

/// Mock implementation of DatabaseService for testing and preview
/// This allows development without a backend connection
actor MockDatabaseService: DatabaseService {
    
    private var posts: [Post] = []
    private var events: [Event] = []
    private var comments: [Comment] = []
    private var likes: Set<String> = [] // "userId_postId"
    private var bookmarks: Set<String> = [] // "userId_eventId"
    private var eventAttendees: Set<String> = [] // "userId_eventId"
    private var userOnlineStatus: [String: Bool] = [:] // userId -> isOnline
    
    // Simulated network delay (nonisolated to allow synchronous configuration)
    nonisolated(unsafe) var simulatedDelay: TimeInterval = 0.5
    
    init() {
        loadMockData()
    }
    
    // MARK: - Feed Operations
    
    func fetchFeed(
        filter: FeedFilter,
        limit: Int,
        lastItemId: String? = nil
    ) async throws -> [FeedItem] {
        try await simulateNetworkDelay()
        
        var items: [FeedItem] = []
        
        if filter != .events {
            items.append(contentsOf: posts.map { .post($0) })
        }
        
        if filter != .posts {
            items.append(contentsOf: events.map { .event($0) })
        }
        
        // Sort by date
        items.sort { item1, item2 in
            let date1: Date
            let date2: Date
            
            switch item1 {
            case .post(let post): date1 = post.timestamp
            case .event(let event): date1 = event.date
            }
            
            switch item2 {
            case .post(let post): date2 = post.timestamp
            case .event(let event): date2 = event.date
            }
            
            return date1 > date2
        }
        
        return Array(items.prefix(limit))
    }
    
    func observeFeed(
        filter: FeedFilter,
        onChange: @escaping ([FeedItem]) -> Void
    ) -> DatabaseObserver {
        // For mock, just return immediately with current data
        Task {
            let items = try await fetchFeed(filter: filter, limit: 50, lastItemId: nil)
            await MainActor.run {
                onChange(items)
            }
        }
        
        return MockObserver()
    }
    
    // MARK: - Post Operations
    
    func createPost(_ post: Post) async throws -> Post {
        try await simulateNetworkDelay()
        
        let newPost = Post(
            id: UUID().uuidString,
            userId: post.userId,
            userName: post.userName,
            userProfileImageURL: post.userProfileImageURL,
            userLocation: post.userLocation,
            content: post.content,
            timestamp: Date(),
            likeCount: 0,
            commentCount: 0,
            isLiked: false
        )
        
        posts.insert(newPost, at: 0)
        return newPost
    }
    
    func togglePostLike(postId: String, userId: String, isLiked: Bool) async throws {
        try await simulateNetworkDelay()
        
        let likeKey = "\(userId)_\(postId)"
        
        if isLiked {
            likes.insert(likeKey)
        } else {
            likes.remove(likeKey)
        }
        
        // Update post like count
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            let post = posts[index]
            posts[index] = Post(
                id: post.id,
                userId: post.userId,
                userName: post.userName,
                userProfileImageURL: post.userProfileImageURL,
                userLocation: post.userLocation,
                content: post.content,
                timestamp: post.timestamp,
                likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
                commentCount: post.commentCount,
                isLiked: isLiked
            )
        }
    }
    
    func fetchPost(id postId: String) async throws -> Post? {
        try await simulateNetworkDelay()
        return posts.first { $0.id == postId }
    }
    
    func deletePost(id postId: String) async throws {
        try await simulateNetworkDelay()
        posts.removeAll { $0.id == postId }
        comments.removeAll { $0.postId == postId }
    }
    
    // MARK: - Event Operations
    
    func createEvent(_ event: Event) async throws -> Event {
        try await simulateNetworkDelay()
        
        let newEvent = Event(
            id: UUID().uuidString,
            title: event.title,
            hostedBy: event.hostedBy,
            imageURL: event.imageURL,
            location: event.location,
            date: event.date,
            time: event.time,
            attendeeCount: 0,
            attendeeProfileImages: [],
            isBookmarked: false,
            isJoined: false
        )
        
        events.insert(newEvent, at: 0)
        return newEvent
    }
    
    func toggleEventBookmark(eventId: String, userId: String, isBookmarked: Bool) async throws {
        try await simulateNetworkDelay()
        
        let bookmarkKey = "\(userId)_\(eventId)"
        
        if isBookmarked {
            bookmarks.insert(bookmarkKey)
        } else {
            bookmarks.remove(bookmarkKey)
        }
    }
    
    func toggleEventJoin(eventId: String, userId: String, isJoined: Bool) async throws {
        try await simulateNetworkDelay()
        
        let attendeeKey = "\(userId)_\(eventId)"
        
        if isJoined {
            eventAttendees.insert(attendeeKey)
        } else {
            eventAttendees.remove(attendeeKey)
        }
        
        // Update event attendee count
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            let event = events[index]
            events[index] = Event(
                id: event.id,
                title: event.title,
                hostedBy: event.hostedBy,
                imageURL: event.imageURL,
                location: event.location,
                date: event.date,
                time: event.time,
                attendeeCount: isJoined ? event.attendeeCount + 1 : event.attendeeCount - 1,
                attendeeProfileImages: event.attendeeProfileImages,
                isBookmarked: event.isBookmarked,
                isJoined: isJoined
            )
        }
    }
    
    func fetchNearbyEvents(
        latitude: Double,
        longitude: Double,
        radiusInKm: Double
    ) async throws -> [Event] {
        try await simulateNetworkDelay()
        // In mock, just return all events
        return events
    }
    
    func fetchEvent(id eventId: String) async throws -> Event? {
        try await simulateNetworkDelay()
        return events.first { $0.id == eventId }
    }
    
    func deleteEvent(id eventId: String) async throws {
        try await simulateNetworkDelay()
        events.removeAll { $0.id == eventId }
    }
    
    // MARK: - User Operations
    
    func updateUserOnlineStatus(userId: String, isOnline: Bool) async throws {
        try await simulateNetworkDelay()
        userOnlineStatus[userId] = isOnline
    }
    
    func observeUserOnlineStatus(
        userId: String,
        onChange: @escaping (Bool) -> Void
    ) -> DatabaseObserver {
        Task { [weak self] in
            guard let self = self else { return }
            // Read actor-isolated state on the actor, then hop to MainActor
            let status = await self.userOnlineStatus[userId] ?? false
            await MainActor.run {
                onChange(status)
            }
        }
        return MockObserver()
    }
    
    // MARK: - Comment Operations
    
    func fetchComments(for postId: String) async throws -> [Comment] {
        try await simulateNetworkDelay()
        return comments.filter { $0.postId == postId }
    }
    
    func createComment(for postId: String, comment: Comment) async throws -> Comment {
        try await simulateNetworkDelay()
        
        let newComment = Comment(
            id: UUID().uuidString,
            postId: postId,
            userId: comment.userId,
            userName: comment.userName,
            userProfileImageURL: comment.userProfileImageURL,
            content: comment.content,
            timestamp: Date()
        )
        
        comments.append(newComment)
        
        // Update comment count
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            let post = posts[index]
            posts[index] = Post(
                id: post.id,
                userId: post.userId,
                userName: post.userName,
                userProfileImageURL: post.userProfileImageURL,
                userLocation: post.userLocation,
                content: post.content,
                timestamp: post.timestamp,
                likeCount: post.likeCount,
                commentCount: post.commentCount + 1,
                isLiked: post.isLiked
            )
        }
        
        return newComment
    }
    
    // MARK: - Image Operations
    
    func uploadImage(imageData: Data, path: String) async throws -> String {
        try await simulateNetworkDelay()
        // Return a mock URL
        return "https://mock-storage.example.com/\(path)"
    }
    
    func deleteImage(url: String) async throws {
        try await simulateNetworkDelay()
        // No-op for mock
    }
    
    // MARK: - Private Helpers
    
    private func simulateNetworkDelay() async throws {
        if simulatedDelay > 0 {
            try await Task.sleep(for: .seconds(simulatedDelay))
        }
    }
    
    private func loadMockData() {
        // Create dates to ensure predictable order
        let now = Date()
        
        posts = [
            Post(
                userId: "user1",
                userName: "Jane Doe",
                userLocation: "ARTS DISTRICT",
                content: "The quiet before the storm...",
                timestamp: now.addingTimeInterval(-3600), // 1 hour ago
                likeCount: 24,
                commentCount: 8
            ),
            Post(
                userId: "user2",
                userName: "Marcus Chen",
                userLocation: "SOUND LAB",
                content: "Finally tuned the new synthesizer module. The resonance at the low-end is incredible. Signal is pure.",
                timestamp: now.addingTimeInterval(-10800), // 3 hours ago
                likeCount: 112,
                commentCount: 42
            )
        ]
        
        events = [
            Event(
                title: "Sunset Yoga Session",
                hostedBy: "GreenSpace",
                location: "Skyline Terrace, Block B",
                date: now.addingTimeInterval(-7200), // 2 hours ago (so it comes between the two posts)
                time: "Earlier • 2 hours ago",
                attendeeCount: 14,
                attendeeProfileImages: []
            )
        ]
        
        userOnlineStatus = [
            "user1": true,
            "user2": true
        ]
    }
}

// MARK: - Mock Observer

final class MockObserver: DatabaseObserver {
    func cancel() {
        // No-op for mock
    }
}
