//
//  SignUpSession.swift
//  Onlife
//
//  Created by Daniel Lee on 7/25/26.
//

import Foundation

/// Shared, in-memory state threaded through the sign-up wizard
/// (`SignUpView` → `VerificationCodeView` → `VerificationBirthdayView` →
/// `AddPhotosView` → `CreateProfileView`). Created once in `SignUpView` and
/// passed by reference so each screen can read what earlier screens
/// collected without every `init` needing every field.
@Observable
@MainActor
final class SignUpSession {
    var phoneNumber: String = ""
    var verificationID: String?
    var dateOfBirth: Date?
    var profilePhotoURL: String?
    var publicPhotoURL: String?
    var privatePhotoURLs: [String] = []
}
