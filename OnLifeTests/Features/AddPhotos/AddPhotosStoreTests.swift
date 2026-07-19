//
//  AddPhotosStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import PhotosUI
@testable import OnLife

@Suite("Add Photos Store Tests")
struct AddPhotosStoreTests {
    
    // MARK: - Test Helpers
    
    @MainActor
    func createMockPhotoItem(type: AddPhotosStore.PhotoType = .profile) -> PhotoItem {
        // Create a 1x1 pixel image for testing
        #if os(iOS)
        let image = UIImage(systemName: "star.fill")!
        let data = image.pngData()!
        #else
        let image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)!
        let data = image.tiffRepresentation!
        #endif
        
        return PhotoItem(
            id: UUID(),
            data: data,
            image: image,
            type: type
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = AddPhotosStore()
        
        #expect(store.profilePhoto == nil)
        #expect(store.publicPhoto == nil)
        #expect(store.privatePhotos.count == 4)
        #expect(store.privatePhotos.allSatisfy { $0 == nil })
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
        #expect(!store.showProfilePhotoPicker)
        #expect(!store.showPublicPhotoPicker)
        #expect(store.selectedPrivatePhotoIndex == nil)
    }
    
    // MARK: - Photo Count Tests
    
    @Test("Selected photo count is zero initially")
    @MainActor
    func testInitialPhotoCount() async {
        let store = AddPhotosStore()
        
        #expect(store.selectedPhotoCount == 0)
        #expect(store.photoCountText == "0/6 photos")
    }
    
    @Test("Photo count increases with profile photo")
    @MainActor
    func testPhotoCountWithProfilePhoto() async {
        let store = AddPhotosStore()
        let mockPhoto = createMockPhotoItem(type: .profile)
        
        store.profilePhoto = mockPhoto
        
        #expect(store.selectedPhotoCount == 1)
        #expect(store.photoCountText == "1/6 photos")
    }
    
    @Test("Photo count increases with public photo")
    @MainActor
    func testPhotoCountWithPublicPhoto() async {
        let store = AddPhotosStore()
        let mockPhoto = createMockPhotoItem(type: .publicPhoto)
        
        store.publicPhoto = mockPhoto
        
        #expect(store.selectedPhotoCount == 1)
        #expect(store.photoCountText == "1/6 photos")
    }
    
    @Test("Photo count with all photos selected")
    @MainActor
    func testPhotoCountWithAllPhotos() async {
        let store = AddPhotosStore()
        
        store.profilePhoto = createMockPhotoItem(type: .profile)
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[1] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[2] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[3] = createMockPhotoItem(type: .privatePhoto)
        
        #expect(store.selectedPhotoCount == 6)
        #expect(store.photoCountText == "6/6 photos")
    }
    
    @Test("Photo count with only private photos")
    @MainActor
    func testPhotoCountWithOnlyPrivatePhotos() async {
        let store = AddPhotosStore()
        
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[2] = createMockPhotoItem(type: .privatePhoto)
        
        #expect(store.selectedPhotoCount == 2)
        #expect(store.photoCountText == "2/6 photos")
    }
    
    // MARK: - Validation Tests
    
    @Test("Minimum photos validation - no photos")
    @MainActor
    func testHasMinimumPhotosWhenEmpty() async {
        let store = AddPhotosStore()
        
        #expect(!store.hasMinimumPhotos)
    }
    
