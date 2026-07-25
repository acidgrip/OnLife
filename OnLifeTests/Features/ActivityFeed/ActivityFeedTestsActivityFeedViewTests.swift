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

        // `body` is `some View` - a concrete, non-optional opaque type that
        // isn't Equatable/ExpressibleByNilLiteral, so `!= nil` doesn't
        // compile. Evaluating it without crashing is the assertion.
        _ = view.body
    }

    @Test("ActivityFeedView can be rendered")
    func testActivityFeedViewRendering() {
        let view = ActivityFeedView()

        // View body should be accessible
        let body = view.body
        _ = body
    }
}

@Suite("NotificationsPlaceholderView Tests")
@MainActor
struct NotificationsPlaceholderViewTests {
    
    @Test("NotificationsPlaceholderView initializes successfully")
    func testNotificationsPlaceholderViewInitialization() {
        let view = NotificationsPlaceholderView()

        // View should initialize without errors ("body" is a non-optional
        // `some View`, so this just confirms it evaluates without crashing)
        _ = view.body
    }
}

@Suite("MessagesPlaceholderView Tests")
@MainActor
struct MessagesPlaceholderViewTests {
    
    @Test("MessagesPlaceholderView initializes successfully")
    func testMessagesPlaceholderViewInitialization() {
        let view = MessagesPlaceholderView()

        // View should initialize without errors ("body" is a non-optional
        // `some View`, so this just confirms it evaluates without crashing)
        _ = view.body
    }
}
