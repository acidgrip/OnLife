//
//  EventCardView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

struct EventCardView: View {
    let event: Event
    let onBookmark: () -> Void
    let onJoin: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Image
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.3, blue: 0.5),
                                Color(red: 0.8, green: 0.4, blue: 0.3),
                                Color(red: 0.3, green: 0.2, blue: 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                
                // Bookmark Button
                Button(action: onBookmark) {
                    Image(systemName: event.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.white)
                        .padding(Spacing.small)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(Spacing.medium)
            }
            
            // Event Details
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Title and Host
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Hosted by \(event.hostedBy)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "mappin")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text(event.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Time
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text(event.time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Bottom Actions
                HStack {
                    // Attendee Avatars
                    HStack(spacing: -8) {
                        ForEach(0..<min(3, event.attendeeCount), id: \.self) { index in
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                }
                        }
                        
                        if event.attendeeCount > 3 {
                            Text("+\(event.attendeeCount - 3)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // Share Button
                    Button(action: onShare) {
                        Image(systemName: "arrowshape.turn.up.right")
                            .foregroundColor(.gray)
                            .padding(Spacing.small)
                    }
                    
                    // Join Button
                    Button(action: onJoin) {
                        Text(event.isJoined ? "JOINED" : "JOIN")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, Spacing.large)
                            .padding(.vertical, Spacing.small)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.6, blue: 0.4),
                                        Color(red: 1.0, green: 0.4, blue: 0.3)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(Spacing.medium)
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        EventCardView(
            event: Event(
                title: "Sunset Yoga Session",
                hostedBy: "GreenSpace",
                location: "Skyline Terrace, Block B",
                date: Date(),
                time: "Later • 6:00 PM today",
                attendeeCount: 14
            ),
            onBookmark: {},
            onJoin: {},
            onShare: {}
        )
        .padding()
    }
}
