//
//  ActivityFeedIntegrationTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("ActivityFeed Integration Tests")
@MainActor
struct ActivityFeedIntegrationTests {
    
    @Test("Complete user flow - like post, bookmark event, join event")
    func testCompleteUserFlow() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        // Verify initial state
        #expect(store.feedItems.count == 3)
        #expect(store.isOnline == false)
        
        // User goes online
        store.toggleOnlineStatus()
        #expect(store.isOnline == true)
        
        // User likes a post
        guard case .post(let post) = store.feedItems[0] else {
            Issue.record("First item should be a post")
            return
        }
        
        let initialLikeCount = post.likeCount
        await store.likePost(post)
        
        guard case .post(let likedPost) = store.feedItems[0] else {
            Issue.record("First item should still be a post")
            return
        }
        
        #expect(likedPost.isLiked == true)
        #expect(likedPost.likeCount == initialLikeCount + 1)
        
        // User bookmarks an event
        guard case .event(let event) = store.feedItems[1] else {
            Issue.record("Second item should be an event")
            return
        }
        
        await store.bookmarkEvent(event)
        
        guard case .event(let bookmarkedEvent) = store.feedItems[1] else {
            Issue.record("Second item should still be an event")
            return
        }
        
        #expect(bookmarkedEvent.isBookmarked == true)
        
        // User joins the event
        let initialAttendeeCount = bookmarkedEvent.attendeeCount
        await store.joinEvent(bookmarkedEvent)
        
        guard case .event(let joinedEvent) = store.feedItems[1] else {
            Issue.record("Second item should still be an event")
            return
        }
        
        #expect(joinedEvent.isJoined == true)
        #expect(joinedEvent.attendeeCount == initialAttendeeCount + 1)
        
