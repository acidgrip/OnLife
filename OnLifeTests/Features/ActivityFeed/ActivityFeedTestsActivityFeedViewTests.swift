//
//  ActivityFeedViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("ActivityFeedView Tests")
@MainActor
struct ActivityFeedViewTests {
    
    @Test("ActivityFeedView initializes successfully")
    func testActivityFeedViewInitialization() {
        let view = ActivityFeedView()
        
        // View should initialize without errors
        #expect(view.body != nil)
    }
    
    @Test("ActivityFeedView can be rendered")
    func testActivityFeedViewRendering() {
        let view = ActivityFeedView()
        
        // View body should be accessible
        let body = view.body
        #expect(body != nil)
    }
}

@Suite("NotificationsPlaceholderView Tests")
@MainActor
struct NotificationsPlaceholderViewTests {
    
    @Test("NotificationsPlaceholderView initializes successfully")
    func testNotificationsPlaceholderViewInitialization() {
        let view = NotificationsPlaceholderView()
        
        // View should initialize without errors
        #expect(view.body != nil)
    }
}

@Suite("MessagesPlaceholderView Tests")
@MainActor
struct MessagesPlaceholderViewTests {
    
    @Test("MessagesPlaceholderView initializes successfully")
    func testMessagesPlaceholderViewInitialization() {
        let view = MessagesPlaceholderView()
        
        // View should initialize without errors
        #expect(view.body != nil)
    }
}
