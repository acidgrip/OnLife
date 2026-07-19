//
//  AddPhotosStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
final class AddPhotosStore {
    // MARK: - Published State
    
    var profilePhoto: PhotoItem?
    var publicPhoto: PhotoItem?
    var privatePhotos: [PhotoItem?] = [nil, nil, nil, nil]
    
    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?
    
    // Photo picker state
    var showProfilePhotoPicker = false
    var showPublicPhotoPicker = false
    var selectedPrivatePhotoIndex: Int?
    
    // MARK: - Constants
    
    private let maxFileSize: Int = 10 * 1024 * 1024 // 10 MB
    private let maxPhotos = 6 // 1 profile + 1 public + 4 private
    
    // MARK: - Computed Properties
    
    /// Check if at least profile photo is selected (minimum requirement)
    var hasMinimumPhotos: Bool {
        profilePhoto != nil
    }
    
    /// Check if form is valid for submission
    var isFormValid: Bool {
        hasMinimumPhotos && !isLoading
    }
    
    /// Count of total selected photos
    var selectedPhotoCount: Int {
        var count = 0
        if profilePhoto != nil { count += 1 }
        if publicPhoto != nil { count += 1 }
        count += privatePhotos.compactMap { $0 }.count
        return count
    }
    
    /// Photo count text for display
    var photoCountText: String {
        "\(selectedPhotoCount)/\(maxPhotos) photos"
    }
    
    // MARK: - Photo Selection Actions
    
    /// Select profile photo from picker result
    func selectProfilePhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let photoItem = try await loadPhoto(from: item, type: .profile)
            profilePhoto = photoItem
        } catch {
            showErrorMessage("Failed to load profile photo: \(error.localizedDescription)")
        }
    }
    
    /// Select public photo from picker result
    func selectPublicPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let photoItem = try await loadPhoto(from: item, type: .publicPhoto)
            publicPhoto = photoItem
        } catch {
            showErrorMessage("Failed to load public photo: \(error.localizedDescription)")
        }
    }
    
    /// Select private photo at specific index
    func selectPrivatePhoto(from item: PhotosPickerItem?, at index: Int) async {
        guard let item = item, index >= 0, index < privatePhotos.count else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let photoItem = try await loadPhoto(from: item, type: .privatePhoto)
            privatePhotos[index] = photoItem
        } catch {
            showErrorMessage("Failed to load photo: \(error.localizedDescription)")
        }
    }
    
    /// Remove profile photo
    func removeProfilePhoto() {
        profilePhoto = nil
    }
    
    /// Remove public photo
    func removePublicPhoto() {
        publicPhoto = nil
    }
    
    /// Remove private photo at index
    func removePrivatePhoto(at index: Int) {
        guard index >= 0, index < privatePhotos.count else { return }
        privatePhotos[index] = nil
    }
    
    // MARK: - Photo Loading
    
    private func loadPhoto(from item: PhotosPickerItem, type: PhotoType) async throws -> PhotoItem {
        // Load image data
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw PhotoError.loadFailed
        }
        
        // Validate file size
        guard data.count <= maxFileSize else {
            throw PhotoError.fileTooLarge
        }
        
        // Create UIImage/NSImage to validate it's a valid image
        #if os(iOS)
        guard let image = UIImage(data: data) else {
            throw PhotoError.invalidImage
        }
        #else
        guard let image = NSImage(data: data) else {
            throw PhotoError.invalidImage
        }
        #endif
        
        return PhotoItem(
            id: UUID(),
            data: data,
            image: image,
            type: type
        )
    }
    
    // MARK: - Upload Photos
    
    /// Upload all selected photos
    func uploadPhotos() async {
        guard isFormValid else {
            showErrorMessage("Please select at least a profile photo")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await uploadPhotosToBackend()
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Backend Communication (Placeholder)
    
    private func uploadPhotosToBackend() async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(2))
        
        print("✅ Photos uploaded:")
        if let profilePhoto = profilePhoto {
            print("   Profile Photo: \(profilePhoto.data.count) bytes")
        }
        if let publicPhoto = publicPhoto {
            print("   Public Photo: \(publicPhoto.data.count) bytes")
        }
        let privateCount = privatePhotos.compactMap { $0 }.count
        if privateCount > 0 {
            print("   Private Photos: \(privateCount)")
        }
        
        // In production, this would be an actual API call:
        // Example:
        // let photos = PhotoUploadRequest(
        //     profilePhoto: profilePhoto?.data,
        //     publicPhoto: publicPhoto?.data,
        //     privatePhotos: privatePhotos.compactMap { $0?.data }
        // )
        // try await NetworkService.shared.uploadPhotos(photos)
    }
    
    // MARK: - Helpers
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Reset all photos
    func reset() {
        profilePhoto = nil
        publicPhoto = nil
        privatePhotos = [nil, nil, nil, nil]
        showError = false
        showSuccess = false
        errorMessage = nil
        selectedPrivatePhotoIndex = nil
    }
}

// MARK: - Supporting Types

extension AddPhotosStore {
    enum PhotoType {
        case profile
        case publicPhoto
        case privatePhoto
    }
    
    enum PhotoError: LocalizedError {
        case loadFailed
        case fileTooLarge
        case invalidImage
        
        var errorDescription: String? {
            switch self {
            case .loadFailed:
                return "Failed to load photo"
            case .fileTooLarge:
                return "Photo file size is too large (max 10 MB)"
            case .invalidImage:
                return "Selected file is not a valid image"
            }
        }
    }
}

struct PhotoItem: Identifiable, Equatable {
    let id: UUID
    let data: Data
    #if os(iOS)
    let image: UIImage
    #else
    let image: NSImage
    #endif
    let type: AddPhotosStore.PhotoType
    
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
    }
}
