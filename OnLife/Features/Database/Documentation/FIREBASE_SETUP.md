# Firebase Integration Setup Guide

This guide will help you integrate Firebase into your Onlife app.

## Current Status (as of this pass)

What's already done in code:
- ✅ Firebase SDK linked via SPM (`FirebaseAuth`, `FirebaseCore`, `FirebaseFirestore`, `FirebaseStorage`)
- ✅ `GoogleSignIn-iOS` SDK linked via SPM (`GoogleSignIn`, `GoogleSignInSwift`)
- ✅ `GoogleService-Info.plist` is in place at `OnLife/GoogleService-Info.plist` (the project's `OnLife/` group is an Xcode 16 synchronized folder, so it's automatically part of the app target - no `project.pbxproj` edit needed)
- ✅ `OnLifeApp.swift` configures Firebase from `AppDelegate.application(_:didFinishLaunchingWithOptions:)` via `@UIApplicationDelegateAdaptor` (Firebase's recommended SwiftUI pattern), still guarded so the app doesn't crash if the plist is ever missing (skips configuration and logs a warning instead)
- ✅ `AuthService.swift` implements email/password, Sign in with Apple, and Sign in with Google for real
- ✅ `AuthService.swift` also implements real Firebase Phone Auth (`sendPhoneVerificationCode`/`verifyPhoneCode`) and email/password account linking (`linkEmailPassword`), used by the sign-up wizard below
- ✅ The full sign-up wizard (`LoginView → SignUpView → VerificationCodeView → VerificationBirthdayView → AddPhotosView → CreateProfileView → LocationPermissionView → HomeView`) is wired end to end with a real `NavigationStack`, a shared `SignUpSession`, and `AuthService.isOnboarding` gating so mid-wizard phone verification doesn't eject the user to `HomeView` early
- ✅ `UserProfile.swift` model + `DatabaseService.createUserProfile(_:)` write the new user's profile (username, name, bio, birthday, photo URLs) to Firestore's `users` collection at the end of the wizard
- ✅ `DatabaseManager`/`DatabaseConfiguration` already switch between `MockDatabaseService` and `FirebaseDatabaseService` - **`development` now defaults to `.firebase`**, so Debug builds (running from Xcode) write to real Firestore/Storage, not just Release builds
- ✅ `firestore.rules` / `storage.rules` already drafted in this folder

⚠️ Two things found in the delivered `GoogleService-Info.plist` that need your attention in Firebase Console before Google Sign-In will work and before the project is fully consistent:
- **No `CLIENT_ID` / `REVERSED_CLIENT_ID` keys in the plist.** Firebase only generates those once "Google" is enabled as a sign-in provider for this iOS app (Step 7 below). Until you enable it and **re-download** the plist, `configureFirebaseIfPossible()` in `OnLifeApp.swift` will find no `clientID` on `FirebaseApp.app()?.options`, so `GIDSignIn` never gets configured and "Continue with Google" will fail at runtime (not compile-time).
- **`BUNDLE_ID` in the plist is `com.onlife.onlife`, but the Xcode target's actual bundle identifier is `name.sophiesun.OnLife`** (`project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`). Firebase doesn't hard-enforce this match at runtime, so the app will still run, but it means the Firebase Console "iOS app" you registered doesn't actually correspond to this Xcode target - things like APNs/push, Dynamic Links, and Crashlytics can silently misbehave later. Either update the Firebase Console app's bundle ID to match, or change the Xcode target's bundle identifier to match - your call on which is "correct" - then re-download the plist if you change the Firebase Console side.

**No paid Apple Developer account? No problem for phone auth.** Firebase Phone Auth's default verification path (silent push via APNs) needs a paid account, but the SDK automatically falls back to a reCAPTCHA web-view challenge when silent push isn't available - no code changes required, just a different Xcode/Firebase Console setup step (see Step 7 below). A free "Personal Team" (Xcode → Settings → Accounts → sign in with any Apple ID) is all you need to build and run.

What still needs **your** Firebase Console / Apple Developer account access (can't be done remotely):
- ⬜ Resolve the `CLIENT_ID`/bundle ID issues above
- ⬜ Enable Email/Password, Apple, Google, and **Phone** sign-in providers (Step 7 below)
- ⬜ Add the Google Sign-In URL scheme in Xcode (Step 7 below - new)
- ⬜ Add the Phone Auth reCAPTCHA URL scheme in Xcode (Step 7 below - new; no paid Apple Developer account required)
- ⬜ Enable the "Sign in with Apple" capability in Xcode (Signing & Capabilities), which requires your Apple Developer account
- ⬜ Publish `firestore.rules` / `storage.rules` from this folder to the Firebase Console

## Prerequisites

- Xcode 15.0+
- iOS 17.0+ deployment target
- A Firebase account (free tier is sufficient to start)

## Step 1: Create Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name: "Onlife"
   - Enable Google Analytics (optional but recommended)
   - Choose your Analytics account

## Step 2: Register iOS App

1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter your iOS bundle ID (e.g., `com.yourcompany.onlife`)
   - Find this in Xcode: Target → General → Bundle Identifier
3. Enter App nickname: "Onlife iOS"
4. Download `GoogleService-Info.plist`
5. **Important**: Drag `GoogleService-Info.plist` into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Add to your app target
   - Without this file, `OnLifeApp.swift`'s guard skips `FirebaseApp.configure()` entirely and the app runs with no backend - auth/database calls will fail with `AuthError.firebaseNotConfigured` / equivalent until this file is added.

## Step 3: Add Firebase SDK via Swift Package Manager

Already done in this project - `firebase-ios-sdk` and `GoogleSignIn-iOS` are both linked in `project.pbxproj`. For reference, this is what was added:

1. In Xcode, go to **File → Add Package Dependencies...**
2. Firebase SDK: `https://github.com/firebase/firebase-ios-sdk`
   - Packages: `FirebaseAuth`, `FirebaseCore`, `FirebaseFirestore`, `FirebaseStorage`
3. Google Sign-In SDK: `https://github.com/google/GoogleSignIn-iOS`
   - Packages: `GoogleSignIn`, `GoogleSignInSwift`

The first time you build after this file is added, Xcode needs network access to resolve these packages (source download) - this can take a few minutes.

## Step 4: Initialize Firebase in Your App

Already done - `OnLifeApp.swift` configures Firebase from an `AppDelegate` registered via `@UIApplicationDelegateAdaptor`, which is Firebase's documented pattern for SwiftUI apps (it guarantees Firebase is configured at `application(_:didFinishLaunchingWithOptions:)`, the lifecycle point Firebase - and things that hook into it - expect, rather than at the `App` struct's `init()`):

```swift
import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        OnLifeApp.configureFirebaseIfPossible() // no-ops safely if plist is missing
        DatabaseManager.configureForEnvironment()
        return true
    }
}

@main
struct OnlifeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // ...
}
```

## Step 5: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create Database**
3. Choose starting mode:
   - **Test mode** (for development): Allows all reads/writes
   - **Production mode**: Requires security rules (recommended for production)
4. Select a location (choose closest to your users)

### Security Rules (Important!)

This project already has drafted rules in this folder - `firestore.rules` and `storage.rules`. Publish them as-is (Firebase Console → Firestore Database → Rules → paste → Publish, and similarly for Storage → Rules) rather than the inline example below, which is kept only as a reference of the general shape:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && isOwner(userId);
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.userId);
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.userId);
    }
    
    // Likes collection
    match /likes/{likeId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && isOwner(resource.data.userId);
    }
    
    // Bookmarks collection
    match /bookmarks/{bookmarkId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && isOwner(resource.data.userId);
    }
    
    // Event attendees collection
    match /eventAttendees/{attendeeId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && isOwner(resource.data.userId);
    }
    
    // Comments collection
    match /comments/{commentId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.userId);
    }
  }
}
```

## Step 6: Set Up Firebase Storage

1. In Firebase Console, go to **Storage**
2. Click **Get Started**
3. Choose security rules:
   - **Test mode** for development
   - Or use these production rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024  // Max 5MB
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Step 7: Set Up Firebase Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Enable sign-in methods you want to use:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Apple (required for App Store)
   - ✅ Anonymous (for testing)

### Sign in with Apple (Xcode-side setup)

`AuthService.signInWithApple(credential:)` is already implemented. You still need to:
1. Select the `OnLife` target → **Signing & Capabilities** → **+ Capability** → **Sign in with Apple**
2. This requires your Apple Developer account to be signed into Xcode

### Google Sign-In (Xcode-side setup)

`AuthService.signInWithGoogle()` is already implemented (`GoogleSignIn-iOS` linked, `GIDSignIn` configured from Firebase's `clientID` in `OnLifeApp.swift`, `.onOpenURL` wired up). You still need to add the URL scheme so the sign-in redirect can get back into the app:

1. Open the `GoogleService-Info.plist` you downloaded in Step 2
2. Copy the `REVERSED_CLIENT_ID` value
3. In Xcode: `OnLife` target → **Info** tab → **URL Types** → **+** → paste that value into **URL Schemes**

Without this step, tapping "Continue with Google" will authenticate with Google but fail to redirect back into the app afterward.

### Phone Authentication (Sign-Up flow)

`AuthService.sendPhoneVerificationCode(phoneNumber:)` and `AuthService.verifyPhoneCode(verificationID:code:)` are already implemented and drive the sign-up wizard's phone verification step; `AuthService.linkEmailPassword(email:password:)` is called later in the wizard (`CreateProfileView`) to attach an email/password credential to the same account, so the user can sign back in later via `LoginStore.login(email:password:)`. To make this work end to end:

1. In Firebase Console → **Authentication → Sign-in method**, enable **Phone**.
2. Firebase's iOS SDK verifies a phone number one of two ways:
   - **Silent push (APNs)** - the default when available. Requires uploading an APNs authentication key (Firebase Console → Project Settings → Cloud Messaging) and enabling the **Push Notifications** capability in Xcode (Signing & Capabilities). This requires a **paid** Apple Developer account.
   - **reCAPTCHA fallback** - automatic, no code changes, and works with a **free** "Personal Team" (Xcode → Settings → Accounts → sign in with any Apple ID). When silent push isn't configured or isn't possible (simulator, no APNs key, etc.), the SDK transparently shows a reCAPTCHA web-view challenge instead. This is the recommended path if you don't have a paid Apple Developer account.
3. Either way, the reCAPTCHA fallback needs one Xcode setup step - a custom URL scheme distinct from Google's `REVERSED_CLIENT_ID`:
   - In Firebase Console, go to the gear icon → **Project settings → General** tab → your **iOS app** entry, and copy the **Encoded App ID** (looks like `app-1-1234567890-ios-abcdef1234567890`).
   - In Xcode: `OnLife` target → **Info** tab → **URL Types** → **+** → paste that value into **URL Schemes** (leave **Identifier** blank).
4. If you do have a paid account and want silent push instead of reCAPTCHA, additionally upload the APNs key and add the **Push Notifications** capability as described above - the SDK prefers silent push automatically when it's available, so no code or additional config is needed beyond that.

Without step 3, phone verification will fail to complete when it falls back to reCAPTCHA (the redirect back into the app breaks the same way Google Sign-In does without its own URL scheme).

## Step 8: Create Database Indexes

For optimal query performance, create these indexes in Firestore:

1. Go to **Firestore Database → Indexes**
2. Click **Add Index**

### Posts Index
- Collection: `posts`
- Fields:
  - `timestamp` (Descending)
  - `userId` (Ascending)
- Query scope: Collection

### Events Index
- Collection: `events`
- Fields:
  - `date` (Ascending)
  - `location` (Ascending)
- Query scope: Collection

### Comments Index
- Collection: `comments`
- Fields:
  - `postId` (Ascending)
  - `timestamp` (Ascending)
- Query scope: Collection

## Step 9: Configure Database in Your App

By default, the app uses `MockDatabaseService` in DEBUG mode and `FirebaseDatabaseService` in production.

To force Firebase in development:

```swift
// In your app initialization or SwiftUI preview
DatabaseManager.shared.configure(with: .firebase)
```

To use mock database in production (testing):

```swift
DatabaseManager.shared.configure(with: .mock(simulatedDelay: 0.3))
```

## Step 10: Test Your Integration

1. Build and run your app
2. The app should now connect to Firebase
3. Check Firebase Console to see:
   - Authentication: New users appearing
   - Firestore: New documents being created
   - Storage: Images being uploaded

## GPS Proximity Filtering

`Post` and `Event` now carry optional `latitude`/`longitude` fields, and `fetchFeed`/`fetchNearbyEvents` in both `MockDatabaseService` and `FirebaseDatabaseService` do real `CLLocation.distance(from:)` filtering client-side when a coordinate is supplied - no GeoFirestore or Firestore geo-index needed for this. This is adequate at small-to-moderate scale (every client fetches the same bounded window of recent documents and filters locally) but doesn't scale to large datasets the way a real geohash-indexed query would. If usage grows to the point that "fetch recent N, filter client-side" becomes too coarse or too expensive in reads, that's the point to revisit adding geohashing (a geohash field per document + Firestore range queries) rather than a third-party dependency like GeoFirestore.

## Troubleshooting

### GoogleService-Info.plist not found
- Make sure the file is in your project root
- Check target membership in File Inspector
- With this project's guard in `OnLifeApp.swift`, a missing plist no longer crashes the app - it just runs without Firebase configured, so auth/database calls will fail until the file is added

### Firestore permission denied
- Check your security rules
- Ensure user is authenticated
- Verify `request.auth.uid` matches the userId field

### Real-time updates not working
- Enable real-time updates in ActivityFeedStore:
  ```swift
  await store.observeFeedChanges()
  ```

### Storage uploads failing
- Check storage security rules
- Verify file size limits
- Ensure correct content type

### Google Sign-In redirects but doesn't return to the app
- You're missing the `REVERSED_CLIENT_ID` URL scheme - see Step 7 above

### "Continue with Google" does nothing / fails silently
- Check whether `GoogleService-Info.plist` actually has `CLIENT_ID`/`REVERSED_CLIENT_ID` keys. If not, Google hasn't been enabled as a sign-in provider for this iOS app in Firebase Console yet (Step 7) - enable it, then re-download and replace the plist in Xcode.

### Phone verification isn't completing / reCAPTCHA not appearing
- Make sure **Phone** is enabled as a sign-in provider in Firebase Console → Authentication → Sign-in method.
- If you're relying on the reCAPTCHA fallback (no paid Apple Developer account / no APNs key), confirm the **Encoded App ID** URL scheme from Step 7 is added under `OnLife` target → **Info** tab → **URL Types**. This is a different value from Google's `REVERSED_CLIENT_ID` - double check you didn't paste the wrong one.
- If a reCAPTCHA challenge silently fails or never appears, check that Safari/WebKit isn't being blocked by a content blocker or simulator networking issue - try a different simulator or a real device.
- If you do have a paid Apple Developer account and expected silent push instead of a reCAPTCHA prompt, confirm the APNs authentication key is uploaded (Firebase Console → Project Settings → Cloud Messaging) and the **Push Notifications** capability is added in Xcode (Signing & Capabilities) - without both, Firebase falls back to reCAPTCHA even on a real device.

## Next Steps

1. ✅ Set up Firebase Authentication (separate guide)
2. ✅ Implement user profiles
3. ✅ Add image upload functionality
4. ✅ Set up push notifications
5. ✅ Configure Analytics
6. ✅ Add Crashlytics for error tracking

## Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Google Sign-In for iOS Documentation](https://developers.google.com/identity/sign-in/ios)
