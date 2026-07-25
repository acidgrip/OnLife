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
    // MARK: - Shared Instance

    /// App-wide instance, mirroring `AuthService.shared`. A single
    /// `CLLocationManager` should own authorization/location state so that
    /// permission granted in one place (e.g. onboarding) is visible
    /// everywhere else that needs the current coordinate (e.g. the feed).
    static let shared = LocationPermissionStore()

    // MARK: - Published Properties
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var hasRequestedPermission: Bool = false
    @Published var isLoading: Bool = false
    /// The most recent location fix, published once authorization is granted
    /// and `CLLocationManager` starts delivering updates. `nil` until then.
    @Published var currentLocation: CLLocation?
    
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
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            isLoading = false

            if isAuthorized {
                manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            currentLocation = latest
        }
    }
}
