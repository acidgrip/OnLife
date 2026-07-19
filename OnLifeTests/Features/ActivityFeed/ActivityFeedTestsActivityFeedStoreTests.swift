//
//  ActivityFeedStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("ActivityFeedStore Tests")
@MainActor
struct ActivityFeedStoreTests {
    
    @Test("ActivityFeedStore initializes with default values")
    func testStoreInitialization() async {
        let store = ActivityFeedStore(autoLoad: false)
        
        #expect(store.feedItems.isEmpty) // No data loaded yet
        #expect(store.isLoading == false)
        #expect(store.isOnline == false)
        #expect(store.selectedFilter == .all)
        #expect(store.errorMessage == nil)
        #expect(store.showError == false)
        
        // Load data
        await store.loadFeed()
        #expect(!store.feedItems.isEmpty) // Mock data is now loaded
    }
    
    @Test("ActivityFeedStore loads mock data on initialization")
    func testStoreLoadsMockData() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        
        #expect(store.feedItems.count == 3)
        
        // Verify first item is a post
        if case .post(let post) = store.feedItems[0] {
            #expect(post.userName == "Jane Doe")
            #expect(post.userLocation == "ARTS DISTRICT")
        } else {
            Issue.record("First item should be a post")
        }
        
        // Verify second item is an event
        if case .event(let event) = store.feedItems[1] {
            #expect(event.title == "Sunset Yoga Session")
            #expect(event.hostedBy == "GreenSpace")
        } else {
            Issue.record("Second item should be an event")
        }
        
