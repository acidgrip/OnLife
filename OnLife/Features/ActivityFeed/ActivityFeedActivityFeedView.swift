//
//  ActivityFeedView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

struct ActivityFeedView: View {
    @State private var store = ActivityFeedStore()
    @State private var postText = ""
    @State private var selectedTab: AppTab = .home
    @State private var showNotifications = false
    @State private var showMessages = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    ActivityFeedHeaderView(
                        isOnline: $store.isOnline,
                        onNotificationsTapped: {
                            showNotifications = true
                        },
                        onMessagesTapped: {
                            showMessages = true
                        }
                    )
                    
                    // Main Content
                    ScrollView {
                        VStack(spacing: Spacing.medium) {
                            // Compose Post Section
                            ComposePostView(
                                postText: $postText,
                                onPost: {
                                    Task {
                                        await store.createPost(content: postText)
                                        postText = ""
                                    }
                                }
                            )
                            .padding(.top, Spacing.small)
                            
                            // Filter Pills
                            FilterPillsView(
                                selectedFilter: $store.selectedFilter,
                                onFilterSelected: { filter in
                                    store.applyFilter(filter)
                                }
                            )
                            
                            // Feed Items
                            LazyVStack(spacing: Spacing.medium) {
                                ForEach(store.feedItems) { item in
                                    switch item {
                                    case .post(let post):
                                        PostCardView(
                                            post: post,
                                            onLike: {
                                                Task {
                                                    await store.likePost(post)
                                                }
                                            },
                                            onComment: {
                                                // TODO: Navigate to comments
                                                print("Comment on post: \(post.id)")
                                            },
                                            onShare: {
                                                // TODO: Share post
                                                print("Share post: \(post.id)")
                                            }
                                        )
                                        .padding(.horizontal, Spacing.medium)
                                        
                                    case .event(let event):
                                        EventCardView(
                                            event: event,
                                            onBookmark: {
                                                Task {
                                                    await store.bookmarkEvent(event)
                                                }
                                            },
                                            onJoin: {
                                                Task {
                                                    await store.joinEvent(event)
                                                }
                                            },
                                            onShare: {
                                                // TODO: Share event
                                                print("Share event: \(event.id)")
                                            }
                                        )
                                        .padding(.horizontal, Spacing.medium)
                                    }
                                }
                            }
                            .padding(.vertical, Spacing.small)
                        }
                    }
                    .refreshable {
                        await store.refreshFeed()
                    }
                    .scrollDismissesKeyboard(.interactively)
                    
                    // Bottom Navigation
                    AppTabBar(selectedTab: $selectedTab)
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #elseif os(macOS)
            .toolbar(.hidden, for: .windowToolbar)
            #endif
        }
        .task {
            await store.loadFeed()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsPlaceholderView()
        }
        .sheet(isPresented: $showMessages) {
            MessagesPlaceholderView()
        }
    }
}

// MARK: - Placeholder Views

struct NotificationsPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: Spacing.medium) {
                    // Onlife Icon
                    Image.onlifeIcon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .opacity(0.2)
                        .padding(.bottom, Spacing.small)
                    
                    Image(systemName: "bell.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.6, blue: 0.4),
                                    Color(red: 1.0, green: 0.4, blue: 0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Notifications")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your notifications will appear here")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Notifications")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.35))
                }
                #else
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.35))
                }
                #endif
            }
        }
    }
}

struct MessagesPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: Spacing.medium) {
                    // Onlife Icon
                    Image.onlifeIcon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .opacity(0.2)
                        .padding(.bottom, Spacing.small)
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.6, blue: 0.4),
                                    Color(red: 1.0, green: 0.4, blue: 0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Direct Messages")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your conversations will appear here")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Messages")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.35))
                }
                #else
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.35))
                }
                #endif
            }
        }
    }
}

#Preview {
    ActivityFeedView()
}
