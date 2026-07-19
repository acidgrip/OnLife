//
//  ComposePostView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

struct ComposePostView: View {
    @Binding var postText: String
    let onPost: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            // Profile Thumbnail
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                }
            
            // Text Field
            HStack {
                TextField("What's happening?", text: $postText, axis: .vertical)
                    .foregroundColor(.white)
                    .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
                    .lineLimit(1...5)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(Color.white.opacity(0.05))
            .cornerRadius(24)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ComposePostView(
            postText: .constant(""),
            onPost: {}
        )
    }
}
