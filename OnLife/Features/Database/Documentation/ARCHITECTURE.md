# Database Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      SwiftUI Views                          │
│  (ActivityFeedView, PostCardView, EventCardView, etc.)      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   View Models / Stores                       │
│              (ActivityFeedStore, etc.)                       │
│                                                              │
│  • Manages UI state                                          │
│  • Coordinates business logic                                │
│  • Injects database dependency                               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   DatabaseService Protocol                   │
│                                                              │
│  Protocol defining all database operations:                  │
│  • fetchFeed(filter, limit, lastItemId)                     │
│  • createPost(post)                                          │
│  • togglePostLike(postId, userId, isLiked)                  │
│  • createEvent(event)                                        │
│  • toggleEventJoin(eventId, userId, isJoined)               │
│  • uploadImage(imageData, path)                             │
│  • etc...                                                    │
└────────────┬───────────────────────────────┬────────────────┘
             │                               │
             ▼                               ▼
┌────────────────────────┐    ┌─────────────────────────────┐
│  MockDatabaseService   │    │  FirebaseDatabaseService    │
│                        │    │                             │
│  • In-memory storage   │    │  • Firestore integration    │
│  • Simulated delays    │    │  • Firebase Storage         │
│  • Perfect for testing │    │  • Real-time listeners      │
│  • No setup required   │    │  • Production ready         │
└────────────────────────┘    └──────────┬──────────────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │   Firebase Backend   │
                              │                      │
                              │  • Firestore         │
                              │  • Storage           │
                              │  • Authentication    │
                              └──────────────────────┘
```

## Data Flow: Creating a Post

```
User taps "Post"
      │
      ▼
┌──────────────────────┐
│  ComposePostView     │  User enters text
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  ActivityFeedStore   │  await store.createPost(content, location)
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  DatabaseService     │  let created = try await database.createPost(post)
└──────────┬───────────┘
           │
           ├─────────────────────┬─────────────────────┐
           │                     │                     │
           ▼                     ▼                     ▼
    ┌──────────┐         ┌─────────────┐     ┌──────────────┐
    │   Mock   │         │   Firebase  │     │   CloudKit   │
    │ (Testing)│         │ (Production)│     │   (Future)   │
    └──────────┘         └──────┬──────┘     └──────────────┘
                                │
                                ▼
                         ┌──────────────┐
                         │   Firestore  │
                         │  Collection  │
                         │    "posts"   │
                         └──────────────┘
```

## Data Flow: Liking a Post (Optimistic Update)

```
User taps "Like" button
      │
      ▼
┌──────────────────────────┐
│  PostCardView            │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│  ActivityFeedStore       │
│                          │
│  1. Update UI            │  (Optimistic)
│     immediately          │  ──────────┐
│                          │            │
│  2. Call database        │            │
│     togglePostLike()     │            │
│                          │            │
│  3. On error:            │            │
│     revert UI change     │  <─────────┘
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│  DatabaseService         │  try await database.togglePostLike(...)
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│  FirebaseDatabaseService │
│                          │
│  Uses Firestore          │
│  transaction to:         │
│  • Add to "likes"        │
│  • Increment likeCount   │
└──────────────────────────┘
```

## Data Flow: Real-time Updates

```
┌─────────────────────────────────────────────────────────┐
│  ActivityFeedStore                                      │
│                                                         │
│  observeFeedChanges() {                                 │
│    observer = database.observeFeed { items in           │
│      self.feedItems = items  // Auto-updates UI         │
│    }                                                     │
│  }                                                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  DatabaseService                                        │
│                                                         │
│  func observeFeed(                                      │
│    filter: FeedFilter,                                  │
│    onChange: @escaping ([FeedItem]) -> Void             │
│  ) -> DatabaseObserver                                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  FirebaseDatabaseService                                │
│                                                         │
│  Sets up Firestore listener:                            │
│  db.collection("posts")                                 │
│    .addSnapshotListener { snapshot, error in            │
│      // Fetch fresh data and call onChange()            │
│    }                                                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  Firestore                                              │
│                                                         │
│  Sends updates when data changes                        │
│  ───────────────────────────────┐                       │
│                                 │                       │
└─────────────────────────────────┼───────────────────────┘
                                  │
                                  │ Real-time update
                                  │
                     ┌────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  onChange([FeedItem]) callback                          │
