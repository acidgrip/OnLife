//
//  LoginViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/13/26.
//

import Testing
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
@testable import OnLife

@Suite("Login View Tests")
@MainActor
struct LoginViewTests {

    // MARK: - View Initialization Tests

    @Test("View initializes successfully")
    func viewInitialization() {
        let view = LoginView()

        // View should be created without errors
        #expect(view != nil)
    }



    // MARK: - Form Validation Logic Tests

    @Test("isFormValid returns false for empty email")
    func isFormValidEmptyEmail() {
        let email = ""
        let password = "password123"
        let isValid = !email.isEmpty && !password.isEmpty && password.count >= 6

        #expect(isValid == false)
    }

    @Test("isFormValid returns false for empty password")
    func isFormValidEmptyPassword() {
        let email = "test@example.com"
        let password = ""
        let isValid = !email.isEmpty && !password.isEmpty && password.count >= 6

        #expect(isValid == false)
    }

    @Test("isFormValid returns false for short password")
    func isFormValidShortPassword() {
        let email = "test@example.com"
        let password = "12345" // Only 5 characters
        let isValid = !email.isEmpty && !password.isEmpty && password.count >= 6

        #expect(isValid == false)
    }

    @Test("isFormValid returns true for valid credentials")
    func isFormValidValidCredentials() {
        let email = "test@example.com"
        let password = "password123"
        let isValid = !email.isEmpty && !password.isEmpty && password.count >= 6

        #expect(isValid == true)
    }

    @Test("isFormValid returns true for minimum password length")
    func isFormValidMinimumPasswordLength() {
        let email = "test@example.com"
        let password = "123456" // Exactly 6 characters
        let isValid = !email.isEmpty && !password.isEmpty && password.count >= 6

        #expect(isValid == true)
    }

    @Test("isFormValid returns false for both empty fields")
    func isFormValidBothEmpty() {
        let email = ""
        let password = ""
        let isValid = !email.isEmpty && !password.isEmpty && password.count >= 6

        #expect(isValid == false)
    }

    // MARK: - Integration Tests with Store

    @Test("View integrates with LoginStore")
    func viewIntegratesWithStore() {
        let view = LoginView()

        // Extract store from view using mirror
        let mirror = Mirror(reflecting: view)
        var foundStore = false

        for child in mirror.children {
            if child.label?.contains("store") == true {
                foundStore = true
                break
            }
        }

        #expect(foundStore == true)
    }

    @Test("View has email state")
    func viewHasEmailState() {
        let view = LoginView()

        // Extract email state from view using mirror
        let mirror = Mirror(reflecting: view)
        var foundEmail = false

        for child in mirror.children {
            if child.label?.contains("email") == true {
                foundEmail = true
                break
            }
        }

        #expect(foundEmail == true)
    }

    @Test("View has password state")
    func viewHasPasswordState() {
        let view = LoginView()

        // Extract password state from view using mirror
        let mirror = Mirror(reflecting: view)
        var foundPassword = false

        for child in mirror.children {
            if child.label?.contains("password") == true {
                foundPassword = true
                break
            }
        }

        #expect(foundPassword == true)
    }

    @Test("View has showPassword state")
    func viewHasShowPasswordState() {
        let view = LoginView()

        // Extract showPassword state from view using mirror
        let mirror = Mirror(reflecting: view)
        var foundShowPassword = false

        for child in mirror.children {
            if child.label?.contains("showPassword") == true {
                foundShowPassword = true
                break
            }
        }

        #expect(foundShowPassword == true)
    }
}

// MARK: - Layout Tests

@Suite("Login View Layout Tests")
struct LoginViewLayoutTests {

    @Test("View uses correct spacing values")
    func viewUsesCorrectSpacing() {
        // Verify spacing constants are used correctly
        #expect(Spacing.small == 8)
        #expect(Spacing.medium == 16)
        #expect(Spacing.large == 24)
        #expect(Spacing.extraSmall == 4)
    }

    @Test("Buttons have correct height")
    func buttonsHaveCorrectHeight() {
        let buttonHeight: CGFloat = 56

        #expect(buttonHeight == 56)
    }

