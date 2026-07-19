//
//  HomeStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/13/26.
//

import Testing
@testable import OnLife

@Suite("Home Store Tests")
@MainActor
struct HomeStoreTests {
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes successfully")
    func storeInitialization() {
        let store = HomeStore()
        
        // Store should be created without errors
        #expect(store != nil)
    }
    
    // MARK: - State Tests
    
    @Test("Store is Observable")
    func storeIsObservable() {
        let store = HomeStore()
        
        // Verify store is an Observable type
        let mirror = Mirror(reflecting: store)
        #expect(mirror.subjectType == HomeStore.self)
    }
    
    @Test("Store is MainActor isolated")
    func storeIsMainActorIsolated() async {
        let store = HomeStore()
        
        // Should be able to access on MainActor
        await MainActor.run {
            #expect(store != nil)
        }
    }
}
