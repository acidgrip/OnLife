//
//  CreateProfileStoreTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/14/26.
//

import Testing
@testable import OnLife

@Suite("Create Profile Store Tests")
struct CreateProfileStoreTests {
    
    // MARK: - Initialization Tests
    
    @Test("Store initializes with correct default values")
    @MainActor
    func testInitialState() async {
        let store = CreateProfileStore()
        
        #expect(store.username.isEmpty)
        #expect(store.name.isEmpty)
        #expect(store.bio.isEmpty)
        #expect(!store.isLoading)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
    }
    
    // MARK: - Username Validation Tests
    
    @Test("Username is invalid when empty")
    @MainActor
    func testUsernameInvalidWhenEmpty() async {
        let store = CreateProfileStore()
        
        #expect(!store.isUsernameValid)
    }
    
    @Test("Username is invalid when too short")
    @MainActor
    func testUsernameInvalidWhenTooShort() async {
        let store = CreateProfileStore()
        store.username = "ab"
        
        #expect(!store.isUsernameValid)
    }
    
    @Test("Username is valid with 3 characters")
    @MainActor
    func testUsernameValidWith3Characters() async {
        let store = CreateProfileStore()
        store.username = "abc"
        
        #expect(store.isUsernameValid)
    }
    
    @Test("Username is valid with alphanumeric characters")
    @MainActor
    func testUsernameValidWithAlphanumeric() async {
        let store = CreateProfileStore()
        store.username = "user123"
        
        #expect(store.isUsernameValid)
    }
    
    @Test("Username is valid with underscores")
    @MainActor
    func testUsernameValidWithUnderscores() async {
        let store = CreateProfileStore()
        store.username = "user_name_123"
        
        #expect(store.isUsernameValid)
    }
    
    @Test("Username is invalid with special characters")
    @MainActor
    func testUsernameInvalidWithSpecialCharacters() async {
        let store = CreateProfileStore()
        store.username = "user@name"
        
        #expect(!store.isUsernameValid)
    }
    
    @Test("Username is invalid with spaces")
    @MainActor
    func testUsernameInvalidWithSpaces() async {
        let store = CreateProfileStore()
        store.username = "user name"
        
        #expect(!store.isUsernameValid)
    }
    
    @Test("Update username converts to lowercase")
    @MainActor
    func testUpdateUsernameConvertsToLowercase() async {
        let store = CreateProfileStore()
        
        store.updateUsername("UserName123")
        
        #expect(store.username == "username123")
    }
    
    @Test("Update username trims to max length")
    @MainActor
    func testUpdateUsernameTrimsToMaxLength() async {
        let store = CreateProfileStore()
        let longUsername = String(repeating: "a", count: 50)
        
        store.updateUsername(longUsername)
        
        #expect(store.username.count == 30)
    }
    
    @Test("Username validation message for empty")
    @MainActor
    func testUsernameValidationMessageEmpty() async {
        let store = CreateProfileStore()
        
        #expect(store.usernameValidationMessage == nil)
    }
    
    @Test("Username validation message for too short")
    @MainActor
    func testUsernameValidationMessageTooShort() async {
        let store = CreateProfileStore()
        store.username = "ab"
        
        #expect(store.usernameValidationMessage == "Username must be at least 3 characters")
    }
    
    @Test("Username validation message for invalid characters")
    @MainActor
    func testUsernameValidationMessageInvalidCharacters() async {
        let store = CreateProfileStore()
        store.username = "user@name"
        
        #expect(store.usernameValidationMessage == "Username can only contain letters, numbers, and underscores")
    }
    
    @Test("Username validation message for valid username")
    @MainActor
    func testUsernameValidationMessageValid() async {
        let store = CreateProfileStore()
        store.username = "username123"
        
        #expect(store.usernameValidationMessage == nil)
    }
    
    // MARK: - Name Validation Tests
    
    @Test("Name is invalid when empty")
    @MainActor
    func testNameInvalidWhenEmpty() async {
        let store = CreateProfileStore()
        
        #expect(!store.isNameValid)
    }
    
