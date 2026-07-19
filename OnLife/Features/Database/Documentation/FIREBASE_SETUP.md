# Firebase Integration Setup Guide

This guide will help you integrate Firebase into your Onlife app.

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

## Step 3: Add Firebase SDK via Swift Package Manager

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the Firebase SDK URL:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Select version: **10.0.0** or later
4. Choose the following packages:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseAnalytics (optional)
   - ✅ FirebaseMessaging (for push notifications)

## Step 4: Initialize Firebase in Your App

Create or update your App file (e.g., `OnlifeApp.swift`):

```swift
import SwiftUI
import FirebaseCore

@main
struct OnlifeApp: App {
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure database to use Firebase in production
        #if !DEBUG
        DatabaseManager.shared.configure(with: .firebase)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
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

Replace the default rules with these:

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

## Optional: Add GeoFirestore for Location Queries

For the "nearby events" feature, add GeoFirestore:

1. Add package: `https://github.com/imperiumlabs/GeoFirestore-iOS`
2. Update `FirebaseDatabaseService.swift` to use GeoFirestore queries

## Troubleshooting

### GoogleService-Info.plist not found
- Make sure the file is in your project root
- Check target membership in File Inspector

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