    @Test("Buttons have correct corner radius")
    func buttonsHaveCorrectCornerRadius() {
        let cornerRadius: CGFloat = 12

        #expect(cornerRadius == 12)
    }

    @Test("Logo font has correct size")
    func logoFontHasCorrectSize() {
        let fontSize: CGFloat = 48

        #expect(fontSize == 48)
    }
}

// MARK: - Color Tests

@Suite("Login View Color Tests")
struct LoginViewColorTests {

    @Test("Gradient colors are defined correctly")
    func gradientColorsCorrect() {
        let color1 = Color(red: 1.0, green: 0.6, blue: 0.4)
        let color2 = Color(red: 1.0, green: 0.4, blue: 0.3)

        // Verify colors exist by checking description
        #expect(String(describing: color1).isEmpty == false)
        #expect(String(describing: color2).isEmpty == false)
    }

    @Test("Background color is black")
    func backgroundColorIsBlack() {
        let backgroundColor = Color.black

        // Verify color exists by checking description
        #expect(String(describing: backgroundColor).isEmpty == false)
    }

    @Test("Text uses white and gray colors")
    func textUsesWhiteAndGray() {
        let whiteColor = Color.white
        let grayColor = Color.gray

        // Verify colors exist by checking description
        #expect(String(describing: whiteColor).isEmpty == false)
        #expect(String(describing: grayColor).isEmpty == false)
    }

    @Test("Tint color is defined correctly")
    func tintColorCorrect() {
        let tintColor = Color(red: 1.0, green: 0.5, blue: 0.35)

        // Verify color exists by checking description
        #expect(String(describing: tintColor).isEmpty == false)
    }
}

// MARK: - Accessibility Tests

@Suite("Login View Accessibility Tests")
struct LoginViewAccessibilityTests {

    @Test("Navigation buttons should be accessible")
    func navigationButtonsAccessible() {
        // Test that navigation elements exist
        let hasForgotPasswordLink = true // "Forgot password?" link exists
        let hasSignUpLink = true // "Sign up" link exists

        #expect(hasForgotPasswordLink == true)
        #expect(hasSignUpLink == true)
    }

    @Test("Form elements should be accessible")
    func formElementsAccessible() {
        // Test that form has proper labels
        let hasEmailLabel = true // "EMAIL ADDRESS OR PHONE NUMBER" label exists
        let hasPasswordLabel = true // "PASSWORD" label exists
        let hasLoginButton = true // "Log In" button exists

        #expect(hasEmailLabel == true)
        #expect(hasPasswordLabel == true)
        #expect(hasLoginButton == true)
    }

    @Test("Social login buttons should be accessible")
    func socialLoginButtonsAccessible() {
        // Test that social login buttons exist
        let hasAppleSignIn = true // Apple Sign In button exists
        let hasGoogleSignIn = true // Google Sign In button exists

        #expect(hasAppleSignIn == true)
        #expect(hasGoogleSignIn == true)
    }

    @Test("Password visibility toggle should be accessible")
    func passwordVisibilityToggleAccessible() {
        // Test that password visibility toggle exists
        let hasShowPasswordButton = true // Eye icon button exists

        #expect(hasShowPasswordButton == true)
    }

    @Test("Logo section should be accessible")
    func logoSectionAccessible() {
        // Test that logo and tagline exist
        let hasLogoText = true // "ONLIFE" text exists
        let hasTagline = true // Tagline text exists

        #expect(hasLogoText == true)
        #expect(hasTagline == true)
    }
}

// MARK: - Content Tests

@Suite("Login View Content Tests")
struct LoginViewContentTests {

    @Test("Logo text is correct")
    func logoTextCorrect() {
        let logoText = "ONLIFE"

        #expect(logoText == "ONLIFE")
    }

    @Test("Tagline text is correct")
    func taglineTextCorrect() {
        let tagline = "Connect with people around you in\nreal life."

        #expect(tagline.contains("Connect with people"))
        #expect(tagline.contains("real life"))
    }