        // User goes offline
        store.toggleOnlineStatus()
        #expect(store.isOnline == false)
    }
    
    @Test("Feed maintains data integrity across multiple operations")
    func testFeedDataIntegrity() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        let initialFeedCount = store.feedItems.count
        let initialFeedItems = store.feedItems
        
        // Perform multiple operations
        if case .post(let post) = store.feedItems[0] {
            await store.likePost(post)
        }
        
        if case .event(let event) = store.feedItems[1] {
            await store.bookmarkEvent(event)
            await store.joinEvent(event)
        }
        
        if case .post(let post2) = store.feedItems[2] {
            await store.likePost(post2)
        }
        
        // Verify feed integrity
        #expect(store.feedItems.count == initialFeedCount, "Feed count should not change")
        
        // Verify IDs remain the same
        for (index, item) in store.feedItems.enumerated() {
            #expect(item.id == initialFeedItems[index].id, "Item IDs should remain consistent")
        }
    }
    
    @Test("Filter changes work with existing feed data")
    func testFilterWithFeedData() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        #expect(store.selectedFilter == .all)
        #expect(!store.feedItems.isEmpty)
        
        // Apply different filters
        store.applyFilter(.nearbyScenes)
        #expect(store.selectedFilter == .nearbyScenes)
        #expect(!store.feedItems.isEmpty, "Feed should still have data")
        
        store.applyFilter(.posts)
        #expect(store.selectedFilter == .posts)
        
        store.applyFilter(.events)
        #expect(store.selectedFilter == .events)
        
        store.applyFilter(.all)
        #expect(store.selectedFilter == .all)
    }
    
    @Test("Feed refresh maintains state")
    func testFeedRefreshMaintainsState() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        // Set some state
        store.toggleOnlineStatus()
        store.applyFilter(.nearbyScenes)
        
        #expect(store.isOnline == true)
        #expect(store.selectedFilter == .nearbyScenes)
        
        // Refresh feed
        await store.refreshFeed()
        
        // State should be maintained
        #expect(store.isOnline == true)
        #expect(store.selectedFilter == .nearbyScenes)
        #expect(!store.feedItems.isEmpty)
    }
    
    @Test("Multiple rapid state changes handle correctly")
    func testRapidStateChanges() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        // Rapid online/offline toggles
        store.toggleOnlineStatus()
        store.toggleOnlineStatus()
        store.toggleOnlineStatus()
        
        #expect(store.isOnline == true)
        
        // Rapid filter changes
        store.applyFilter(.nearbyScenes)
        store.applyFilter(.posts)
        store.applyFilter(.events)
        store.applyFilter(.all)
        
        #expect(store.selectedFilter == .all)
        
        // Verify feed is still intact
        #expect(!store.feedItems.isEmpty)
    }
    
    @Test("Like, unlike, like post works correctly")
    func testMultipleLikeUnlikeSequence() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        guard case .post(let originalPost) = store.feedItems[0] else {
            Issue.record("First item should be a post")
            return
        }
        
        let originalLikeCount = originalPost.likeCount
        let originalLikeStatus = originalPost.isLiked
        
        // Like
        await store.likePost(originalPost)
        
        guard case .post(let likedPost) = store.feedItems[0] else {
            Issue.record("Item should still be a post")
            return
        }
        
        #expect(likedPost.isLiked == !originalLikeStatus)
        
        // Unlike
        await store.likePost(likedPost)
        
        guard case .post(let unlikedPost) = store.feedItems[0] else {
            Issue.record("Item should still be a post")
            return
        }
        
        #expect(unlikedPost.isLiked == originalLikeStatus)
        #expect(unlikedPost.likeCount == originalLikeCount)
        
        // Like again
        await store.likePost(unlikedPost)
        
        guard case .post(let relikedPost) = store.feedItems[0] else {
            Issue.record("Item should still be a post")
            return
        }
        
        #expect(relikedPost.isLiked == !originalLikeStatus)
    }
    
    @Test("Bookmark and join event independently")
    func testBookmarkAndJoinIndependence() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        guard case .event(let event) = store.feedItems[1] else {
            Issue.record("Second item should be an event")
            return
        }
        
        // Bookmark without joining
        await store.bookmarkEvent(event)
        
        guard case .event(let bookmarkedEvent) = store.feedItems[1] else {
            Issue.record("Item should still be an event")
            return
        }
        
        #expect(bookmarkedEvent.isBookmarked == true)
        #expect(bookmarkedEvent.isJoined == false)
        
        // Join without unbookmarking
        await store.joinEvent(bookmarkedEvent)
        
        guard case .event(let joinedEvent) = store.feedItems[1] else {
            Issue.record("Item should still be an event")
            return
        }
        
        #expect(joinedEvent.isBookmarked == true)
        #expect(joinedEvent.isJoined == true)
        
        // Unbookmark without unjoining
        await store.bookmarkEvent(joinedEvent)
        
        guard case .event(let unbookmarkedEvent) = store.feedItems[1] else {
            Issue.record("Item should still be an event")
            return
        }
        
        #expect(unbookmarkedEvent.isBookmarked == false)
        #expect(unbookmarkedEvent.isJoined == true)
    }
    
    @Test("Feed items can be processed sequentially")
    func testSequentialFeedProcessing() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        for item in store.feedItems {
            switch item {
            case .post(let post):
                await store.likePost(post)
                // Verify post was liked
                if case .post(let updatedPost) = store.feedItems.first(where: { $0.id == item.id }) {
                    #expect(updatedPost.isLiked == true)
                }
                
            case .event(let event):
                await store.bookmarkEvent(event)
                // Verify event was bookmarked
                if case .event(let updatedEvent) = store.feedItems.first(where: { $0.id == item.id }) {
                    #expect(updatedEvent.isBookmarked == true)
                }
            }
        }
    }
    
    @Test("Store state remains consistent after errors")
    func testStoreConsistencyAfterErrors() async {
        let store = ActivityFeedStore(database: MockDatabaseService(), autoLoad: false)
        await store.loadFeed()
        
        let initialState = (
            feedCount: store.feedItems.count,
            isOnline: store.isOnline,
            filter: store.selectedFilter
        )
        
        // Try to like a non-existent post
        let fakePost = Post(
            id: "fake-id",
            userId: "fake-user",
            userName: "Fake",
            content: "Fake"
        )
        
        await store.likePost(fakePost)
        
        // State should remain unchanged
        #expect(store.feedItems.count == initialState.feedCount)
        #expect(store.isOnline == initialState.isOnline)
        #expect(store.selectedFilter == initialState.filter)
    }
    
    @Test("View can be instantiated")
    func testViewInstantiation() {
        // View should instantiate without errors
        let _ = ActivityFeedView()
        
        // If we reach here, instantiation succeeded
        #expect(Bool(true))
    }
}