        // Verify third item is a post
        if case .post(let post) = store.feedItems[2] {
            #expect(post.userName == "Marcus Chen")
            #expect(post.userLocation == "SOUND LAB")
        } else {
            Issue.record("Third item should be a post")
        }
    }
    
    @Test("Toggle online status changes state")
    func testToggleOnlineStatus() async {
        let store = ActivityFeedStore(autoLoad: false)
        
        #expect(store.isOnline == false)
        
        store.toggleOnlineStatus()
        #expect(store.isOnline == true)
        
        store.toggleOnlineStatus()
        #expect(store.isOnline == false)
    }
    
    @Test("Load feed sets and clears loading state")
    func testLoadFeedLoadingState() async {
        let store = ActivityFeedStore(autoLoad: false)
        
        #expect(store.isLoading == false)
        
        let loadTask = Task {
            await store.loadFeed()
        }
        
        await loadTask.value
        
        #expect(store.isLoading == false)
        #expect(!store.feedItems.isEmpty)
    }
    
    @Test("Refresh feed reloads data")
    func testRefreshFeed() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        let initialCount = store.feedItems.count
        
        await store.refreshFeed()
        
        #expect(store.feedItems.count == initialCount)
        #expect(store.isLoading == false)
    }
    
    @Test("Like post toggles like status")
    func testLikePost() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        
        guard case .post(let originalPost) = store.feedItems[0] else {
            Issue.record("First item should be a post")
            return
        }
        
        let originalLikeCount = originalPost.likeCount
        let originalLikeStatus = originalPost.isLiked
        
        await store.likePost(originalPost)
        
        guard case .post(let updatedPost) = store.feedItems[0] else {
            Issue.record("First item should still be a post")
            return
        }
        
        #expect(updatedPost.isLiked == !originalLikeStatus)
        
        if originalLikeStatus {
            #expect(updatedPost.likeCount == originalLikeCount - 1)
        } else {
            #expect(updatedPost.likeCount == originalLikeCount + 1)
        }
    }
    
    @Test("Like post with invalid ID does nothing")
    func testLikePostInvalidID() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        let originalCount = store.feedItems.count
        
        let fakePost = Post(
            id: "nonexistent-id",
            userId: "user-1",
            userName: "Fake User",
            content: "Fake content"
        )
        
        await store.likePost(fakePost)
        
        #expect(store.feedItems.count == originalCount)
    }
    
    @Test("Bookmark event toggles bookmark status")
    func testBookmarkEvent() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        
        guard case .event(let originalEvent) = store.feedItems[1] else {
            Issue.record("Second item should be an event")
            return
        }
        
        let originalBookmarkStatus = originalEvent.isBookmarked
        
        await store.bookmarkEvent(originalEvent)
        
        guard case .event(let updatedEvent) = store.feedItems[1] else {
            Issue.record("Second item should still be an event")
            return
        }
        
        #expect(updatedEvent.isBookmarked == !originalBookmarkStatus)
    }
    
    @Test("Join event toggles join status and updates attendee count")
    func testJoinEvent() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        
        guard case .event(let originalEvent) = store.feedItems[1] else {
            Issue.record("Second item should be an event")
            return
        }
        
        let originalAttendeeCount = originalEvent.attendeeCount
        let originalJoinStatus = originalEvent.isJoined
        
        await store.joinEvent(originalEvent)
        
        guard case .event(let updatedEvent) = store.feedItems[1] else {
            Issue.record("Second item should still be an event")
            return
        }
        
        #expect(updatedEvent.isJoined == !originalJoinStatus)
        
        if originalJoinStatus {
            #expect(updatedEvent.attendeeCount == originalAttendeeCount - 1)
        } else {
            #expect(updatedEvent.attendeeCount == originalAttendeeCount + 1)
        }
    }
    
    @Test("Apply filter updates selected filter")
    func testApplyFilter() async {
        let store = ActivityFeedStore(autoLoad: false)
        
        #expect(store.selectedFilter == .all)
        
        store.applyFilter(.nearbyScenes)
        #expect(store.selectedFilter == .nearbyScenes)
        
        store.applyFilter(.posts)
        #expect(store.selectedFilter == .posts)
        
        store.applyFilter(.events)
        #expect(store.selectedFilter == .events)
    }
    
    @Test("Multiple likes toggle correctly")
    func testMultipleLikeToggles() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        
        guard case .post(let post) = store.feedItems[0] else {
            Issue.record("First item should be a post")
            return
        }
        
        let originalLikeCount = post.likeCount
        
        // Like the post
        await store.likePost(post)
        
        guard case .post(let likedPost) = store.feedItems[0] else {
            Issue.record("Item should still be a post")
            return
        }
        
        #expect(likedPost.isLiked == true)
        #expect(likedPost.likeCount == originalLikeCount + 1)
        
        // Unlike the post
        await store.likePost(likedPost)
        
        guard case .post(let unlikedPost) = store.feedItems[0] else {
            Issue.record("Item should still be a post")
            return
        }
        
        #expect(unlikedPost.isLiked == false)
        #expect(unlikedPost.likeCount == originalLikeCount)
    }
    
    @Test("Multiple bookmark toggles work correctly")
    func testMultipleBookmarkToggles() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        
        guard case .event(let event) = store.feedItems[1] else {
            Issue.record("Second item should be an event")
            return
        }
        
        let originalStatus = event.isBookmarked
        
        // Bookmark
        await store.bookmarkEvent(event)
        
        guard case .event(let bookmarkedEvent) = store.feedItems[1] else {
            Issue.record("Item should still be an event")
            return
        }
        
        #expect(bookmarkedEvent.isBookmarked == !originalStatus)
        
        // Unbookmark
        await store.bookmarkEvent(bookmarkedEvent)
        
        guard case .event(let unbookmarkedEvent) = store.feedItems[1] else {
            Issue.record("Item should still be an event")
            return
        }
        
        #expect(unbookmarkedEvent.isBookmarked == originalStatus)
    }
    
    @Test("Feed items maintain order after updates")
    func testFeedItemsOrderMaintained() async {
        let store = ActivityFeedStore(autoLoad: false)
        await store.loadFeed()
        
        let originalCount = store.feedItems.count
        
        guard case .post(let post) = store.feedItems[0] else {
            Issue.record("First item should be a post")
            return
        }
        
        await store.likePost(post)
        
        #expect(store.feedItems.count == originalCount)
        
        // Verify order is preserved
        if case .post = store.feedItems[0],
           case .event = store.feedItems[1],
           case .post = store.feedItems[2] {
            // Order is correct
        } else {
            Issue.record("Feed item order was changed")
        }
    }
}
