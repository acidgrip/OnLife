//
//  MockDatabaseService.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import CoreLocation
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
    private var userProfiles: [String: UserProfile] = [:] // userId -> profile

    // Simulated network delay (nonisolated to allow synchronous configuration)
    nonisolated(unsafe) var simulatedDelay: TimeInterval = 0.5

    init() {
        loadMockData()
    }

    // MARK: - Feed Operations

    func fetchFeed(
        filter: FeedFilter,
        limit: Int,
        lastItemId: String? = nil,
        near coordinate: CLLocationCoordinate2D? = nil,
        radiusInKm: Double? = nil
    ) async throws -> [FeedItem] {
        try await simulateNetworkDelay()

        var items: [FeedItem] = []

        if filter != .events {
            items.append(contentsOf: filterByProximity(posts, near: coordinate, radiusInKm: radiusInKm).map { .post($0) })
        }

        if filter != .posts {
            items.append(contentsOf: filterByProximity(events, near: coordinate, radiusInKm: radiusInKm).map { .event($0) })
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
            let items = try await fetchFeed(filter: filter, limit: 50, lastItemId: nil, near: nil, radiusInKm: nil)
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
            latitude: post.latitude,
            longitude: post.longitude,
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
                latitude: post.latitude,
                longitude: post.longitude,
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
            latitude: event.latitude,
            longitude: event.longitude,
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
                latitude: event.latitude,
                longitude: event.longitude,
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

        let origin = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return filterByProximity(events, near: origin, radiusInKm: radiusInKm)
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

    func createUserProfile(_ profile: UserProfile) async throws {
        try await simulateNetworkDelay()
        userProfiles[profile.id] = profile
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
                latitude: post.latitude,
                longitude: post.longitude,
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

    /// Filters items to those within `radiusInKm` of `coordinate`, using real
    /// `CLLocation.distance(from:)`. Items with no known coordinate are
    /// excluded, since there's nothing to measure distance against. When
    /// `coordinate` is `nil`, returns `items` unfiltered (matches
    /// `fetchFeed`'s "no proximity filtering requested" behavior).
    private func filterByProximity<T>(
        _ items: [T],
        near coordinate: CLLocationCoordinate2D?,
        radiusInKm: Double?,
        distance: (T, CLLocation) -> CLLocationDistance?
    ) -> [T] {
        guard let coordinate, let radiusInKm else { return items }
        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let radiusInMeters = radiusInKm * 1000
        return items.filter { item in
            guard let itemDistance = distance(item, origin) else { return false }
            return itemDistance <= radiusInMeters
        }
    }

    private func filterByProximity(
        _ posts: [Post],
        near coordinate: CLLocationCoordinate2D?,
        radiusInKm: Double?
    ) -> [Post] {
        filterByProximity(posts, near: coordinate, radiusInKm: radiusInKm) { $0.distance(from: $1) }
    }

    private func filterByProximity(
        _ events: [Event],
        near coordinate: CLLocationCoordinate2D?,
        radiusInKm: Double?
    ) -> [Event] {
        filterByProximity(events, near: coordinate, radiusInKm: radiusInKm) { $0.distance(from: $1) }
    }

    private func loadMockData() {
        // Create dates to ensure predictable order
        let now = Date()

        // Coordinates are all in/around downtown Los Angeles so the mock
        // data actually demonstrates proximity filtering: the two posts and
        // the event are close to each other (a few km apart), matching
        // "ARTS DISTRICT" / "SOUND LAB" / "Skyline Terrace" as if they were
        // real nearby LA neighborhoods.
        posts = [
            Post(
                userId: "user1",
                userName: "Jane Doe",
                userLocation: "ARTS DISTRICT",
                latitude: 34.0403,
                longitude: -118.2345,
                content: "The quiet before the storm...",
                timestamp: now.addingTimeInterval(-3600), // 1 hour ago
                likeCount: 24,
                commentCount: 8
            ),
            Post(
                userId: "user2",
                userName: "Marcus Chen",
                userLocation: "SOUND LAB",
                latitude: 34.0511,
                longitude: -118.2430,
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
                latitude: 34.0455,
                longitude: -118.2380,
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
