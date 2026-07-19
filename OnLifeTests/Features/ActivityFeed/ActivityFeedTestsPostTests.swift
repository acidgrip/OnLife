//
//  PostTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("Post Model Tests")
struct PostTests {
    
    @Test("Post initializes with all properties")
    func testPostInitialization() {
        let timestamp = Date()
        let post = Post(
            id: "test-id",
            userId: "user-123",
            userName: "John Doe",
            userProfileImageURL: "https://example.com/image.jpg",
            userLocation: "DOWNTOWN",
            content: "Hello, world!",
            timestamp: timestamp,
            likeCount: 10,
            commentCount: 5,
            isLiked: true
        )
        
        #expect(post.id == "test-id")
        #expect(post.userId == "user-123")
        #expect(post.userName == "John Doe")
        #expect(post.userProfileImageURL == "https://example.com/image.jpg")
        #expect(post.userLocation == "DOWNTOWN")
        #expect(post.content == "Hello, world!")
        #expect(post.timestamp == timestamp)
        #expect(post.likeCount == 10)
        #expect(post.commentCount == 5)
        #expect(post.isLiked == true)
    }
    
    @Test("Post initializes with default values")
    func testPostDefaultInitialization() {
        let post = Post(
            userId: "user-123",
            userName: "Jane Doe",
            content: "Test post"
        )
        
        #expect(!post.id.isEmpty)
        #expect(post.userId == "user-123")
        #expect(post.userName == "Jane Doe")
        #expect(post.userProfileImageURL == nil)
        #expect(post.userLocation == nil)
        #expect(post.content == "Test post")
        #expect(post.likeCount == 0)
        #expect(post.commentCount == 0)
        #expect(post.isLiked == false)
    }
    
    @Test("Post without location initializes correctly")
    func testPostWithoutLocation() {
        let post = Post(
            userId: "user-456",
            userName: "Anonymous",
            content: "Secret post"
        )
        
        #expect(post.userLocation == nil)
        #expect(post.userName == "Anonymous")
    }
    
    @Test("Post conforms to Identifiable")
    func testPostIdentifiable() {
        let post1 = Post(
            id: "post-1",
            userId: "user-1",
            userName: "User 1",
            content: "Content 1"
        )
        let post2 = Post(
            id: "post-2",
            userId: "user-2",
            userName: "User 2",
            content: "Content 2"
        )
        
        #expect(post1.id != post2.id)
    }
    
    @Test("Post with zero engagement")
    func testPostWithZeroEngagement() {
        let post = Post(
            userId: "user-789",
            userName: "New User",
            content: "First post!",
            likeCount: 0,
            commentCount: 0
        )
        
        #expect(post.likeCount == 0)
        #expect(post.commentCount == 0)
        #expect(post.isLiked == false)
    }
    
    @Test("Post with high engagement")
    func testPostWithHighEngagement() {
        let post = Post(
            userId: "user-999",
            userName: "Popular User",
            content: "Viral post!",
            likeCount: 1000,
            commentCount: 250,
            isLiked: true
        )
        
        #expect(post.likeCount == 1000)
        #expect(post.commentCount == 250)
        #expect(post.isLiked == true)
    }
    
    @Test("Post timestamp is preserved")
    func testPostTimestamp() {
        let specificDate = Date(timeIntervalSince1970: 1700000000)
        let post = Post(
            userId: "user-123",
            userName: "Time Keeper",
            content: "Testing timestamps",
            timestamp: specificDate
        )
        
        #expect(post.timestamp == specificDate)
    }
}
