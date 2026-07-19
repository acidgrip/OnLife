//
//  FeedFilterTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("FeedFilter Model Tests")
struct FeedFilterTests {
    
    @Test("FeedFilter has correct raw values")
    func testFeedFilterRawValues() {
        #expect(FeedFilter.nearbyScenes.rawValue == "12 scenes nearby")
        #expect(FeedFilter.scenesPickingUp.rawValue == "Scenes picking up")
        #expect(FeedFilter.all.rawValue == "All")
        #expect(FeedFilter.posts.rawValue == "Posts")
        #expect(FeedFilter.events.rawValue == "Events")
    }
    
    @Test("FeedFilter conforms to CaseIterable")
    func testFeedFilterCaseIterable() {
        let allCases = FeedFilter.allCases
        
        #expect(allCases.count == 5)
        #expect(allCases.contains(.nearbyScenes))
        #expect(allCases.contains(.scenesPickingUp))
        #expect(allCases.contains(.all))
        #expect(allCases.contains(.posts))
        #expect(allCases.contains(.events))
    }
    
    @Test("FeedFilter conforms to Identifiable")
    func testFeedFilterIdentifiable() {
        let filter1 = FeedFilter.nearbyScenes
        let filter2 = FeedFilter.all
        
        #expect(filter1.id == "12 scenes nearby")
        #expect(filter2.id == "All")
        #expect(filter1.id != filter2.id)
    }
    
    @Test("FeedFilter ID equals raw value")
    func testFeedFilterIDEqualsRawValue() {
        for filter in FeedFilter.allCases {
            #expect(filter.id == filter.rawValue)
        }
    }
    
    @Test("FeedFilter can be compared")
    func testFeedFilterComparison() {
        let filter1 = FeedFilter.nearbyScenes
        let filter2 = FeedFilter.nearbyScenes
        let filter3 = FeedFilter.all
        
        #expect(filter1 == filter2)
        #expect(filter1 != filter3)
    }
    
    @Test("FeedFilter all cases are unique")
    func testFeedFilterUniqueness() {
        let allCases = FeedFilter.allCases
        let uniqueIDs = Set(allCases.map { $0.id })
        
        #expect(uniqueIDs.count == allCases.count)
    }
    
    @Test("FeedFilter ordering is correct")
    func testFeedFilterOrdering() {
        let allCases = Array(FeedFilter.allCases)
        
        #expect(allCases[0] == .nearbyScenes)
        #expect(allCases[1] == .scenesPickingUp)
        #expect(allCases[2] == .all)
        #expect(allCases[3] == .posts)
        #expect(allCases[4] == .events)
    }
}
