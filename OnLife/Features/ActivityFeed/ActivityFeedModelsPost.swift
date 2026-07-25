//
//  Post.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import CoreLocation
import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let userProfileImageURL: String?
    let userLocation: String? // e.g., "ARTS DISTRICT" - display label, not used for filtering
    let latitude: Double? // GPS coordinate the post was made at, if known
    let longitude: Double?
    let content: String
    let timestamp: Date
    let likeCount: Int
    let commentCount: Int
    var isLiked: Bool

    init(
        id: String = UUID().uuidString,
        userId: String,
        userName: String,
        userProfileImageURL: String? = nil,
        userLocation: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        content: String,
        timestamp: Date = Date(),
        likeCount: Int = 0,
        commentCount: Int = 0,
        isLiked: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userProfileImageURL = userProfileImageURL
        self.userLocation = userLocation
        self.latitude = latitude
        self.longitude = longitude
        self.content = content
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
    }

    /// `nil` unless both `latitude` and `longitude` are known.
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Distance from `location`, or `nil` if this post has no known coordinate.
    func distance(from location: CLLocation) -> CLLocationDistance? {
        guard let coordinate else { return nil }
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: location)
    }
}
