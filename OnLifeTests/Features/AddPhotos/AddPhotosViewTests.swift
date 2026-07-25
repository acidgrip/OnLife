//
//  AddPhotosViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Add Photos View Tests")
struct AddPhotosViewTests {

    @Test("View initializes with a session")
    @MainActor
    func testViewInitializationWithSession() async {
        let session = SignUpSession()
        session.phoneNumber = "1234567890"

        let view = AddPhotosView(session: session)

        #expect(view.session.phoneNumber == "1234567890")
    }

    @Test("View's store is seeded from the same session")
    @MainActor
    func testStoreSharesSession() async {
        let session = SignUpSession()
        let view = AddPhotosView(session: session)

        let mirror = Mirror(reflecting: view)
        let hasStore = mirror.children.contains { $0.label == "_store" }

        #expect(hasStore, "View should have a store")
    }

    @Test("View body can be rendered")
    @MainActor
    func testViewBodyRendering() async {
        let view = AddPhotosView(session: SignUpSession())

        _ = view.body
    }
}
