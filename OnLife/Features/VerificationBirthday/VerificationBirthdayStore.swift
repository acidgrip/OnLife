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
    
    /// Submit birthday for verification
    func submitBirthday() async {
        // Validate age requirement
        guard meetsMinimumAge else {
            showErrorMessage("You must be at least 13 years old to use this service")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await submitBirthdayToBackend(birthday: selectedDate)
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    /// Calculate age from birth date
    private func calculateAge(from birthDate: Date) -> Int? {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year
    }
    
    /// Submit birthday to backend (placeholder)
    private func submitBirthdayToBackend(birthday: Date) async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        // In production, this would be an actual API call to your backend
        // Example:
        // let response = try await NetworkService.shared.submitBirthday(birthday)
        // if !response.success {
        //     throw BirthdayError.invalidDate
        // }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        print("✅ Birthday submitted: \(formatter.string(from: birthday))")
    }
    
    /// Show error message
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
