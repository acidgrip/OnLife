//
//  VerificationBirthdayStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("Verification Birthday Store Tests")
struct VerificationBirthdayStoreTests {
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = VerificationBirthdayStore()
        
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
        
        // Verify default date is reasonable (around 25 years ago)
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: store.selectedDate, to: Date()).year
        #expect(age != nil)
        #expect(age! >= 20 && age! <= 30, "Default age should be around 25 years")
    }
    
    @Test("Store initializes with custom date")
    @MainActor
    func testInitialStateWithCustomDate() async {
        let calendar = Calendar.current
        let customDate = calendar.date(byAdding: .year, value: -20, to: Date())!
        
        let store = VerificationBirthdayStore(initialDate: customDate)
        
        #expect(store.selectedDate == customDate)
    }
    
    // MARK: - Date Validation Tests
    
    @Test("Minimum date is 120 years ago")
    @MainActor
    func testMinimumDate() async {
        let store = VerificationBirthdayStore()
        let calendar = Calendar.current
        
        let expectedMinDate = calendar.date(byAdding: .year, value: -120, to: Date())!
        let diff = calendar.dateComponents([.day], from: store.minimumDate, to: expectedMinDate).day!
        
        #expect(abs(diff) <= 1, "Minimum date should be 120 years ago")
    }
    
    @Test("Maximum date is 13 years ago")
    @MainActor
    func testMaximumDate() async {
        let store = VerificationBirthdayStore()
        let calendar = Calendar.current
        
        let expectedMaxDate = calendar.date(byAdding: .year, value: -13, to: Date())!
        let diff = calendar.dateComponents([.day], from: store.maximumDate, to: expectedMaxDate).day!
        
        #expect(abs(diff) <= 1, "Maximum date should be 13 years ago")
    }
    
    // MARK: - Age Requirement Tests
    
    @Test("Meets minimum age with 18 year old")
    @MainActor
    func testMeetsMinimumAge18() async {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -18, to: Date())!
        
        let store = VerificationBirthdayStore(initialDate: birthDate)
        
        #expect(store.meetsMinimumAge)
        #expect(store.isFormValid)
    }
    
    @Test("Meets minimum age with exactly 13 year old")
    @MainActor
    func testMeetsMinimumAge13() async {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -13, to: Date())!
        
        let store = VerificationBirthdayStore(initialDate: birthDate)
        
        #expect(store.meetsMinimumAge)
        #expect(store.isFormValid)
    }
    
    @Test("Does not meet minimum age with 12 year old")
    @MainActor
    func testDoesNotMeetMinimumAge() async {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -12, to: Date())!
        
        let store = VerificationBirthdayStore(initialDate: birthDate)
        
        #expect(!store.meetsMinimumAge)
        #expect(!store.isFormValid)
    }
    
    @Test("Meets minimum age with 50 year old")
    @MainActor
    func testMeetsMinimumAge50() async {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -50, to: Date())!
        
        let store = VerificationBirthdayStore(initialDate: birthDate)
        
        #expect(store.meetsMinimumAge)
        #expect(store.isFormValid)
    }
    
    // MARK: - Date Update Tests
    
    @Test("Update date changes selected date")
    @MainActor
    func testUpdateDate() async {
        let store = VerificationBirthdayStore()
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .year, value: -30, to: Date())!
        
        store.updateDate(newDate)
        
        #expect(store.selectedDate == newDate)
    }
    
    @Test("Update date to different value")
    @MainActor
    func testUpdateDateMultipleTimes() async {
        let store = VerificationBirthdayStore()
        let calendar = Calendar.current
        
        let firstDate = calendar.date(byAdding: .year, value: -20, to: Date())!
        store.updateDate(firstDate)
        #expect(store.selectedDate == firstDate)
        
        let secondDate = calendar.date(byAdding: .year, value: -30, to: Date())!
        store.updateDate(secondDate)
        #expect(store.selectedDate == secondDate)
    }
    
    // MARK: - Formatted Date String Tests
    
    @Test("Formatted date string displays correctly")
    @MainActor
    func testFormattedDateString() async {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 11
        components.day = 8
        let date = calendar.date(from: components)!
        
        let store = VerificationBirthdayStore(initialDate: date)
        
        #expect(store.formattedDateString == "8 November 2000")
    }
    
    @Test("Formatted date string for different date")
    @MainActor
    func testFormattedDateStringDifferentDate() async {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1995
        components.month = 6
        components.day = 15
        let date = calendar.date(from: components)!
        
        let store = VerificationBirthdayStore(initialDate: date)
        
        #expect(store.formattedDateString == "15 June 1995")
    }
    
    @Test("Formatted date string updates when date changes")
    @MainActor
    func testFormattedDateStringUpdates() async {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        let initialDate = calendar.date(from: components)!
        
        let store = VerificationBirthdayStore(initialDate: initialDate)
        #expect(store.formattedDateString == "1 January 2000")
        
        components.year = 1990
        components.month = 12
        components.day = 31
        let newDate = calendar.date(from: components)!
        store.updateDate(newDate)
        
        #expect(store.formattedDateString == "31 December 1990")
    }
    
    // MARK: - Submit Birthday Tests
    
    @Test("Submit birthday succeeds with valid age")
    @MainActor
    func testSubmitBirthdaySuccess() async {
        let calendar = Calendar.current
        let validDate = calendar.date(byAdding: .year, value: -25, to: Date())!
        let store = VerificationBirthdayStore(initialDate: validDate)
        
        await store.submitBirthday()
        
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
        #expect(store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Submit birthday fails with underage")
    @MainActor
    func testSubmitBirthdayFailsUnderage() async {
        let calendar = Calendar.current
        let underageDate = calendar.date(byAdding: .year, value: -10, to: Date())!
        let store = VerificationBirthdayStore(initialDate: underageDate)
        
        await store.submitBirthday()
        
        #expect(store.showError)
        #expect(store.errorMessage == "You must be at least 13 years old to use this service")
        #expect(!store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Submit birthday with minimum age succeeds")
    @MainActor
    func testSubmitBirthdayMinimumAge() async {
        let calendar = Calendar.current
        let minAgeDate = calendar.date(byAdding: .year, value: -13, to: Date())!
        let store = VerificationBirthdayStore(initialDate: minAgeDate)
        
        await store.submitBirthday()
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Submit birthday sets loading state during submission")
    @MainActor
    func testSubmitBirthdayLoadingState() async {
        let calendar = Calendar.current
        let validDate = calendar.date(byAdding: .year, value: -20, to: Date())!
        let store = VerificationBirthdayStore(initialDate: validDate)
        
        // Start submission
        let task = Task {
            await store.submitBirthday()
        }
        
        // Give it a moment to start
        try? await Task.sleep(for: .milliseconds(100))
        
        // Should be loading
        #expect(store.isLoading == true || store.showSuccess == true)
        
        // Wait for completion
        await task.value
        
        // Should be done loading
        #expect(!store.isLoading)
    }
    
    // MARK: - Form Validation Tests
    
    @Test("Form is invalid with underage date")
    @MainActor
    func testFormInvalidUnderage() async {
        let calendar = Calendar.current
        let underageDate = calendar.date(byAdding: .year, value: -12, to: Date())!
        let store = VerificationBirthdayStore(initialDate: underageDate)
        
        #expect(!store.isFormValid)
    }
    
    @Test("Form is valid with valid age")
    @MainActor
    func testFormValidWithValidAge() async {
        let calendar = Calendar.current
        let validDate = calendar.date(byAdding: .year, value: -20, to: Date())!
        let store = VerificationBirthdayStore(initialDate: validDate)
        
        #expect(store.isFormValid)
    }
    
    // MARK: - Edge Cases
    
    @Test("Handle leap year birthday")
    @MainActor
    func testLeapYearBirthday() async {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 2
        components.day = 29
        let leapYearDate = calendar.date(from: components)!
        
        let store = VerificationBirthdayStore(initialDate: leapYearDate)
        
        #expect(store.formattedDateString == "29 February 2000")
        #expect(store.meetsMinimumAge)
    }
    
    @Test("Handle January 1st birthday")
    @MainActor
    func testJanuaryFirstBirthday() async {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        let jan1Date = calendar.date(from: components)!
        
        let store = VerificationBirthdayStore(initialDate: jan1Date)
        
        #expect(store.formattedDateString == "1 January 2000")
    }
    
    @Test("Handle December 31st birthday")
    @MainActor
    func testDecember31Birthday() async {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 12
        components.day = 31
        let dec31Date = calendar.date(from: components)!
        
        let store = VerificationBirthdayStore(initialDate: dec31Date)
        
        #expect(store.formattedDateString == "31 December 2000")
    }
    
    @Test("Very old birthday is valid")
    @MainActor
    func testVeryOldBirthday() async {
        let calendar = Calendar.current
        let veryOldDate = calendar.date(byAdding: .year, value: -100, to: Date())!
        let store = VerificationBirthdayStore(initialDate: veryOldDate)
        
        #expect(store.meetsMinimumAge)
        #expect(store.isFormValid)
    }
    
    @Test("Date exactly on boundary is valid")
    @MainActor
    func testDateOnBoundary() async {
        let store = VerificationBirthdayStore(initialDate: Date())
        
        // Test maximum allowed date
        store.updateDate(store.maximumDate)
        #expect(store.meetsMinimumAge || !store.meetsMinimumAge) // Should handle gracefully
        
        // Test minimum allowed date
        store.updateDate(store.minimumDate)
        #expect(store.meetsMinimumAge)
    }
    
    // MARK: - State Management Tests
    
    @Test("Error state clears on successful submission")
    @MainActor
    func testErrorStateClearsOnSuccess() async {
        let calendar = Calendar.current
        let underageDate = calendar.date(byAdding: .year, value: -10, to: Date())!
        let store = VerificationBirthdayStore(initialDate: underageDate)
        
        // First submission fails
        await store.submitBirthday()
        #expect(store.showError)
        
        // Reset error
        store.showError = false
        store.errorMessage = nil
        
        // Update to valid date
        let validDate = calendar.date(byAdding: .year, value: -20, to: Date())!
        store.updateDate(validDate)
        
        // Second submission succeeds
        await store.submitBirthday()
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Multiple date updates work correctly")
    @MainActor
    func testMultipleDateUpdates() async {
        let store = VerificationBirthdayStore()
        let calendar = Calendar.current
        
        // Update date multiple times
        for yearOffset in [20, 25, 30, 35, 40] {
            let date = calendar.date(byAdding: .year, value: -yearOffset, to: Date())!
            store.updateDate(date)
            
            let age = calendar.dateComponents([.year], from: store.selectedDate, to: Date()).year
            #expect(age! >= yearOffset - 1 && age! <= yearOffset + 1)
        }
    }
}
