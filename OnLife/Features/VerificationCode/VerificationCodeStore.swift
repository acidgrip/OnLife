//
//  VerificationCodeStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

@Observable
@MainActor
final class VerificationCodeStore {
    // MARK: - Published State
    
    var isLoading = false
    var showError = false
    var showSuccess = false
    var errorMessage: String?
    var verificationCode: [String] = Array(repeating: "", count: 6)
    var resendCountdown: Int = 30
    var canResend: Bool = false
    
    // MARK: - Private State
    
    private nonisolated(unsafe) var countdownTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {
        startResendCountdown()
    }
    
    deinit {
        countdownTask?.cancel()
    }
    
    // MARK: - Verification Methods
    
    /// Verify the entered code
    func verifyCode(emailOrPhone: String) async {
        let code = verificationCode.joined()
        
        // Validate code is complete
        guard code.count == 6 else {
            showErrorMessage("Please enter the complete 6-digit code")
            return
        }
        
        // Validate code contains only digits
        guard code.allSatisfy({ $0.isNumber }) else {
            showErrorMessage("Verification code must contain only numbers")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await verifyCodeWithBackend(code: code, emailOrPhone: emailOrPhone)
            showSuccess = true
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    /// Resend verification code
    func resendCode(to emailOrPhone: String) async {
        guard canResend else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await sendVerificationCodeToBackend(emailOrPhone: emailOrPhone)
            
            // Reset countdown
            resendCountdown = 30
            canResend = false
            startResendCountdown()
            
            // Clear existing code
            verificationCode = Array(repeating: "", count: 6)
            
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    /// Update a specific digit in the verification code
    func updateDigit(at index: Int, with value: String) {
        guard index >= 0 && index < verificationCode.count else { return }
        
        // Only allow single digit
        let filtered = value.filter { $0.isNumber }
        verificationCode[index] = String(filtered.prefix(1))
    }
    
    /// Clear a specific digit
    func clearDigit(at index: Int) {
        guard index >= 0 && index < verificationCode.count else { return }
        verificationCode[index] = ""
    }
    
    /// Check if the form is valid (all 6 digits entered)
    var isFormValid: Bool {
        verificationCode.allSatisfy { !$0.isEmpty }
    }
    
    // MARK: - Countdown Timer
    
    private func startResendCountdown() {
        countdownTask?.cancel()
        
        countdownTask = Task {
            while resendCountdown > 0 {
                try? await Task.sleep(for: .seconds(1))
                
                guard !Task.isCancelled else { return }
                
                resendCountdown -= 1
                
                if resendCountdown == 0 {
                    canResend = true
                }
            }
        }
    }
    
    // MARK: - Backend Communication (Placeholder)
    
    private func verifyCodeWithBackend(code: String, emailOrPhone: String) async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        // Simulate code verification
        // In production, this would be an actual API call to your backend
        // Example:
        // let response = try await NetworkService.shared.verifyCode(code: code, for: emailOrPhone)
        // if !response.success {
        //     throw VerificationError.invalidCode
        // }
        
        print("✅ Code verified: \(code) for \(emailOrPhone)")
        
        // For demo purposes, accept any 6-digit code
        // In production, you might throw errors for invalid codes, expired codes, etc.
    }
    
    private func sendVerificationCodeToBackend(emailOrPhone: String) async throws {
        // TODO: Replace with actual API call
        // This is a placeholder that simulates a network request
        
        try await Task.sleep(for: .seconds(1.5))
        
        print("✅ Verification code resent to: \(emailOrPhone)")
    }
    
    // MARK: - Helpers
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Format countdown time as MM:SS
    var formattedCountdown: String {
        let minutes = resendCountdown / 60
        let seconds = resendCountdown % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
