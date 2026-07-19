//
//  DatabaseService.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import Foundation

/// Protocol defining all database operations for the Onlife app.
/// This abstraction allows swapping database implementations without changing app logic.
protocol DatabaseService: Actor {
    
    // MARK: - Feed Operations
    
    /// Fetches feed items (posts and events) with optional filters
    /// - Parameters:
    ///   - filter: The type of content to fetch
    ///   - limit: Maximum number of items to return
    ///   - lastItemId: For pagination, the ID of the last item from previous fetch
    /// - Returns: Array of feed items
    func fetchFeed(
        filter: FeedFilter,
        limit: Int,
        lastItemId: String?
    ) async throws -> [FeedItem]
    
    /// Observes feed changes in real-time
    /// - Parameters:
    ///   - filter: The type of content to observe
    ///   - onChange: Callback when feed items change
    /// - Returns: A cancellable object to stop observing
    func observeFeed(
        filter: FeedFilter,
        onChange: @escaping ([FeedItem]) -> Void
    ) -> DatabaseObserver
    
    // MARK: - Post Operations
    
    /// Creates a new post
    /// - Parameter post: The post to create
    /// - Returns: The created post with server-generated ID
    func createPost(_ post: Post) async throws -> Post
    
    /// Likes or unlikes a post
    /// - Parameters:
    ///   - postId: The ID of the post
    ///   - userId: The ID of the user liking the post
    ///   - isLiked: True to like, false to unlike
    func togglePostLike(postId: String, userId: String, isLiked: Bool) async throws
    
    /// Fetches a single post by ID
    /// - Parameter postId: The ID of the post
    /// - Returns: The post if found
    func fetchPost(id postId: String) async throws -> Post?
    
    /// Deletes a post
    /// - Parameter postId: The ID of the post to delete
    func deletePost(id postId: String) async throws
    
    // MARK: - Event Operations
    
    /// Creates a new event
    /// - Parameter event: The event to create
    /// - Returns: The created event with server-generated ID
    func createEvent(_ event: Event) async throws -> Event
    
    /// Toggles bookmark status for an event
    /// - Parameters:
    ///   - eventId: The ID of the event
    ///   - userId: The ID of the user bookmarking
    ///   - isBookmarked: True to bookmark, false to unbookmark
    func toggleEventBookmark(eventId: String, userId: String, isBookmarked: Bool) async throws
    
    /// Joins or leaves an event
    /// - Parameters:
    ///   - eventId: The ID of the event
    ///   - userId: The ID of the user joining/leaving
    ///   - isJoined: True to join, false to leave
    func toggleEventJoin(eventId: String, userId: String, isJoined: Bool) async throws
    
    /// Fetches nearby events based on location
    /// - Parameters:
    ///   - latitude: The latitude coordinate
    ///   - longitude: The longitude coordinate
    ///   - radiusInKm: Search radius in kilometers
    /// - Returns: Array of nearby events
    func fetchNearbyEvents(
        latitude: Double,
        longitude: Double,
        radiusInKm: Double
    ) async throws -> [Event]
    
    /// Fetches a single event by ID
    /// - Parameter eventId: The ID of the event
    /// - Returns: The event if found
    func fetchEvent(id eventId: String) async throws -> Event?
    
    /// Deletes an event
    /// - Parameter eventId: The ID of the event to delete
    func deleteEvent(id eventId: String) async throws
    
    // MARK: - User Operations
    
    /// Updates user's online status
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - isOnline: True if online, false if offline
    func updateUserOnlineStatus(userId: String, isOnline: Bool) async throws
    
    /// Observes a user's online status
    /// - Parameters:
    ///   - userId: The ID of the user to observe
    ///   - onChange: Callback when online status changes
    /// - Returns: A cancellable object to stop observing
    func observeUserOnlineStatus(
        userId: String,
        onChange: @escaping (Bool) -> Void
    ) -> DatabaseObserver
    
    // MARK: - Comment Operations
    
    /// Fetches comments for a post
    /// - Parameter postId: The ID of the post
    /// - Returns: Array of comments
    func fetchComments(for postId: String) async throws -> [Comment]
    
    /// Creates a new comment on a post
    /// - Parameters:
    ///   - postId: The ID of the post
    ///   - comment: The comment to create
    /// - Returns: The created comment with server-generated ID
    func createComment(for postId: String, comment: Comment) async throws -> Comment
    
    // MARK: - Image Operations
    
    /// Uploads an image
    /// - Parameters:
    ///   - imageData: The image data to upload
    ///   - path: The storage path (e.g., "events/image123.jpg")
    /// - Returns: The public URL of the uploaded image
    func uploadImage(imageData: Data, path: String) async throws -> String
    
    /// Deletes an image
    /// - Parameter url: The URL of the image to delete
    func deleteImage(url: String) async throws
}

// MARK: - Supporting Types

/// A token that can be used to cancel database observations
protocol DatabaseObserver {
    func cancel()
}

/// Comment model for posts
struct Comment: Identifiable, Codable {
    let id: String
    let postId: String
    let userId: String
    let userName: String
    let userProfileImageURL: String?
    let content: String
    let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        postId: String,
        userId: String,
        userName: String,
        userProfileImageURL: String? = nil,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.userProfileImageURL = userProfileImageURL
        self.content = content
        self.timestamp = timestamp
    }
}

/// Errors that can occur during database operations
enum DatabaseError: LocalizedError {
    case notFound
    case unauthorized
    case invalidData
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested item was not found."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .invalidData:
            return "The data is invalid or corrupted."
        case .networkError:
            return "A network error occurred. Please check your connection."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
