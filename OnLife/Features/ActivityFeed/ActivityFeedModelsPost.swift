//
//  Post.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    let userName: String
    let userProfileImageURL: String?
    let userLocation: String? // e.g., "ARTS DISTRICT"
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
        self.content = content
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
    }
}
