//
//  SignUpSessionTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 7/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("Sign Up Session Tests")
struct SignUpSessionTests {

    @Test("Session initializes with empty/default values")
    @MainActor
    func testInitialState() async {
        let session = SignUpSession()

        #expect(session.phoneNumber.isEmpty)
        #expect(session.verificationID == nil)
        #expect(session.dateOfBirth == nil)
        #expect(session.profilePhotoURL == nil)
        #expect(session.publicPhotoURL == nil)
        #expect(session.privatePhotoURLs.isEmpty)
    }

    @Test("Session retains values written to it across the wizard")
    @MainActor
    func testSessionRetainsValues() async {
        let session = SignUpSession()

        session.phoneNumber = "+15551234567"
        session.verificationID = "verification-id"
        session.dateOfBirth = Date(timeIntervalSince1970: 0)
        session.profilePhotoURL = "https://mock-storage.example.com/profile.jpg"
        session.publicPhotoURL = "https://mock-storage.example.com/public.jpg"
        session.privatePhotoURLs = ["https://mock-storage.example.com/private_0.jpg"]

        #expect(session.phoneNumber == "+15551234567")
        #expect(session.verificationID == "verification-id")
        #expect(session.dateOfBirth == Date(timeIntervalSince1970: 0))
        #expect(session.profilePhotoURL == "https://mock-storage.example.com/profile.jpg")
        #expect(session.publicPhotoURL == "https://mock-storage.example.com/public.jpg")
        #expect(session.privatePhotoURLs == ["https://mock-storage.example.com/private_0.jpg"])
    }

    @Test("Session is a reference type shared across screens")
    @MainActor
    func testSessionIsReferenceType() async {
        let session = SignUpSession()

        func mutate(_ session: SignUpSession) {
            session.phoneNumber = "1234567890"
        }

        mutate(session)

        #expect(session.phoneNumber == "1234567890")
    }
}
