//
//  EventTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("Event Model Tests")
struct EventTests {
    
    @Test("Event initializes with all properties")
    func testEventInitialization() {
        let eventDate = Date()
        let event = Event(
            id: "event-123",
            title: "Summer BBQ",
            hostedBy: "John's House",
            imageURL: "https://example.com/bbq.jpg",
            location: "123 Main St",
            date: eventDate,
            time: "6:00 PM",
            attendeeCount: 15,
            attendeeProfileImages: ["url1", "url2", "url3"],
            isBookmarked: true,
            isJoined: true
        )
        
        #expect(event.id == "event-123")
        #expect(event.title == "Summer BBQ")
        #expect(event.hostedBy == "John's House")
        #expect(event.imageURL == "https://example.com/bbq.jpg")
        #expect(event.location == "123 Main St")
        #expect(event.date == eventDate)
        #expect(event.time == "6:00 PM")
        #expect(event.attendeeCount == 15)
        #expect(event.attendeeProfileImages.count == 3)
        #expect(event.isBookmarked == true)
        #expect(event.isJoined == true)
    }
    
    @Test("Event initializes with default values")
    func testEventDefaultInitialization() {
        let date = Date()
        let event = Event(
            title: "Yoga Session",
            hostedBy: "Wellness Center",
            location: "Park",
            date: date,
            time: "9:00 AM"
        )
        
        #expect(!event.id.isEmpty)
        #expect(event.title == "Yoga Session")
        #expect(event.hostedBy == "Wellness Center")
        #expect(event.imageURL == nil)
        #expect(event.location == "Park")
        #expect(event.attendeeCount == 0)
        #expect(event.attendeeProfileImages.isEmpty)
        #expect(event.isBookmarked == false)
        #expect(event.isJoined == false)
    }
    
    @Test("Event without image URL")
    func testEventWithoutImage() {
        let event = Event(
            title: "Book Club",
            hostedBy: "Library",
            imageURL: nil,
            location: "Downtown Library",
            date: Date(),
            time: "7:00 PM"
        )
        
        #expect(event.imageURL == nil)
        #expect(event.title == "Book Club")
    }
    
    @Test("Event conforms to Identifiable")
    func testEventIdentifiable() {
        let event1 = Event(
            id: "event-1",
            title: "Event 1",
            hostedBy: "Host 1",
            location: "Location 1",
            date: Date(),
            time: "1:00 PM"
        )
        let event2 = Event(
            id: "event-2",
            title: "Event 2",
            hostedBy: "Host 2",
            location: "Location 2",
            date: Date(),
            time: "2:00 PM"
        )
        
        #expect(event1.id != event2.id)
    }
    
    @Test("Event with no attendees")
    func testEventWithNoAttendees() {
        let event = Event(
            title: "New Event",
            hostedBy: "Organizer",
            location: "Venue",
            date: Date(),
            time: "5:00 PM",
            attendeeCount: 0
        )
        
        #expect(event.attendeeCount == 0)
        #expect(event.attendeeProfileImages.isEmpty)
    }
    
    @Test("Event with multiple attendees")
    func testEventWithMultipleAttendees() {
        let attendeeImages = ["user1.jpg", "user2.jpg", "user3.jpg", "user4.jpg"]
        let event = Event(
            title: "Popular Event",
            hostedBy: "Big Organizer",
            location: "Convention Center",
            date: Date(),
            time: "10:00 AM",
            attendeeCount: 50,
            attendeeProfileImages: attendeeImages
        )
        
        #expect(event.attendeeCount == 50)
        #expect(event.attendeeProfileImages.count == 4)
    }
    
    @Test("Event bookmark status can be toggled")
    func testEventBookmarkStatus() {
        var event = Event(
            title: "Concert",
            hostedBy: "Music Hall",
            location: "Downtown",
            date: Date(),
            time: "8:00 PM",
            isBookmarked: false
        )
        
        #expect(event.isBookmarked == false)
        
        event = Event(
            id: event.id,
            title: event.title,
            hostedBy: event.hostedBy,
            imageURL: event.imageURL,
            location: event.location,
            date: event.date,
            time: event.time,
            attendeeCount: event.attendeeCount,
            attendeeProfileImages: event.attendeeProfileImages,
            isBookmarked: true,
            isJoined: event.isJoined
        )
        
        #expect(event.isBookmarked == true)
    }
    
    @Test("Event join status can be toggled")
    func testEventJoinStatus() {
        var event = Event(
            title: "Workshop",
            hostedBy: "Tech Hub",
            location: "Office",
            date: Date(),
            time: "2:00 PM",
            isJoined: false
        )
        
        #expect(event.isJoined == false)
        
        event = Event(
            id: event.id,
            title: event.title,
            hostedBy: event.hostedBy,
            imageURL: event.imageURL,
            location: event.location,
            date: event.date,
            time: event.time,
            attendeeCount: event.attendeeCount,
            attendeeProfileImages: event.attendeeProfileImages,
            isBookmarked: event.isBookmarked,
            isJoined: true
        )
        
        #expect(event.isJoined == true)
    }
    
    @Test("Event date is preserved")
    func testEventDatePreserved() {
        let futureDate = Date(timeIntervalSinceNow: 86400) // Tomorrow
        let event = Event(
            title: "Future Event",
            hostedBy: "Time Travelers",
            location: "Future Place",
            date: futureDate,
            time: "3:00 PM"
        )
        
        #expect(event.date == futureDate)
    }
}
