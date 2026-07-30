//
//  OnLifeApp.swift
//  OnLife
//
//  Created by Daniel Lee on 7/18/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

/// Firebase's own guidance for SwiftUI apps is to configure it from
/// `application(_:didFinishLaunchingWithOptions:)` via a
/// `UIApplicationDelegateAdaptor`, rather than from the `App`'s `init()` -
/// that's the lifecycle point Firebase (and anything that hooks into it) is
/// documented to expect.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        OnLifeApp.configureFirebaseIfPossible()

        // Configure database for environment
        DatabaseManager.configureForEnvironment()

        return true
    }

    /// Firebase Phone Auth silently registers the app for remote
    /// notifications so it can verify devices via a silent push before
    /// falling back to a reCAPTCHA challenge. The Firebase Auth SDK expects
    /// the app delegate to forward any incoming remote notification to
    /// `Auth.auth().canHandleNotification(_:)` - and, in practice, simply
    /// *not having any implementation* of this method at all makes the SDK
    /// throw "If app delegate swizzling is disabled, remote notifications
    /// received by UIApplicationDelegate need to be forwarded to
    /// FirebaseAuth's canHandleNotification method" as soon as phone
    /// verification starts, instead of proceeding to the reCAPTCHA fallback
    /// - this reproduces even on the Simulator, which never actually
    /// receives a real push. Adding this method (even though this app has
    /// no other remote-notification handling to do) resolves it.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) async -> UIBackgroundFetchResult {
        _ = Auth.auth().canHandleNotification(userInfo)
        return .noData
    }
}

@main
struct OnLifeApp: App {
    // Registers AppDelegate above so Firebase configures at app launch.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var authService = AuthService.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // `!authService.isOnboarding` keeps the app on the sign-up
            // wizard's NavigationStack even after phone verification makes
            // isAuthenticated true partway through - otherwise the wizard
            // (birthday/photos/profile/location steps still pending) would
            // be yanked away to HomeView the instant the phone number is
            // verified. isOnboarding is cleared once the wizard's last step
            // (LocationPermissionView's onComplete) runs.
            if authService.isAuthenticated && !authService.isOnboarding {
                HomeView()
                    .onOpenURL { url in
                        // Completes the Google Sign-In redirect back into the app.
                        GIDSignIn.sharedInstance.handle(url)
                    }
            } else {
                LoginView()
                    .onOpenURL { url in
                        // Completes the Google Sign-In redirect back into the app.
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    // Guarded because FirebaseApp.configure() crashes if GoogleService-Info.plist
    // isn't in the bundle yet - until it's added (see
    // Features/Database/Documentation/FIREBASE_SETUP.md), skip configuration
    // so the rest of the app still builds and runs. AuthService already
    // checks `FirebaseApp.app() != nil` before every call, so auth just
    // fails gracefully instead of crashing at launch.
    fileprivate static func configureFirebaseIfPossible() {
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            print("⚠️ OnLifeApp: GoogleService-Info.plist not found - Firebase was not configured. See Features/Database/Documentation/FIREBASE_SETUP.md.")
            return
        }

        FirebaseApp.configure()

        // Google Sign-In reuses the OAuth client ID Firebase already knows
        // about from GoogleService-Info.plist - nothing else to configure
        // here besides the URL scheme step in FIREBASE_SETUP.md (Xcode ->
        // target -> Info -> URL Types -> REVERSED_CLIENT_ID) so the redirect
        // can get back into the app via the onOpenURL handler above.
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
    }
}
