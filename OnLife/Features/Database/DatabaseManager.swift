//
//  DatabaseManager.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import Foundation

/// Manages the database service instance and provides a global access point
/// This allows easy switching between database implementations (Firebase, mock, etc.)
@MainActor
final class DatabaseManager {
    
    /// Shared singleton instance
    static let shared = DatabaseManager()
    
    /// The active database service
    private(set) var service: DatabaseService
    
    /// Configuration for database service
    enum Configuration {
        case firebase
        case mock(simulatedDelay: TimeInterval = 0.5)
        
        // Add other implementations here as needed:
        // case cloudKit
        // case supabase
        // case custom(DatabaseService)
    }
    
    private init() {
        // Default to mock for development
        // Initialize without instantiation - will be set via configure()
        #if DEBUG
        self.service = MockDatabaseService()
        #else
        self.service = MockDatabaseService() // Use mock for now until Firebase is set up
        #endif
    }
    
    /// Configure the database service
    /// - Parameter configuration: The configuration to use
    func configure(with configuration: Configuration) {
        switch configuration {
        case .firebase:
            service = FirebaseDatabaseService()
            
        case .mock(let delay):
            let mockService = MockDatabaseService()
            mockService.simulatedDelay = delay
            service = mockService
        }
    }
    
    /// Convenience method to get the current service
    /// Use this in your view models/stores
    static var current: DatabaseService {
        shared.service
    }
}
