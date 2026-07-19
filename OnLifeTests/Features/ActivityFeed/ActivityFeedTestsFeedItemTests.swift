//
//  FeedItemTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("FeedItem Model Tests")
struct FeedItemTests {
    
    @Test("FeedItem post case returns correct ID")
    func testFeedItemPostID() {
        let post = Post(
            id: "post-123",
            userId: "user-1",
            userName: "Test User",
            content: "Test content"
        )
        let feedItem = FeedItem.post(post)
        
        #expect(feedItem.id == "post-post-123")
    }
    
    @Test("FeedItem event case returns correct ID")
    func testFeedItemEventID() {
        let event = Event(
            id: "event-456",
            title: "Test Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "1:00 PM"
        )
        let feedItem = FeedItem.event(event)
        
        #expect(feedItem.id == "event-event-456")
    }
    
    @Test("FeedItem post and event have different IDs")
    func testFeedItemDifferentIDs() {
        let post = Post(
            id: "123",
            userId: "user-1",
            userName: "User",
            content: "Content"
        )
        let event = Event(
            id: "123",
            title: "Event",
            hostedBy: "Host",
            location: "Place",
            date: Date(),
            time: "Time"
        )
        
        let postFeedItem = FeedItem.post(post)
        let eventFeedItem = FeedItem.event(event)
        
        #expect(postFeedItem.id != eventFeedItem.id)
        #expect(postFeedItem.id == "post-123")
        #expect(eventFeedItem.id == "event-123")
    }
    
    @Test("FeedItem conforms to Identifiable")
    func testFeedItemIdentifiable() {
        let post1 = Post(
            id: "post-1",
            userId: "user-1",
            userName: "User 1",
            content: "Content 1"
        )
        let post2 = Post(
            id: "post-2",
            userId: "user-2",
            userName: "User 2",
            content: "Content 2"
        )
        
        let feedItem1 = FeedItem.post(post1)
        let feedItem2 = FeedItem.post(post2)
        
        #expect(feedItem1.id != feedItem2.id)
    }
    
    @Test("FeedItem can switch between post and event")
    func testFeedItemPattern() {
        let post = Post(
            userId: "user-1",
            userName: "User",
            content: "Post content"
        )
        let event = Event(
            title: "Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time"
        )
        
        let postFeedItem = FeedItem.post(post)
        let eventFeedItem = FeedItem.event(event)
        
        // Pattern matching
        switch postFeedItem {
        case .post(let extractedPost):
            #expect(extractedPost.id == post.id)
        case .event:
            Issue.record("Should be a post")
        }
        
        switch eventFeedItem {
        case .post:
            Issue.record("Should be an event")
        case .event(let extractedEvent):
            #expect(extractedEvent.id == event.id)
        }
    }
    
    @Test("FeedItem preserves post data")
    func testFeedItemPreservesPostData() {
        let post = Post(
            id: "post-789",
            userId: "user-789",
            userName: "Jane Doe",
            userLocation: "DOWNTOWN",
            content: "Important post",
            likeCount: 42,
            commentCount: 10
        )
        
        let feedItem = FeedItem.post(post)
        
        if case .post(let extractedPost) = feedItem {
            #expect(extractedPost.id == "post-789")
            #expect(extractedPost.userName == "Jane Doe")
            #expect(extractedPost.userLocation == "DOWNTOWN")
            #expect(extractedPost.content == "Important post")
            #expect(extractedPost.likeCount == 42)
            #expect(extractedPost.commentCount == 10)
        } else {
            Issue.record("FeedItem should contain post")
        }
    }
    
    @Test("FeedItem preserves event data")
    func testFeedItemPreservesEventData() {
        let event = Event(
            id: "event-999",
            title: "Summer Fest",
            hostedBy: "City Council",
            location: "Central Park",
            date: Date(),
            time: "6:00 PM",
            attendeeCount: 100,
            isBookmarked: true
        )
        
        let feedItem = FeedItem.event(event)
        
        if case .event(let extractedEvent) = feedItem {
            #expect(extractedEvent.id == "event-999")
            #expect(extractedEvent.title == "Summer Fest")
            #expect(extractedEvent.hostedBy == "City Council")
            #expect(extractedEvent.location == "Central Park")
            #expect(extractedEvent.attendeeCount == 100)
            #expect(extractedEvent.isBookmarked == true)
        } else {
            Issue.record("FeedItem should contain event")
        }
    }
}
