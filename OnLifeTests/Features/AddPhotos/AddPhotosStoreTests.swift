//
//  AddPhotosStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import Foundation
@testable import OnLife

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@Suite("Add Photos Store Tests")
struct AddPhotosStoreTests {

    // MARK: - Test Helpers

    /// A `PhotoItem` doesn't need a real decodable image for these tests -
    /// only its `data` is read (by `uploadPhotos`), so an empty placeholder
    /// image is enough to satisfy the non-optional `image` field.
    private func makePhotoItem(bytes: [UInt8] = [0x1, 0x2, 0x3], type: AddPhotosStore.PhotoType) -> PhotoItem {
        #if os(iOS)
        let image = UIImage()
        #else
        let image = NSImage()
        #endif
        return PhotoItem(id: UUID(), data: Data(bytes), image: image, type: type)
    }

    // MARK: - Initialization Tests

    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = AddPhotosStore(session: SignUpSession(), database: MockDatabaseService())

        #expect(store.profilePhoto == nil)
        #expect(store.publicPhoto == nil)
        #expect(store.privatePhotos == [nil, nil, nil, nil])
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
    }

    // MARK: - Form Validation Tests

    @Test("Form is invalid without a profile photo")
    @MainActor
    func testFormInvalidWithoutProfilePhoto() async {
        let store = AddPhotosStore(session: SignUpSession(), database: MockDatabaseService())

        #expect(!store.hasMinimumPhotos)
        #expect(!store.isFormValid)
    }

    @Test("Form is valid with only a profile photo")
    @MainActor
    func testFormValidWithProfilePhotoOnly() async {
        let store = AddPhotosStore(session: SignUpSession(), database: MockDatabaseService())
        store.profilePhoto = makePhotoItem(type: .profile)

        #expect(store.hasMinimumPhotos)
        #expect(store.isFormValid)
    }

    // MARK: - Photo Removal Tests

    @Test("Removing profile photo clears it")
    @MainActor
    func testRemoveProfilePhoto() async {
        let store = AddPhotosStore(session: SignUpSession(), database: MockDatabaseService())
        store.profilePhoto = makePhotoItem(type: .profile)

        store.removeProfilePhoto()

        #expect(store.profilePhoto == nil)
    }

    @Test("Removing private photo at index clears only that slot")
    @MainActor
    func testRemovePrivatePhoto() async {
        let store = AddPhotosStore(session: SignUpSession(), database: MockDatabaseService())
        store.privatePhotos[1] = makePhotoItem(type: .privatePhoto)

        store.removePrivatePhoto(at: 1)

        #expect(store.privatePhotos[1] == nil)
    }

    // MARK: - Selected Photo Count Tests

    @Test("Selected photo count reflects all populated slots")
    @MainActor
    func testSelectedPhotoCount() async {
        let store = AddPhotosStore(session: SignUpSession(), database: MockDatabaseService())
        store.profilePhoto = makePhotoItem(type: .profile)
        store.publicPhoto = makePhotoItem(type: .publicPhoto)
        store.privatePhotos[0] = makePhotoItem(type: .privatePhoto)

        #expect(store.selectedPhotoCount == 3)
        #expect(store.photoCountText == "3/6 photos")
    }

    // MARK: - Upload Tests

    @Test("Uploading photos writes URLs onto the session")
    @MainActor
    func testUploadPhotosWritesSessionURLs() async throws {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        try await mockAuth.signInAnonymously()

        let session = SignUpSession()
        let store = AddPhotosStore(session: session, database: MockDatabaseService(), authService: mockAuth)
        store.profilePhoto = makePhotoItem(type: .profile)
        store.publicPhoto = makePhotoItem(type: .publicPhoto)
        store.privatePhotos[0] = makePhotoItem(type: .privatePhoto)

        await store.uploadPhotos()

        #expect(!store.showError)
        #expect(store.showSuccess)
        #expect(session.profilePhotoURL != nil)
        #expect(session.publicPhotoURL != nil)
        #expect(session.privatePhotoURLs.count == 1)
        mockAuth.reset()
    }

    @Test("Uploading photos fails without a profile photo")
    @MainActor
    func testUploadPhotosFailsWithoutProfilePhoto() async {
        let session = SignUpSession()
        let store = AddPhotosStore(session: session, database: MockDatabaseService())

        await store.uploadPhotos()

        #expect(store.showError)
        #expect(!store.showSuccess)
        #expect(session.profilePhotoURL == nil)
    }

    @Test("Uploading skips empty private photo slots")
    @MainActor
    func testUploadSkipsEmptyPrivateSlots() async throws {
        let mockAuth = MockAuthService()
        mockAuth.reset()
        try await mockAuth.signInAnonymously()

        let session = SignUpSession()
        let store = AddPhotosStore(session: session, database: MockDatabaseService(), authService: mockAuth)
        store.profilePhoto = makePhotoItem(type: .profile)
        // Leave publicPhoto and all privatePhotos empty

        await store.uploadPhotos()

        #expect(store.showSuccess)
        #expect(session.publicPhotoURL == nil)
        #expect(session.privatePhotoURLs.isEmpty)
        mockAuth.reset()
    }

    // MARK: - Reset Tests

    @Test("Reset clears all photo and status state")
    @MainActor
    func testReset() async {
        let store = AddPhotosStore(session: SignUpSession(), database: MockDatabaseService())
        store.profilePhoto = makePhotoItem(type: .profile)
        store.publicPhoto = makePhotoItem(type: .publicPhoto)
        store.privatePhotos[0] = makePhotoItem(type: .privatePhoto)
        store.showError = true
        store.showSuccess = true
        store.errorMessage = "Oops"

        store.reset()

        #expect(store.profilePhoto == nil)
        #expect(store.publicPhoto == nil)
        #expect(store.privatePhotos == [nil, nil, nil, nil])
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
    }
}