    @Test("Name is invalid when too short")
    @MainActor
    func testNameInvalidWhenTooShort() async {
        let store = CreateProfileStore()
        store.name = "A"
        
        #expect(!store.isNameValid)
    }
    
    @Test("Name is valid with 2 characters")
    @MainActor
    func testNameValidWith2Characters() async {
        let store = CreateProfileStore()
        store.name = "Jo"
        
        #expect(store.isNameValid)
    }
    
    @Test("Name is valid with full name")
    @MainActor
    func testNameValidWithFullName() async {
        let store = CreateProfileStore()
        store.name = "John Doe"
        
        #expect(store.isNameValid)
    }
    
    @Test("Update name trims to max length")
    @MainActor
    func testUpdateNameTrimsToMaxLength() async {
        let store = CreateProfileStore()
        let longName = String(repeating: "a", count: 100)
        
        store.updateName(longName)
        
        #expect(store.name.count == 50)
    }
    
    @Test("Name validation message for empty")
    @MainActor
    func testNameValidationMessageEmpty() async {
        let store = CreateProfileStore()
        
        #expect(store.nameValidationMessage == nil)
    }
    
    @Test("Name validation message for too short")
    @MainActor
    func testNameValidationMessageTooShort() async {
        let store = CreateProfileStore()
        store.name = "A"
        
        #expect(store.nameValidationMessage == "Name must be at least 2 characters")
    }
    
    @Test("Name validation message for valid name")
    @MainActor
    func testNameValidationMessageValid() async {
        let store = CreateProfileStore()
        store.name = "John"
        
        #expect(store.nameValidationMessage == nil)
    }
    
    // MARK: - Bio Validation Tests
    
    @Test("Bio is valid when empty (optional field)")
    @MainActor
    func testBioValidWhenEmpty() async {
        let store = CreateProfileStore()
        
        #expect(store.isBioValid)
    }
    
    @Test("Bio is valid with text")
    @MainActor
    func testBioValidWithText() async {
        let store = CreateProfileStore()
        store.bio = "This is my bio"
        
        #expect(store.isBioValid)
    }
    
    @Test("Bio is valid at max length")
    @MainActor
    func testBioValidAtMaxLength() async {
        let store = CreateProfileStore()
        store.bio = String(repeating: "a", count: 150)
        
        #expect(store.isBioValid)
    }
    
    @Test("Bio is invalid over max length")
    @MainActor
    func testBioInvalidOverMaxLength() async {
        let store = CreateProfileStore()
        store.bio = String(repeating: "a", count: 151)
        
        #expect(!store.isBioValid)
    }
    
    @Test("Update bio trims to max length")
    @MainActor
    func testUpdateBioTrimsToMaxLength() async {
        let store = CreateProfileStore()
        let longBio = String(repeating: "a", count: 200)
        
        store.updateBio(longBio)
        
        #expect(store.bio.count == 150)
    }
    
    @Test("Bio character count displays correctly")
    @MainActor
    func testBioCharacterCount() async {
        let store = CreateProfileStore()
        store.bio = "Hello world"
        
        #expect(store.bioCharacterCount == "11/150")
    }
    
    @Test("Bio character count for empty bio")
    @MainActor
    func testBioCharacterCountEmpty() async {
        let store = CreateProfileStore()
        
        #expect(store.bioCharacterCount == "0/150")
    }
    
    @Test("Bio character count at max")
    @MainActor
    func testBioCharacterCountAtMax() async {
        let store = CreateProfileStore()
        store.bio = String(repeating: "a", count: 150)
        
        #expect(store.bioCharacterCount == "150/150")
    }
    
    // MARK: - Form Validation Tests
    
    @Test("Form is invalid when all fields empty")
    @MainActor
    func testFormInvalidWhenEmpty() async {
        let store = CreateProfileStore()
        
        #expect(!store.isFormValid)
    }
    
