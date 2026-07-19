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
    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?
    
    // MARK: - Constants
    
    private let maxUsernameLength = 30
    private let maxNameLength = 50
    private let maxBioLength = 150
    
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
    
    /// Check if the entire form is valid
    var isFormValid: Bool {
        isUsernameValid && isNameValid && isBioValid
    }
    
    /// Check if username format is valid (alphanumeric and underscores only)
    private var isUsernameFormatValid: Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        return username.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
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
    
    /// Create the user profile
    func createProfile() async {
        guard isFormValid else {
            showErrorMessage("Please complete all required fields correctly")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await createProfileWithBackend()
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Backend Communication (Placeholder)
    
    private func createProfileWithBackend() async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        // Simulate profile creation
        // In production, this would be an actual API call to your backend
        // Example:
        // let profile = Profile(username: username, name: name, bio: bio)
        // try await NetworkService.shared.createProfile(profile)
        
        print("✅ Profile created:")
        print("   Username: \(username)")
        print("   Name: \(name)")
        print("   Bio: \(bio.isEmpty ? "(empty)" : bio)")
        
        // For demo purposes, accept any valid input
        // In production, you might need to handle:
        // - Username already taken
        // - Invalid characters detected by server
        // - Network errors
        // - etc.
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
        showError = false
        showSuccess = false
        errorMessage = nil
    }
}
