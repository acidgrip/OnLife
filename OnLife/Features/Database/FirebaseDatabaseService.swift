//
//  FirebaseDatabaseService.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//

import CoreLocation
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

/// Firebase implementation of DatabaseService
/// To use: Add Firebase to your Xcode project via SPM:
/// https://github.com/firebase/firebase-ios-sdk
actor FirebaseDatabaseService: DatabaseService {

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // Collection names
    private enum Collections {
        static let posts = "posts"
        static let events = "events"
        static let users = "users"
        static let comments = "comments"
        static let likes = "likes"
        static let bookmarks = "bookmarks"
        static let eventAttendees = "eventAttendees"
    }

    // MARK: - Feed Operations

    func fetchFeed(
        filter: FeedFilter,
        limit: Int,
        lastItemId: String? = nil,
        near coordinate: CLLocationCoordinate2D? = nil,
        radiusInKm: Double? = nil
    ) async throws -> [FeedItem] {
        var items: [FeedItem] = []

        // Fetch posts unless filter is .events only
        if filter != .events {
            let posts = try await fetchPosts(limit: limit / 2)
            items.append(contentsOf: filterByProximity(posts, near: coordinate, radiusInKm: radiusInKm).map { .post($0) })
        }

        // Fetch events unless filter is .posts only
        if filter != .posts {
            let events = try await fetchEvents(limit: limit / 2)
            items.append(contentsOf: filterByProximity(events, near: coordinate, radiusInKm: radiusInKm).map { .event($0) })
        }

        // Sort by timestamp (most recent first)
        items.sort { item1, item2 in
            let date1: Date
            let date2: Date

            switch item1 {
            case .post(let post):
                date1 = post.timestamp
            case .event(let event):
                date1 = event.date
            }

            switch item2 {
            case .post(let post):
                date2 = post.timestamp
            case .event(let event):
                date2 = event.date
            }

            return date1 > date2
        }

        return Array(items.prefix(limit))
    }

    func observeFeed(
        filter: FeedFilter,
        onChange: @escaping ([FeedItem]) -> Void
    ) -> DatabaseObserver {
        let observer = FirebaseObserver()

        Task {
            // Set up real-time listeners for posts and events
            let postsListener = db.collection(Collections.posts)
                .order(by: "timestamp", descending: true)
                .limit(to: 20)
                .addSnapshotListener { [weak observer] snapshot, error in
                    guard observer?.isCancelled == false else { return }

                    Task {
                        do {
                            let items = try await self.fetchFeed(filter: filter, limit: 50, lastItemId: nil, near: nil, radiusInKm: nil)
                            await MainActor.run {
                                onChange(items)
                            }
                        } catch {
                            print("Error observing feed: \(error)")
                        }
                    }
                }

            await observer.setListener(postsListener)
        }

        return observer
    }

    // MARK: - Post Operations

    func createPost(_ post: Post) async throws -> Post {
        let docRef = db.collection(Collections.posts).document()

        let postData: [String: Any] = [
            "userId": post.userId,
            "userName": post.userName,
            "userProfileImageURL": post.userProfileImageURL ?? NSNull(),
            "userLocation": post.userLocation ?? NSNull(),
            "latitude": post.latitude ?? NSNull(),
            "longitude": post.longitude ?? NSNull(),
            "content": post.content,
            "timestamp": Timestamp(date: post.timestamp),
            "likeCount": post.likeCount,
            "commentCount": post.commentCount
        ]

        try await docRef.setData(postData)

        return Post(
            id: docRef.documentID,
            userId: post.userId,
            userName: post.userName,
            userProfileImageURL: post.userProfileImageURL,
            userLocation: post.userLocation,
            latitude: post.latitude,
            longitude: post.longitude,
            content: post.content,
            timestamp: post.timestamp,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            isLiked: false
        )
    }

    func togglePostLike(postId: String, userId: String, isLiked: Bool) async throws {
        let likeRef = db.collection(Collections.likes).document("\(userId)_\(postId)")
        let postRef = db.collection(Collections.posts).document(postId)

        try await db.runTransaction { transaction, errorPointer in
            if isLiked {
                // Add like
                transaction.setData(["userId": userId, "postId": postId], forDocument: likeRef)
                transaction.updateData(["likeCount": FieldValue.increment(Int64(1))], forDocument: postRef)
            } else {
                // Remove like
                transaction.deleteDocument(likeRef)
                transaction.updateData(["likeCount": FieldValue.increment(Int64(-1))], forDocument: postRef)
            }
            return nil
        }
    }

    func fetchPost(id postId: String) async throws -> Post? {
        let snapshot = try await db.collection(Collections.posts).document(postId).getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            return nil
        }

        return try parsePost(id: snapshot.documentID, data: data)
    }

    func deletePost(id postId: String) async throws {
        try await db.collection(Collections.posts).document(postId).delete()

        // Clean up related data
        let likesQuery = db.collection(Collections.likes).whereField("postId", isEqualTo: postId)
        let commentsQuery = db.collection(Collections.comments).whereField("postId", isEqualTo: postId)

        let likeSnapshots = try await likesQuery.getDocuments()
        let commentSnapshots = try await commentsQuery.getDocuments()

        let batch = db.batch()
        likeSnapshots.documents.forEach { batch.deleteDocument($0.reference) }
        commentSnapshots.documents.forEach { batch.deleteDocument($0.reference) }
        try await batch.commit()
    }

    // MARK: - Event Operations

    func createEvent(_ event: Event) async throws -> Event {
        let docRef = db.collection(Collections.events).document()

        let eventData: [String: Any] = [
            "title": event.title,
            "hostedBy": event.hostedBy,
            "imageURL": event.imageURL ?? NSNull(),
            "location": event.location,
            "latitude": event.latitude ?? NSNull(),
            "longitude": event.longitude ?? NSNull(),
            "date": Timestamp(date: event.date),
            "time": event.time,
            "attendeeCount": event.attendeeCount,
            "attendeeProfileImages": event.attendeeProfileImages
        ]

        try await docRef.setData(eventData)

        return Event(
            id: docRef.documentID,
            title: event.title,
            hostedBy: event.hostedBy,
            imageURL: event.imageURL,
            location: event.location,
            latitude: event.latitude,
            longitude: event.longitude,
            date: event.date,
            time: event.time,
            attendeeCount: event.attendeeCount,
            attendeeProfileImages: event.attendeeProfileImages,
            isBookmarked: false,
            isJoined: false
        )
    }

    func toggleEventBookmark(eventId: String, userId: String, isBookmarked: Bool) async throws {
        let bookmarkRef = db.collection(Collections.bookmarks).document("\(userId)_\(eventId)")

        if isBookmarked {
            try await bookmarkRef.setData(["userId": userId, "eventId": eventId])
        } else {
            try await bookmarkRef.delete()
        }
    }

    func toggleEventJoin(eventId: String, userId: String, isJoined: Bool) async throws {
        let attendeeRef = db.collection(Collections.eventAttendees).document("\(userId)_\(eventId)")
        let eventRef = db.collection(Collections.events).document(eventId)

        try await db.runTransaction { transaction, errorPointer in
            if isJoined {
                // Join event
                transaction.setData(["userId": userId, "eventId": eventId], forDocument: attendeeRef)
                transaction.updateData(["attendeeCount": FieldValue.increment(Int64(1))], forDocument: eventRef)
            } else {
                // Leave event
                transaction.deleteDocument(attendeeRef)
                transaction.updateData(["attendeeCount": FieldValue.increment(Int64(-1))], forDocument: eventRef)
            }
            return nil
        }
    }

    func fetchNearbyEvents(
        latitude: Double,
        longitude: Double,
        radiusInKm: Double
    ) async throws -> [Event] {
        // Fetch a bounded, recency-ordered window and filter by real distance
        // client-side. This scales to hundreds/low-thousands of documents,
        // not millions - see FIREBASE_SETUP.md's "GPS Proximity Filtering"
        // section for when to revisit this with geohash range queries.
        let snapshot = try await db.collection(Collections.events)
            .order(by: "date", descending: false)
            .limit(to: 50)
            .getDocuments()

        let allEvents = try snapshot.documents.compactMap { doc -> Event? in
            guard let data = doc.data() as? [String: Any] else { return nil }
            return try parseEvent(id: doc.documentID, data: data)
        }

        let origin = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return filterByProximity(allEvents, near: origin, radiusInKm: radiusInKm)
    }

    func fetchEvent(id eventId: String) async throws -> Event? {
        let snapshot = try await db.collection(Collections.events).document(eventId).getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            return nil
        }

        return try parseEvent(id: snapshot.documentID, data: data)
    }

    func deleteEvent(id eventId: String) async throws {
        try await db.collection(Collections.events).document(eventId).delete()

        // Clean up related data
        let bookmarksQuery = db.collection(Collections.bookmarks).whereField("eventId", isEqualTo: eventId)
        let attendeesQuery = db.collection(Collections.eventAttendees).whereField("eventId", isEqualTo: eventId)

        let bookmarkSnapshots = try await bookmarksQuery.getDocuments()
        let attendeeSnapshots = try await attendeesQuery.getDocuments()

        let batch = db.batch()
        bookmarkSnapshots.documents.forEach { batch.deleteDocument($0.reference) }
        attendeeSnapshots.documents.forEach { batch.deleteDocument($0.reference) }
        try await batch.commit()
    }

    // MARK: - User Operations

    func updateUserOnlineStatus(userId: String, isOnline: Bool) async throws {
        let userRef = db.collection(Collections.users).document(userId)

        try await userRef.updateData([
            "isOnline": isOnline,
            "lastSeen": Timestamp(date: Date())
        ])
    }

    func observeUserOnlineStatus(
        userId: String,
        onChange: @escaping (Bool) -> Void
    ) -> DatabaseObserver {
        let observer = FirebaseObserver()

        Task {
            let listener = db.collection(Collections.users).document(userId)
                .addSnapshotListener { [weak observer] snapshot, error in
                    guard observer?.isCancelled == false else { return }
                    guard let data = snapshot?.data(),
                          let isOnline = data["isOnline"] as? Bool else {
                        return
                    }

                    Task { @MainActor in
                        onChange(isOnline)
                    }
                }

            await observer.setListener(listener)
        }

        return observer
    }

    func createUserProfile(_ profile: UserProfile) async throws {
        let userRef = db.collection(Collections.users).document(profile.id)

        let profileData: [String: Any] = [
            "phoneNumber": profile.phoneNumber ?? NSNull(),
            "email": profile.email ?? NSNull(),
            "username": profile.username,
            "name": profile.name,
            "bio": profile.bio,
            "dateOfBirth": profile.dateOfBirth.map { Timestamp(date: $0) } ?? NSNull(),
            "profilePhotoURL": profile.profilePhotoURL ?? NSNull(),
            "publicPhotoURL": profile.publicPhotoURL ?? NSNull(),
            "privatePhotoURLs": profile.privatePhotoURLs,
            "createdAt": Timestamp(date: profile.createdAt)
        ]

        // merge: true because updateUserOnlineStatus may already have (or
        // will later) write isOnline/lastSeen onto this same document.
        try await userRef.setData(profileData, merge: true)
    }

    // MARK: - Comment Operations

    func fetchComments(for postId: String) async throws -> [Comment] {
        let snapshot = try await db.collection(Collections.comments)
            .whereField("postId", isEqualTo: postId)
            .order(by: "timestamp", descending: false)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            guard let data = doc.data() as? [String: Any] else { return nil }
            return try parseComment(id: doc.documentID, data: data)
        }
    }

    func createComment(for postId: String, comment: Comment) async throws -> Comment {
        let docRef = db.collection(Collections.comments).document()
        let postRef = db.collection(Collections.posts).document(postId)

        let commentData: [String: Any] = [
            "postId": postId,
            "userId": comment.userId,
            "userName": comment.userName,
            "userProfileImageURL": comment.userProfileImageURL ?? NSNull(),
            "content": comment.content,
            "timestamp": Timestamp(date: comment.timestamp)
        ]

        // Use transaction to create comment and increment comment count
        try await db.runTransaction { transaction, errorPointer in
            transaction.setData(commentData, forDocument: docRef)
            transaction.updateData(["commentCount": FieldValue.increment(Int64(1))], forDocument: postRef)
            return nil
        }

        return Comment(
            id: docRef.documentID,
            postId: postId,
            userId: comment.userId,
            userName: comment.userName,
            userProfileImageURL: comment.userProfileImageURL,
            content: comment.content,
            timestamp: comment.timestamp
        )
    }

    // MARK: - Image Operations

    func uploadImage(imageData: Data, path: String) async throws -> String {
        let storageRef = storage.reference().child(path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let url = try await storageRef.downloadURL()

        return url.absoluteString
    }

    func deleteImage(url: String) async throws {
        let storageRef = storage.reference(forURL: url)
        try await storageRef.delete()
    }

    // MARK: - Private Helper Methods

    private func fetchPosts(limit: Int) async throws -> [Post] {
        let snapshot = try await db.collection(Collections.posts)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            guard let data = doc.data() as? [String: Any] else { return nil }
            return try parsePost(id: doc.documentID, data: data)
        }
    }

    private func fetchEvents(limit: Int) async throws -> [Event] {
        let snapshot = try await db.collection(Collections.events)
            .order(by: "date", descending: false)
            .limit(to: limit)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            guard let data = doc.data() as? [String: Any] else { return nil }
            return try parseEvent(id: doc.documentID, data: data)
        }
    }

    /// Filters items to those within `radiusInKm` of `coordinate` using real
    /// `CLLocation.distance(from:)`. Items with no known coordinate are
    /// excluded. `nil` coordinate/radius means "no proximity filtering" and
    /// returns `items` unchanged - matches `MockDatabaseService`'s behavior.
    private func filterByProximity<T>(
        _ items: [T],
        near coordinate: CLLocationCoordinate2D?,
        radiusInKm: Double?,
        distance: (T, CLLocation) -> CLLocationDistance?
    ) -> [T] {
        guard let coordinate, let radiusInKm else { return items }
        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let radiusInMeters = radiusInKm * 1000
        return items.filter { item in
            guard let itemDistance = distance(item, origin) else { return false }
            return itemDistance <= radiusInMeters
        }
    }

    private func filterByProximity(
        _ posts: [Post],
        near coordinate: CLLocationCoordinate2D?,
        radiusInKm: Double?
    ) -> [Post] {
        filterByProximity(posts, near: coordinate, radiusInKm: radiusInKm) { $0.distance(from: $1) }
    }

    private func filterByProximity(
        _ events: [Event],
        near coordinate: CLLocationCoordinate2D?,
        radiusInKm: Double?
    ) -> [Event] {
        filterByProximity(events, near: coordinate, radiusInKm: radiusInKm) { $0.distance(from: $1) }
    }

    private func parsePost(id: String, data: [String: Any]) throws -> Post {
        guard let userId = data["userId"] as? String,
              let userName = data["userName"] as? String,
              let content = data["content"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let likeCount = data["likeCount"] as? Int,
              let commentCount = data["commentCount"] as? Int else {
            throw DatabaseError.invalidData
        }

        return Post(
            id: id,
            userId: userId,
            userName: userName,
            userProfileImageURL: data["userProfileImageURL"] as? String,
            userLocation: data["userLocation"] as? String,
            latitude: data["latitude"] as? Double,
            longitude: data["longitude"] as? Double,
            content: content,
            timestamp: timestamp.dateValue(),
            likeCount: likeCount,
            commentCount: commentCount,
            isLiked: false // This will be determined by checking the likes collection
        )
    }

    private func parseEvent(id: String, data: [String: Any]) throws -> Event {
        guard let title = data["title"] as? String,
              let hostedBy = data["hostedBy"] as? String,
              let location = data["location"] as? String,
              let date = data["date"] as? Timestamp,
              let time = data["time"] as? String,
              let attendeeCount = data["attendeeCount"] as? Int else {
            throw DatabaseError.invalidData
        }

        let attendeeImages = data["attendeeProfileImages"] as? [String] ?? []

        return Event(
            id: id,
            title: title,
            hostedBy: hostedBy,
            imageURL: data["imageURL"] as? String,
            location: location,
            latitude: data["latitude"] as? Double,
            longitude: data["longitude"] as? Double,
            date: date.dateValue(),
            time: time,
            attendeeCount: attendeeCount,
            attendeeProfileImages: attendeeImages,
            isBookmarked: false,
            isJoined: false
        )
    }

    private func parseComment(id: String, data: [String: Any]) throws -> Comment {
        guard let postId = data["postId"] as? String,
              let userId = data["userId"] as? String,
              let userName = data["userName"] as? String,
              let content = data["content"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else {
            throw DatabaseError.invalidData
        }

        return Comment(
            id: id,
            postId: postId,
            userId: userId,
            userName: userName,
            userProfileImageURL: data["userProfileImageURL"] as? String,
            content: content,
            timestamp: timestamp.dateValue()
        )
    }
}

// MARK: - Firebase Observer

/// Manages Firebase snapshot listeners
private actor FirebaseObserver: DatabaseObserver {
    private var listener: ListenerRegistration?
    private(set) var isCancelled = false

    func setListener(_ listener: ListenerRegistration) {
        self.listener = listener
    }

    func cancel() {
        listener?.remove()
        listener = nil
        isCancelled = true
    }
}
