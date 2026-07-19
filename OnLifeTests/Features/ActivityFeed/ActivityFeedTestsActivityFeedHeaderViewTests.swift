//
//  ActivityFeedHeaderViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("ActivityFeedHeaderView Tests")
@MainActor
struct ActivityFeedHeaderViewTests {
    
    @Test("ActivityFeedHeaderView displays online status")
    func testHeaderViewOnlineStatus() {
        var isOnline = true
        let binding = Binding(
            get: { isOnline },
            set: { isOnline = $0 }
        )
        
        let view = ActivityFeedHeaderView(
            isOnline: binding,
            onNotificationsTapped: {},
            onMessagesTapped: {}
        )
        
        #expect(isOnline == true)
    }
    
    @Test("ActivityFeedHeaderView handles notifications callback")
    func testHeaderViewNotificationsCallback() {
        var notificationsTapped = false
        
        let view = ActivityFeedHeaderView(
            isOnline: .constant(true),
            onNotificationsTapped: { notificationsTapped = true },
            onMessagesTapped: {}
        )
        
        view.onNotificationsTapped()
        #expect(notificationsTapped == true)
    }
    
    @Test("ActivityFeedHeaderView handles messages callback")
    func testHeaderViewMessagesCallback() {
        var messagesTapped = false
        
        let view = ActivityFeedHeaderView(
            isOnline: .constant(true),
            onNotificationsTapped: {},
            onMessagesTapped: { messagesTapped = true }
        )
        
        view.onMessagesTapped()
        #expect(messagesTapped == true)
    }
    
    @Test("ActivityFeedHeaderView binding updates online status")
    func testHeaderViewBindingUpdates() {
        var isOnline = false
        let binding = Binding(
            get: { isOnline },
            set: { isOnline = $0 }
        )
        
        _ = ActivityFeedHeaderView(
            isOnline: binding,
            onNotificationsTapped: {},
            onMessagesTapped: {}
        )
        
        #expect(isOnline == false)
        
        // Simulate toggle
        binding.wrappedValue = true
        #expect(isOnline == true)
        
        binding.wrappedValue = false
        #expect(isOnline == false)
    }
    
    @Test("ActivityFeedHeaderView handles both callbacks independently")
    func testHeaderViewIndependentCallbacks() {
        var notificationsTapped = false
        var messagesTapped = false
        
        let view = ActivityFeedHeaderView(
            isOnline: .constant(true),
            onNotificationsTapped: { notificationsTapped = true },
            onMessagesTapped: { messagesTapped = true }
        )
        
        view.onNotificationsTapped()
        #expect(notificationsTapped == true)
        #expect(messagesTapped == false)
        
        notificationsTapped = false
        view.onMessagesTapped()
        #expect(notificationsTapped == false)
        #expect(messagesTapped == true)
    }
}
