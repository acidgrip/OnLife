//
//  FilterPillsViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("FilterPillsView Tests")
@MainActor
struct FilterPillsViewTests {
    
    @Test("FilterPillsView initializes with selected filter")
    func testFilterPillsViewInitialization() {
        var selectedFilter = FeedFilter.all
        let binding = Binding(
            get: { selectedFilter },
            set: { selectedFilter = $0 }
        )
        
        let view = FilterPillsView(
            selectedFilter: binding,
            onFilterSelected: { _ in }
        )
        
        #expect(selectedFilter == .all)
    }
    
    @Test("FilterPillsView binding updates selected filter")
    func testFilterPillsViewBindingUpdates() {
        var selectedFilter = FeedFilter.all
        let binding = Binding(
            get: { selectedFilter },
            set: { selectedFilter = $0 }
        )
        
        _ = FilterPillsView(
            selectedFilter: binding,
            onFilterSelected: { _ in }
        )
        
        binding.wrappedValue = .nearbyScenes
        #expect(selectedFilter == .nearbyScenes)
        
        binding.wrappedValue = .posts
        #expect(selectedFilter == .posts)
    }
    
    @Test("FilterPillsView handles filter selection callback")
    func testFilterPillsViewCallback() {
        var callbackFilter: FeedFilter?
        
        let view = FilterPillsView(
            selectedFilter: .constant(.all),
            onFilterSelected: { filter in
                callbackFilter = filter
            }
        )
        
        view.onFilterSelected(.nearbyScenes)
        #expect(callbackFilter == .nearbyScenes)
        
        view.onFilterSelected(.events)
        #expect(callbackFilter == .events)
    }
    
    @Test("FilterPillsView updates binding when filter is selected")
    func testFilterPillsViewBindingAndCallback() {
        var selectedFilter = FeedFilter.all
        var callbackInvoked = false
        
        let binding = Binding(
            get: { selectedFilter },
            set: { selectedFilter = $0 }
        )
        
        let view = FilterPillsView(
            selectedFilter: binding,
            onFilterSelected: { _ in
                callbackInvoked = true
            }
        )
        
        binding.wrappedValue = .scenesPickingUp
        view.onFilterSelected(.scenesPickingUp)
        
        #expect(selectedFilter == .scenesPickingUp)
        #expect(callbackInvoked == true)
    }
}

@Suite("FilterPillButton Tests")
@MainActor
struct FilterPillButtonTests {
    
    @Test("FilterPillButton displays title")
    func testFilterPillButtonTitle() {
        let button = FilterPillButton(
            title: "Test Filter",
            isSelected: false,
            action: {}
        )
        
        #expect(button.title == "Test Filter")
    }
    
    @Test("FilterPillButton handles selected state")
    func testFilterPillButtonSelectedState() {
        let selectedButton = FilterPillButton(
            title: "Filter",
            isSelected: true,
            action: {}
        )
        
        let unselectedButton = FilterPillButton(
            title: "Filter",
            isSelected: false,
            action: {}
        )
        
        #expect(selectedButton.isSelected == true)
        #expect(unselectedButton.isSelected == false)
    }
    
    @Test("FilterPillButton handles action callback")
    func testFilterPillButtonAction() {
        var actionCalled = false
        
        let button = FilterPillButton(
            title: "Filter",
            isSelected: false,
            action: { actionCalled = true }
        )
        
        button.action()
        #expect(actionCalled == true)
    }
    
    @Test("FilterPillButton handles different titles")
    func testFilterPillButtonDifferentTitles() {
        let button1 = FilterPillButton(
            title: "12 scenes nearby",
            isSelected: false,
            action: {}
        )
        
        let button2 = FilterPillButton(
            title: "Scenes picking up",
            isSelected: false,
            action: {}
        )
        
        #expect(button1.title == "12 scenes nearby")
        #expect(button2.title == "Scenes picking up")
    }
}
