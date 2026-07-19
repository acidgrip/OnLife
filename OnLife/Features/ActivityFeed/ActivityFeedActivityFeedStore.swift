//
//  ActivityFeedStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import Foundation

@MainActor
@Observable
final class ActivityFeedStore {
    var feedItems: [FeedItem] = []
    var isLoading = false
    var isOnline = false
    var selectedFilter: FeedFilter = .all
    var errorMessage: String?
    var showError = false
    
    // Database service (injected for testability)
    private let database: DatabaseService
    
    // Auth service
    private let authService: AuthService
    
    // Current user ID (from auth service)
    private var currentUserId: String {
        authService.currentUserId ?? "anonymous"
    }
    
    // Feed observer for real-time updates
    private nonisolated(unsafe) var feedObserver: DatabaseObserver?
    
    // MARK: - Initialization
    
    init(
        database: DatabaseService? = nil,
        authService: AuthService = .shared,
        autoLoad: Bool = true
    ) {
        self.database = database ?? DatabaseManager.shared.service
        self.authService = authService
        
        if autoLoad {
            Task {
                await loadFeed()
            }
        }
    }
    
    // MARK: - Public Methods
    
    func toggleOnlineStatus() {
        isOnline.toggle()
        
        Task {
            do {
                try await database.updateUserOnlineStatus(
                    userId: currentUserId,
                    isOnline: isOnline
                )
            } catch {
                await handleError(error)
            }
        }
    }
    
    func loadFeed() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            feedItems = try await database.fetchFeed(
                filter: selectedFilter,
                limit: 50,
                lastItemId: nil
            )
            
            // Optionally set up real-time listener
            // observeFeedChanges()
        } catch {
            await handleError(error)
        }
    }
    
    func refreshFeed() async {
        await loadFeed()
    }
    
    func likePost(_ post: Post) async {
        // Optimistically update UI
        updatePostInFeed(post) { updatedPost in
            Post(
                id: updatedPost.id,
                userId: updatedPost.userId,
                userName: updatedPost.userName,
                userProfileImageURL: updatedPost.userProfileImageURL,
                userLocation: updatedPost.userLocation,
                content: updatedPost.content,
                timestamp: updatedPost.timestamp,
                likeCount: updatedPost.isLiked ? updatedPost.likeCount - 1 : updatedPost.likeCount + 1,
                commentCount: updatedPost.commentCount,
                isLiked: !updatedPost.isLiked
            )
        }
        
        // Update backend
        do {
            try await database.togglePostLike(
                postId: post.id,
                userId: currentUserId,
                isLiked: !post.isLiked
            )
        } catch {
            // Revert optimistic update on error
            updatePostInFeed(post) { $0 }
            await handleError(error)
        }
    }
    
    func bookmarkEvent(_ event: Event) async {
        // Optimistically update UI
        updateEventInFeed(event) { updatedEvent in
            Event(
                id: updatedEvent.id,
                title: updatedEvent.title,
                hostedBy: updatedEvent.hostedBy,
                imageURL: updatedEvent.imageURL,
                location: updatedEvent.location,
                date: updatedEvent.date,
                time: updatedEvent.time,
                attendeeCount: updatedEvent.attendeeCount,
                attendeeProfileImages: updatedEvent.attendeeProfileImages,
                isBookmarked: !updatedEvent.isBookmarked,
                isJoined: updatedEvent.isJoined
            )
        }
        
        // Update backend
        do {
            try await database.toggleEventBookmark(
                eventId: event.id,
                userId: currentUserId,
                isBookmarked: !event.isBookmarked
            )
        } catch {
            // Revert optimistic update on error
            updateEventInFeed(event) { $0 }
            await handleError(error)
        }
    }
    
    func joinEvent(_ event: Event) async {
        // Optimistically update UI
        updateEventInFeed(event) { updatedEvent in
            Event(
                id: updatedEvent.id,
                title: updatedEvent.title,
                hostedBy: updatedEvent.hostedBy,
                imageURL: updatedEvent.imageURL,
                location: updatedEvent.location,
                date: updatedEvent.date,
                time: updatedEvent.time,
                attendeeCount: updatedEvent.isJoined ? updatedEvent.attendeeCount - 1 : updatedEvent.attendeeCount + 1,
                attendeeProfileImages: updatedEvent.attendeeProfileImages,
                isBookmarked: updatedEvent.isBookmarked,
                isJoined: !updatedEvent.isJoined
            )
        }
        
        // Update backend
        do {
            try await database.toggleEventJoin(
                eventId: event.id,
                userId: currentUserId,
                isJoined: !event.isJoined
            )
        } catch {
            // Revert optimistic update on error
            updateEventInFeed(event) { $0 }
            await handleError(error)
        }
    }
    
    func applyFilter(_ filter: FeedFilter) {
        selectedFilter = filter
        
        Task {
            await loadFeed()
        }
    }
    
    func createPost(content: String, location: String? = nil) async {
        do {
            // Get current user info
            let userId = currentUserId
            let userName = "User \(userId.prefix(8))" // TODO: Get from user profile
            
            let post = Post(
                userId: userId,
                userName: userName,
                userLocation: location,
                content: content
            )
            
            let createdPost = try await database.createPost(post)
            
            // Add to feed
            feedItems.insert(.post(createdPost), at: 0)
        } catch {
            await handleError(error)
        }
    }
    
    // MARK: - Real-time Updates
    
    func observeFeedChanges() async {
        feedObserver?.cancel()
        
        feedObserver = await database.observeFeed(filter: selectedFilter) { [weak self] items in
            guard let self else { return }
            // Schedule update on MainActor without detaching
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.feedItems = items
            }
        }
    }
    
    func stopObserving() {
        feedObserver?.cancel()
        feedObserver = nil
    }
    
    // MARK: - Private Helpers
    
    private func updatePostInFeed(_ post: Post, transform: (Post) -> Post) {
        guard let index = feedItems.firstIndex(where: {
            if case .post(let p) = $0, p.id == post.id {
                return true
            }
            return false
        }) else { return }
        
        if case .post(let existingPost) = feedItems[index] {
            feedItems[index] = .post(transform(existingPost))
        }
    }
    
    private func updateEventInFeed(_ event: Event, transform: (Event) -> Event) {
        guard let index = feedItems.firstIndex(where: {
            if case .event(let e) = $0, e.id == event.id {
                return true
            }
            return false
        }) else { return }
        
        if case .event(let existingEvent) = feedItems[index] {
            feedItems[index] = .event(transform(existingEvent))
        }
    }
    
    private func handleError(_ error: Error) async {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    deinit {
        feedObserver?.cancel()
        feedObserver = nil
    }
}
