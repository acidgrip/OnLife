//
//  VerificationBirthdayStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

@Observable
@MainActor
final class VerificationBirthdayStore {
    // MARK: - Published State

    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?
    var selectedDate: Date

    // MARK: - Computed Properties

    /// Minimum allowed birth date (must be at least 13 years old)
    var minimumDate: Date {
        Calendar.current.date(byAdding: .year, value: -120, to: Date()) ?? Date()
    }

    /// Maximum allowed birth date (must be at least 13 years old for most platforms)
    var maximumDate: Date {
        Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    }

    /// Check if user meets minimum age requirement (13 years)
    var meetsMinimumAge: Bool {
        guard let age = calculateAge(from: selectedDate) else { return false }
        return age >= 13
    }

    /// Check if the form is valid
    var isFormValid: Bool {
        meetsMinimumAge
    }

    /// Formatted date string for display (e.g., "8 November 2022")
    var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    // MARK: - Initialization

    init(initialDate: Date? = nil) {
        // Default to a reasonable date if none provided
        if let initialDate = initialDate {
            self.selectedDate = initialDate
        } else {
            // Default to 25 years ago
            self.selectedDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
        }
    }

    // MARK: - Public Methods

    /// Update the selected date
    func updateDate(_ date: Date) {
        selectedDate = date
    }

    /// Validate the birthday and record it on `session`. This is purely
    /// local validation - there's no backend call, since the birthday is
    /// only persisted once the whole profile is written in CreateProfileStore.
    func submitBirthday(session: SignUpSession) async {
        guard meetsMinimumAge else {
            showErrorMessage("You must be at least 13 years old to use this service")
            return
        }

        session.dateOfBirth = selectedDate
        showSuccess = true
    }

    // MARK: - Private Methods

    /// Calculate age from birth date
    private func calculateAge(from birthDate: Date) -> Int? {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year
    }

    /// Show error message
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
