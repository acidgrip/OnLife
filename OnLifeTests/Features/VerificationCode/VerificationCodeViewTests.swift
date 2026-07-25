//
//  VerificationCodeViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Verification Code View Tests")
struct VerificationCodeViewTests {

    @Test("View initializes with a session")
    @MainActor
    func testViewInitializationWithSession() async {
        let session = SignUpSession()
        session.phoneNumber = "+1234567890"

        let view = VerificationCodeView(session: session)

        #expect(view.session.phoneNumber == "+1234567890")
    }

    @Test("View reflects updates made to the session it was given")
    @MainActor
    func testViewReflectsSessionUpdates() async {
        let session = SignUpSession()
        let view = VerificationCodeView(session: session)

        session.phoneNumber = "1234567890"

        #expect(view.session.phoneNumber == "1234567890")
    }

    @Test("View has focus state for input fields")
    @MainActor
    func testViewHasFocusState() async {
        let view = VerificationCodeView(session: SignUpSession())

        let mirror = Mirror(reflecting: view)
        let hasFocusState = mirror.children.contains { $0.label == "_focusedField" }

        #expect(hasFocusState, "View should have focus state")
    }

    @Test("View body can be rendered")
    @MainActor
    func testViewBodyRendering() async {
        let view = VerificationCodeView(session: SignUpSession())

        _ = view.body
    }

    @Test("View handles empty phone number gracefully")
    @MainActor
    func testEmptyPhoneNumber() async {
        let view = VerificationCodeView(session: SignUpSession())

        #expect(view.session.phoneNumber.isEmpty)
        _ = view.body
    }
}
