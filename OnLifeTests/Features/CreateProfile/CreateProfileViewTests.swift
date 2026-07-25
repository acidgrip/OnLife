//
//  CreateProfileViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Create Profile View Tests")
struct CreateProfileViewTests {

    @Test("View initializes with a session")
    @MainActor
    func testViewInitializationWithSession() async {
        let session = SignUpSession()
        session.phoneNumber = "1234567890"

        let view = CreateProfileView(session: session)

        #expect(view.session.phoneNumber == "1234567890")
    }

    @Test("View has a focus state for its fields")
    @MainActor
    func testViewHasFocusState() async {
        let view = CreateProfileView(session: SignUpSession())

        let mirror = Mirror(reflecting: view)
        let hasFocusState = mirror.children.contains { $0.label == "_focusedField" }

        #expect(hasFocusState, "View should have focus state")
    }

    @Test("View body can be rendered")
    @MainActor
    func testViewBodyRendering() async {
        let view = CreateProfileView(session: SignUpSession())

        _ = view.body
    }
}
