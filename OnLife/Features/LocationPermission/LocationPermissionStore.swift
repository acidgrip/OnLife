//
//  LocationPermissionStore.swift
//  Onlife
//
//  Created by Daniel Lee on 6/23/26.
//

import SwiftUI
import CoreLocation
import Combine

@MainActor
final class LocationPermissionStore: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var hasRequestedPermission: Bool = false
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Computed Properties
    
    var isAuthorized: Bool {
        #if os(iOS)
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        #elseif os(macOS)
        return authorizationStatus == .authorizedAlways
        #else
        return false
        #endif
    }
    
    var isDenied: Bool {
        return authorizationStatus == .denied
    }
    
    var isRestricted: Bool {
        return authorizationStatus == .restricted
    }
    
    var canRequestPermission: Bool {
        return authorizationStatus == .notDetermined
    }
    
    var statusDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        @unknown default:
            return "Unknown"
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    func requestPermission() {
        guard canRequestPermission else {
            return
        }
        
        hasRequestedPermission = true
        isLoading = true
        
        #if os(iOS)
        locationManager.requestWhenInUseAuthorization()
        #elseif os(macOS)
        locationManager.requestAlwaysAuthorization()
        #endif
    }
    
    func openSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
    
    func reset() {
        hasRequestedPermission = false
        isLoading = false
    }
    
    // MARK: - Testing Helper
    
    #if DEBUG
    func setAuthorizationStatus(_ status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
    #endif
}

// MARK: - CLLocationManagerDelegate

extension LocationPermissionStore: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            isLoading = false
        }
    }
}
