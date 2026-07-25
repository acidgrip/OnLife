//
//  VerificationBirthdayViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Verification Birthday View Tests")
struct VerificationBirthdayViewTests {

    @Test("View initializes with a session")
    @MainActor
    func testViewInitializationWithSession() async {
        let session = SignUpSession()
        session.phoneNumber = "1234567890"

        let view = VerificationBirthdayView(session: session)

        #expect(view.session.phoneNumber == "1234567890")
    }

    @Test("View body can be rendered")
    @MainActor
    func testViewBodyRendering() async {
        let view = VerificationBirthdayView(session: SignUpSession())

        _ = view.body
    }

    @Test("View has a store with default state")
    @MainActor
    func testViewHasStore() async {
        let view = VerificationBirthdayView(session: SignUpSession())

        let mirror = Mirror(reflecting: view)
        let hasStore = mirror.children.contains { $0.label == "_store" }

        #expect(hasStore, "View should have a store")
    }
}
