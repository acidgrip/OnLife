//
//  TestConfiguration.swift
//  OnlifeTests
//
//  Created by Test Configuration on 7/18/26.
//

import Testing
import Foundation
import FirebaseCore
@testable import OnLife

/// Global test configuration - runs before any tests
/// This ensures Firebase is properly configured for testing
struct TestSetup {
    static let shared = TestSetup()
    
    private init() {
        setupTestEnvironment()
    }
    
    private func setupTestEnvironment() {
        print("🧪 Setting up test environment...")
        
        // Mark that we're in a test environment
        setenv("RUNNING_TESTS", "1", 1)
        
        // Try to configure Firebase for testing
        // This prevents crashes when tests try to access Firebase
        if FirebaseApp.app() == nil {
            // Check if GoogleService-Info.plist exists for testing
            if let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               FileManager.default.fileExists(atPath: plistPath) {
                print("🔥 Configuring Firebase for tests...")
                FirebaseApp.configure()
            } else {
                print("⚠️ No GoogleService-Info.plist found - Firebase tests will be skipped")
            }
        }
        
        // Configure database for testing
        Task { @MainActor in
            DatabaseManager.configureForEnvironment()
            print("✅ Test environment ready")
        }
        
        print("🔄 Test environment setup initiated")
    }
}

/// Ensure test setup runs before any tests
/// Call this from a test suite's init to ensure proper setup
func ensureTestSetup() {
    _ = TestSetup.shared
}

/// Test environment helper
enum TestEnvironment {
    static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
               ProcessInfo.processInfo.environment["RUNNING_TESTS"] == "1"
    }
    
    static var isFirebaseConfigured: Bool {
        return FirebaseApp.app() != nil
    }
}
