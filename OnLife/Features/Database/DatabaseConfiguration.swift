//
//  DatabaseConfiguration.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import Foundation

/// Centralized database configuration for the app
/// Use this to easily switch between database implementations
enum DatabaseConfiguration {
    
    /// The active configuration based on build environment
    static var current: DatabaseManager.Configuration {
        #if DEBUG
        return development
        #else
        return production
        #endif
    }
    
    /// Development configuration (you can switch between .mock and .firebase)
    private static var development: DatabaseManager.Configuration {
        // Using mock database for faster development without network calls
        .mock(simulatedDelay: 0.0)  // No delay = instant responses
        
        // Uncomment the line below to use Firebase in development
        // .firebase
    }
    
    /// Production configuration (Firebase)
    private static var production: DatabaseManager.Configuration {
        .firebase // Using Firebase in production
    }
    
    /// Testing configuration (no delay)
    static var testing: DatabaseManager.Configuration {
        .mock(simulatedDelay: 0)
    }
}

// MARK: - Environment Configuration

/// Configuration values that change based on environment
struct EnvironmentConfig {
    
    /// Whether to use real-time database listeners
    static var useRealtimeUpdates: Bool {
        #if DEBUG
        return false // Disable in development to save bandwidth
        #else
        return true  // Enable in production
        #endif
    }
    
    /// Maximum number of feed items to fetch at once
    static var feedPageSize: Int {
        #if DEBUG
        return 10 // Smaller pages for testing
        #else
        return 50 // Larger pages for production
        #endif
    }
    
    /// Whether to enable verbose logging
    static var enableVerboseLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Maximum image upload size (in bytes)
    static var maxImageSize: Int {
        5 * 1024 * 1024 // 5MB
    }
    
    /// Image compression quality (0.0 to 1.0)
    static var imageCompressionQuality: Double {
        0.8
    }
}

// MARK: - Feature Flags

/// Feature flags for gradual rollout of new features
struct FeatureFlags {
    
    /// Enable real-time feed updates
    static var realtimeFeed: Bool {
        EnvironmentConfig.useRealtimeUpdates
    }
    
    /// Enable location-based event discovery
    static var nearbyEvents: Bool {
        true
    }
    
    /// Enable image uploads
    static var imageUpload: Bool {
        true
    }
    
    /// Enable comments on posts
    static var comments: Bool {
        true
    }
    
    /// Enable push notifications
    static var pushNotifications: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    /// Enable analytics tracking
    static var analytics: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
}

// MARK: - App Initialization Helper

extension DatabaseManager {
    
    /// Configures the database with the appropriate implementation
    /// Call this in your app's init() method
    static func configureForEnvironment() {
        shared.configure(with: DatabaseConfiguration.current)
        
        if EnvironmentConfig.enableVerboseLogging {
            print("🗄️ Database configured with: \(DatabaseConfiguration.current)")
            print("📊 Feature Flags:")
            print("  - Realtime Feed: \(FeatureFlags.realtimeFeed)")
            print("  - Nearby Events: \(FeatureFlags.nearbyEvents)")
            print("  - Image Upload: \(FeatureFlags.imageUpload)")
            print("  - Comments: \(FeatureFlags.comments)")
            print("  - Push Notifications: \(FeatureFlags.pushNotifications)")
            print("  - Analytics: \(FeatureFlags.analytics)")
        }
    }
}

// MARK: - Custom Configuration for Testing

#if DEBUG
extension DatabaseManager.Configuration: CustomStringConvertible {
    var description: String {
        switch self {
        case .firebase:
            return "Firebase"
        case .mock(let delay):
            return "Mock (delay: \(delay)s)"
        }
    }
}
#endif
