//
//  String+Email.swift
//  Onlife
//
//  Created by Daniel Lee on 7/30/26.
//

import Foundation

extension String {
    /// A version of this string normalized for use as a Firebase Auth email
    /// address: leading/trailing whitespace trimmed, then lowercased.
    ///
    /// Firebase Auth already stores/matches account emails in lowercase
    /// internally, but normalizing on the client too makes sign-in, account
    /// creation, and credential linking explicitly case-insensitive from the
    /// user's point of view ("Jane@Example.com" and "jane@example.com" are
    /// the same account), and keeps any email we persist ourselves (e.g. in
    /// a Firestore user profile) consistent with what Firebase Auth actually
    /// stores for that account.
    var normalizedEmail: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
