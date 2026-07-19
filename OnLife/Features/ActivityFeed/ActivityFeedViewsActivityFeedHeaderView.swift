//
//  ActivityFeedHeaderView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

struct ActivityFeedHeaderView: View {
    @Binding var isOnline: Bool
    let onNotificationsTapped: () -> Void
    let onMessagesTapped: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            // Power Button (Online/Offline Toggle)
            PowerButton(isOnline: $isOnline, size: 32)
            
            // App Logo
            Image.onlifeLogo(colorScheme: colorScheme)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)
            
            Spacer()
            
            // Notifications Bell
            Button(action: onNotificationsTapped) {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Direct Messages
            Button(action: onMessagesTapped) {
                VStack(spacing: 2) {
                    Text("DM")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("ICON")
                        .font(.system(size: 8))
                }
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ActivityFeedHeaderView(
            isOnline: .constant(true),
            onNotificationsTapped: {},
            onMessagesTapped: {}
        )
    }
}
