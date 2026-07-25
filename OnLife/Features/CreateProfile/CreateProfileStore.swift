//
//  CreateProfileStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

@Observable
@MainActor
final class CreateProfileStore {
    // MARK: - Published State

    var username: String = ""
    var name: String = ""
    var bio: String = ""
    var email: String = ""
    var password: String = ""
    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?

    // MARK: - Dependencies

    let session: SignUpSession
    private let database: DatabaseService
    private let authService: any AuthServiceProtocol

    // MARK: - Constants

    private let maxUsernameLength = 30
    private let maxNameLength = 50
    private let maxBioLength = 150

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

    // MARK: - Validation

    /// Check if the username is valid
    var isUsernameValid: Bool {
        !username.isEmpty && username.count >= 3 && isUsernameFormatValid
    }

    /// Check if the name is valid
    var isNameValid: Bool {
        !name.isEmpty && name.count >= 2
    }

    /// Check if the bio is valid (optional field)
    var isBioValid: Bool {
        bio.count <= maxBioLength
    }

    /// Check if the email is valid
    var isEmailValid: Bool {
        isValidEmail(email)
    }

    /// Check if the password is valid
    var isPasswordValid: Bool {
        password.count >= 6
    }

    /// Check if the entire form is valid
    var isFormValid: Bool {
        isUsernameValid && isNameValid && isBioValid && isEmailValid && isPasswordValid
    }

    /// Check if username format is valid (alphanumeric and underscores only)
    private var isUsernameFormatValid: Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        return username.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// Get validation message for username
    var usernameValidationMessage: String? {
        if username.isEmpty {
            return nil
        }

        if username.count < 3 {
            return "Username must be at least 3 characters"
        }

        if !isUsernameFormatValid {
            return "Username can only contain letters, numbers, and underscores"
        }

        return nil
    }

    /// Get validation message for name
    var nameValidationMessage: String? {
        if name.isEmpty {
            return nil
        }

        if name.count < 2 {
            return "Name must be at least 2 characters"
        }

        return nil
    }

    /// Get validation message for password
    var passwordValidationMessage: String? {
        if password.isEmpty {
            return nil
        }

        if password.count < 6 {
            return "Password must be at least 6 characters"
        }

        return nil
    }

    /// Get character count for bio
    var bioCharacterCount: String {
        "\(bio.count)/\(maxBioLength)"
    }

    // MARK: - Actions

    /// Update username with validation
    func updateUsername(_ newValue: String) {
        // Trim to max length
        let trimmed = String(newValue.prefix(maxUsernameLength))

        // Convert to lowercase for username
        username = trimmed.lowercased()
    }

    /// Update name with validation
    func updateName(_ newValue: String) {
        // Trim to max length
        name = String(newValue.prefix(maxNameLength))
    }

    /// Update bio with validation
    func updateBio(_ newValue: String) {
        // Trim to max length
        bio = String(newValue.prefix(maxBioLength))
    }

    /// Create the user profile: links an email/password credential onto the
    /// phone-authenticated account (so the user can sign in with either
    /// later), then writes the full profile - assembled from this screen's
    /// fields plus everything collected earlier in `session` - to Firestore.
    func createProfile() async {
        guard isFormValid else {
            showErrorMessage("Please complete all required fields correctly")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.linkEmailPassword(email: email, password: password)

            guard let uid = authService.currentUserId else {
                throw AuthError.invalidCredential
            }

            let profile = UserProfile(
                id: uid,
                phoneNumber: session.phoneNumber,
                email: email,
                username: username,
                name: name,
                bio: bio,
                dateOfBirth: session.dateOfBirth,
                profilePhotoURL: session.profilePhotoURL,
                publicPhotoURL: session.publicPhotoURL,
                privatePhotoURLs: session.privatePhotoURLs
            )

            try await database.createUserProfile(profile)
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    /// Reset all fields
    func reset() {
        username = ""
        name = ""
        bio = ""
        email = ""
        password = ""
        showError = false
        showSuccess = false
        errorMessage = nil
    }
}