│                                                         │
│  Updates store.feedItems                                │
│  Automatically refreshes SwiftUI views                  │
└─────────────────────────────────────────────────────────┘
```

## Dependency Injection Pattern

```
┌─────────────────────────────────────────────────────────┐
│  Production App                                         │
│                                                         │
│  let store = ActivityFeedStore()                        │
│                                                         │
│  Uses: DatabaseManager.current                          │
│  → FirebaseDatabaseService                              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Unit Tests                                             │
│                                                         │
│  let mockDB = MockDatabaseService()                     │
│  let store = ActivityFeedStore(database: mockDB)        │
│                                                         │
│  Uses: Injected mock                                    │
│  → MockDatabaseService                                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  SwiftUI Previews                                       │
│                                                         │
│  ActivityFeedView()                                     │
│    .environment(\.databaseService, MockDatabaseService())
│                                                         │
│  Uses: Environment injection                            │
│  → MockDatabaseService                                  │
└─────────────────────────────────────────────────────────┘
```

## Configuration System

```
App Launch
    │
    ▼
DatabaseManager.configureForEnvironment()
    │
    ├─── DEBUG build?
    │    │
    │    ├─ Yes → MockDatabaseService
    │    │        • simulatedDelay: 0.3s
    │    │        • Mock data preloaded
    │    │
    │    └─ No ──→ FirebaseDatabaseService
    │              • Real Firestore connection
    │              • Real-time listeners
    │
    ▼
DatabaseManager.current
    │
    └──→ Used by all stores
         └──→ ActivityFeedStore(database: DatabaseManager.current)
