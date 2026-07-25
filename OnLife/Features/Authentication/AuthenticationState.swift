// This file is deprecated and replaced by AuthService.swift
// AuthService now handles all authentication using Firebase Auth
// 
// To migrate:
// - Replace AuthenticationState with AuthService
// - Use AuthService.shared.isAuthenticated instead of isAuthenticated
// - Use AuthService.shared.currentUserId instead of userId
// - Use AuthService.shared.signOut() instead of logout()
//
// This file can be deleted once all references are removed.

#if false

//
//  AuthenticationState.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//  DEPRECATED: Use AuthService instead
//

import Foundation
import SwiftUI

/// Manages the global authentication state of the app
@Observable
@MainActor
final class AuthenticationState {
    
    // MARK: - Published State
    
    /// Whether the user is currently logged in
    var isAuthenticated = false
    
    /// The current user's ID (if authenticated)
    var userId: String?
    
    /// The current user's display name (if available)
    var displayName: String?
    
    /// The current user's email (if available)
    var email: String?
    
    // MARK: - Initialization
    
    init() {
        // Check for existing session on initialization
        checkExistingSession()
    }
    
    // MARK: - Authentication Methods
    
    /// Marks the user as logged in
    func login(userId: String? = nil, email: String? = nil, displayName: String? = nil) {
        self.isAuthenticated = true
        self.userId = userId ?? "temp-user-id"
        self.email = email
        self.displayName = displayName
    }
    
    /// Logs out the current user
    func logout() {
        self.isAuthenticated = false
        self.userId = nil
        self.email = nil
        self.displayName = nil
        
        // Clear any stored credentials
        clearStoredCredentials()
    }
    
    // MARK: - Session Management
    
    /// Checks if there's an existing session stored
    private func checkExistingSession() {
        // TODO: Check UserDefaults, Keychain, or Firebase for existing session
        // For now, default to not authenticated
        
        // Example implementation:
        // if let storedUserId = UserDefaults.standard.string(forKey: "userId") {
        //     self.isAuthenticated = true
        //     self.userId = storedUserId
        // }
    }
    
    /// Clears stored credentials from persistent storage
    private func clearStoredCredentials() {
        // TODO: Clear UserDefaults, Keychain, or Firebase session
        
        // Example implementation:
        // UserDefaults.standard.removeObject(forKey: "userId")
        // KeychainHelper.delete(key: "authToken")
    }
}

#endif
