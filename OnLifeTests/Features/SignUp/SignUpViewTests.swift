//
//  SignUpViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Sign Up View Tests")
struct SignUpViewTests {

    @Test("SignUpView initializes successfully")
    @MainActor
    func testViewInitialization() async {
        let view = SignUpView()
        _ = view.body
    }

    @Test("View owns its own SignUpSession")
    @MainActor
    func testViewOwnsSession() async {
        let view = SignUpView()
        let mirror = Mirror(reflecting: view)

        let hasSession = mirror.children.contains { $0.label == "_session" }
        #expect(hasSession, "View should own a SignUpSession")
    }

    @Test("View integrates with SignUpStore")
    @MainActor
    func testStoreIntegration() async {
        let view = SignUpView()
        let mirror = Mirror(reflecting: view)

        let hasStore = mirror.children.contains { $0.label == "_store" }
        #expect(hasStore, "View should have a store")
    }

    @Test("View body renders without crashing")
    @MainActor
    func testViewBodyRendering() async {
        let view = SignUpView()
        _ = view.body
    }
}