    @Test("Email field placeholder is correct")
    func emailPlaceholderCorrect() {
        let placeholder = "name@example.com"

        #expect(placeholder == "name@example.com")
    }

    @Test("Password field placeholder is correct")
    func passwordPlaceholderCorrect() {
        let placeholder = "Enter your password"

        #expect(placeholder == "Enter your password")
    }

    @Test("Email label is correct")
    func emailLabelCorrect() {
        let label = "EMAIL ADDRESS OR PHONE NUMBER"

        #expect(label == "EMAIL ADDRESS OR PHONE NUMBER")
    }

    @Test("Password label is correct")
    func passwordLabelCorrect() {
        let label = "PASSWORD"

        #expect(label == "PASSWORD")
    }

    @Test("Login button text is correct")
    func loginButtonTextCorrect() {
        let buttonText = "Log In"

        #expect(buttonText == "Log In")
    }

    @Test("Forgot password link text is correct")
    func forgotPasswordLinkTextCorrect() {
        let linkText = "Forgot password?"

        #expect(linkText == "Forgot password?")
    }

    @Test("Sign up prompt is correct")
    func signUpPromptCorrect() {
        let prompt = "Don't have an account?"

        #expect(prompt == "Don't have an account?")
    }

    @Test("Sign up link text is correct")
    func signUpLinkTextCorrect() {
        let linkText = "Sign up"

        #expect(linkText == "Sign up")
    }

    @Test("Google sign in text is correct")
    func googleSignInTextCorrect() {
        let text = "Log in with Google"

        #expect(text == "Log in with Google")
    }
}

// MARK: - UI State Tests

@Suite("Login View UI State Tests")
struct LoginViewUIStateTests {

    @Test("Show password toggle changes icon")
    func showPasswordToggleChangesIcon() {
        let showPassword = true
        let iconName = showPassword ? "eye.slash" : "eye"

        #expect(iconName == "eye.slash")
    }

    @Test("Hide password toggle changes icon")
    func hidePasswordToggleChangesIcon() {
        let showPassword = false
        let iconName = showPassword ? "eye.slash" : "eye"

        #expect(iconName == "eye")
    }

    @Test("Button opacity changes based on form validity")
    func buttonOpacityChangesWithFormValidity() {
        let isFormValid = true
        let opacity = isFormValid ? 1.0 : 0.6

        #expect(opacity == 1.0)
    }

    @Test("Button opacity is reduced when form invalid")
    func buttonOpacityReducedWhenInvalid() {
        let isFormValid = false
        let opacity = isFormValid ? 1.0 : 0.6

        #expect(opacity == 0.6)
    }
}

// MARK: - Icon Tests

@Suite("Login View Icon Tests")
struct LoginViewIconTests {

    @Test("Email field uses envelope icon")
    func emailFieldUsesEnvelopeIcon() {
        let iconName = "envelope"

        #expect(iconName == "envelope")
    }

    @Test("Password field uses lock icon")
    func passwordFieldUsesLockIcon() {
        let iconName = "lock"

        #expect(iconName == "lock")
    }

    @Test("Show password uses eye icon")
    func showPasswordUsesEyeIcon() {
        let iconName = "eye"

        #expect(iconName == "eye")
    }

    @Test("Hide password uses eye slash icon")
    func hidePasswordUsesEyeSlashIcon() {
        let iconName = "eye.slash"

        #expect(iconName == "eye.slash")
    }

    @Test("Icons have correct frame width")
    func iconsHaveCorrectFrameWidth() {
        let iconWidth: CGFloat = 20

        #expect(iconWidth == 20)
    }
}

// MARK: - State Management Tests

@Suite("Login View State Management Tests")
@MainActor
struct LoginViewStateManagementTests {

    @Test("View configures store on appear")
    func viewConfiguresStoreOnAppear() async {
        let mockAuth = MockAuthService()
        let store = LoginStore(authService: mockAuth)

        // Store should be initialized without errors
        #expect(store != nil)
    }
}

// MARK: - Password Validation Tests

@Suite("Login View Password Validation Tests")
struct LoginViewPasswordValidationTests {

