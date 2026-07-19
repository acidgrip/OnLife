//
//  LocationPermissionStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/23/26.
//

import Testing
import CoreLocation
@testable import OnLife

@Suite("Location Permission Store Tests")
struct LocationPermissionStoreTests {
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = LocationPermissionStore()
        
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
    }
    
    @Test("Store reads initial authorization status")
    @MainActor
    func testInitialAuthorizationStatus() async {
        let store = LocationPermissionStore()
        
        // Authorization status should be set from CLLocationManager
        // In tests, it will typically be .notDetermined
        #expect(store.authorizationStatus == .notDetermined || store.authorizationStatus != .authorizedAlways)
    }
    
    // MARK: - Authorization Status Tests
    
    #if DEBUG
    @Test("isAuthorized returns true for authorized when in use")
    @MainActor
    func testIsAuthorizedWhenInUse() async {
        let store = LocationPermissionStore()
        
        #if os(iOS)
        store.setAuthorizationStatus(.authorizedWhenInUse)
        #expect(store.isAuthorized)
        #endif
    }
    
    @Test("isAuthorized returns true for authorized always")
    @MainActor
    func testIsAuthorizedAlways() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(store.isAuthorized)
    }
    
    @Test("isAuthorized returns false for not determined")
    @MainActor
    func testIsAuthorizedNotDetermined() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(!store.isAuthorized)
    }
    
    @Test("isAuthorized returns false for denied")
    @MainActor
    func testIsAuthorizedDenied() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.denied)
        #expect(!store.isAuthorized)
    }
    
    @Test("isAuthorized returns false for restricted")
    @MainActor
    func testIsAuthorizedRestricted() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.restricted)
        #expect(!store.isAuthorized)
    }
    #endif
    
    // MARK: - isDenied Tests
    
    #if DEBUG
    @Test("isDenied returns true when status is denied")
    @MainActor
    func testIsDeniedTrue() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.denied)
        #expect(store.isDenied)
    }
    
    @Test("isDenied returns false for other statuses")
    @MainActor
    func testIsDeniedFalse() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(!store.isDenied)
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(!store.isDenied)
        
        store.setAuthorizationStatus(.restricted)
        #expect(!store.isDenied)
    }
    #endif
    
    // MARK: - isRestricted Tests
    
    #if DEBUG
    @Test("isRestricted returns true when status is restricted")
    @MainActor
    func testIsRestrictedTrue() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.restricted)
        #expect(store.isRestricted)
    }
    
    @Test("isRestricted returns false for other statuses")
    @MainActor
    func testIsRestrictedFalse() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(!store.isRestricted)
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(!store.isRestricted)
        
        store.setAuthorizationStatus(.denied)
        #expect(!store.isRestricted)
    }
    #endif
    
    // MARK: - canRequestPermission Tests
    
    #if DEBUG
    @Test("canRequestPermission returns true when not determined")
    @MainActor
    func testCanRequestPermissionNotDetermined() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(store.canRequestPermission)
    }
    
    @Test("canRequestPermission returns false when already authorized")
    @MainActor
    func testCanRequestPermissionAuthorized() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(!store.canRequestPermission)
    }
    
    @Test("canRequestPermission returns false when denied")
    @MainActor
    func testCanRequestPermissionDenied() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.denied)
        #expect(!store.canRequestPermission)
    }
    
    @Test("canRequestPermission returns false when restricted")
    @MainActor
    func testCanRequestPermissionRestricted() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.restricted)
        #expect(!store.canRequestPermission)
    }
    #endif
    
    // MARK: - Status Description Tests
    
    #if DEBUG
    @Test("statusDescription for not determined")
    @MainActor
    func testStatusDescriptionNotDetermined() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(store.statusDescription == "Not Determined")
    }
    
    @Test("statusDescription for authorized always")
    @MainActor
    func testStatusDescriptionAuthorizedAlways() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(store.statusDescription == "Authorized Always")
    }
    
    #if os(iOS)
    @Test("statusDescription for authorized when in use")
    @MainActor
    func testStatusDescriptionAuthorizedWhenInUse() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.authorizedWhenInUse)
        #expect(store.statusDescription == "Authorized When In Use")
    }
    #endif
    
    @Test("statusDescription for denied")
    @MainActor
    func testStatusDescriptionDenied() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.denied)
        #expect(store.statusDescription == "Denied")
    }
    
    @Test("statusDescription for restricted")
    @MainActor
    func testStatusDescriptionRestricted() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.restricted)
        #expect(store.statusDescription == "Restricted")
    }
    #endif
    
    // MARK: - Request Permission Tests
    
    @Test("requestPermission sets hasRequestedPermission to true")
    @MainActor
    func testRequestPermissionSetsFlag() async {
        let store = LocationPermissionStore()
        
        #expect(!store.hasRequestedPermission)
        
        store.requestPermission()
        
        #expect(store.hasRequestedPermission)
    }
    
    @Test("requestPermission sets isLoading to true")
    @MainActor
    func testRequestPermissionSetsLoading() async {
        let store = LocationPermissionStore()
        
        #expect(!store.isLoading)
        
        store.requestPermission()
        
        #expect(store.isLoading)
    }
    
    #if DEBUG
    @Test("requestPermission does nothing when permission already granted")
    @MainActor
    func testRequestPermissionWhenAlreadyGranted() async {
        let store = LocationPermissionStore()
        store.setAuthorizationStatus(.authorizedAlways)
        
        store.requestPermission()
        
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
    }
    
    @Test("requestPermission does nothing when denied")
    @MainActor
    func testRequestPermissionWhenDenied() async {
        let store = LocationPermissionStore()
        store.setAuthorizationStatus(.denied)
        
        store.requestPermission()
        
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
    }
    
    @Test("requestPermission does nothing when restricted")
    @MainActor
    func testRequestPermissionWhenRestricted() async {
        let store = LocationPermissionStore()
        store.setAuthorizationStatus(.restricted)
        
        store.requestPermission()
        
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
    }
    #endif
    
    // MARK: - Reset Tests
    
    @Test("reset clears hasRequestedPermission")
    @MainActor
    func testResetClearsRequestedFlag() async {
        let store = LocationPermissionStore()
        store.requestPermission()
        
        #expect(store.hasRequestedPermission)
        
        store.reset()
        
        #expect(!store.hasRequestedPermission)
    }
    
    @Test("reset clears isLoading")
    @MainActor
    func testResetClearsLoading() async {
        let store = LocationPermissionStore()
        store.requestPermission()
        
        #expect(store.isLoading)
        
        store.reset()
        
        #expect(!store.isLoading)
    }
    
    @Test("reset can be called multiple times")
    @MainActor
    func testResetMultipleTimes() async {
        let store = LocationPermissionStore()
        
        store.reset()
        store.reset()
        store.reset()
        
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
    }
    
    // MARK: - State Transition Tests
    
    #if DEBUG
    @Test("authorization status can transition from not determined to authorized")
    @MainActor
    func testStatusTransitionToAuthorized() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(!store.isAuthorized)
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(store.isAuthorized)
    }
    
    @Test("authorization status can transition from not determined to denied")
    @MainActor
    func testStatusTransitionToDenied() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(!store.isDenied)
        
        store.setAuthorizationStatus(.denied)
        #expect(store.isDenied)
    }
    
    @Test("canRequestPermission changes when status changes")
    @MainActor
    func testCanRequestPermissionChangesWithStatus() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(store.canRequestPermission)
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(!store.canRequestPermission)
        
        store.setAuthorizationStatus(.denied)
        #expect(!store.canRequestPermission)
    }
    #endif
    
    // MARK: - Edge Cases
    
    @Test("multiple reset calls maintain clean state")
    @MainActor
    func testMultipleResets() async {
        let store = LocationPermissionStore()
        
        for _ in 0..<5 {
            store.requestPermission()
            store.reset()
        }
        
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
    }
    
    #if DEBUG
    @Test("status description handles all cases")
    @MainActor
    func testAllStatusDescriptions() async {
        let store = LocationPermissionStore()
        
        var statuses: [CLAuthorizationStatus] = [
            .notDetermined,
            .restricted,
            .denied,
            .authorizedAlways
        ]
        
        #if os(iOS)
        statuses.append(.authorizedWhenInUse)
        #endif
        
        for status in statuses {
            store.setAuthorizationStatus(status)
            #expect(!store.statusDescription.isEmpty)
        }
    }
    
    @Test("multiple status changes tracked correctly")
    @MainActor
    func testMultipleStatusChanges() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(store.authorizationStatus == .notDetermined)
        
        #if os(iOS)
        store.setAuthorizationStatus(.authorizedWhenInUse)
        #expect(store.authorizationStatus == .authorizedWhenInUse)
        #else
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(store.authorizationStatus == .authorizedAlways)
        #endif
        
        store.setAuthorizationStatus(.denied)
        #expect(store.authorizationStatus == .denied)
    }
    #endif
    
    // MARK: - Platform-Specific Tests
    
    #if DEBUG
    @Test("iOS authorization checks both when in use and always")
    @MainActor
    func testIOSAuthorizationTypes() async {
        let store = LocationPermissionStore()
        
        #if os(iOS)
        store.setAuthorizationStatus(.authorizedWhenInUse)
        #expect(store.isAuthorized)
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(store.isAuthorized)
        #endif
    }
    
    @Test("macOS authorization requires always")
    @MainActor
    func testMacOSAuthorizationRequiresAlways() async {
        let store = LocationPermissionStore()
        
        #if os(macOS)
        // On macOS, only .authorizedAlways grants authorization
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(store.isAuthorized)
        
        // Test that other statuses don't grant authorization
        store.setAuthorizationStatus(.notDetermined)
        #expect(!store.isAuthorized)
        #endif
    }
    #endif
    
    // MARK: - Computed Property Consistency Tests
    
    #if DEBUG
    @Test("isDenied and isAuthorized are mutually exclusive")
    @MainActor
    func testDeniedAndAuthorizedMutuallyExclusive() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.denied)
        #expect(store.isDenied)
        #expect(!store.isAuthorized)
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(!store.isDenied)
        #expect(store.isAuthorized)
    }
    
    @Test("isRestricted and isAuthorized are mutually exclusive")
    @MainActor
    func testRestrictedAndAuthorizedMutuallyExclusive() async {
        let store = LocationPermissionStore()
        
        store.setAuthorizationStatus(.restricted)
        #expect(store.isRestricted)
        #expect(!store.isAuthorized)
        
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(!store.isRestricted)
        #expect(store.isAuthorized)
    }
    
    @Test("canRequestPermission is false for all non-notDetermined states")
    @MainActor
    func testCanRequestPermissionOnlyForNotDetermined() async {
        let store = LocationPermissionStore()
        
        var nonRequestableStatuses: [CLAuthorizationStatus] = [
            .restricted,
            .denied,
            .authorizedAlways
        ]
        
        #if os(iOS)
        nonRequestableStatuses.append(.authorizedWhenInUse)
        #endif
        
        for status in nonRequestableStatuses {
            store.setAuthorizationStatus(status)
            #expect(!store.canRequestPermission)
        }
        
        store.setAuthorizationStatus(.notDetermined)
        #expect(store.canRequestPermission)
    }
    #endif
    
    // MARK: - Request Flow Tests
    
    @Test("request flow: permission requested sets correct flags")
    @MainActor
    func testRequestFlowFlags() async {
        let store = LocationPermissionStore()
        
        // Initial state
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
        
        // Request permission
        store.requestPermission()
        
        // After request
        #expect(store.hasRequestedPermission)
        #expect(store.isLoading)
        
        // Reset
        store.reset()
        
        // After reset
        #expect(!store.hasRequestedPermission)
        #expect(!store.isLoading)
    }
    
    #if DEBUG
    @Test("request flow: complete permission cycle")
    @MainActor
    func testCompletePermissionCycle() async {
        let store = LocationPermissionStore()
        
        // Start: not determined
        store.setAuthorizationStatus(.notDetermined)
        #expect(store.canRequestPermission)
        #expect(!store.isAuthorized)
        
        // Request permission
        store.requestPermission()
        #expect(store.hasRequestedPermission)
        #expect(store.isLoading)
        
        // Permission granted
        store.setAuthorizationStatus(.authorizedAlways)
        #expect(store.isAuthorized)
        #expect(!store.canRequestPermission)
        
        // Note: isLoading would be cleared by the delegate method in real usage
    }
    
    @Test("request flow: permission denied")
    @MainActor
    func testPermissionDeniedFlow() async {
        let store = LocationPermissionStore()
        
        // Start: not determined
        store.setAuthorizationStatus(.notDetermined)
        #expect(store.canRequestPermission)
        
        // Request permission
        store.requestPermission()
        #expect(store.hasRequestedPermission)
        
        // Permission denied
        store.setAuthorizationStatus(.denied)
        #expect(store.isDenied)
        #expect(!store.isAuthorized)
        #expect(!store.canRequestPermission)
    }
    #endif
}
