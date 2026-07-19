//
//  PostCardView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

struct PostCardView: View {
    let post: Post
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // User Info Header
            HStack(spacing: Spacing.small) {
                // Profile Image
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay {
                        if let imageURL = post.userProfileImageURL {
                            // TODO: Load actual image from URL
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        } else {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        }
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let location = post.userLocation {
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Online Status Indicator
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 8, height: 8)
            }
            
            // Post Content
            Text(post.content)
                .font(.body)
                .foregroundColor(.white)
                .lineSpacing(4)
            
            // Actions Row
            HStack(spacing: Spacing.large) {
                // Like Button
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .gray)
                        Text("\(post.likeCount)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Comment Button
                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "message")
                            .foregroundColor(.gray)
                        Text("\(post.commentCount)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Share Button
                Button(action: onShare) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding(Spacing.medium)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        PostCardView(
            post: Post(
                userId: "1",
                userName: "Jane Doe",
                userLocation: "ARTS DISTRICT",
                content: "The quiet before the storm...",
                likeCount: 24,
                commentCount: 8
            ),
            onLike: {},
            onComment: {},
            onShare: {}
        )
        .padding()
    }
}
