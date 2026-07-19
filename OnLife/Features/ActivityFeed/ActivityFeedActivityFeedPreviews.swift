//
//  ActivityFeedPreviews.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

/// Collection of preview helpers for ActivityFeed components
struct ActivityFeedPreviews {
    
    // MARK: - Sample Data
    
    static let samplePost = Post(
        userId: "user1",
        userName: "Jane Doe",
        userLocation: "ARTS DISTRICT",
        content: "The quiet before the storm...",
        timestamp: Date().addingTimeInterval(-3600),
        likeCount: 24,
        commentCount: 8
    )
    
    static let samplePost2 = Post(
        userId: "user2",
        userName: "Marcus Chen",
        userLocation: "SOUND LAB",
        content: "Finally tuned the new synthesizer module. The resonance at the low-end is incredible. Signal is pure.",
        timestamp: Date().addingTimeInterval(-7200),
        likeCount: 112,
        commentCount: 42
    )
    
    static let sampleEvent = Event(
        title: "Sunset Yoga Session",
        hostedBy: "GreenSpace",
        location: "Skyline Terrace, Block B",
        date: Date(),
        time: "Later • 6:00 PM today",
        attendeeCount: 14,
        attendeeProfileImages: [],
        isBookmarked: false
    )
    
    static let sampleEvent2 = Event(
        title: "Late Night Jazz Jam",
        hostedBy: "Blue Note Cafe",
        location: "Downtown Arts Quarter",
        date: Date().addingTimeInterval(86400),
        time: "Tomorrow • 9:00 PM",
        attendeeCount: 28,
        attendeeProfileImages: [],
        isBookmarked: true
    )
}

// MARK: - Component Previews

#Preview("Post Card") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        PostCardView(
            post: ActivityFeedPreviews.samplePost,
            onLike: {},
            onComment: {},
            onShare: {}
        )
        .padding()
    }
}

#Preview("Post Card - Liked") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        PostCardView(
            post: Post(
                userId: "user1",
                userName: "Jane Doe",
                userLocation: "ARTS DISTRICT",
                content: "The quiet before the storm...",
                likeCount: 25,
                commentCount: 8,
                isLiked: true
            ),
            onLike: {},
            onComment: {},
            onShare: {}
        )
        .padding()
    }
}

#Preview("Event Card") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        EventCardView(
            event: ActivityFeedPreviews.sampleEvent,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        .padding()
    }
}

#Preview("Event Card - Bookmarked") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        EventCardView(
            event: ActivityFeedPreviews.sampleEvent2,
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        .padding()
    }
}

#Preview("Header - Online") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            ActivityFeedHeaderView(
                isOnline: .constant(true),
                onNotificationsTapped: {},
                onMessagesTapped: {}
            )
            Spacer()
        }
    }
}

#Preview("Header - Offline") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            ActivityFeedHeaderView(
                isOnline: .constant(false),
                onNotificationsTapped: {},
                onMessagesTapped: {}
            )
            Spacer()
        }
    }
}

#Preview("Compose Post") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ComposePostView(
            postText: .constant(""),
            onPost: {}
        )
    }
}

#Preview("Filter Pills") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        FilterPillsView(
            selectedFilter: .constant(.nearbyScenes),
            onFilterSelected: { _ in }
        )
    }
}

#Preview("Tab Bar - Home Selected") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Spacer()
            AppTabBar(selectedTab: .constant(.home))
        }
    }
}

#Preview("Tab Bar - Explore Selected") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Spacer()
            AppTabBar(selectedTab: .constant(.explore))
        }
    }
}

#Preview("Full Activity Feed") {
    ActivityFeedView()
}
