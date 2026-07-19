//
//  EventCardViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("EventCardView Tests")
@MainActor
struct EventCardViewTests {
    
    @Test("EventCardView displays event data")
    func testEventCardDisplaysData() {
        let event = Event(
            title: "Test Event",
            hostedBy: "Test Host",
            location: "Test Location",
            date: Date(),
            time: "6:00 PM",
            attendeeCount: 15
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        #expect(view.event.title == "Test Event")
        #expect(view.event.hostedBy == "Test Host")
        #expect(view.event.location == "Test Location")
        #expect(view.event.time == "6:00 PM")
        #expect(view.event.attendeeCount == 15)
    }
    
    @Test("EventCardView handles bookmark callback")
    func testEventCardBookmarkCallback() {
        var bookmarkCalled = false
        
        let event = Event(
            title: "Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time"
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: { bookmarkCalled = true },
            onJoin: {},
            onShare: {}
        )
        
        view.onBookmark()
        #expect(bookmarkCalled == true)
    }
    
    @Test("EventCardView handles join callback")
    func testEventCardJoinCallback() {
        var joinCalled = false
        
        let event = Event(
            title: "Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time"
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: {},
            onJoin: { joinCalled = true },
            onShare: {}
        )
        
        view.onJoin()
        #expect(joinCalled == true)
    }
    
    @Test("EventCardView handles share callback")
    func testEventCardShareCallback() {
        var shareCalled = false
        
        let event = Event(
            title: "Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time"
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: {},
            onJoin: {},
            onShare: { shareCalled = true }
        )
        
        view.onShare()
        #expect(shareCalled == true)
    }
    
    @Test("EventCardView displays bookmarked state")
    func testEventCardBookmarkedState() {
        let bookmarkedEvent = Event(
            title: "Event 1",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time",
            isBookmarked: true
        )
        
        let unbookmarkedEvent = Event(
            title: "Event 2",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time",
            isBookmarked: false
        )
        
        let bookmarkedView = EventCardView(
            event: bookmarkedEvent,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        let unbookmarkedView = EventCardView(
            event: unbookmarkedEvent,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        #expect(bookmarkedView.event.isBookmarked == true)
        #expect(unbookmarkedView.event.isBookmarked == false)
    }
    
    @Test("EventCardView displays joined state")
    func testEventCardJoinedState() {
        let joinedEvent = Event(
            title: "Event 1",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time",
            isJoined: true
        )
        
        let unjoinedEvent = Event(
            title: "Event 2",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time",
            isJoined: false
        )
        
        let joinedView = EventCardView(
            event: joinedEvent,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        let unjoinedView = EventCardView(
            event: unjoinedEvent,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        #expect(joinedView.event.isJoined == true)
        #expect(unjoinedView.event.isJoined == false)
    }
    
    @Test("EventCardView handles event without image")
    func testEventCardWithoutImage() {
        let event = Event(
            title: "Event",
            hostedBy: "Host",
            imageURL: nil,
            location: "Location",
            date: Date(),
            time: "Time"
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        #expect(view.event.imageURL == nil)
    }
    
    @Test("EventCardView handles zero attendees")
    func testEventCardZeroAttendees() {
        let event = Event(
            title: "New Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time",
            attendeeCount: 0
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        #expect(view.event.attendeeCount == 0)
    }
    
    @Test("EventCardView handles many attendees")
    func testEventCardManyAttendees() {
        let event = Event(
            title: "Popular Event",
            hostedBy: "Big Host",
            location: "Arena",
            date: Date(),
            time: "Time",
            attendeeCount: 500
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        #expect(view.event.attendeeCount == 500)
    }
    
    @Test("EventCardView handles attendee profile images")
    func testEventCardAttendeeImages() {
        let images = ["user1.jpg", "user2.jpg", "user3.jpg"]
        let event = Event(
            title: "Event",
            hostedBy: "Host",
            location: "Location",
            date: Date(),
            time: "Time",
            attendeeCount: 10,
            attendeeProfileImages: images
        )
        
        let view = EventCardView(
            event: event,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        
        #expect(view.event.attendeeProfileImages.count == 3)
    }
}
