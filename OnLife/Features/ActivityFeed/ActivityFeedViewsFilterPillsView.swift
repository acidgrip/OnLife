//
//  FilterPillsView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

struct FilterPillsView: View {
    @Binding var selectedFilter: FeedFilter
    let onFilterSelected: (FeedFilter) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small) {
                ForEach([FeedFilter.nearbyScenes, FeedFilter.scenesPickingUp]) { filter in
                    FilterPillButton(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        action: {
                            selectedFilter = filter
                            onFilterSelected(filter)
                        }
                    )
                }
            }
            .padding(.horizontal, Spacing.medium)
        }
    }
}

struct FilterPillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if title.contains("nearby") {
                    Image(systemName: "location.fill")
                        .font(.caption)
                } else if title.contains("picking") {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
            .foregroundColor(.white)
            .cornerRadius(20)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        FilterPillsView(
            selectedFilter: .constant(.nearbyScenes),
            onFilterSelected: { _ in }
        )
    }
}
