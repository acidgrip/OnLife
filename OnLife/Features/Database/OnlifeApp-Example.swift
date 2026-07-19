#if false
//
//  OnlifeApp.swift
//  Onlife
//
//  Example app initialization with database abstraction
//  Created by Daniel Lee on 6/29/26.
//

import SwiftUI

@main
struct OnlifeApp: App {
    
    init() {
        setupDatabase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupDatabase() {
        // Configure database based on environment
        // In DEBUG: uses MockDatabaseService
        // In RELEASE: uses FirebaseDatabaseService
        DatabaseManager.configureForEnvironment()
        
        // Optional: Override for specific testing scenarios
        // DatabaseManager.shared.configure(with: .mock(simulatedDelay: 0.5))
    }
}

// MARK: - Alternative: Manual Configuration

/*
 If you want more control over the configuration:
 
 init() {
     #if DEBUG
     // Use mock in development
     DatabaseManager.shared.configure(with: .mock(simulatedDelay: 0.3))
     #else
     // Use Firebase in production
     // Note: If using Firebase, you'll need to:
     // 1. Add Firebase packages to your project
     // 2. Import FirebaseCore at the top of this file
     // 3. Call FirebaseApp.configure() before DatabaseManager setup
     DatabaseManager.shared.configure(with: .firebase)
     #endif
 }
 */

// MARK: - Alternative: Testing Configuration

/*
 For UI testing, you can override the configuration:
 
 init() {
     if ProcessInfo.processInfo.arguments.contains("--uitesting") {
         // Use mock with no delay for UI tests
         DatabaseManager.shared.configure(with: .mock(simulatedDelay: 0))
     } else {
         DatabaseManager.configureForEnvironment()
     }
 }
 */

#endif