```

## File Structure

```
Onlife/
│
├── ActivityFeed/
│   ├── Models/
│   │   ├── Post.swift
│   │   ├── Event.swift
│   │   ├── FeedItem.swift
│   │   └── FeedFilter.swift
│   │
│   ├── Views/
│   │   ├── ActivityFeedView.swift
│   │   ├── PostCardView.swift
│   │   └── EventCardView.swift
│   │
│   └── ActivityFeedStore.swift  ──────┐
│                                      │ Uses
├── Database/                          │
│   ├── DatabaseService.swift  <───────┘ (Protocol)
│   ├── FirebaseDatabaseService.swift  (Implementation)
│   ├── MockDatabaseService.swift      (Implementation)
│   ├── DatabaseManager.swift          (Singleton)
│   ├── DatabaseConfiguration.swift    (Config)
│   │
│   ├── README.md
│   ├── QUICKSTART.md
│   ├── FIREBASE_SETUP.md
│   ├── DEPLOYMENT_CHECKLIST.md
│   ├── INTEGRATION_SUMMARY.md
│   └── ARCHITECTURE.md  ← (This file)
│
└── OnlifeApp.swift  (App initialization)
```

## Component Responsibilities

```
┌─────────────────────────────────────────────────────────┐
│  SwiftUI Views                                          │
│                                                         │
│  Responsibilities:                                      │
│  • Display UI                                           │
│  • Handle user input                                    │
│  • Observe store state                                  │
│                                                         │
│  NOT responsible for:                                   │
│  • Business logic                                       │
│  • Data fetching                                        │
│  • Database operations                                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Stores / View Models                                   │
│                                                         │
│  Responsibilities:                                      │
│  • Manage view state                                    │
│  • Coordinate business logic                            │
│  • Call database methods                                │
│  • Handle errors                                        │
│  • Optimistic updates                                   │
│                                                         │
│  NOT responsible for:                                   │
│  • Database implementation details                      │
│  • Network calls                                        │
│  • Data serialization                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  DatabaseService (Protocol)                             │
│                                                         │
│  Responsibilities:                                      │
│  • Define database interface                            │
│  • Ensure consistent API                                │
│                                                         │
│  NOT responsible for:                                   │
│  • Implementation details                               │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Database Implementations                               │
│                                                         │
│  Responsibilities:                                      │
│  • Implement database operations                        │
│  • Handle network calls                                 │
│  • Serialize/deserialize data                           │
│  • Manage connections                                   │
│  • Handle backend-specific errors                       │
│                                                         │
│  NOT responsible for:                                   │
│  • UI updates                                           │
│  • Business logic                                       │
│  • View state management                                │
└─────────────────────────────────────────────────────────┘
```

## Testing Strategy

```
┌─────────────────────────────────────────────────────────┐
│  Unit Tests                                             │
│                                                         │
│  Test with: MockDatabaseService                         │
│  Focus on: Business logic in stores                     │
│                                                         │
│  Example:                                               │
│  @Test                                                  │
│  func testLikePost() async throws {                     │
│    let store = ActivityFeedStore(                       │
│      database: MockDatabaseService()                    │
│    )                                                    │
│    await store.likePost(post)                           │
│    #expect(store.feedItems[0].likeCount == 1)           │
│  }                                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Integration Tests                                      │
│                                                         │
│  Test with: FirebaseDatabaseService                     │
│  Focus on: Database operations                          │
│                                                         │
│  Example:                                               │
│  @Test                                                  │
│  func testFirebaseCreatePost() async throws {           │
│    let db = FirebaseDatabaseService()                   │
│    let post = try await db.createPost(...)              │
│    #expect(post.id.isEmpty == false)                    │
│  }                                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  UI Tests                                               │
│                                                         │
│  Test with: MockDatabaseService (zero delay)            │
│  Focus on: User interactions                            │
│                                                         │
│  Example:                                               │
│  func testLikeButton() {                                │
│    app.launch()                                         │
│    app.buttons["likeButton"].tap()                      │
│    XCTAssert(app.staticTexts["1 like"].exists)          │
│  }                                                      │
└─────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
Database Error Occurs
        │
        ▼
┌────────────────────┐
│ DatabaseService    │  throw DatabaseError.networkError
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ ActivityFeedStore  │  do { ... } catch { handleError(error) }
│                    │
│ Updates:           │
│ • errorMessage     │
│ • showError = true │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ SwiftUI View       │  .alert(isPresented: $store.showError) { ... }
│                    │
│ Shows alert to     │
│ user with error    │
│ message            │
└────────────────────┘
```

## Adding a New Database Implementation

```
1. Create new class conforming to DatabaseService

   actor PostgresDatabaseService: DatabaseService {
       func fetchFeed(...) async throws -> [FeedItem] {
           // Your implementation
       }
       
       func createPost(...) async throws -> Post {
           // Your implementation
       }
       
       // ... implement all protocol methods
   }

2. Add to DatabaseManager.Configuration

   enum Configuration {
       case firebase
       case mock(simulatedDelay: TimeInterval)
       case postgres  // ← Add new case
   }

3. Update configure() method

   func configure(with configuration: Configuration) {
       switch configuration {
       case .postgres:
           service = PostgresDatabaseService()  // ← Add case
       // ... other cases
       }
   }

4. Use it!

   DatabaseManager.shared.configure(with: .postgres)

No changes needed in views or stores! 🎉
```

---

This architecture provides:

✅ **Separation of Concerns** - Each layer has clear responsibilities  
✅ **Testability** - Easy to mock and test  
✅ **Flexibility** - Swap databases without changing app code  
✅ **Type Safety** - Compile-time checking with protocols  
✅ **Scalability** - Easy to add new features and databases  
✅ **Maintainability** - Clean, organized, documented code  
