//
//  AuthService.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore

/// Manages user authentication state
@MainActor
@Observable
final class AuthService {
    
    static let shared = AuthService()
    
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    
    nonisolated(unsafe) private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        // Only set up listener if Firebase is configured
        guard FirebaseApp.app() != nil else {
            print("⚠️ AuthService: Firebase not configured, skipping auth listener")
            return
        }
        
        // Listen for auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.currentUser = user
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    /// Sign in anonymously for testing (before implementing full auth)
    func signInAnonymously() async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }
        let result = try await Auth.auth().signInAnonymously()
        currentUser = result.user
    }
    
    /// Sign out the current user
    func signOut() throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }
        try Auth.auth().signOut()
        currentUser = nil
    }
    
    /// Get the current user's ID
    var currentUserId: String? {
        currentUser?.uid
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case firebaseNotConfigured
    
    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured. Please add GoogleService-Info.plist to your project."
        }
    }
}
