//
//  UserProfile.swift
//  Onlife
//
//  Created by Daniel Lee on 7/25/26.
//

import Foundation

/// A user's profile document as stored in the "users" Firestore collection.
/// `id` is always the Firebase Auth UID for that user.
struct UserProfile: Identifiable, Codable {
    let id: String
    var phoneNumber: String?
    var email: String?
    var username: String
    var name: String
    var bio: String
    var dateOfBirth: Date?
    var profilePhotoURL: String?
    var publicPhotoURL: String?
    var privatePhotoURLs: [String]
    let createdAt: Date

    init(
        id: String,
        phoneNumber: String? = nil,
        email: String? = nil,
        username: String,
        name: String,
        bio: String = "",
        dateOfBirth: Date? = nil,
        profilePhotoURL: String? = nil,
        publicPhotoURL: String? = nil,
        privatePhotoURLs: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.email = email
        self.username = username
        self.name = name
        self.bio = bio
        self.dateOfBirth = dateOfBirth
        self.profilePhotoURL = profilePhotoURL
        self.publicPhotoURL = publicPhotoURL
        self.privatePhotoURLs = privatePhotoURLs
        self.createdAt = createdAt
    }
}