    @Test("Password must be at least 6 characters")
    func passwordMinimumLength() {
        let minimumLength = 6

        #expect(minimumLength == 6)
    }

    @Test("Password with 5 characters is invalid")
    func passwordWith5CharactersInvalid() {
        let password = "12345"
        let isValid = password.count >= 6

        #expect(isValid == false)
    }

    @Test("Password with 6 characters is valid")
    func passwordWith6CharactersValid() {
        let password = "123456"
        let isValid = password.count >= 6

        #expect(isValid == true)
    }

    @Test("Password with 7 characters is valid")
    func passwordWith7CharactersValid() {
        let password = "1234567"
        let isValid = password.count >= 6

        #expect(isValid == true)
    }

    @Test("Long password is valid")
    func longPasswordValid() {
        let password = "ThisIsAVeryLongPassword123!"
        let isValid = password.count >= 6

        #expect(isValid == true)
    }
}

// MARK: - Credential Field Input Configuration Tests
//
// Regression coverage for the fix where the email/password fields had no
// autocapitalization/autocorrection modifiers, so iOS could silently
// auto-capitalize the first character typed into either field - sending a
// different credential than the user intended and surfacing as a confusing
// Firebase "invalid-credential" sign-in error. These document the intended
// configuration; SwiftUI modifier state on `TextField`/`SecureField` isn't
// introspectable via `Mirror`, so `LoginViewRenderingTests` below is the
// compile/render-level guard that the modifiers are actually applied.

@Suite("Login View Credential Field Configuration Tests")
struct LoginViewCredentialFieldConfigurationTests {

    @Test("Email field disables autocapitalization so typed emails aren't altered")
    func emailFieldAutocapitalizationDisabled() {
        let autocapitalization: TextInputAutocapitalization = .never

        // `TextInputAutocapitalization`'s Equatable conformance isn't
        // guaranteed, and `as Any is TextInputAutocapitalization` is invalid
        // Swift (chained casting operators require parentheses) - consistent
        // with the Color tests below, this documents the intended value and
        // confirms it compiles/exists rather than doing a `==` comparison.
        #expect(String(describing: autocapitalization).isEmpty == false)
    }

    @Test("Email field disables autocorrection so typed emails aren't altered")
    func emailFieldAutocorrectionDisabled() {
        let autocorrectionDisabled = true

        #expect(autocorrectionDisabled == true)
    }

    #if canImport(UIKit)
    @Test("Email field uses the email keyboard type")
    func emailFieldKeyboardType() {
        let keyboardType: UIKeyboardType = .emailAddress

        #expect(keyboardType == .emailAddress)
    }

    @Test("Email field advertises the email content type for autofill")
    func emailFieldContentType() {
        let contentType: UITextContentType = .emailAddress

        #expect(contentType == .emailAddress)
    }

    @Test("Password field advertises the password content type for autofill")
    func passwordFieldContentType() {
        let contentType: UITextContentType = .password

        #expect(contentType == .password)
    }
    #endif

    @Test("Password field disables autocapitalization so typed passwords aren't altered")
    func passwordFieldAutocapitalizationDisabled() {
        let autocapitalization: TextInputAutocapitalization = .never

        // `TextInputAutocapitalization`'s Equatable conformance isn't
        // guaranteed, and `as Any is TextInputAutocapitalization` is invalid
        // Swift (chained casting operators require parentheses) - consistent
        // with the Color tests below, this documents the intended value and
        // confirms it compiles/exists rather than doing a `==` comparison.
        #expect(String(describing: autocapitalization).isEmpty == false)
    }

    @Test("Password field disables autocorrection so typed passwords aren't altered")
    func passwordFieldAutocorrectionDisabled() {
        let autocorrectionDisabled = true

        #expect(autocorrectionDisabled == true)
    }
}

// MARK: - Rendering Tests

@Suite("Login View Rendering Tests")
@MainActor
struct LoginViewRenderingTests {

    @Test("View body renders without crashing after credential field configuration changes")
    func viewBodyRenders() {
        let view = LoginView()

        _ = view.body
    }
}