    @Test("Minimum photos validation - with profile photo")
    @MainActor
    func testHasMinimumPhotosWithProfilePhoto() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        #expect(store.hasMinimumPhotos)
    }
    
    @Test("Minimum photos validation - only public photo")
    @MainActor
    func testHasMinimumPhotosWithOnlyPublicPhoto() async {
        let store = AddPhotosStore()
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        
        #expect(!store.hasMinimumPhotos) // Profile photo is required
    }
    
    @Test("Form is invalid when no photos")
    @MainActor
    func testFormInvalidWhenNoPhotos() async {
        let store = AddPhotosStore()
        
        #expect(!store.isFormValid)
    }
    
    @Test("Form is valid with profile photo")
    @MainActor
    func testFormValidWithProfilePhoto() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        #expect(store.isFormValid)
    }
    
    @Test("Form is invalid when loading")
    @MainActor
    func testFormInvalidWhenLoading() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        store.isLoading = true
        
        #expect(!store.isFormValid)
    }
    
    // MARK: - Photo Removal Tests
    
    @Test("Remove profile photo")
    @MainActor
    func testRemoveProfilePhoto() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        #expect(store.profilePhoto != nil)
        
        store.removeProfilePhoto()
        
        #expect(store.profilePhoto == nil)
    }
    
    @Test("Remove public photo")
    @MainActor
    func testRemovePublicPhoto() async {
        let store = AddPhotosStore()
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        
        #expect(store.publicPhoto != nil)
        
        store.removePublicPhoto()
        
        #expect(store.publicPhoto == nil)
    }
    
    @Test("Remove private photo at valid index")
    @MainActor
    func testRemovePrivatePhotoAtValidIndex() async {
        let store = AddPhotosStore()
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[2] = createMockPhotoItem(type: .privatePhoto)
        
        #expect(store.privatePhotos[0] != nil)
        #expect(store.privatePhotos[2] != nil)
        
        store.removePrivatePhoto(at: 0)
        
        #expect(store.privatePhotos[0] == nil)
        #expect(store.privatePhotos[2] != nil) // Other photos unaffected
    }
    
    @Test("Remove private photo at invalid index does nothing")
    @MainActor
    func testRemovePrivatePhotoAtInvalidIndex() async {
        let store = AddPhotosStore()
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        
        // Try to remove at invalid indices
        store.removePrivatePhoto(at: -1)
        store.removePrivatePhoto(at: 10)
        
        #expect(store.privatePhotos[0] != nil) // Photo still there
    }
    
    @Test("Remove all photos")
    @MainActor
    func testRemoveAllPhotos() async {
        let store = AddPhotosStore()
        
        store.profilePhoto = createMockPhotoItem(type: .profile)
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[1] = createMockPhotoItem(type: .privatePhoto)
        
        #expect(store.selectedPhotoCount == 4)
        
        store.removeProfilePhoto()
        store.removePublicPhoto()
        store.removePrivatePhoto(at: 0)
        store.removePrivatePhoto(at: 1)
        
        #expect(store.selectedPhotoCount == 0)
        #expect(store.profilePhoto == nil)
        #expect(store.publicPhoto == nil)
        #expect(store.privatePhotos.allSatisfy { $0 == nil })
    }
    
    // MARK: - Upload Tests
    
    @Test("Upload photos succeeds with profile photo")
    @MainActor
    func testUploadPhotosSuccess() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        await store.uploadPhotos()
        
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
        #expect(store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Upload photos succeeds with all photos")
    @MainActor
    func testUploadPhotosSuccessWithAllPhotos() async {
        let store = AddPhotosStore()
        
        store.profilePhoto = createMockPhotoItem(type: .profile)
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[1] = createMockPhotoItem(type: .privatePhoto)
        
        await store.uploadPhotos()
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Upload photos fails when no photos selected")
    @MainActor
    func testUploadPhotosFailsWithNoPhotos() async {
        let store = AddPhotosStore()
        
        await store.uploadPhotos()
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please select at least a profile photo")
        #expect(!store.showSuccess)
    }
    
    @Test("Upload photos fails when only public photo selected")
    @MainActor
    func testUploadPhotosFailsWithOnlyPublicPhoto() async {
        let store = AddPhotosStore()
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        
        await store.uploadPhotos()
        
        #expect(store.showError)
        #expect(!store.showSuccess)
    }
    
    @Test("Upload photos fails when only private photos selected")
    @MainActor
    func testUploadPhotosFailsWithOnlyPrivatePhotos() async {
        let store = AddPhotosStore()
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        
        await store.uploadPhotos()
        
        #expect(store.showError)
        #expect(!store.showSuccess)
    }
    
    // MARK: - Reset Tests
    
    @Test("Reset clears all photos and state")
    @MainActor
    func testResetClearsAllState() async {
        let store = AddPhotosStore()
        
        // Set up state
        store.profilePhoto = createMockPhotoItem(type: .profile)
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        store.showError = true
        store.errorMessage = "Test error"
        store.selectedPrivatePhotoIndex = 2
        
        store.reset()
        
        #expect(store.profilePhoto == nil)
        #expect(store.publicPhoto == nil)
        #expect(store.privatePhotos.allSatisfy { $0 == nil })
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
        #expect(store.selectedPrivatePhotoIndex == nil)
    }
    
    @Test("Reset after successful upload")
    @MainActor
    func testResetAfterSuccessfulUpload() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        await store.uploadPhotos()
        
        #expect(store.showSuccess)
        
        store.reset()
        
        #expect(!store.showSuccess)
        #expect(store.profilePhoto == nil)
    }
    
    // MARK: - Photo Item Tests
    
    @Test("PhotoItem equality by ID")
    @MainActor
    func testPhotoItemEquality() async {
        let id1 = UUID()
        let id2 = UUID()
        
        #if os(iOS)
        let image = UIImage(systemName: "star.fill")!
        let data = image.pngData()!
        #else
        let image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)!
        let data = image.tiffRepresentation!
        #endif
        
        let photo1 = PhotoItem(id: id1, data: data, image: image, type: .profile)
        let photo2 = PhotoItem(id: id1, data: data, image: image, type: .profile)
        let photo3 = PhotoItem(id: id2, data: data, image: image, type: .profile)
        
        #expect(photo1 == photo2) // Same ID
        #expect(photo1 != photo3) // Different ID
    }
    
    @Test("PhotoItem has correct type")
    @MainActor
    func testPhotoItemType() async {
        let profilePhoto = createMockPhotoItem(type: .profile)
        let publicPhoto = createMockPhotoItem(type: .publicPhoto)
        let privatePhoto = createMockPhotoItem(type: .privatePhoto)
        
        #expect(profilePhoto.type == .profile)
        #expect(publicPhoto.type == .publicPhoto)
        #expect(privatePhoto.type == .privatePhoto)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Photo error descriptions")
    @MainActor
    func testPhotoErrorDescriptions() async {
        let loadFailedError = AddPhotosStore.PhotoError.loadFailed
        let fileTooLargeError = AddPhotosStore.PhotoError.fileTooLarge
        let invalidImageError = AddPhotosStore.PhotoError.invalidImage
        
        #expect(loadFailedError.errorDescription == "Failed to load photo")
        #expect(fileTooLargeError.errorDescription == "Photo file size is too large (max 10 MB)")
        #expect(invalidImageError.errorDescription == "Selected file is not a valid image")
    }
    
    // MARK: - Private Photos Array Tests
    
    @Test("Private photos array has 4 slots")
    @MainActor
    func testPrivatePhotosArraySize() async {
        let store = AddPhotosStore()
        
        #expect(store.privatePhotos.count == 4)
    }
    
    @Test("Can set all private photo slots")
    @MainActor
    func testSetAllPrivatePhotoSlots() async {
        let store = AddPhotosStore()
        
        for i in 0..<4 {
            store.privatePhotos[i] = createMockPhotoItem(type: .privatePhoto)
        }
        
        #expect(store.privatePhotos.allSatisfy { $0 != nil })
        #expect(store.selectedPhotoCount == 4)
    }
    
    @Test("Can set private photos in non-sequential order")
    @MainActor
    func testSetPrivatePhotosNonSequential() async {
        let store = AddPhotosStore()
        
        store.privatePhotos[3] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        
        #expect(store.privatePhotos[0] != nil)
        #expect(store.privatePhotos[1] == nil)
        #expect(store.privatePhotos[2] == nil)
        #expect(store.privatePhotos[3] != nil)
        #expect(store.selectedPhotoCount == 2)
    }
    
    // MARK: - State Management Tests
    
    @Test("Selected private photo index tracking")
    @MainActor
    func testSelectedPrivatePhotoIndex() async {
        let store = AddPhotosStore()
        
        #expect(store.selectedPrivatePhotoIndex == nil)
        
        store.selectedPrivatePhotoIndex = 2
        
        #expect(store.selectedPrivatePhotoIndex == 2)
        
        store.selectedPrivatePhotoIndex = nil
        
        #expect(store.selectedPrivatePhotoIndex == nil)
    }
    
    @Test("Photo picker state toggles")
    @MainActor
    func testPhotoPickerStateToggles() async {
        let store = AddPhotosStore()
        
        #expect(!store.showProfilePhotoPicker)
        #expect(!store.showPublicPhotoPicker)
        
        store.showProfilePhotoPicker = true
        
        #expect(store.showProfilePhotoPicker)
        #expect(!store.showPublicPhotoPicker)
        
        store.showPublicPhotoPicker = true
        
        #expect(store.showProfilePhotoPicker)
        #expect(store.showPublicPhotoPicker)
    }
    
    // MARK: - Edge Cases
    
    @Test("Removing photo that doesn't exist")
    @MainActor
    func testRemovingNonExistentPhoto() async {
        let store = AddPhotosStore()
        
        // Should not crash or error
        store.removeProfilePhoto()
        store.removePublicPhoto()
        store.removePrivatePhoto(at: 0)
        
        #expect(store.profilePhoto == nil)
        #expect(store.publicPhoto == nil)
        #expect(store.privatePhotos[0] == nil)
    }
    
    @Test("Multiple resets in a row")
    @MainActor
    func testMultipleResetsInRow() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        store.reset()
        store.reset()
        store.reset()
        
        #expect(store.profilePhoto == nil)
        #expect(store.selectedPhotoCount == 0)
    }
    
    @Test("Upload with only profile photo (minimum requirement)")
    @MainActor
    func testUploadWithMinimumRequirement() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        #expect(store.isFormValid)
        
        await store.uploadPhotos()
        
        #expect(store.showSuccess)
    }
    
    @Test("Photo count text formatting")
    @MainActor
    func testPhotoCountTextFormatting() async {
        let store = AddPhotosStore()
        
        #expect(store.photoCountText == "0/6 photos")
        
        store.profilePhoto = createMockPhotoItem(type: .profile)
        #expect(store.photoCountText == "1/6 photos")
        
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        #expect(store.photoCountText == "2/6 photos")
        
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        #expect(store.photoCountText == "3/6 photos")
    }
    
    @Test("Complex photo selection scenario")
    @MainActor
    func testComplexPhotoSelectionScenario() async {
        let store = AddPhotosStore()
        
        // Add profile and public
        store.profilePhoto = createMockPhotoItem(type: .profile)
        store.publicPhoto = createMockPhotoItem(type: .publicPhoto)
        #expect(store.selectedPhotoCount == 2)
        
        // Add some private photos
        store.privatePhotos[0] = createMockPhotoItem(type: .privatePhoto)
        store.privatePhotos[2] = createMockPhotoItem(type: .privatePhoto)
        #expect(store.selectedPhotoCount == 4)
        
        // Remove public photo
        store.removePublicPhoto()
        #expect(store.selectedPhotoCount == 3)
        
        // Remove private photo
        store.removePrivatePhoto(at: 0)
        #expect(store.selectedPhotoCount == 2)
        
        // Should still be valid (has profile photo)
        #expect(store.isFormValid)
        
        // Remove profile photo - now invalid
        store.removeProfilePhoto()
        #expect(!store.isFormValid)
        #expect(store.selectedPhotoCount == 1)
    }
    
    @Test("Error state clears on successful operation")
    @MainActor
    func testErrorStateClearsOnSuccess() async {
        let store = AddPhotosStore()
        
        // First fail
        await store.uploadPhotos()
        #expect(store.showError)
        
        // Then succeed
        store.profilePhoto = createMockPhotoItem(type: .profile)
        await store.uploadPhotos()
        
        #expect(store.showSuccess)
    }
    
    @Test("Loading state is properly managed")
    @MainActor
    func testLoadingStateManagement() async {
        let store = AddPhotosStore()
        store.profilePhoto = createMockPhotoItem(type: .profile)
        
        #expect(!store.isLoading)
        
        let task = Task {
            await store.uploadPhotos()
        }
        
        // Give it a moment to start
        try? await Task.sleep(for: .milliseconds(100))
        
        await task.value
        
        #expect(!store.isLoading) // Should be false after completion
    }
}
