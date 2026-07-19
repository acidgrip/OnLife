//
//  AppTabBarTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("AppTabBar Tests")
@MainActor
struct AppTabBarTests {
    
    @Test("AppTabBar initializes with selected tab")
    func testAppTabBarInitialization() {
        var selectedTab = AppTab.home
        let binding = Binding(
            get: { selectedTab },
            set: { selectedTab = $0 }
        )
        
        let view = AppTabBar(selectedTab: binding)
        
        #expect(selectedTab == .home)
    }
    
    @Test("AppTabBar binding updates selected tab")
    func testAppTabBarBindingUpdates() {
        var selectedTab = AppTab.home
        let binding = Binding(
            get: { selectedTab },
            set: { selectedTab = $0 }
        )
        
        _ = AppTabBar(selectedTab: binding)
        
        #expect(selectedTab == .home)
        
        binding.wrappedValue = .map
        #expect(selectedTab == .map)
        
        binding.wrappedValue = .explore
        #expect(selectedTab == .explore)
        
        binding.wrappedValue = .calendar
        #expect(selectedTab == .calendar)
        
        binding.wrappedValue = .friends
        #expect(selectedTab == .friends)
    }
    
    @Test("AppTabBar can switch between all tabs")
    func testAppTabBarSwitchingTabs() {
        var selectedTab = AppTab.home
        let binding = Binding(
            get: { selectedTab },
            set: { selectedTab = $0 }
        )
        
        _ = AppTabBar(selectedTab: binding)
        
        for tab in AppTab.allCases {
            binding.wrappedValue = tab
            #expect(selectedTab == tab)
        }
    }
    
    @Test("AppTabBar maintains tab selection")
    func testAppTabBarMaintainsSelection() {
        var selectedTab = AppTab.explore
        let binding = Binding(
            get: { selectedTab },
            set: { selectedTab = $0 }
        )
        
        _ = AppTabBar(selectedTab: binding)
        
        #expect(selectedTab == .explore)
        
        // Verify it doesn't change unexpectedly
        #expect(selectedTab == .explore)
    }
    
    @Test("AppTabBar handles rapid tab switching")
    func testAppTabBarRapidSwitching() {
        var selectedTab = AppTab.home
        let binding = Binding(
            get: { selectedTab },
            set: { selectedTab = $0 }
        )
        
        _ = AppTabBar(selectedTab: binding)
        
        binding.wrappedValue = .map
        binding.wrappedValue = .explore
        binding.wrappedValue = .calendar
        binding.wrappedValue = .friends
        binding.wrappedValue = .home
        
        #expect(selectedTab == .home)
    }
    
    @Test("AppTabBar starts with different tabs")
    func testAppTabBarDifferentStartingTabs() {
        let tabs: [AppTab] = [.map, .explore, .home, .calendar, .friends]
        
        for tab in tabs {
            var selectedTab = tab
            let binding = Binding(
                get: { selectedTab },
                set: { selectedTab = $0 }
            )
            
            _ = AppTabBar(selectedTab: binding)
            
            #expect(selectedTab == tab)
        }
    }
}
