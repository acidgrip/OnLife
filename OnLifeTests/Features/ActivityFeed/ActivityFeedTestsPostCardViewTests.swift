//
//  PostCardViewTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/25/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("PostCardView Tests")
@MainActor
struct PostCardViewTests {
    
    @Test("PostCardView displays post content")
    func testPostCardDisplaysContent() throws {
        let post = Post(
            userId: "user-1",
            userName: "Test User",
            userLocation: "TEST LOCATION",
            content: "This is test content",
            likeCount: 10,
            commentCount: 5
        )
        
        let view = PostCardView(
            post: post,
            onLike: {},
            onComment: {},
            onShare: {}
        )
        
        // Basic instantiation test
        #expect(view.post.userName == "Test User")
        #expect(view.post.content == "This is test content")
        #expect(view.post.likeCount == 10)
        #expect(view.post.commentCount == 5)
    }
    
    @Test("PostCardView handles like callback")
    func testPostCardLikeCallback() {
        var likeCalled = false
        
        let post = Post(
            userId: "user-1",
            userName: "User",
            content: "Content"
        )
        
        let view = PostCardView(
            post: post,
            onLike: { likeCalled = true },
            onComment: {},
            onShare: {}
        )
        
        view.onLike()
        #expect(likeCalled == true)
    }
    
    @Test("PostCardView handles comment callback")
    func testPostCardCommentCallback() {
        var commentCalled = false
        
        let post = Post(
            userId: "user-1",
            userName: "User",
            content: "Content"
        )
        
        let view = PostCardView(
            post: post,
            onLike: {},
            onComment: { commentCalled = true },
            onShare: {}
        )
        
        view.onComment()
        #expect(commentCalled == true)
    }
    
    @Test("PostCardView handles share callback")
    func testPostCardShareCallback() {
        var shareCalled = false
        
        let post = Post(
            userId: "user-1",
            userName: "User",
            content: "Content"
        )
        
        let view = PostCardView(
            post: post,
            onLike: {},
            onComment: {},
            onShare: { shareCalled = true }
        )
        
        view.onShare()
        #expect(shareCalled == true)
    }
    
    @Test("PostCardView displays liked state")
    func testPostCardLikedState() {
        let likedPost = Post(
            userId: "user-1",
            userName: "User",
            content: "Content",
            isLiked: true
        )
        
        let unlikedPost = Post(
            userId: "user-2",
            userName: "User 2",
            content: "Content 2",
            isLiked: false
        )
        
        let likedView = PostCardView(
            post: likedPost,
            onLike: {},
            onComment: {},
            onShare: {}
        )
        
        let unlikedView = PostCardView(
            post: unlikedPost,
            onLike: {},
            onComment: {},
            onShare: {}
        )
        
        #expect(likedView.post.isLiked == true)
        #expect(unlikedView.post.isLiked == false)
    }
    
    @Test("PostCardView handles post without location")
    func testPostCardWithoutLocation() {
        let post = Post(
            userId: "user-1",
            userName: "User",
            userLocation: nil,
            content: "Content"
        )
        
        let view = PostCardView(
            post: post,
            onLike: {},
            onComment: {},
            onShare: {}
        )
        
        #expect(view.post.userLocation == nil)
    }
    
    @Test("PostCardView handles high engagement numbers")
    func testPostCardHighEngagement() {
        let post = Post(
            userId: "user-1",
            userName: "Popular User",
            content: "Viral content",
            likeCount: 9999,
            commentCount: 1234
        )
        
        let view = PostCardView(
            post: post,
            onLike: {},
            onComment: {},
            onShare: {}
        )
        
        #expect(view.post.likeCount == 9999)
        #expect(view.post.commentCount == 1234)
    }
    
    @Test("PostCardView handles zero engagement")
    func testPostCardZeroEngagement() {
        let post = Post(
            userId: "user-1",
            userName: "New User",
            content: "First post",
            likeCount: 0,
            commentCount: 0
        )
        
        let view = PostCardView(
            post: post,
            onLike: {},
            onComment: {},
            onShare: {}
        )
        
        #expect(view.post.likeCount == 0)
        #expect(view.post.commentCount == 0)
    }
}