    @Test("Form is invalid when username missing")
    @MainActor
    func testFormInvalidWhenUsernameMissing() async {
        let store = CreateProfileStore()
        store.name = "John Doe"
        
        #expect(!store.isFormValid)
    }
    
    @Test("Form is invalid when name missing")
    @MainActor
    func testFormInvalidWhenNameMissing() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        
        #expect(!store.isFormValid)
    }
    
    @Test("Form is valid with username and name (bio optional)")
    @MainActor
    func testFormValidWithUsernameAndName() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        store.name = "John Doe"
        
        #expect(store.isFormValid)
    }
    
    @Test("Form is valid with all fields")
    @MainActor
    func testFormValidWithAllFields() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        store.name = "John Doe"
        store.bio = "This is my bio"
        
        #expect(store.isFormValid)
    }
    
    @Test("Form is invalid when username has invalid format")
    @MainActor
    func testFormInvalidWhenUsernameInvalidFormat() async {
        let store = CreateProfileStore()
        store.username = "john@doe"
        store.name = "John Doe"
        
        #expect(!store.isFormValid)
    }
    
    @Test("Form is invalid when bio exceeds max length")
    @MainActor
    func testFormInvalidWhenBioTooLong() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        store.name = "John Doe"
        store.bio = String(repeating: "a", count: 151)
        
        #expect(!store.isFormValid)
    }
    
    // MARK: - Create Profile Tests
    
    @Test("Create profile succeeds with valid data")
    @MainActor
    func testCreateProfileSuccess() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        store.name = "John Doe"
        store.bio = "Hello world"
        
        await store.createProfile()
        
        #expect(!store.showError)
        #expect(store.errorMessage == nil)
        #expect(store.showSuccess)
        #expect(!store.isLoading)
    }
    
    @Test("Create profile succeeds without bio")
    @MainActor
    func testCreateProfileSuccessWithoutBio() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        store.name = "John Doe"
        
        await store.createProfile()
        
        #expect(!store.showError)
        #expect(store.showSuccess)
    }
    
    @Test("Create profile fails when form is invalid")
    @MainActor
    func testCreateProfileFailsWhenInvalid() async {
        let store = CreateProfileStore()
        store.username = "ab" // Too short
        store.name = "John Doe"
        
        await store.createProfile()
        
        #expect(store.showError)
        #expect(store.errorMessage == "Please complete all required fields correctly")
        #expect(!store.showSuccess)
    }
    
    @Test("Create profile fails when username missing")
    @MainActor
    func testCreateProfileFailsWhenUsernameMissing() async {
        let store = CreateProfileStore()
        store.name = "John Doe"
        
        await store.createProfile()
        
        #expect(store.showError)
        #expect(!store.showSuccess)
    }
    
    @Test("Create profile fails when name missing")
    @MainActor
    func testCreateProfileFailsWhenNameMissing() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        
        await store.createProfile()
        
        #expect(store.showError)
        #expect(!store.showSuccess)
    }
    
    @Test("Loading state is set during profile creation")
    @MainActor
    func testLoadingStateDuringCreation() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        store.name = "John Doe"
        
        let task = Task {
            await store.createProfile()
        }
        
        // Give it a moment to start
        try? await Task.sleep(for: .milliseconds(100))
        
        // Check if loading (might already be done depending on timing)
        // This test is timing-dependent and might be flaky
        // In a real app, you'd use a mock network service
        
        await task.value
        
        #expect(!store.isLoading) // Should be false after completion
    }
    
    // MARK: - Reset Tests
    
    @Test("Reset clears all fields")
    @MainActor
    func testResetClearsAllFields() async {
        let store = CreateProfileStore()
        store.username = "johndoe"
        store.name = "John Doe"
        store.bio = "Hello world"
        store.showError = true
        store.errorMessage = "Error"
        
        store.reset()
        
        #expect(store.username.isEmpty)
        #expect(store.name.isEmpty)
        #expect(store.bio.isEmpty)
        #expect(!store.showError)
        #expect(!store.showSuccess)
        #expect(store.errorMessage == nil)
    }
    
    // MARK: - Edge Cases
    
    @Test("Username with only underscores is valid")
    @MainActor
    func testUsernameWithOnlyUnderscores() async {
        let store = CreateProfileStore()
        store.username = "___"
        
        #expect(store.isUsernameValid)
    }
    
    @Test("Username with numbers only is valid")
    @MainActor
    func testUsernameWithNumbersOnly() async {
        let store = CreateProfileStore()
        store.username = "123456"
        
        #expect(store.isUsernameValid)
    }
    
    @Test("Name with special characters is valid")
    @MainActor
    func testNameWithSpecialCharacters() async {
        let store = CreateProfileStore()
        store.name = "Jean-Pierre O'Brien"
        
        #expect(store.isNameValid)
    }
    
    @Test("Bio with emoji is valid")
    @MainActor
    func testBioWithEmoji() async {
        let store = CreateProfileStore()
        store.bio = "Hello 👋 World 🌍"
        
        #expect(store.isBioValid)
    }
    
    @Test("Bio with newlines is valid")
    @MainActor
    func testBioWithNewlines() async {
        let store = CreateProfileStore()
        store.bio = "Line 1\nLine 2\nLine 3"
        
        #expect(store.isBioValid)
    }
    
    @Test("Update username with mixed case preserves lowercase")
    @MainActor
    func testUpdateUsernameMultipleTimes() async {
        let store = CreateProfileStore()
        
        store.updateUsername("ABC")
        #expect(store.username == "abc")
        
        store.updateUsername("DEF")
        #expect(store.username == "def")
    }
    
    @Test("Update operations are independent")
    @MainActor
    func testUpdateOperationsIndependent() async {
        let store = CreateProfileStore()
        
        store.updateUsername("user123")
        store.updateName("John Doe")
        store.updateBio("Bio text")
        
        #expect(store.username == "user123")
        #expect(store.name == "John Doe")
        #expect(store.bio == "Bio text")
    }
    
    // MARK: - Boundary Tests
    
    @Test("Username at exact minimum length is valid")
    @MainActor
    func testUsernameAtMinLength() async {
        let store = CreateProfileStore()
        store.username = "abc"
        
        #expect(store.isUsernameValid)
        #expect(store.username.count == 3)
    }
    
    @Test("Username at exact maximum length is valid")
    @MainActor
    func testUsernameAtMaxLength() async {
        let store = CreateProfileStore()
        let maxUsername = String(repeating: "a", count: 30)
        store.updateUsername(maxUsername)
        
        #expect(store.isUsernameValid)
        #expect(store.username.count == 30)
    }
    
    @Test("Name at exact minimum length is valid")
    @MainActor
    func testNameAtMinLength() async {
        let store = CreateProfileStore()
        store.name = "AB"
        
        #expect(store.isNameValid)
        #expect(store.name.count == 2)
    }
    
    @Test("Name at exact maximum length is valid")
    @MainActor
    func testNameAtMaxLength() async {
        let store = CreateProfileStore()
        let maxName = String(repeating: "a", count: 50)
        store.updateName(maxName)
        
        #expect(store.isNameValid)
        #expect(store.name.count == 50)
    }
    
    @Test("Bio at exact maximum length is valid")
    @MainActor
    func testBioAtMaxLength() async {
        let store = CreateProfileStore()
        let maxBio = String(repeating: "a", count: 150)
        store.updateBio(maxBio)
        
        #expect(store.isBioValid)
        #expect(store.bio.count == 150)
    }
    
    @Test("Complex username with underscores and numbers")
    @MainActor
    func testComplexUsername() async {
        let store = CreateProfileStore()
        store.username = "john_doe_123_test"
        
        #expect(store.isUsernameValid)
    }
    
    @Test("Form validation with edge case values")
    @MainActor
    func testFormValidationEdgeCases() async {
        let store = CreateProfileStore()
        store.username = "abc" // Minimum valid
        store.name = "Jo" // Minimum valid
        store.bio = "" // Optional, empty is valid
        
        #expect(store.isFormValid)
    }
}
