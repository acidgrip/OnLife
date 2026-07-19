//
//  AppTabTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("AppTab Enum Tests")
struct AppTabTests {
    
    @Test("AppTab has correct raw values")
    func testAppTabRawValues() {
        #expect(AppTab.map.rawValue == "Map")
        #expect(AppTab.explore.rawValue == "Explore")
        #expect(AppTab.home.rawValue == "Home")
        #expect(AppTab.calendar.rawValue == "Calendar")
        #expect(AppTab.friends.rawValue == "Friends")
    }
    
    @Test("AppTab has correct icons")
    func testAppTabIcons() {
        #expect(AppTab.map.icon == "map")
        #expect(AppTab.explore.icon == "safari")
        #expect(AppTab.home.icon == "house.fill")
        #expect(AppTab.calendar.icon == "calendar")
        #expect(AppTab.friends.icon == "person.2")
    }
    
    @Test("AppTab conforms to CaseIterable")
    func testAppTabCaseIterable() {
        let allCases = AppTab.allCases
        
        #expect(allCases.count == 5)
        #expect(allCases.contains(.map))
        #expect(allCases.contains(.explore))
        #expect(allCases.contains(.home))
        #expect(allCases.contains(.calendar))
        #expect(allCases.contains(.friends))
    }
    
    @Test("AppTab ordering is correct")
    func testAppTabOrdering() {
        let allCases = Array(AppTab.allCases)
        
        #expect(allCases[0] == .map)
        #expect(allCases[1] == .explore)
        #expect(allCases[2] == .home)
        #expect(allCases[3] == .calendar)
        #expect(allCases[4] == .friends)
    }
    
    @Test("AppTab can be compared")
    func testAppTabComparison() {
        let tab1 = AppTab.home
        let tab2 = AppTab.home
        let tab3 = AppTab.map
        
        #expect(tab1 == tab2)
        #expect(tab1 != tab3)
    }
    
    @Test("AppTab all cases are unique")
    func testAppTabUniqueness() {
        let allCases = AppTab.allCases
        let uniqueRawValues = Set(allCases.map { $0.rawValue })
        
        #expect(uniqueRawValues.count == allCases.count)
    }
    
    @Test("AppTab icons are all different")
    func testAppTabIconsUnique() {
        let allCases = AppTab.allCases
        let uniqueIcons = Set(allCases.map { $0.icon })
        
        #expect(uniqueIcons.count == allCases.count)
    }
}
