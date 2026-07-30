//
//  AuthService.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit
import GoogleSignIn

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Protocol for authentication services
@MainActor
protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var currentUserId: String? { get }

    func signIn(email: String, password: String) async throws
    func createAccount(email: String, password: String) async throws
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws
    func signInWithGoogle() async throws
    func signOut() throws

    /// Starts real Firebase Phone Auth verification for `phoneNumber`.
    /// Returns a verification ID to pass back into `verifyPhoneCode`.
    func sendPhoneVerificationCode(phoneNumber: String) async throws -> String

    /// Completes Firebase Phone Auth by signing in with the SMS `code` sent
    /// for `verificationID`. On success this authenticates the user (sets
    /// `currentUser`), so `isAuthenticated` becomes true.
    func verifyPhoneCode(verificationID: String, code: String) async throws

    /// Attaches an email/password credential to the currently signed-in
    /// user (e.g. one authenticated via phone during sign-up), so they can
    /// later sign in with `signIn(email:password:)` as well.
    func linkEmailPassword(email: String, password: String) async throws

    /// Signs in with an anonymous Firebase Auth account - unlike Phone Auth,
    /// this doesn't require the Firebase project to be on the Blaze billing
    /// plan. Used as a stand-in identity for the sign-up wizard's "Skip
    /// phone verification" testing affordance (see `SignUpStore`), so the
    /// rest of the wizard (which needs a signed-in user to link an
    /// email/password credential onto) still works before phone
    /// verification is turned back on.
    func signInAnonymously() async throws
}

/// Manages user authentication state using Firebase Auth
@MainActor
@Observable
final class AuthService: AuthServiceProtocol {

    static let shared = AuthService()

    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }

    /// True while the user is partway through the sign-up wizard (set once
    /// phone verification succeeds, cleared once the wizard's final step
    /// completes). Transient/in-memory only - see
    /// Features/SignUp/SignUpSession.swift and OnLifeApp.swift for how this
    /// is used to keep the app from routing to HomeView mid-wizard.
    var isOnboarding: Bool = false

    nonisolated(unsafe) private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    nonisolated(unsafe) private var currentNonce: String?

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

    // MARK: - Email/Password Authentication

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }

        let result = try await Auth.auth().signIn(withEmail: email.normalizedEmail, password: password)
        currentUser = result.user
    }

    /// Create a new account with email and password
    func createAccount(email: String, password: String) async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }

        let result = try await Auth.auth().createUser(withEmail: email.normalizedEmail, password: password)
        currentUser = result.user
    }

    // MARK: - Phone Authentication

    /// Sends a real Firebase Phone Auth SMS code to `phoneNumber` (e.g.
    /// "+15551234567"). Returns the verification ID that must be passed
    /// back into `verifyPhoneCode` along with the code the user receives.
    func sendPhoneVerificationCode(phoneNumber: String) async throws -> String {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }

        return try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let verificationID {
                    continuation.resume(returning: verificationID)
                } else {
                    continuation.resume(throwing: AuthError.invalidCredential)
                }
            }
        }
    }

    /// Signs in using the SMS `code` sent for `verificationID`. This is the
    /// point at which the user actually becomes authenticated, so it also
    /// marks `isOnboarding = true` - only the sign-up wizard calls this
    /// method, never returning-user sign-in.
    func verifyPhoneCode(verificationID: String, code: String) async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        let result = try await Auth.auth().signIn(with: credential)
        currentUser = result.user
        isOnboarding = true
    }

    /// Attaches an email/password credential to the currently signed-in
    /// user. Used by the sign-up wizard's final step so a phone-verified
    /// account can also sign in later with `signIn(email:password:)`.
    func linkEmailPassword(email: String, password: String) async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }

        guard let user = currentUser else {
            throw AuthError.invalidCredential
        }

        let credential = EmailAuthProvider.credential(withEmail: email.normalizedEmail, password: password)
        let result = try await user.link(with: credential)
        currentUser = result.user
    }

    // MARK: - Apple Sign In

    /// Sign in with Apple
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }

        // Get the ID token from Apple
        guard let idTokenData = credential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        // Verify we have a nonce
        guard let nonce = currentNonce else {
            throw AuthError.invalidCredential
        }

        // Create Firebase credential
        let firebaseCredential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        // Sign in with Firebase
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        currentUser = result.user

        // Update display name if available (only on first sign in)
        if let fullName = credential.fullName,
           let givenName = fullName.givenName,
           let familyName = fullName.familyName {
            let displayName = "\(givenName) \(familyName)"
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
        }
    }

    /// Generate nonce for Apple Sign In
    /// Call this before presenting Apple Sign In UI
    func prepareAppleSignIn() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    // MARK: - Google Sign In

    /// Sign in with Google
    func signInWithGoogle() async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }

        guard let presentingViewController = Self.currentPresentingViewController() else {
            throw AuthError.noPresentingViewController
        }

        let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)

        guard let idToken = googleResult.user.idToken?.tokenString else {
            throw AuthError.invalidCredential
        }

        let firebaseCredential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleResult.user.accessToken.tokenString
        )

        let result = try await Auth.auth().signIn(with: firebaseCredential)
        currentUser = result.user

        // Update display name if available and not already set (only useful
        // on first sign in - matches the Apple Sign In flow above)
        if result.user.displayName == nil, let googleName = googleResult.user.profile?.name {
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = googleName
            try await changeRequest.commitChanges()
        }
    }

    /// Finds the window to present the Google Sign In UI from.
    /// On iOS, Google's SDK requires a `UIViewController`, but on macOS it uses `NSWindow`.
    #if canImport(UIKit)
    private static func currentPresentingViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
    #else
    private static func currentPresentingViewController() -> NSWindow? {
        NSApplication.shared.keyWindow
    }
    #endif

    // MARK: - Anonymous Sign In

    /// Signs in anonymously. Also marks `isOnboarding = true`, matching
    /// `verifyPhoneCode` above, since this method's other real caller is
    /// `SignUpStore`'s "Skip phone verification" testing path through the
    /// sign-up wizard (this method is never called for a returning user's
    /// sign-in).
    func signInAnonymously() async throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }
        let result = try await Auth.auth().signInAnonymously()
        currentUser = result.user
        isOnboarding = true
    }

    // MARK: - Sign Out

    /// Sign out the current user
    func signOut() throws {
        guard FirebaseApp.app() != nil else {
            throw AuthError.firebaseNotConfigured
        }
        if GIDSignIn.sharedInstance.currentUser != nil {
            GIDSignIn.sharedInstance.signOut()
        }
        try Auth.auth().signOut()
        currentUser = nil
        isOnboarding = false
    }

    // MARK: - User Info

    /// Get the current user's ID
    var currentUserId: String? {
        currentUser?.uid
    }

    /// Get the current user's email
    var currentUserEmail: String? {
        currentUser?.email
    }

    /// Get the current user's display name
    var currentUserDisplayName: String? {
        currentUser?.displayName
    }

    // MARK: - Helper Methods

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case firebaseNotConfigured
    case invalidCredential
    case notImplemented
    case noPresentingViewController

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured. Please add GoogleService-Info.plist to your project."
        case .invalidCredential:
            return "Invalid authentication credential."
        case .notImplemented:
            return "This authentication method is not yet implemented."
        case .noPresentingViewController:
            return "Couldn't find a screen to present sign-in from."
        }
    }
}
