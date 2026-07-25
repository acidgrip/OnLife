//
//  UserProfileTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 7/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("User Profile Tests")
struct UserProfileTests {

    @Test("Initializes with required fields and sensible defaults")
    func testDefaults() {
        let profile = UserProfile(id: "user-1", username: "jane_doe", name: "Jane Doe")

        #expect(profile.id == "user-1")
        #expect(profile.username == "jane_doe")
        #expect(profile.name == "Jane Doe")
        #expect(profile.bio.isEmpty)
        #expect(profile.phoneNumber == nil)
        #expect(profile.email == nil)
        #expect(profile.dateOfBirth == nil)
        #expect(profile.profilePhotoURL == nil)
        #expect(profile.publicPhotoURL == nil)
        #expect(profile.privatePhotoURLs.isEmpty)
    }

    @Test("Round-trips through Codable")
    func testCodableRoundTrip() throws {
        let original = UserProfile(
            id: "user-1",
            phoneNumber: "+15551234567",
            email: "jane@example.com",
            username: "jane_doe",
            name: "Jane Doe",
            bio: "Hello!",
            dateOfBirth: Date(timeIntervalSince1970: 0),
            profilePhotoURL: "https://mock-storage.example.com/profile.jpg",
            publicPhotoURL: "https://mock-storage.example.com/public.jpg",
            privatePhotoURLs: ["https://mock-storage.example.com/private_0.jpg"],
            createdAt: Date(timeIntervalSince1970: 1000)
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.phoneNumber == original.phoneNumber)
        #expect(decoded.email == original.email)
        #expect(decoded.username == original.username)
        #expect(decoded.name == original.name)
        #expect(decoded.bio == original.bio)
        #expect(decoded.dateOfBirth == original.dateOfBirth)
        #expect(decoded.profilePhotoURL == original.profilePhotoURL)
        #expect(decoded.publicPhotoURL == original.publicPhotoURL)
        #expect(decoded.privatePhotoURLs == original.privatePhotoURLs)
        #expect(decoded.createdAt == original.createdAt)
    }
}
