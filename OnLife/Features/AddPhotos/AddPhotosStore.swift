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

    // MARK: - Dependencies

    let session: SignUpSession
    private let database: DatabaseService
    private let authService: any AuthServiceProtocol

    // MARK: - Constants

    private let maxFileSize: Int = 10 * 1024 * 1024 // 10 MB
    private let maxPhotos = 6 // 1 profile + 1 public + 4 private

    // MARK: - Initialization

    init(
        session: SignUpSession,
        database: DatabaseService? = nil,
        authService: any AuthServiceProtocol = AuthService.shared
    ) {
        self.session = session
        self.database = database ?? DatabaseManager.shared.service
        self.authService = authService
    }

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

    /// Upload all selected photos to Firebase Storage and record their URLs
    /// on `session` for CreateProfileStore to write into the user's profile.
    func uploadPhotos() async {
        guard isFormValid else {
            showErrorMessage("Please select at least a profile photo")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let uid = authService.currentUserId ?? "unknown"

            if let profilePhoto {
                session.profilePhotoURL = try await database.uploadImage(
                    imageData: profilePhoto.data,
                    path: "users/\(uid)/profile.jpg"
                )
            }

            if let publicPhoto {
                session.publicPhotoURL = try await database.uploadImage(
                    imageData: publicPhoto.data,
                    path: "users/\(uid)/public.jpg"
                )
            }

            var privateURLs: [String] = []
            for (index, photo) in privatePhotos.enumerated() {
                guard let photo else { continue }
                let url = try await database.uploadImage(
                    imageData: photo.data,
                    path: "users/\(uid)/private_\(index).jpg"
                )
                privateURLs.append(url)
            }
            session.privatePhotoURLs = privateURLs

            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }

    /// Skips real photo upload for developing/testing without a device photo
    /// library (e.g. the Simulator's Photos app is often empty, or picking
    /// photos there doesn't work as expected). Bypasses Firebase Storage
    /// entirely and leaves `session`'s photo URL fields unset, then signals
    /// success exactly like `uploadPhotos()` so the wizard still proceeds to
    /// `CreateProfileView`. This is a **temporary testing affordance** - the
    /// button that calls this in `AddPhotosView` is wrapped in `#if DEBUG`
    /// so it never ships in a Release build.
    func skipPhotoUpload() {
        showSuccess = true
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
